# Phase 16 — Realtime Sync

**Status:** DONE

## Feature
Every open view updates **live** when anyone changes data, via WebSocket events, plus presence ("who is viewing this task").

## Why it exists
Stale boards and "refresh to see changes" are constant complaints in both Jira and ClickUp, and a source of duplicate work and lost edits. Live sync removes that class of bug.

## How it works (plain words)
After sign-in the app opens one WebSocket and subscribes to rooms: the current workspace, the open project, and the user's private room. When a service commits a change, it publishes a tiny event (`task.updated`, entity id, new `version`) after the DB transaction commits. The client compares the version with its cache: if it's newer, it fetches the row via gRPC and updates the UI; if the app itself made the change (same `actor` and already at that version) it ignores it. If the socket drops, the client reconnects with exponential backoff and, on reconnect, asks for everything changed **since its last seen cursor** (`Sync.Since(cursor)`), so no event is ever lost.

## Scope
**In:** Channels consumer, rooms/groups, publish-after-commit helper, event schema, version-based cache invalidation in Flutter, reconnect + catch-up, presence on task detail, typing/“editing” indicator on description.
**Out:** collaborative co-editing of text (docs phase 23 handles its own), offline queue (30).

## Data model
- `ChangeLog(id bigserial, workspace, project, entity_type, entity_id, version, action, actor, at)` — append-only, trimmed after 14 days; its id is the sync cursor.
- Presence stored in Redis with TTL (no DB table).

## API surface
- WS messages: `subscribe`, `unsubscribe`, `event`, `presence`, `ping`
- gRPC: `Sync.Since(cursor, limit) → stream ChangeLog entries`
- Permission checked on subscribe **and** when delivering to private-project rooms.

## Flutter UI
Subtle “live” indicator, connection state banner (“Reconnecting…”), changed rows flash briefly, presence avatars on the task header, “Someone else is editing this” hint.

## Rules and edge cases
- Events are hints, not data: no private content in payloads.
- Revoked access: user is removed from the room immediately (role/membership event).
- Thundering herd after server restart: jittered backoff.
- Ordering: clients trust `version`, not arrival order.
- Gap detection: cursor gap → full refetch of visible views.

## Acceptance criteria
- [x] Two clients: change on one appears on the other in < 500 ms (local network) (tested in process: well under 500 ms; not measured over a real network)
- [x] Kill the socket for 60 s, make 100 changes elsewhere: reconnect converges exactly (tested with a fake socket and a hundred real log entries; not a real 60 s TCP outage)
- [x] Private project events never reach non-members
- [x] No duplicate UI flicker on own edits

## Tests
Publish-after-commit (rollback sends nothing), catch-up correctness, permission on subscribe, Flutter reconnect state machine with fake socket.

## Depends on
Phases 04, 06 (benefits all views 11–15).

## Hand-off from earlier phases
- Phase 09 already sends `task_changed` with action `linked` / `unlinked` (both tasks of a link, version unchanged) through `transaction.on_commit`; turn them into `task.updated` events so other clients refresh the links and the blocked lock (`Task.is_blocked`, `Task.blocked_by`).

## As built
- **Transport**: a plain ASGI socket at `/ws/sync` (as the notification socket is), not Channels; events ride the broker the notifications app already runs (memory in a single process, Redis otherwise). `make run`, `make serve` and `make grpc` now use the Redis broker (start `make dev` first): changes are made in the gRPC process and sockets are held in the REST/WebSocket one, so a per-process broker would deliver nothing.
- **Pipeline**: the existing `task_changed`, `project_changed`, `workflow_changed` and `fields_changed` signals (all sent after commit) are turned into a `ChangeLog` row plus an event by `infrastructure/sync/receivers.py`; a new `access_changed` signal (member removed or given a role, role edited or deleted, project members or visibility changed) tells the person's sockets to re-check their rooms at once. Task `linked`/`unlinked` (phase 09) become `task.updated`. Rooms: `proj:`, `ws:` (open projects only), `user:`. Reference: `backend/docs/sync.md`.
- **Catch-up**: `SyncController.Since` (stream, with `sync.more` paging and one `sync.gap` entry when the cursor is older than the log) and `Head`; the log is trimmed after 14 days by `manage.py trim_changelog` and, with no scheduler needed, by about one write in a thousand. `Since` leaves out a private project's entries for those who cannot open it and other people's access changes.
- **Own edits**: the app sends `x-client-id` on every gRPC call (allowed in the Envoy and Django CORS lists, and tested); events carry it as `origin`, and the client skips events it made itself. An edit made before a drop comes back through catch-up without an origin and reads once more.
- **Flutter**: a `SyncClient` state machine (connect, authenticate with a fresh token, join rooms, catch up, heartbeat, silence watchdog, jittered exponential retry) behind a fake-able socket; a coordinator that reads the open list, board, calendar, timeline and tray again, coalesced over 200 ms and silently (the whole open view is read again rather than one row: each view keeps the newer version of a task, so an answer that overtakes another cannot undo it, and `version` is used for that, not to fetch one row); the first connection also reads the screens once more, because they were read before it listened. A live/reconnecting indicator and banner, a brief flash on rows and cards another person changed, avatars of who else is on a task, "Ana is editing this", and a heartbeat that lapses by itself.
- Not verified: a timing run with two real clients, a real 60 s network outage, a browser run (CORS and the socket in Chrome), Redis presence across several workers (tested against a fake client), PostgreSQL.
