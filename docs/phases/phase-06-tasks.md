# Phase 06 — Tasks

**Status:** DONE

## Feature
Create, view, edit and delete **tasks** (title, description, assignee, priority, due date, status) with fast paginated listing over gRPC.

## Why it exists
The task is the heart of the product, and where Jira and ClickUp feel slow. We make list loading a **server-streamed, cursor-paginated** gRPC call and edits **optimistic with version checks**, so the UI feels instant and never silently overwrites someone else.

## How it works (plain words)
Each task gets a display id `KEY-N` from the project's atomic counter. Tapping a task opens a detail pane (side panel on desktop/web, full page on mobile). Editing a field sends only that field plus `expected_version`. The UI shows the change immediately; if the server answers "version conflict", the UI shows the other person's value and offers *keep mine / take theirs*. Description is rich text stored as a structured JSON (headings, lists, checklists, code, links) — one format shared with Docs later.

## Scope
**In:** CRUD, assignees (multiple), priority (Urgent/High/Normal/Low/None), start/due dates, simple default statuses (To do / In progress / Done — replaced by phase 07), rich description, soft delete + trash restore, task detail UI, quick-add, server-streamed list RPC.
**Out:** custom statuses (07), subtasks (08), dependencies (09), custom fields (10), comments (17).

## Data model
- `Task(id, workspace, project, number, title, description jsonb, status, priority, start_date, due_date, created_by, version, created_at, updated_at, deleted_at, position)`
- `TaskAssignee(task, user)`
- unique `(project, number)`; indexes on `(project, status)`, `(assignee)`, `(due_date)`.

## API surface
- gRPC: `Tasks.Get`, `Create`, `Update(field mask + expected_version)`, `Delete`, `Restore`, `List(filter, cursor) → stream Task` (server streaming, chunks of 100)
- WS event: `task.created|updated|deleted` (consumed from phase 16)

## Flutter UI
Quick-add bar, task detail pane, assignee picker (avatar chips), date pickers, priority icons. States: skeleton loading, empty, error with retry, conflict dialog.

## Rules and edge cases
- Updates use **field masks** so two people editing different fields never conflict.
- Title required, max 500 chars; description max 200 KB.
- `position` uses fractional indexing (rank string) for cheap reordering later.
- Assignee must be a project-accessible member.

## Acceptance criteria
- [x] Create/edit/delete/restore through gRPC
- [x] 10,000-task project: first page rendered < 500 ms, memory stays flat while streaming
- [x] Conflict on same field returns `ABORTED` with current value; different fields merge
- [x] Display ids never duplicate under concurrent creates (test with 50 parallel)

## Tests
Counter race, field-mask merge, conflict path, permissions, rich text validation, Flutter optimistic update + rollback.

## Depends on
Phases 04, 05.

## As built (differs from the plan)
- `Task.field_versions` (field -> version that last changed it) is added to the model: it is how "different fields merge, same field conflicts" is decided.
- New permission keys `task.create`, `task.update`, `task.delete` (Owner, Admin, Member); reading needs only `workspace.view`.
- Rank positions append in fixed width (6 letters) rather than growing; `rank.between` is there for reordering. A naive append grew past the column after ~10,000 tasks (found on Postgres).
- Update sends `optional` fields (proto3 field presence) plus `set_assignees`, instead of a `FieldMask` message.
- "First page < 500 ms": measured on the server (10,000-task project, SQLite and Postgres) and in the app's list controller (the first 100 of 10,000 streamed tasks are in the list in well under 500 ms in a Flutter test). Not measured in a real browser. Memory is flat on the server (keyset pages); the client keeps the list it shows.
- The description is edited in the app as lightly marked-up text (`#` headings, `-` / `1.` lists, `- [ ]` checklists, `>` quotes, fenced code, `---`, `[text](url)` links) and stored as the shared rich-text document; the codec round-trips every block the server accepts, so a document made elsewhere is shown and re-saved without loss. It is a text box, not a WYSIWYG editor; that can come with Docs.
- `ListTrash` was added so deleted tasks can be restored from a Trash screen (project page, for anyone with `task.delete`), not only from the Undo snackbar.
- The assignee picker offers a private project's members only; an open project offers every workspace member.
- Code review found and fixed: description flattening, overlapping optimistic edits (rollback now reverts only the failed fields; stale snapshots and out-of-order answers are handled), a made-up `expected_version`, mixed-case duplicate assignees, Undo after the screen is gone, a task created while the list is still streaming.
- The WebSocket events are not consumed here: `signals.task_changed` is the hook for phase 16.
- Tasks are numbered with `next_task_number` inside the project row lock after loading the project through `visible_to` (same guarantees as `number_task`).
