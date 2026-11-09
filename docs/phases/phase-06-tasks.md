# Phase 06 — Tasks

**Status:** TODO

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
- [ ] Create/edit/delete/restore through gRPC
- [ ] 10,000-task project: first page rendered < 500 ms, memory stays flat while streaming
- [ ] Conflict on same field returns `ABORTED` with current value; different fields merge
- [ ] Display ids never duplicate under concurrent creates (test with 50 parallel)

## Tests
Counter race, field-mask merge, conflict path, permissions, rich text validation, Flutter optimistic update + rollback.

## Depends on
Phases 04, 05.
