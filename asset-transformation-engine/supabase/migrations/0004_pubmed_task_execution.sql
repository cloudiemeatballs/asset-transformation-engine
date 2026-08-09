create or replace function complete_pubmed_task(p_task_id uuid,p_query text,p_records jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare v_task research_tasks;v_source_id uuid;v_ingestion_run_id uuid;v_record jsonb;v_raw_id uuid;v_imported integer:=0;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if current_app_role()<>'admin' then raise exception 'Administrator role required'; end if;
  if nullif(trim(p_query),'') is null then raise exception 'PubMed query is required'; end if;
  if jsonb_typeof(p_records)<>'array' then raise exception 'Records must be a JSON array'; end if;
  select * into v_task from research_tasks where id=p_task_id for update;
  if not found then raise exception 'Research task was not found'; end if;
  if v_task.status<>'queued' then raise exception 'Research task is not queued'; end if;
  select id into v_source_id from ingestion_sources where provider='pubmed' and status='active';
  if v_source_id is null then raise exception 'Active PubMed ingestion source was not found'; end if;
  insert into ingestion_runs(ingestion_source_id,run_type,query_payload,status,started_at,completed_at,records_found,records_imported,created_by_type,created_by_user_id)
  values(v_source_id,'manual_search',jsonb_build_object('query',p_query,'researchTaskId',p_task_id),'complete',now(),now(),jsonb_array_length(p_records),0,'human',auth.uid()) returning id into v_ingestion_run_id;
  for v_record in select value from jsonb_array_elements(p_records) loop
    v_raw_id:=null;
    insert into raw_ingestion_records(ingestion_run_id,provider_record_id,provider_url,record_type,raw_payload,content_hash,retrieved_at,processing_status)
    values(v_ingestion_run_id,v_record->>'providerRecordId',v_record->>'providerUrl',coalesce(v_record->>'recordType','publication'),v_record->'rawPayload',v_record->>'contentHash',(v_record->>'retrievedAt')::timestamptz,'normalized')
    on conflict(content_hash) do nothing returning id into v_raw_id;
    if v_raw_id is not null then
      insert into normalized_scientific_records(raw_ingestion_record_id,normalized_type,title,abstract_or_summary,publication_date,identifiers,authors,organizations,normalized_payload,normalization_version)
      values(v_raw_id,coalesce(v_record->'normalized'->>'normalizedType','publication'),v_record->'normalized'->>'title',v_record->'normalized'->>'abstractOrSummary',nullif(v_record->'normalized'->>'publicationDate','')::date,coalesce(v_record->'normalized'->'identifiers','{}'::jsonb),coalesce(v_record->'normalized'->'authors','[]'::jsonb),coalesce(v_record->'normalized'->'organizations','[]'::jsonb),coalesce(v_record->'normalized'->'normalizedPayload','{}'::jsonb),v_record->'normalized'->>'normalizationVersion');
      v_imported:=v_imported+1;
    end if;
  end loop;
  update ingestion_runs set records_imported=v_imported where id=v_ingestion_run_id;
  update ingestion_sources set last_successful_sync_at=now(),updated_at=now() where id=v_source_id;
  update research_tasks set status='complete',attempt_count=attempt_count+1,started_at=now(),completed_at=now(),error=null,output_payload=jsonb_build_object('provider','pubmed','query',p_query,'recordsFound',jsonb_array_length(p_records),'recordsImported',v_imported,'ingestionRunId',v_ingestion_run_id,'pmids',(select coalesce(jsonb_agg(value->>'providerRecordId'),'[]'::jsonb) from jsonb_array_elements(p_records))) where id=p_task_id;
  update research_runs set status='running',model_configuration=jsonb_build_object('provider','pubmed') where id=v_task.research_run_id;
  return jsonb_build_object('taskId',p_task_id,'status','complete','query',p_query,'recordsFound',jsonb_array_length(p_records),'recordsImported',v_imported,'ingestionRunId',v_ingestion_run_id);
end $$;
revoke all on function complete_pubmed_task(uuid,text,jsonb) from public;
grant execute on function complete_pubmed_task(uuid,text,jsonb) to authenticated;
