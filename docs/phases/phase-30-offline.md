# Phase 30 — Offline Mode

**Status:** DONE

## Feature
The app works **without a connection**: browse cached data, make edits that queue, and sync automatically when back online.

## Why it exists
Both incumbents mostly fail offline (blank screens, lost edits), especially on mobile and in low-connectivity regions. Offline-first makes the app feel instant and trustworthy everywhere.

## How it works (plain words)
The Flutter app keeps a local SQLite database (Drift) on mobile and desktop; the browser has none yet. What the app reads is copied into it (a typed JSON cache, one row per entity, plus the last answer of the catalog reads); when the server cannot be reached the screens are answered from that copy. Reads go to the server first so what is shown is current; the live feed of phase 16 (its own `Sync.Since` catch-up) refreshes the open screens, and on reconnect the open screens and the projects kept offline are read again. Edits are written to the local DB immediately **and** appended to an **outbox** (a list of pending mutations with client-generated ids and `expected_version`). A sync worker replays the outbox in order when online. If the server rejects a mutation due to conflict, the user sees it in a **“Needs attention”** list with *keep mine / take theirs / merge* choices. Creating tasks offline uses client UUIDs; the display id (`WEB-12`) is assigned by the server on sync and shown as “pending” until then.

## Scope
**In:** a local typed JSON cache of the core entities (workspaces, projects, tasks, board, statuses, fields, comments, members), outbox, sync worker, conflict resolution UI, online/offline indicator, selective cache (kept projects, the most recently read projects, size cap), clear-cache, attachment queue (upload when online, native only).
**Out:** offline for docs editing beyond read-only (later), offline search of the entire workspace (cache-limited search only).

## Data model
Client-side only: `cached_rows(workspace, kind, id, scope, version, json, saved_at)` (the typed JSON cache), `outbox_rows(id, entity, op, payload, expected_version, created_at, attempts, state, …)`, `offline_meta` (size cap, kept projects, read times). There is no per-workspace cursor table: the live feed keeps its own cursor and replays what it missed.
Server: idempotency key table `AppliedMutation(client_mutation_id unique, result)`.

## API surface
- gRPC mutations accept `client_mutation_id` (idempotent replays return the stored result).
- Deltas come from the live feed (`Sync.Since`, phase 16) for open screens; a project kept offline is downloaded with the streamed `Tasks.List` plus the workflow, fields and members reads. A separate `Sync.Snapshot` is not built (the reads above already stream and are permission-checked).

## Flutter UI
Offline banner, per-item “pending” clock icon, “Needs attention” screen, storage settings, first-run progress for downloading a project.

## Rules and edge cases
- Outbox order preserved per entity; dependent ops (create task → edit it) coalesced.
- Permission changes while offline: rejected mutations surface clearly, never silent.
- Local DB wiped on logout. (The encrypted-at-rest option is *not built*: see *Not built*.)
- Schema migrations for the local DB are versioned and tested.

## Acceptance criteria
- [x] Airplane mode: browse, create, edit, comment; reconnect → everything syncs
- [x] Replaying the same mutation twice is harmless (idempotent)
- [x] Conflict scenario produces the attention item and resolves correctly
- [x] Logout wipes local data

## Tests
Outbox ordering/coalescing, idempotency on server, conflict flow, migration tests, fake-network integration test (`app/integration_test/offline_flow_test.dart`).

## Depends on
Phases 06, 16 (and the data phases it caches: 05, 07, 10, 17).

## Built
- **Server**: `sync.AppliedMutation` and `once()` (`sync/mutations.py`): a repeated `client_mutation_id` returns the entity as it now is; an id belongs to whoever used it first (409 for anyone else); refused changes are not recorded so they can be sent again; `purge()` runs in `trim_changelog`. Task create and comment create accept a client-chosen id; Task `Create`/`Update`/`Delete` and Comment `Create` take `client_mutation_id`.
- **App** (`core/offline`): a Drift database (`local_db`, versioned migrations, generated code committed, `make gen`), `OfflineStore` (cache, outbox, size cap and trim, kept projects, wipe), `foldIntoQueue` (create+edit = one create, create+delete = nothing, edit+edit = one edit; entries being sent or waiting on a decision are never folded), codecs, `OutboxWorker` (in order, one mutation id each, retry-safe; a clash becomes *conflict*, a refusal *rejected*; later changes to the same task wait behind either; a refused create rejects what hung on it), `OfflineTasksClient`/`OfflineCommentsClient` over the real clients, `ReadCache` for the workspaces, projects, members, workflow and fields reads, `NetworkMonitor`, `OfflineSync` (sends when the live feed returns, every 30 s, on "Sync now"; probes the server while offline; trims the cache; wipes everything at sign-out), and a durable attachment queue (files picked offline, or cut off by the connection, are copied to the app folder and uploaded later).
- **UI**: offline banner with the waiting count and "Sync now", a clock on rows and in the task header for anything not yet sent, an *Offline and storage* screen (Settings: changes needing a decision with keep mine / take theirs / merge, or try again / discard; what waits; cache size and cap; clear cache; keep a project offline with progress).
- **Decisions**: reads go to the server first and fall back to the local copy (the plan said local first: this keeps what is shown current); `Sync.Snapshot` is not built, `Tasks.List` (already streamed) fills a kept project; no encryption at rest (no SQLCipher): the screen says to use the device's disk encryption; moving with subtasks, bulk edits, links, restore and comment edits or reactions need the server and fail with a network error offline; a filtered or grouped list offline shows the plain tree; a task made offline shows as *Pending* with the status *New* until the server numbers it; a change made online to a task that has changes waiting goes behind them; on the web there is no local database yet, so it stays online-only; sign-out removes unsent changes too.
- **Review fixes**: an entry whose send was tried (a cut-off call, a requeue) is never folded into, since its mutation id may already be applied; ids a client makes are canonical UUIDs (the server writes ids back that way); a later edit of a task is rebased onto the version the earlier one saved, also across passes; sign-out seals the store (late writes are refused), wipes it, removes kept files, and a launch that is already signed out finishes the wipe; a mutation id reused for another call is refused; a create replay answers with the recorded id; trimming spares kept projects.
- **Added after the audit**: the board works offline (`OfflineBoardClient`: the last board read is shown with waiting changes laid over it; a drop is queued as an ordinary edit of the task's status, priority, assignee or field; a status change from the list (`TasksClient.move` without subtasks) is queued too); on reconnect the open lists, boards and comments read again and the projects kept offline are re-read; trimming spares kept projects with their comments and, last, the three projects read most recently; waiting comments and kept files show a clock; a refused comment counts as an answer (the server is reachable); calls that need the server say "This needs a connection to the server"; a client-chosen id that another workspace holds is refused exactly like a malformed id (a same-workspace duplicate stays a 409).
- **Not built**: (1) *encrypted-at-rest option*: needs SQLCipher binaries (`sqlcipher_flutter_libs`) and a key in secure storage with a migrate-or-recreate toggle; it cannot be built and checked in this environment (no device, no SQLCipher build), so it is not offered; the Offline screen says the copy is unencrypted and to use disk encryption. (2) *Web persistence* (Drift WASM + IndexedDB): needs the sqlite3 WASM and worker assets and a real browser to verify; the browser is online-only. (3) *`Sync.Snapshot`* (above). (4) *Per-card position*: a card dropped offline lands last in its column, not where it was dropped.
- **Known limits**: a column's later pages, moving with subtasks, bulk edits, links, restore, and comment edit/delete/react need the server; a filtered or grouped list offline shows the plain tree; the board with swimlanes offline shows the last read without re-sorting rows; a client-chosen id collision with the caller's own workspace answers 409; no real-device or airplane-mode run.
- **Tests**: server idempotency and the cross-workspace id rules; outbox folding, store, migrations, trimming; client and worker flows (offline create/edit/delete, lost answer, clash and its three choices, refusals, ordering, dependants); offline board; read cache; sync controller and catch-up on reconnect; attachment queue; banner, pending mark and attention screen widgets; `integration_test/offline_flow_test.dart` (browse, drop the connection, create, edit and comment, reconnect, all on the server).
- **Not verified**: the browser, a real device or airplane mode, PostgreSQL (no database here).
