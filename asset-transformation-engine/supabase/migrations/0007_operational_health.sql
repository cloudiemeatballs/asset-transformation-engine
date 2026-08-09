-- Public, data-free liveness probe used by the application health endpoint.
-- It proves the database is reachable and this migration has been applied,
-- without exposing table contents or bypassing row-level security.
create or replace function operational_health() returns jsonb
language sql
stable
set search_path=public
as $$
  select jsonb_build_object(
    'database', true,
    'schemaVersion', '0007'
  )
$$;

revoke all on function operational_health() from public;
grant execute on function operational_health() to anon, authenticated;
