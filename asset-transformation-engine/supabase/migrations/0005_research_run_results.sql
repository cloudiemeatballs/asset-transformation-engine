create or replace function get_research_run_detail(p_run_id uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare v_result jsonb;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select jsonb_build_object('id',r.id,'status',r.status,'researchType',r.research_type,'startedAt',r.started_at,'completedAt',r.completed_at,'summary',r.summary,'researchPlan',r.research_plan,'modelConfiguration',r.model_configuration,'budgetConfiguration',r.budget_configuration,
    'tasks',coalesce((select jsonb_agg(jsonb_build_object('id',t.id,'agentType',t.agent_type,'objective',t.objective,'status',t.status,'attemptCount',t.attempt_count,'startedAt',t.started_at,'completedAt',t.completed_at,'error',t.error,'input',t.input_payload,'output',t.output_payload,
      'publications',coalesce((select jsonb_agg(jsonb_build_object('id',n.id,'title',n.title,'publicationDate',n.publication_date,'pmid',n.identifiers->>'pmid','doi',n.identifiers->>'doi','authors',n.authors,'providerUrl',raw.provider_url,'normalizationVersion',n.normalization_version) order by n.publication_date desc nulls last,n.title) from raw_ingestion_records raw join normalized_scientific_records n on n.raw_ingestion_record_id=raw.id where raw.ingestion_run_id=case when nullif(t.output_payload->>'ingestionRunId','') is null then null else (t.output_payload->>'ingestionRunId')::uuid end),'[]'::jsonb)
    ) order by t.started_at nulls last,t.id) from research_tasks t where t.research_run_id=r.id),'[]'::jsonb)
  ) into v_result from research_runs r where r.id=p_run_id;
  if v_result is null then raise exception 'Research run was not found'; end if;
  return v_result;
end $$;
revoke all on function get_research_run_detail(uuid) from public;
grant execute on function get_research_run_detail(uuid) to authenticated;
