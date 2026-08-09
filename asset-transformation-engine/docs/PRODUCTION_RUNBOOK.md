# Production runbook

## Deployment environments

Use separate Supabase projects for staging and production. Vercel Preview must point to staging; Vercel Production must point to production. Never use illustrative seed data in production.

## Database migrations

From `asset-transformation-engine`:

```bash
supabase link --project-ref YOUR_STAGING_PROJECT_REF
supabase db push --dry-run
supabase db push
```

Repeat against production only after staging verification and a database backup. Never make production schema changes directly in the Supabase Dashboard.

## Backups and recovery

- Enable the backup/PITR option appropriate to the selected Supabase plan.
- Before every production migration, verify the latest restorable backup.
- Test restoration quarterly into a separate recovery project.
- Export critical evidence, assessment, transition, and snapshot tables on a scheduled basis to access-controlled storage.
- Record recovery time and recovery point objectives before the pilot.

## Monitoring

- Monitor `/api/health`; `demo` means Supabase is not configured and `ready` means production environment variables are present.
- Configure Vercel deployment and function alerts.
- Add a Sentry project before the pilot and populate the optional variables in `.env.example`.
- Alert on ingestion failures, research-task failures, authentication spikes, proposal transaction errors, and PASS→HOLD/FAIL decision changes.
- Never log source excerpts, tokens, service-role keys, or confidential scientific payloads.

## Incident response

1. Protect data: disable the affected mutation or provider integration.
2. Preserve evidence: retain structured logs and relevant research/analysis run IDs.
3. Assess scope: identify users, records, and decisions affected.
4. Restore service from the last known good deployment or database recovery point.
5. Document root cause and corrective actions before reopening writes.

## Pilot entry criteria

- Supabase migrations pass on staging.
- RLS tests prove unauthenticated access is denied for protected data.
- At least one reviewer and one researcher account are provisioned.
- Review acceptance creates one canonical assessment transactionally.
- TGFBR1 remains HOLD everywhere until its critical path is resolved.
- PubMed queries retain search scope, retrieval date, provider IDs, and immutable raw records.
- Mobile navigation and error recovery pass manual testing.
