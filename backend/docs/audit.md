# Audit log

An append-only record of who changed what, per workspace and per task.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `AuditEntry`

Who did what, to what, when. Ids are plain values (no foreign keys) so that deleting a

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `workspace` | UUID |  |
| `actor` | Char |  |
| `actor_type` | Char |  |
| `action` | Char |  |
| `target_type` | Char |  |
| `target_id` | Char |  |
| `project` | UUID | nullable |
| `changes` | JSON |  |
| `batch_id` | UUID | nullable |
| `ip` | GenericIPAddress | nullable |
| `user_agent` | Char |  |
| `at` | DateTime |  |
<!-- /generated:models -->

## Admin

<!-- generated:admin -->
_This app registers nothing in the admin._
<!-- /generated:admin -->

## Setup

<!-- generated:settings -->
_This app requires no settings of its own._
<!-- /generated:settings -->

## Usage

- **What is recorded**: one `AuditEntry` per change, written **in the transaction of the change** (a rollback takes the entry with it): `actor`, `actor_type` (`user`, `automation`, `system`), `action` (`task.status_changed`), `target_type`/`target_id`, `project`, `changes` (`{field: [before, after]}`), `batch_id`, `ip`, `user_agent`, `at`. Ids are plain values, not foreign keys, so deleting a workspace or a person never touches the log.
- **How**: `tracking.TRACKED` lists the models and watched fields; `receivers` turn `post_save`/`post_delete` into entries (a `pre_save` snapshot gives the "before"). A write that skips the ORM's signals (`queryset.update`, `bulk_create`, `bulk_update`) goes through `changes.update_rows` / `changes.updated` / `recorder.record` instead. A child row (a comment, a file, a link, time) is filed under its **task**, so a task's history is one query. Sign-in events (`auth.login_succeeded`, `auth.password_changed`, second-factor changes) are filed under every workspace the person belongs to.
- **Where from**: `ip` is the peer address; set `DJANGO_AUDIT_TRUSTED_PROXY_HOPS=1` behind Envoy to take the last `X-Forwarded-For` hop (the left part is the client's own claim). A task's history (`Activity.ForTask`) never carries `ip`/`user_agent` and names only tasks the reader may open.
- **Immutable**: no write RPC; the model and queryset refuse `save` of an existing row, `update` and `delete`; on PostgreSQL a trigger (migration 0002) refuses UPDATE and DELETE from any role, the app's own included.
- **Redaction**: keys that name a secret (`password`, `token`, `secret`, `authorization`, `headers`, `key`, plus `AUDIT_REDACT_KEYS`) are blanked at any depth; text over 300 characters and JSON over 600 are stored as their size. Only watched fields are copied at all (never file contents, storage keys or hashes).
- **Purges**: deleting a workspace or an expired field is one `workspace.purged` / `field.purged` entry (receivers are suppressed for the cascade), not one per row.
- **Bulk**: a bulk edit gives one entry per task with a shared `batch_id`. An automation's changes carry `actor_type=automation` and the rule's id as `actor`.
- **gRPC** (`AuditController`, `ActivityController`): `Audit.List` (filters: actor, action exact or a prefix ending in `.`, target, project, `since`/`until`; newest first; `before` is an entry id, `next_before` 0 at the end) and `Audit.Export` (CSV text streamed in chunks; cells starting `= + - @` are quoted; the export is itself recorded as `audit.exported`) need `audit.view` (Owner, Admin). `Activity.ForTask` needs only that the caller can open the task; `labels` name the statuses, people, sprints and tasks the entries mention.
- **Coverage**: `audit/tests/test_coverage.py` calls every write RPC of the permission matrix and fails if one leaves no entry; the few the matrix calls as no-ops are proven in `test_real_changes.py`.
- **Not recorded**: personal state (key bindings, inbox, watching, search history, favourites) and rows derived from other rows (burndown snapshots, automation runs, a page's own mention links).
