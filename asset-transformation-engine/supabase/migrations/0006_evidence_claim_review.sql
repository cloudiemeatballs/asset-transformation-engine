create table evidence_claim_proposals(id uuid primary key default gen_random_uuid(),research_run_id uuid not null references research_runs on delete cascade,normalized_record_id uuid not null references normalized_scientific_records on delete cascade,claim_text text not null,claim_type text not null,species text not null,evidence_level integer not null check(evidence_level between 1 and 5),directness text not null,source_locator text not null,source_excerpt text,extraction_confidence confidence_grade not null,extracted_by text not null,status text not null check(status in ('pending','accepted','rejected')),reviewed_by_user_id uuid,reviewed_at timestamptz,created_at timestamptz not null default now(),unique(normalized_record_id,claim_text));
alter table evidence_claim_proposals enable row level security;
alter table evidence_claims enable row level security;
alter table sources enable row level security;
create policy "authenticated read evidence claim proposals" on evidence_claim_proposals for select to authenticated using(true);
create policy "authenticated read evidence claims" on evidence_claims for select to authenticated using(true);
create policy "authenticated read sources" on sources for select to authenticated using(true);

create or replace function create_evidence_claim_proposals(p_run_id uuid,p_items jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare v_item jsonb;v_id uuid;v_count integer:=0;
begin
 if auth.uid() is null then raise exception 'Authentication required';end if;if current_app_role()<>'admin' then raise exception 'Administrator role required';end if;
 if not exists(select 1 from research_runs where id=p_run_id) then raise exception 'Research run was not found';end if;
 for v_item in select value from jsonb_array_elements(p_items) loop
  v_id:=null;insert into evidence_claim_proposals(research_run_id,normalized_record_id,claim_text,claim_type,species,evidence_level,directness,source_locator,source_excerpt,extraction_confidence,extracted_by,status)
  values(p_run_id,(v_item->>'normalizedRecordId')::uuid,v_item->>'claimText','abstract_statement',coalesce(v_item->>'species','unknown'),(v_item->>'evidenceLevel')::integer,'direct',v_item->>'sourceLocator',v_item->>'sourceExcerpt','C','deterministic_abstract_extractor_v1','pending') on conflict(normalized_record_id,claim_text) do nothing returning id into v_id;
  if v_id is not null then insert into review_queue_items(category,entity_type,entity_id,priority,title,summary,status) values('evidence_claim_proposal','evidence_claim_proposal',v_id,'medium','Review PubMed evidence claim',left(v_item->>'claimText',500),'pending');v_count:=v_count+1;end if;
 end loop;return jsonb_build_object('researchRunId',p_run_id,'proposalsCreated',v_count);
end $$;
revoke all on function create_evidence_claim_proposals(uuid,jsonb) from public;grant execute on function create_evidence_claim_proposals(uuid,jsonb) to authenticated;

create or replace function review_evidence_claim(p_queue_item_id uuid,p_action text,p_rationale text default null) returns jsonb language plpgsql security definer set search_path=public as $$
declare v_item review_queue_items;v_proposal evidence_claim_proposals;v_source_id uuid;v_claim_id uuid;v_record normalized_scientific_records;v_pmid text;v_doi text;
begin
 if auth.uid() is null then raise exception 'Authentication required';end if;if current_app_role() not in('reviewer','admin') then raise exception 'Reviewer role required';end if;if p_action not in('accept','reject','defer') then raise exception 'Evidence claims support accept, reject, or defer';end if;if p_action='reject' and nullif(trim(p_rationale),'') is null then raise exception 'Reviewer rationale required';end if;
 select * into v_item from review_queue_items where id=p_queue_item_id for update;if not found or v_item.status<>'pending' or v_item.category<>'evidence_claim_proposal' then raise exception 'Pending evidence claim review was not found';end if;
 select * into v_proposal from evidence_claim_proposals where id=v_item.entity_id for update;if not found or v_proposal.status<>'pending' then raise exception 'Pending evidence claim proposal was not found';end if;
 if p_action='accept' then select * into v_record from normalized_scientific_records where id=v_proposal.normalized_record_id;v_pmid:=v_record.identifiers->>'pmid';v_doi:=v_record.identifiers->>'doi';insert into sources(source_type,title,url,doi,pmid,publication_date,authors,metadata) values('publication',v_record.title,case when v_pmid is null then null else 'https://pubmed.ncbi.nlm.nih.gov/'||v_pmid||'/' end,nullif(v_doi,''),v_pmid,v_record.publication_date,v_record.authors,jsonb_build_object('normalizedRecordId',v_record.id)) returning id into v_source_id;
  insert into evidence_claims(source_id,claim_text,claim_type,species,evidence_level,directness,source_locator,source_excerpt,extraction_confidence,extracted_by,human_verified) values(v_source_id,v_proposal.claim_text,v_proposal.claim_type,v_proposal.species,v_proposal.evidence_level,v_proposal.directness,v_proposal.source_locator,v_proposal.source_excerpt,v_proposal.extraction_confidence,v_proposal.extracted_by,true) returning id into v_claim_id;
  update evidence_claim_proposals set status='accepted',reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_proposal.id;update review_queue_items set status='accepted',reviewer_rationale=p_rationale,reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_item.id;
 elsif p_action='reject' then update evidence_claim_proposals set status='rejected',reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_proposal.id;update review_queue_items set status='rejected',reviewer_rationale=p_rationale,reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_item.id;
 else update review_queue_items set status='deferred',reviewer_rationale=p_rationale,reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_item.id;end if;
 return jsonb_build_object('queueItemId',v_item.id,'status',case p_action when 'accept' then 'accepted' when 'reject' then 'rejected' else 'deferred' end,'canonicalEvidenceClaimId',v_claim_id);
end $$;
revoke all on function review_evidence_claim(uuid,text,text) from public;grant execute on function review_evidence_claim(uuid,text,text) to authenticated;
