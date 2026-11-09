# Phase 29 — Import and Export

## Feature
**Import** projects and tasks from Jira, ClickUp and CSV; **export** everything to open formats (JSON + CSV).

## Why it exists
Teams stay on Jira/ClickUp mostly because leaving is painful. A trustworthy importer makes switching real, and full export removes lock-in fear for our own users.

## How it works (plain words)
**Import wizard:** choose source → upload the source export file (Jira CSV/JSON backup, ClickUp export, generic CSV) → **map** columns/fields/statuses/users (auto-suggested; unmatched users become “placeholder members” that can be claimed on invite) → **dry run** showing counts and warnings → confirm → server-streamed progress. The import runs in a Celery job, in chunks, and is **resumable and idempotent** (source ids stored, rerunning doesn’t duplicate). **Export:** project or workspace → zip with `tasks.json`, `tasks.csv`, comments, attachments manifest, and a README of the schema.

## Scope
**In:** Jira (issues, sprints, comments, links, labels→custom field), ClickUp (tasks, subtasks, statuses, assignees, comments), generic CSV, mapping UI, dry run, progress stream, undo-last-import (delete by `import_batch`), full JSON/CSV export.
**Out:** live two-way sync with Jira/ClickUp, importing attachments binary from remote URLs requiring their auth (manifest only in v1).

## Data model
- `ImportJob(id, workspace, source, status, mapping jsonb, stats jsonb, error_report, created_by)`
- `ImportedRef(job, source_id, entity_type, entity_id)` for idempotency/undo.
- `PlaceholderUser(workspace, name, source_email, claimed_by nullable)`

## API surface
- REST: `POST /api/imports/upload` (multipart, large file)
- gRPC: `Imports.Analyze(upload) → proposed mapping`, `DryRun`, `Start`, `Progress(job) → stream`, `Undo`; `Exports.Start/Status`, download via signed URL.

## Flutter UI
Stepper wizard (Source → Upload → Map → Review → Import), mapping tables with dropdowns, warning list, progress bar; export dialog with scope chooser.

## Rules and edge cases
- Parsers are streaming (large files must not load into memory) and defensive: malformed rows are collected in an error report, not fatal.
- Imported timestamps and authors preserved; history marked “imported”.
- Never execute content from files; strip HTML to our rich-text format.
- Requires admin permission; audit-logged (27).

## Acceptance criteria
- [ ] A 50k-issue Jira sample imports with correct links, sprints and comments
- [ ] Re-running the same import creates zero duplicates
- [ ] Undo removes exactly the imported set
- [ ] Export → import into a fresh workspace reproduces the project

## Tests
Parser fixtures from real-shaped samples, mapping suggestions, idempotency, undo, round-trip test.

## Depends on
Phases 06–10, 17, 22; benefits from 27.
