# Incident response

## When to use this

Start an incident when the health check is degraded, authentication broadly fails, data is missing or exposed, review actions create incorrect canonical records, a provider repeatedly fails, or scientific decisions appear inconsistent.

## Severity

- **SEV-1:** suspected data exposure, destructive data loss, or materially incorrect accepted scientific decisions. Stop writes immediately.
- **SEV-2:** sign-in, review, ingestion, or evidence workflows are unavailable for multiple users. Pause the affected workflow.
- **SEV-3:** isolated failure with a safe workaround, such as one throttled PubMed run. Record and schedule correction.

## First 15 minutes

1. Name one incident owner and record the start time.
2. Preserve the exact error, URL, timestamp, user impact, and relevant research run/task/queue IDs. Do not copy secrets or source excerpts.
3. Protect data. Ask users to stop the affected action; for SEV-1, disable or roll back the affected deployment rather than continuing writes.
4. Check, in order:
   - `/api/health`;
   - GitHub **Actions → Production health check**;
   - Vercel **Deployments** and **Observability**;
   - Supabase project status, logs, and Database health.
5. Decide whether the issue began with the latest deployment, a database migration, an account/configuration change, or an external provider.

## Recovery paths

- **Bad application deployment:** use Vercel to promote the last known-good deployment, then run the smoke test.
- **Bad migration or corrupted data:** stop writes and follow `docs/BACKUP_RESTORE_DRILL.md`. Do not improvise destructive SQL.
- **Supabase outage:** leave data unchanged, monitor provider status, and verify health plus core records after recovery.
- **PubMed throttling:** wait and retry once provider limits recover; do not create duplicate manual records.
- **Credential exposure:** revoke/rotate the credential in its owning service, update Vercel variables, redeploy, and review access logs.

## Reopening the system

The incident owner must verify sign-in, health, one research run, extraction, one review transaction, and canonical Evidence Room visibility. For a data incident, also reconcile records created after the recovery point.

## Afterward

Within two business days, record what happened, timeline, affected users/data/decisions, root cause, recovery, and one owner/date for every corrective action. Avoid blame; focus on controls that prevent recurrence or shorten detection.
