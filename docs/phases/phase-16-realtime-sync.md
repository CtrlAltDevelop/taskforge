# Phase 16 — Realtime Sync

**Status:** TODO

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
- [ ] Two clients: change on one appears on the other in < 500 ms (local network)
- [ ] Kill the socket for 60 s, make 100 changes elsewhere: reconnect converges exactly
- [ ] Private project events never reach non-members
- [ ] No duplicate UI flicker on own edits

## Tests
Publish-after-commit (rollback sends nothing), catch-up correctness, permission on subscribe, Flutter reconnect state machine with fake socket.

## Depends on
Phases 04, 06 (benefits all views 11–15).

## Hand-off from earlier phases
- Phase 09 already sends `task_changed` with action `linked` / `unlinked` (both tasks of a link, version unchanged) through `transaction.on_commit`; turn them into `task.updated` events so other clients refresh the links and the blocked lock (`Task.is_blocked`, `Task.blocked_by`).
