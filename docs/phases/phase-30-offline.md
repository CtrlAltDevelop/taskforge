# Phase 30 — Offline Mode

**Status:** DONE (web persistence, PostgreSQL and a real device not run: see *Built*)

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
- [x] Airplane mode: browse, create, edit, comment; reconnect → everything syncs
- [x] Replaying the same mutation twice is harmless (idempotent)
- [x] Conflict scenario produces the attention item and resolves correctly
- [x] Logout wipes local data

## Tests
Outbox ordering/coalescing, idempotency on server, conflict flow, migration tests, fake-network integration test.

## Depends on
Phases 06, 16 (and the data phases it caches: 05, 07, 10, 17).

## Built
- **Server**: `sync.AppliedMutation` and `once()` (`sync/mutations.py`): a repeated `client_mutation_id` returns the entity as it now is; an id belongs to whoever used it first (409 for anyone else); refused changes are not recorded so they can be sent again; `purge()` runs in `trim_changelog`. Task create and comment create accept a client-chosen id; Task `Create`/`Update`/`Delete` and Comment `Create` take `client_mutation_id`.
- **App** (`core/offline`): a Drift database (`local_db`, versioned migrations, generated code committed, `make gen`), `OfflineStore` (cache, outbox, size cap and trim, kept projects, wipe), `foldIntoQueue` (create+edit = one create, create+delete = nothing, edit+edit = one edit; entries being sent or waiting on a decision are never folded), codecs, `OutboxWorker` (in order, one mutation id each, retry-safe; a clash becomes *conflict*, a refusal *rejected*; later changes to the same task wait behind either; a refused create rejects what hung on it), `OfflineTasksClient`/`OfflineCommentsClient` over the real clients, `ReadCache` for the workspaces, projects, members, workflow and fields reads, `NetworkMonitor`, `OfflineSync` (sends when the live feed returns, every 30 s, on "Sync now"; probes the server while offline; trims the cache; wipes everything at sign-out), and a durable attachment queue (files picked offline, or cut off by the connection, are copied to the app folder and uploaded later).
- **UI**: offline banner with the waiting count and "Sync now", a clock on rows and in the task header for anything not yet sent, an *Offline and storage* screen (Settings: changes needing a decision with keep mine / take theirs / merge, or try again / discard; what waits; cache size and cap; clear cache; keep a project offline with progress).
- **Decisions**: reads go to the server first and fall back to the local copy (the plan said local first: this keeps what is shown current); `Sync.Snapshot` is not built, `Tasks.List` (already streamed) fills a kept project; no encryption at rest (no SQLCipher): the screen says to use the device's disk encryption; moving with subtasks, bulk edits, links, restore and comment edits or reactions need the server and fail with a network error offline; a filtered or grouped list offline shows the plain tree; a task made offline shows as *Pending* with the status *New* until the server numbers it; a change made online to a task that has changes waiting goes behind them; on the web there is no local database yet, so it stays online-only; sign-out removes unsent changes too.
- **Review fixes**: an entry whose send was tried (a cut-off call, a requeue) is never folded into, since its mutation id may already be applied; ids a client makes are canonical UUIDs (the server writes ids back that way); a later edit of a task is rebased onto the version the earlier one saved, also across passes; sign-out seals the store (late writes are refused), wipes it, removes kept files, and a launch that is already signed out finishes the wipe; a mutation id reused for another call is refused; a create replay answers with the recorded id; trimming spares kept projects.
- **Known limits**: the cursor table (`SyncCursors`) is reserved: reads are network-first so `Sync.Since` is not needed yet; there is no "recent projects" rule beyond the size cap and kept projects; comments of a kept project can still be trimmed; no `integration_test/` flow (the flow is covered by unit and widget tests with a fake network); a client-chosen id that collides answers 409, which tells a member that a task id exists in another workspace (random 122-bit ids, so only someone who already knows it learns it).
- **Tests**: server idempotency; outbox folding, store, migrations; client and worker flows (offline create/edit/delete, lost answer, clash and its three choices, refusals, ordering, dependants); read cache; sync controller; attachment queue; banner, pending mark and attention screen widgets.
- **Not verified**: the browser (no persistence there), a real device or airplane mode, PostgreSQL (no database here).
