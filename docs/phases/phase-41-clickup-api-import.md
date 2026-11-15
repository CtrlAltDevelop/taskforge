# Phase 41 — Import from ClickUp with an API token

**Status:** Done (verified: 108 imports tests pass)

## Feature
Pull spaces, lists, tasks, sub-tasks and comments straight from ClickUp with a personal API token, then import them through the phase-29 wizard (no export file to make or upload).

## Why it exists
Phase 29 reads ClickUp's CSV/JSON exports, but ClickUp's own export has no comments, checklists or links, and a person has to find and upload it. The API has all of it, so switching is one paste of a token.

## How it works (plain words)
Wizard source "ClickUp (API token)": paste a personal token → the server lists the ClickUp workspaces and their lists (space › folder › list) → tick the lists to bring → the server fetches them in the background (tasks 100 per page, then each task's comments) and writes one `{"tasks": [...]}` file into storage → the job becomes a normal `clickup_json` upload and the wizard goes on at **Map**. Everything after that (mapping, dry run, import, undo, idempotent re-run) is phase 29, unchanged.

The token is used for the calls and then dropped: it is never stored, logged, audited or returned.

## Scope
**In:** token check, list picker, background fetch with progress and cancel, rate-limit backoff, a task in several lists fetched once, checklists and custom-field values kept in the task body (also for the file import).
**Out:** OAuth app flow, two-way sync, ClickUp docs/goals/views, attachment binaries (manifest only, as phase 29), time entries.

## Data model
`ImportJob.status` gains `fetching` (the file is still being pulled; `phase`/`done`/`total` count lists then tasks). No new table.

## API surface
- REST: `POST /imports/clickup/lists {workspace_id, token}` → workspaces with their lists; `POST /imports/clickup/fetch {workspace_id, token, list_ids}` → the job (`fetching`). Token only in the body. `data.manage`.
- Progress and cancel use phase-29 gRPC `Get` / `Cancel`; no proto change.

## Flutter UI
Source step lists "ClickUp (API token)"; its Upload step is a token field, a list picker with checkboxes, and a progress bar while `fetching`; then Map as usual.

## Rules and edge cases
- Only `api.clickup.com` is ever called; list ids are validated before going into a URL.
- 401/403 from ClickUp → "ClickUp rejected the token." (never echoes the token). 429 → wait as told, a few tries, then fail the job with a clear message.
- A fetch whose process died is marked failed by `imports_tick` (the token is gone; fetch again).
- Same idempotency as phase 29 (`ImportedRef` by ClickUp task id), so fetching twice never duplicates.
- Checklists become `- [x]` / `- [x]` lines; custom fields a "Custom fields" list, both appended to the body.

## Acceptance criteria
- [x] Lists endpoint returns the token's workspaces and lists; a bad token is a 400 without the token in the message
- [x] Fetch produces a job that analyzes and imports with comments, sub-tasks and links
- [x] A task in two lists is imported once; re-running creates zero duplicates
- [x] Rate limit (429) is waited out; cancel stops a fetch; a dead fetch is failed by the tick
- [x] The token appears in no stored row, audit entry or log
- [x] Checklists and custom fields reach the body from the JSON file import too
- [x] Wizard: token → pick lists → progress → Map

## Tests
Fake ClickUp via `httpx.MockTransport`: hierarchy, paging, comments, dedup, 401, 429, cancel, token never persisted, permission and cross-workspace; parser tests for checklists/custom fields; Flutter wizard test with a fake client.

## Depends on
Phase 29.
