# Asset Transformation Engine

A production-oriented MVP for evaluating whether clinically validated biology is constrained by engineerable drug properties, and whether repeated transformations can form coherent biotechnology companies.

## Run

```bash
npm install
npm run dev
```

Open `http://localhost:3000`. Verification: `npm test`, `npm run typecheck`, `npm run lint`, and `npm run build`.

## Architecture

- `supabase/migrations/0001_domain.sql` — normalized PostgreSQL schema and database invariants.
- `supabase/seed.sql` — reference taxonomy foundation.
- `src/domain` — strict domain types, Zod contracts, gates, consensus, scoring, thesis assembly, stage promotion, and independent-target counting.
- `src/data/seed.ts` — illustrative scientific decision records used by the local repository boundary. They are explicitly labeled illustrative in the UI and APIs.
- `src/app/api` — typed DTO endpoints and validated structured search.
- `src/app` — research, evidence, discovery, scoring, and company-formation surfaces.
- `src/research` — provider-neutral adapters, immutable ingestion, normalized records, entity resolution, atomic claim extraction, evidence verification, confidence calibration, compatibility rules, research planning, budgets, and human-review proposals.
- `supabase/migrations/0002_research_layer.sql` — Phase 2 ingestion, research-task graph, proposal, prompt-versioning, freshness, snapshot, alert, and review-queue persistence.

The SQL schema is ready for Supabase/PostgreSQL. The zero-configuration local mode deliberately uses the same typed DTO repository boundary so the MVP remains runnable without external infrastructure; replacing that adapter with a database-backed implementation does not change domain logic or UI contracts.

The Research Workbench uses synthetic fixture records through the production-shaped `ScientificDataAdapter`; none are represented as factual biomedical findings. Agents submit review proposals and cannot write authoritative scores or bypass the existing gates.

## Production setup

Copy `.env.example` to `.env.local`, create separate staging and production Supabase projects, and apply the checked-in migrations with the Supabase CLI. When Supabase variables are absent, the app intentionally remains in read-only illustrative demo mode. When configured, protected research areas require authentication, opportunity reads use database projections, and proposal review uses the transactional `review_proposal` database function.

Operational deployment, monitoring, backup, incident response, and pilot requirements are in:

- `docs/PRODUCTION_RUNBOOK.md`
- `docs/BACKUP_RESTORE_DRILL.md`
- `docs/INCIDENT_RESPONSE.md`
- `docs/SCIENTIFIC_PILOT_CHECKLIST.md`
