# Phase 27 — Audit Log and Task History

## Feature
An immutable **audit log** of who did what and when, with a per-task **activity history**.

## Why it exists
Both tools reserve audit logs for top tiers, yet “who changed this?” is a daily question and a compliance need. We give it to everyone.

## How it works (plain words)
Every service mutation writes an **audit entry**: actor, action (`task.status_changed`), target, and a before/after diff of changed fields. Entries are append-only — no update or delete API, and the DB role used by the app cannot update/delete the table. The task detail has an **Activity** tab showing history (“Ali changed status Active → Done, 2 h ago”). Workspace admins get an **Audit log** screen with filters (actor, action, date, project) and CSV export. Optional retention (default: keep forever).

## Scope
**In:** audit table, recording helper called inside services, task activity tab, admin audit screen with filters/pagination/export, sensitive-action coverage (login, role change, member removal, invitation, token creation, export).
**Out:** external SIEM streaming (webhooks 32 can forward), tamper-evident hash chain (documented as future).

## Data model
- `AuditEntry(id bigserial, workspace, actor, actor_type(user|automation|system), action, target_type, target_id, project nullable, changes jsonb, ip, user_agent, at)` — indexes on `(workspace, at)`, `(target_type, target_id)`.

## API surface
- gRPC: `Audit.List(filters, cursor)` (admin), `Audit.Export` (server stream CSV), `Activity.ForTask(task, cursor)`.

## Flutter UI
Activity timeline in task detail (grouped by day, collapses noisy field edits), admin table with filter chips, diff viewer showing before/after.

## Rules and edge cases
- Recording is in the **same transaction** as the change so they can’t diverge.
- Never store secrets or full file bodies in `changes`; redact configured keys.
- Activity visible to anyone who can see the task; audit screen needs `audit.view`.
- Bulk operations produce one entry per task (queryable) with a shared `batch_id`.

## Acceptance criteria
- [ ] Every write RPC from earlier phases creates an entry (checked by a test enumerating all write RPCs)
- [ ] App DB role cannot UPDATE/DELETE audit rows
- [ ] Filter by actor+date performs < 300 ms on 1M rows
- [ ] Export streams without loading all rows in memory

## Tests
Atomicity (rollback leaves no entry), redaction, coverage enumeration, permission on screen, pagination stability.

## Depends on
Phase 04 and all write paths (start recording now; each phase adds its actions).
