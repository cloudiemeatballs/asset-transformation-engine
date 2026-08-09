# Operational runbook

This runbook is written for the person operating the pilot. It separates what is automated in the repository from the account settings that must be checked in Supabase, Vercel, and GitHub.

## Current environment status

The public Vercel deployment currently uses the Supabase **staging** project. Treat it as a pilot environment:

- Use invited reviewers and non-confidential or publicly available scientific material only.
- Do not describe it as a validated production system.
- Do not enter patient data, protected health information, secrets, or proprietary source documents.
- Before broader use, create a separate production Supabase project and point only Vercel Production at it. Vercel Preview and Development should continue to use staging.

## Every-day operator check

1. Open the [application](https://asset-transformation-engine-lac.vercel.app/) and sign in.
2. Open the [health endpoint](https://asset-transformation-engine-lac.vercel.app/api/health). It must show `"status":"ready"`, `"databaseReachable":true`, and `"schemaVersion":"0007"`.
3. In GitHub, open the repository, choose **Actions**, then **Production health check**. Confirm the latest run is green.
4. In Vercel, open the project and check **Deployments** for a successful Production deployment and **Observability** for new 5xx errors.
5. In the application, check the Review Queue for old pending items and Research Runs for failed or stuck tasks.

If the health endpoint says `degraded` or GitHub reports a failed check, follow `docs/INCIDENT_RESPONSE.md`.

## Automated availability check

`.github/workflows/production-health.yml` calls the public health endpoint twice an hour and verifies the application can reach the expected database schema. It can also be run manually from GitHub's **Actions** tab.

GitHub scheduled jobs can be delayed and can be disabled after long repository inactivity, so this is a baseline monitor—not a formal uptime guarantee. In GitHub notification settings, enable email notifications for failed Actions runs. The user who adds or last changes the schedule receives scheduled-workflow notifications.

Vercel Observability is available for viewing traffic and errors. Vercel alert subscriptions are plan-dependent; if **Observability → Alerts** is available, subscribe the owner to error-anomaly alerts.

## Deploying safely

1. Make changes on a branch and open a pull request.
2. Wait for tests and the Vercel Preview deployment.
3. Test sign-in, one PubMed run, evidence extraction, one review action, and the Evidence Room in Preview.
4. For a database change, link the Supabase CLI to staging and run:

   ```bash
   npx supabase db push --dry-run
   npx supabase db push
   ```

5. Confirm `/api/health` reports the new expected schema version.
6. Confirm a current backup exists before applying any migration to a future production database.
7. Merge the pull request and repeat the smoke test on Production.

Never make an unrecorded production schema change directly in the Supabase SQL Editor.

## Backups and recovery

Follow `docs/BACKUP_RESTORE_DRILL.md`. At minimum:

- Check **Supabase → Database → Backups** before every migration.
- Paid Supabase projects receive managed daily backups; Point-in-Time Recovery is a paid add-on.
- A free project needs regular off-platform logical exports with `supabase db dump`.
- Database backups do not contain files stored through the Supabase Storage API.
- Never commit a database dump, database password, access token, or service-role key to GitHub.
- Perform a restore drill into a separate recovery project before calling the system production-ready.

Pilot recovery targets are **RPO 24 hours** (at most one day of accepted work lost) and **RTO 4 hours** (restore useful service within four hours). These are goals until a timed restore drill proves them.

## Logging and privacy

- Vercel runtime logs and structured server errors are the first diagnostic source.
- Record research run IDs, task IDs, queue item IDs, timestamps, and error classes.
- Never log source excerpts, tokens, passwords, magic links, service-role keys, or confidential scientific payloads.
- PubMed `429` responses are provider throttling; retry later and preserve the failed run status.

## Pilot entry gate

Use `docs/SCIENTIFIC_PILOT_CHECKLIST.md`. Do not start the pilot until all required items are checked, including a successful backup check and a named incident owner.
