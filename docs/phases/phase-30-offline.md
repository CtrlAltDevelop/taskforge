# Phase 30 — Offline Mode

## Feature
The app works **without a connection**: browse cached data, make edits that queue, and sync automatically when back online.

## Why it exists
Both incumbents mostly fail offline (blank screens, lost edits), especially on mobile and in low-connectivity regions. Offline-first makes the app feel instant and trustworthy everywhere.

## How it works (plain words)
The Flutter app keeps a local SQLite database (Drift; WASM/IndexedDB on web). Screens always read from the local DB; the network layer just keeps it up to date (initial fetch, then realtime events and `Sync.Since(cursor)` from phase 16). Edits are written to the local DB immediately **and** appended to an **outbox** (a list of pending mutations with client-generated ids and `expected_version`). A sync worker replays the outbox in order when online. If the server rejects a mutation due to conflict, the user sees it in a **“Needs attention”** list with *keep mine / take theirs / merge* choices. Creating tasks offline uses client UUIDs; the display id (`WEB-12`) is assigned by the server on sync and shown as “pending” until then.

## Scope
**In:** local DB schema mirroring core entities (workspaces, projects, tasks, statuses, fields, comments, members), outbox, sync worker, conflict resolution UI, online/offline indicator, selective cache (recent projects, size cap), clear-cache, attachment queue (upload when online).
**Out:** offline for docs editing beyond read-only (later), offline search of the entire workspace (cache-limited search only).

## Data model
Client-side only: `local_tasks…`, `outbox(id, entity, op, payload, expected_version, created_at, attempts, state)`, `sync_state(cursor per workspace)`.
Server: idempotency key table `AppliedMutation(client_mutation_id unique, result)`.

## API surface
- gRPC mutations accept `client_mutation_id` (idempotent replays return the stored result).
- `Sync.Since` (phase 16) for deltas; `Sync.Snapshot(project)` for the initial bulk download (streamed).

## Flutter UI
Offline banner, per-item “pending” clock icon, “Needs attention” screen, storage settings, first-run progress for downloading a project.

## Rules and edge cases
- Outbox order preserved per entity; dependent ops (create task → edit it) coalesced.
- Permission changes while offline: rejected mutations surface clearly, never silent.
- Local DB encrypted-at-rest option on desktop/mobile; wiped on logout.
- Schema migrations for the local DB are versioned and tested.

## Acceptance criteria
- [ ] Airplane mode: browse, create, edit, comment; reconnect → everything syncs
- [ ] Replaying the same mutation twice is harmless (idempotent)
- [ ] Conflict scenario produces the attention item and resolves correctly
- [ ] Logout wipes local data

## Tests
Outbox ordering/coalescing, idempotency on server, conflict flow, migration tests, fake-network integration test.

## Depends on
Phases 06, 16 (and the data phases it caches: 05, 07, 10, 17).
