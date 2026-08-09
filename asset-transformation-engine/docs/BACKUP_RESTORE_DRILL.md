# Backup and restore procedure

## What this protects

The Supabase database contains accounts, research runs, imported record metadata, review items, proposals, and accepted evidence claims. A backup protects the database; it does not automatically protect Supabase Storage objects or external provider content.

## Before every migration

1. Sign in to Supabase and open the project.
2. Choose **Database → Backups**.
3. Record the newest available recovery point and the time you checked it in the deployment notes.
4. If no usable backup exists, stop. For a free project, create a logical export before continuing.
5. Run the migration on staging first and complete the application smoke test.

## Free-project logical export

Supabase recommends regular CLI exports for free projects. From the `asset-transformation-engine` directory, first confirm the CLI is linked to the intended project. Then follow Supabase's current **Backup database using the CLI** instructions to export roles, schema, and data into an access-controlled folder outside this Git repository.

Safety rules:

- Name the folder with the project and UTC date.
- Encrypt the backup at rest and restrict access to the operator and recovery owner.
- Do not place exports inside the repository. The local `backups/` directory is ignored as a last line of defense, but it is not an approved archive.
- Do not paste database passwords or access tokens into documentation, commits, issues, or chat.
- Retain at least the last seven successful daily exports during the pilot.

## Quarterly restore drill

Do not restore over the working project for a test.

1. Create or designate a separate Supabase recovery project.
2. Record the drill start time and the backup/recovery point selected.
3. Restore or clone the database into the recovery project using the Supabase Dashboard or current CLI procedure.
4. Configure a local application instance with the recovery project's public URL and publishable key only.
5. Sign in with a test account and verify:
   - a known research run exists;
   - imported PubMed records and identifiers are present;
   - accepted evidence claims and their sources are present;
   - the Review Queue loads;
   - `/api/health` reports `ready` and schema `0007`.
6. Record the recovery completion time, records checked, missing data, and corrective actions.
7. Delete the temporary recovery project only after the drill record has been reviewed and no investigation needs it.

## Recovery decision

Use the newest recovery point from before the damaging event. Restoring the active Supabase project makes it unavailable during restoration, so declare an incident and stop application writes first. After recovery, rotate any credential suspected of exposure, retest row-level security and authentication, and reconcile work created after the selected recovery point.

The pilot targets are:

- **RPO:** 24 hours.
- **RTO:** 4 hours.

Mark them as proven only after a timed drill meets both targets.

## Drill record template

- Date and operator:
- Source project/environment:
- Backup or recovery point:
- Recovery project:
- Start time / service-ready time:
- RPO achieved:
- RTO achieved:
- Verification results:
- Missing or inconsistent data:
- Corrective actions and owner:
- Reviewer approval:
