# Phase 29 — Import and Export

**Status:** DONE

## Feature
**Import** projects and tasks from Jira, ClickUp and CSV; **export** everything to open formats (JSON + CSV).

## Why it exists
Teams stay on Jira/ClickUp mostly because leaving is painful. A trustworthy importer makes switching real, and full export removes lock-in fear for our own users.

## How it works (plain words)
**Import wizard:** choose source → upload the source export file (Jira CSV/JSON backup, ClickUp export, generic CSV) → **map** columns/fields/statuses/users (auto-suggested; unmatched users become “placeholder members” that can be claimed on invite) → **dry run** showing counts and warnings → confirm → server-streamed progress. The import runs in the background (a thread now, Celery later; `imports_tick` resumes a run whose process died), in chunks, and is **resumable and idempotent** (source ids stored, rerunning doesn’t duplicate). **Export:** project or workspace → zip with `tasks.json`, `tasks.csv`, comments, attachments manifest, and a README of the schema.

## Scope
**In:** Jira (issues, sprints, comments, links, labels→custom field), ClickUp (tasks, subtasks, statuses, assignees, comments), generic CSV, mapping UI, dry run, progress stream, undo-last-import (delete by `import_batch`), full JSON/CSV export.
**Out:** live two-way sync with Jira/ClickUp, importing attachments binary from remote URLs requiring their auth (manifest only in v1).

## Data model
- `ImportJob(id, workspace, project, source, status, filename, file_key, member, mapping, analysis, stats, error_report, phase, total, done, heartbeat_at, created_by, version ...)`
- `ImportedRef(workspace, job, family, entity_type, source_id, entity_id, meta)`, unique per `(workspace, family, entity_type, source_id)`: idempotency across jobs and the undo list. `meta` holds the original key, author and the attachments manifest.
- `PlaceholderUser(workspace, key, name, source_email, claimed_by nullable)` and `PlaceholderAssignment(task, placeholder)`.
- `ExportJob(workspace, project, scope, status, file_key, stats ...)`.

## API surface
- REST: `POST /imports/upload` (multipart, streamed to storage), `GET /exports/download?token=` (signed, short-lived, no bearer).
- gRPC `ImportController`: `List`, `Get` (with the error report), `Analyze(job, source?, member?) → proposed mapping`, `DryRun`, `Start` (starting a failed or cancelled job resumes it), `Progress(job) → stream`, `Cancel`, `Undo`, `Discard`, `ListPlaceholders`, `ClaimPlaceholder`; `ExportController.Start/Status` (`Status` carries the signed download path once done). Permission `data.manage` (Owner, Admin) for all.

## Flutter UI
Stepper wizard (Source → Upload → Map → Review → Import), mapping tables with dropdowns, warning list, progress bar; export dialog with scope chooser.

## Rules and edge cases
- One target project per import job (an existing project, or a new one made from a name and key). A workspace export is one folder per project; import them one at a time.
- Closed sprints import as completed, every other state as planned (no invented burndown). Blocking links that would form a loop are skipped with a warning. Tasks are numbered level by level, not in file order.
- An author who is not a member becomes the importer, named at the head of the comment; a task assigned to a non-member waits on a placeholder until they join with the same email (or an admin claims it).
- Undo keeps a task someone added a sub-task to (and the chain above it) and says how many were kept.
- Parsers are streaming (large files must not load into memory) and defensive: malformed rows are collected in an error report, not fatal.
- Imported timestamps and authors preserved; history marked “imported”.
- Never execute content from files; strip HTML to our rich-text format.
- Requires admin permission; audit-logged (27). The target project must be one the importer can open.
- History marked "imported": every imported task has a `task.imported` activity line (source, original key, reporter, original time); a reporter who is not a member keeps the importer as the task's author and is named there.

## Acceptance criteria
- [x] A 50k-issue Jira sample imports with correct links, sprints and comments
- [x] Re-running the same import creates zero duplicates
- [x] Undo removes exactly the imported set
- [x] Export → import into a fresh workspace reproduces the project

## Tests
Parser fixtures from real-shaped samples, mapping suggestions, idempotency, undo, round-trip test.

## Depends on
Phases 06–10, 17, 22; benefits from 27.

## Built
- **Backend** (`imports` app): streaming readers (`streams.py`: CSV with delimiter and encoding sniffing, an incremental JSON array reader, zip members with a bomb limit); parsers for Jira CSV/JSON, ClickUp CSV/JSON, any CSV and TaskForge's own export; `richtext.py` (HTML, Jira markup, Markdown, Atlassian documents to our rich text, no active content); `scan.py` (one pass: counts, ids, parents, link targets), `mapping.py` (proposal and validation), `prepare.py` (project, statuses, fields, sprints, people), `engine.py` (level by level, chunks of 200 in one transaction each with their refs, bulk inserts, links with loop breaking, resume), `dryrun.py`, `undo.py`, `exports.py` + `export_data.py` (project and workspace zips, signed link, purge), placeholders, gRPC, REST, `imports_tick` and `purge_exports` in `make tick` / `make purge`, `data.manage`, audit entries, docs.
- **App**: Import and export screen (Settings): a five-step wizard (Source, Upload with streaming, Map with project/columns/statuses/priorities/people/labels tables, Review from the dry run, Import with a streamed progress bar, cancel, resume, undo), past imports with undo/continue/forget, people waiting to join (assign now), and an export dialog with a scope chooser.
- **Tests**: backend parsers/streams/richtext, every source end to end, idempotent re-run, undo (including a user's own sub-task), resume and cancel, dry run, permissions and cross-workspace, export and the round trip into a fresh workspace, the 50,000-issue Jira file (a streaming memory bound), the RBAC matrix and audit coverage; Flutter domain, REST client, wizard and export UI tests.
- **Review fixes**: one run owns a job (token + heartbeats while reading); a private target the importer cannot open is refused; parents only from the same project; deep chains and loops flattened iteratively; loop-breaking is deterministic and sees links stored by earlier runs; undo keeps tasks, sprints and fields people have used; the download link re-checks the exporter's right; exports spool to disk and include comment replies; lines and JSON entries are read with bounded growth; the real export zip uploads as it is.
- **Audit fixes**: a placeholder is claimed whenever a member turns active, so a removed member invited back takes over their tasks too (the signal no longer needs a new row); handing a placeholder over keeps the assignments of tasks in private projects the person cannot open, and leaves the placeholder open so a later claim finishes it (deleted tasks are dropped); tests for both, for a Jira sprint that is not closed becoming planned, and for ClickUp JSON corners and the background lane.
- **Not verified**: PostgreSQL (no database here); the row lock on the project during chunks and the background thread under a real server; a real browser or device (file chooser, saving the zip); real Jira and ClickUp exports (the fixtures are real-shaped, hand-written).
