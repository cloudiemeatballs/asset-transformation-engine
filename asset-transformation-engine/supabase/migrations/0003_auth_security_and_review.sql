-- Authentication, authorization, read projections, and transactional proposal review.
create type app_role as enum ('researcher','reviewer','admin');
create table user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role app_role not null default 'researcher',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.user_profiles(id,display_name) values(new.id,coalesce(new.raw_user_meta_data->>'display_name',new.email)); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- Rebuildable DTO projection for fast server-component reads. Canonical normalized tables remain authoritative.
create table opportunity_read_models (
  opportunity_id uuid primary key references opportunities(id) on delete cascade,
  slug text not null unique,
  payload jsonb not null,
  source_version integer not null,
  refreshed_at timestamptz not null default now()
);

create or replace function current_app_role() returns app_role language sql stable security definer set search_path=public as $$
  select coalesce((select role from user_profiles where id=auth.uid()),'researcher'::app_role)
$$;

alter table user_profiles enable row level security;
alter table opportunities enable row level security;
alter table opportunity_read_models enable row level security;
alter table assessments enable row level security;
alter table assessment_proposals enable row level security;
alter table constraint_proposals enable row level security;
alter table transformation_hypothesis_proposals enable row level security;
alter table review_queue_items enable row level security;
alter table research_runs enable row level security;
alter table research_tasks enable row level security;
alter table search_runs enable row level security;
alter table ingestion_sources enable row level security;
alter table ingestion_runs enable row level security;
alter table raw_ingestion_records enable row level security;
alter table normalized_scientific_records enable row level security;

create policy "users read own profile" on user_profiles for select to authenticated using(id=auth.uid() or current_app_role() in ('reviewer','admin'));
create policy "authenticated read opportunities" on opportunities for select to authenticated using(true);
create policy "authenticated read opportunity projections" on opportunity_read_models for select to authenticated using(true);
create policy "authenticated read assessments" on assessments for select to authenticated using(true);
create policy "authenticated read proposals" on assessment_proposals for select to authenticated using(true);
create policy "authenticated read constraint proposals" on constraint_proposals for select to authenticated using(true);
create policy "authenticated read transformation proposals" on transformation_hypothesis_proposals for select to authenticated using(true);
create policy "authenticated read review queue" on review_queue_items for select to authenticated using(true);
create policy "reviewers update review queue" on review_queue_items for update to authenticated using(current_app_role() in ('reviewer','admin')) with check(current_app_role() in ('reviewer','admin'));
create policy "authenticated read research runs" on research_runs for select to authenticated using(true);
create policy "researchers create research runs" on research_runs for insert to authenticated with check(initiated_by_user_id=auth.uid());
create policy "authenticated read research tasks" on research_tasks for select to authenticated using(true);
create policy "researchers create research tasks" on research_tasks for insert to authenticated with check(exists(select 1 from research_runs r where r.id=research_run_id and r.initiated_by_user_id=auth.uid()));
create policy "authenticated read search runs" on search_runs for select to authenticated using(true);
create policy "researchers create search runs" on search_runs for insert to authenticated with check(created_by_user_id=auth.uid());
create policy "admins manage ingestion sources" on ingestion_sources for all to authenticated using(current_app_role()='admin') with check(current_app_role()='admin');
create policy "admins manage ingestion runs" on ingestion_runs for all to authenticated using(current_app_role()='admin') with check(current_app_role()='admin');
create policy "admins manage raw records" on raw_ingestion_records for all to authenticated using(current_app_role()='admin') with check(current_app_role()='admin');
create policy "authenticated read normalized records" on normalized_scientific_records for select to authenticated using(true);

create or replace function review_proposal(
  p_queue_item_id uuid,
  p_action text,
  p_rationale text default null,
  p_modified_score integer default null,
  p_modified_confidence confidence_grade default null
) returns jsonb language plpgsql security definer set search_path=public as $$
declare
  v_item review_queue_items;
  v_proposal assessment_proposals;
  v_status text;
  v_assessment_id uuid;
  v_framework_id uuid;
  v_score integer;
  v_confidence confidence_grade;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if current_app_role() not in ('reviewer','admin') then raise exception 'Reviewer role required'; end if;
  if p_action not in ('accept','modify','reject','defer') then raise exception 'Unsupported review action'; end if;
  if p_action in ('modify','reject') and nullif(trim(p_rationale),'') is null then raise exception 'Reviewer rationale required'; end if;
  select * into v_item from review_queue_items where id=p_queue_item_id for update;
  if not found or v_item.status <> 'pending' then raise exception 'Queue item is missing or already reviewed'; end if;
  if v_item.category <> 'assessment_proposal' then
    v_status:=case p_action when 'accept' then 'accepted' when 'modify' then 'modified' when 'reject' then 'rejected' else 'deferred' end;
    update review_queue_items set status=v_status,reviewer_rationale=p_rationale,reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_item.id;
    return jsonb_build_object('queueItemId',v_item.id,'status',v_status,'canonicalAssessmentId',null);
  end if;
  select * into v_proposal from assessment_proposals where id=v_item.entity_id for update;
  if not found or v_proposal.status <> 'pending' then raise exception 'Assessment proposal is missing or already reviewed'; end if;
  v_status:=case p_action when 'accept' then 'accepted' when 'modify' then 'modified' when 'reject' then 'rejected' else 'pending' end;
  update assessment_proposals set status=v_status,reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_proposal.id;
  update review_queue_items set status=case p_action when 'accept' then 'accepted' when 'modify' then 'modified' when 'reject' then 'rejected' else 'deferred' end,reviewer_rationale=p_rationale,reviewed_by_user_id=auth.uid(),reviewed_at=now() where id=v_item.id;
  if p_action in ('accept','modify') then
    select framework_id into v_framework_id from scoring_criteria where id=v_proposal.criterion_id;
    v_score:=coalesce(p_modified_score,v_proposal.proposed_score);
    v_confidence:=coalesce(p_modified_confidence,v_proposal.proposed_confidence);
    insert into assessments(criterion_id,mechanism_context_id,constraint_id,opportunity_id,opportunity_family_id,score,confidence,rationale,assessor_type,assessor_user_id,analysis_run_id,framework_id)
    values(v_proposal.criterion_id,
      case when v_proposal.target_entity_type='mechanism_context' then v_proposal.target_entity_id end,
      case when v_proposal.target_entity_type='constraint' then v_proposal.target_entity_id end,
      case when v_proposal.target_entity_type='opportunity' then v_proposal.target_entity_id end,
      case when v_proposal.target_entity_type='opportunity_family' then v_proposal.target_entity_id end,
      v_score,v_confidence,coalesce(p_rationale,v_proposal.rationale),'human',auth.uid(),v_proposal.analysis_run_id,v_framework_id)
    returning id into v_assessment_id;
  end if;
  return jsonb_build_object('queueItemId',v_item.id,'status',case p_action when 'accept' then 'accepted' when 'modify' then 'modified' when 'reject' then 'rejected' else 'deferred' end,'canonicalAssessmentId',v_assessment_id);
end $$;
revoke all on function review_proposal(uuid,text,text,integer,confidence_grade) from public;
grant execute on function review_proposal(uuid,text,text,integer,confidence_grade) to authenticated;
