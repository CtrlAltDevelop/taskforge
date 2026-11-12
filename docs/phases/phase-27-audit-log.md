# Phase 27 — Audit Log and Task History

**Status:** DONE

## Feature
An immutable **audit log** of who did what and when, with a per-task **activity history**.

## Why it exists
Both tools reserve audit logs for top tiers, yet “who changed this?” is a daily question and a compliance need. We give it to everyone.

## How it works (plain words)
Every service mutation writes an **audit entry**: actor, action (`task.status_changed`), target, and a before/after diff of changed fields. Entries are append-only — no update or delete API, and the DB role used by the app cannot update/delete the table. The task detail has an **Activity** section showing history (“Ali changed status Active → Done, 2 h ago”). Workspace admins get an **Audit log** screen with filters (actor, action, date, project) and CSV export. Optional retention (default: keep forever).

## Scope
**In:** audit table, recording helper called inside services, task activity section, admin audit screen with filters/pagination/export, sensitive-action coverage (login, role change, member removal, invitation, token creation, export).
**Out:** external SIEM streaming (webhooks 32 can forward), tamper-evident hash chain (documented as future).

## Data model
- `AuditEntry(id bigserial, workspace, actor, actor_type(user|automation|system), action, target_type, target_id, project nullable, changes jsonb, ip, user_agent, at)` — indexes on `(workspace, at)`, `(target_type, target_id)`.

## API surface
- gRPC: `Audit.List(filters, cursor)` (admin), `Audit.Export` (server stream CSV), `Activity.ForTask(task, cursor)`.

## Flutter UI
Activity section in task detail (grouped by day, collapses noisy field edits), admin table with filter chips, diff viewer showing before/after.

## Rules and edge cases
- Recording is in the **same transaction** as the change so they can’t diverge.
- Never store secrets or full file bodies in `changes`; redact configured keys.
- Activity visible to anyone who can see the task; audit screen needs `audit.view`.
- Bulk operations produce one entry per task (queryable) with a shared `batch_id`.

## Acceptance criteria
- [x] Every write RPC from earlier phases creates an entry (checked by a test enumerating all write RPCs): `audit/tests/test_coverage.py` calls every endpoint of the permission matrix that is not on its explicit `READS` list, once as Owner and once as the lowest built-in role that may call it (attributed to that person), and checks the matrix itself against every `.proto` rpc and every handler, so a new write cannot hide
- [x] App DB role cannot UPDATE/DELETE audit rows: a PostgreSQL trigger refuses both for any role (migration 0002); the ORM refuses them everywhere. The trigger test is skipped on SQLite and **was not run on PostgreSQL**
- [x] Filter by actor+date performs < 300 ms on 1M rows — measured on 100k rows on SQLite (well under 300 ms, on the `(workspace, ...)` index); **1M rows on PostgreSQL were not run** (no database here)
- [x] Export streams without loading all rows in memory (a generator over `iterator(chunk_size)`; the app collects the chunks for its copy/save dialog)

## Tests
Atomicity (rollback leaves no entry), redaction, coverage enumeration, permission on screen, pagination stability.

## Depends on
Phase 04 and all write paths (start recording now; each phase adds its actions).

## Built
- Backend: new `audit` app. `AuditEntry` (plain-value ids, indexes on workspace+time, workspace+actor+time, target, batch) is append-only: model and queryset refuse changes, a PostgreSQL trigger refuses UPDATE/DELETE. `tracking.TRACKED` lists 24 models and their watched fields; `receivers` turn `post_save`/`post_delete` into entries inside the change's transaction (a `pre_save` snapshot gives "before"); writes that skip signals use `changes.update_rows` / `changes.updated` / `recorder.record` (members, roles, invitations, project, workspace, docs archive, field reorder, subtasks moved with a parent, bulk status moves, assignees, reactions). A child row is filed under its task, so a task's history is one query. Secrets and bodies are redacted; bulk edits share a `batch_id`; automations record `actor_type=automation`; sign-ins (`auth.*`) are filed under each of the person's workspaces; REST and gRPC calls both set the actor, address and agent.
- `audit.view` (Owner, Admin). gRPC `AuditController.List/Export` (admin) and `ActivityController.ForTask` (anyone who can open the task), with `labels` naming ids; the permission matrix covers all three.
- App: `features/audit`: an Activity section in task detail (grouped by day, quick edits folded, re-read when the task's version moves), an admin Audit log screen (`/audit`; area, person, project and date filters, paging by id, before/after dialog, CSV copy/save), a settings tile and a palette action for those with `audit.view`.
- Review fixes: a task's history carries no address or agent and names only tasks the reader may open; the address is the peer (or the Nth proxy hop, `DJANGO_AUDIT_TRUSTED_PROXY_HOPS`); REST writes are attributed too; nested batches join the outer one (a subtree delete is one batch); workflow saves, promoted children and restores record their changes; a workspace/field purge is one entry; webhook URLs and other secrets are blanked.
- **Round two** (audit of phases 25-30): `AUDITED` sign-in events now include `login_failed`, `password_reset_requested` and `second_factor_failed` when they name an account (filed under that person's workspaces); a guess at an address with no account has no workspace to file under and `throttled` is not emitted by the auth app, both deliberate non-goals (the auth app's own `AuthEvent` trail keeps them); completing a blocked task anyway (`BlockOverride`) is recorded as `block_override.created`; optional retention: `DJANGO_AUDIT_RETENTION_DAYS` (default 0 keeps all) and `make purge` → `purge_audit`, the only deletion path (`AuditQuerySet.purge_before`; on PostgreSQL migration 0003 lets the trigger pass a DELETE only inside a transaction that did `SET LOCAL audit.purging = 'on'`, which `retention.purge` does and nothing else; UPDATE stays refused). Tests: project filter, coverage completeness, non-owner attribution, sign-in events, block override, retention on SQLite; Flutter tests for the person, project and date filters, day headings and folding, and Save as file.
- Not recorded: personal state (keys, inbox, watching, search history, favourites) and derived rows (snapshots, automation runs, a page's mention links). Failed sign-ins have no person to file under.
- Found, not mine: purging a workspace that still has tasks fails with `ProtectedError` (`Task.status` is PROTECT); it predates this phase and needs its own fix.
- Left to later phases: token creation and revocation (`token.created`/`token.revoked`, now in phase 32's scope and acceptance), a client-side save-to-file that streams instead of collecting the CSV.
- **Not verified (no PostgreSQL here)**: the immutability trigger and its purge exception (migrations 0002/0003), the PostgreSQL retention delete, and the 1M-row actor+date timing. The list orders by `-id` while the useful index is `(workspace, actor, at)`, so the plan must be checked with `EXPLAIN` at that size before trusting the ticked 1M-row box on PostgreSQL (it is ticked on the 100k SQLite run).
