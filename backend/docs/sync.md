# Realtime sync

The change log, the `/ws/sync` WebSocket (rooms, live events, presence) and catch-up after a gap. Always installed. Phase 16.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `ChangeLog`

What changed, never the content. Appended after the change commits and trimmed after

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | UUID | nullable |
| `entity_type` | Char |  |
| `entity_id` | UUID |  |
| `version` | PositiveInteger |  |
| `action` | Char |  |
| `actor` | Char |  |
| `at` | DateTime |  |

#### `TrimMark`

The highest change-log id ever trimmed: a client whose cursor is behind it missed entries

| Field | Type | Notes |
| --- | --- | --- |
| `id` | PositiveSmallInteger | primary key |
| `upto` | BigInteger |  |
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

### How a change reaches a screen

1. A service commits a change. Its existing `*_changed` signal (`task_changed`, `project_changed`, `workflow_changed`, `fields_changed`, `access_changed`) is sent through `transaction.on_commit`, so a rollback sends nothing.
2. `receivers.py` appends a **`ChangeLog`** row (workspace, project, entity type and id, version, action, actor) and publishes an **event** to the rooms below on the broker the notifications app already runs (Redis whenever the WebSocket and gRPC servers are separate processes, as `make serve` and `make grpc` are: the Makefile sets it; memory only inside one process).
3. Every connected `/ws/sync` socket that joined a room hears it; the client reads the affected screen again, or ignores the event when its own `origin` is its own client id.

An event is a hint, never content: `{"type", "workspace", "project", "entity_id", "version", "actor", "origin", "ts", "cursor"}`. Clients trust `version`, not arrival order. Types: `task.created` / `task.updated` / `task.deleted` (every other task action, links included, is an update), `project.created` / `project.updated`, `comment.created` / `comment.updated` / `comment.deleted` (the `entity_id` is the task whose comments changed), `workflow.updated`, `fields.updated`, `access.changed`.

### Rooms

`proj:<id>` carries everything about a project; `ws:<id>` carries the same for **open** projects (a private project's events never go there) and workspace-level changes; `user:<id>` is a person's own (their access changes). Access is checked when a room is joined, when an `access.changed` hint arrives (a member removed, a role changed or edited, a project's members or visibility changed: the socket re-checks every room at once and sends `unsubscribed` with `reason: "access"`), every 60 seconds, and before a project event is delivered if the room was last checked more than 5 seconds ago. A refused room is one uniform `forbidden` error that names no reason.

### The socket (`/ws/sync`)

Plain ASGI like the notification socket. The first frame must be `{"type": "authenticate", "token": ...}` within 10 seconds (never in the URL), answered by `ready`; anything else closes with 4401. Then `subscribe` / `unsubscribe` (`room`), `presence` (`project`, `task`, `state`: `viewing`, `editing`, `left`) and `ping`. At most 50 rooms, 1,200 commands a minute, 16 KB a frame; 120 seconds of silence closes it. The server answers `subscribed`, `unsubscribed`, `event` (`room`, `event`), `presence` (`project`, `task`, `users`), `pong`, `error` (`code`). The same change announced to a project and its workspace is delivered once (by `cursor`).

### Presence

Who is on a task, and whether they are editing, is kept for 45 seconds and renewed by the client's heartbeat (Redis hashes when the broker is Redis, process memory otherwise; never the database). A change in who is there or in the editing flag is broadcast to the project room; closing the socket leaves every task the connection announced.

### Catching up

`SyncController` (gRPC): `Head(workspace_id)` is the workspace's latest cursor (`"0"` for a quiet one); `Since(workspace_id, cursor, limit)` streams the entries after `cursor` the caller may see (a private project's entries are left out for those who cannot open it, and so are other people's access changes; the cursor still moves past them), oldest first, at most `limit` (default 1,000, at most 5,000). A full page ends with one `sync.more` entry (ask again from its cursor); a cursor older than the log still holds answers with one `sync.gap` entry (read the screens again, then listen from its cursor). A client re-reads a few dozen entries before its cursor because ids can land a little out of commit order; entries are idempotent hints, so that costs nothing.

The log is trimmed after 14 days by `manage.py trim_changelog` (`--days` overrides) and, so no scheduler is needed, by about one change in a thousand. `TrimMark` remembers how far, which is how a gap is told from a quiet period.

### Who made a change

A client sends `x-client-id` with every gRPC call (it must be in `CORS_ALLOW_HEADERS` and Envoy's `allow_headers`; a test checks both). `infrastructure.sync.actor` keeps it (and the caller) in context variables for the length of the request, so the event can carry `actor` and `origin` without every service passing them on.
