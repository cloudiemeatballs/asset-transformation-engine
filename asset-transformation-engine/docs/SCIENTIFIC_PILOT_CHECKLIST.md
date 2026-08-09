# Scientific reviewer pilot checklist

## Scope

Run a small, supervised pilot with three to five scientific reviewers. The purpose is to test workflow clarity, provenance, and review consistency—not to make clinical, investment, or patient-care decisions.

## Required before inviting reviewers

- [ ] One named pilot owner and one backup operator.
- [ ] Reviewers are individually invited; no shared accounts.
- [ ] Each user has the minimum Supabase role needed.
- [ ] `/api/health` reports `ready`, database reachable, schema `0007`.
- [ ] The latest GitHub Production health check is green.
- [ ] Supabase backup status has been checked and recorded.
- [ ] Incident owner has read `docs/INCIDENT_RESPONSE.md`.
- [ ] Reviewers agree not to enter patient data, secrets, or proprietary full text.
- [ ] TGFBR1 is consistently HOLD wherever it appears unless formally re-reviewed.

## Pilot script for each reviewer

1. Sign in using the email magic link in the same browser.
2. Create one narrowly scoped Research Run in Query Builder.
3. Execute PubMed and open the run results.
4. Check titles, PMIDs, links, retrieved counts, and task status.
5. Extract candidate evidence claims.
6. In Review Queue, accept one well-supported claim, reject one unsuitable claim with rationale, and defer one uncertain claim.
7. Confirm accepted evidence appears once in the Evidence Room with its source link.
8. Repeat one action on mobile or a narrow browser window.
9. Record confusing language, missing provenance, errors, and time to completion.

## Stop conditions

Pause the pilot immediately for suspected data exposure, duplicate canonical claims, a review action applied to the wrong record, accepted evidence without traceable source information, inconsistent PASS/HOLD decisions, or repeated authentication failure.

## Success criteria

- [ ] At least 90% of scripted tasks complete without operator intervention.
- [ ] Every accepted claim has a source, stable identifier or link, locator, reviewer, and review timestamp.
- [ ] No review action creates more than one canonical claim.
- [ ] All failures are visible and recoverable; none silently lose work.
- [ ] Reviewers can explain the difference between retrieved records, proposals, accepted claims, and decisions.
- [ ] Median completion time and reviewer feedback are recorded.
- [ ] No unresolved SEV-1 or SEV-2 incident remains.

## Pilot record

- Dates and environment:
- Pilot owner / backup operator:
- Reviewers and roles:
- Research run IDs:
- Tasks completed / attempted:
- Median completion time:
- Errors and incident links:
- Reviewer feedback themes:
- Required changes and owners:
- Go / hold decision and rationale:
