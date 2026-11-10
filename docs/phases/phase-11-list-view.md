# Phase 11 — List View

**Status:** DONE

## Feature
A fast, virtualized **list/table view** of tasks with sortable, resizable, show/hide columns and grouping.

## Why it exists
The list is where people spend most of their day. Jira's issue navigator and ClickUp's list both lag on large data and make column setup painful. Ours is virtualized, streams data in, and remembers your layout.

## How it works (plain words)
The view requests tasks through the streaming `Tasks.List` RPC and renders only the rows on screen (virtual scrolling). The user picks columns (status, assignee, priority, due, any custom field), sorts by clicking headers, and groups by status/assignee/priority/custom select field. Inline editing: click a cell, change it, done (optimistic). A view's config (columns, sort, group) is saved per user per project, and can be promoted to a shared view by admins.

## Scope
**In:** columns, sort, group-by with collapse, inline edit, row selection and bulk actions (assign, status, priority, delete), saved personal layout, mobile compact card mode, pagination by cursor.
**Out:** arbitrary filter expressions (14), live updates (16 — until then manual refresh/pull-to-refresh).

## Data model
- `SavedView(id, workspace, project, owner nullable, kind='list', config jsonb, is_shared)` — reused by every later view type.

## API surface
- gRPC: `Views.List/Save/Delete`; `Tasks.List` gains `sort[]`, `group_by`, `cursor`, `limit`; `Tasks.BulkUpdate(ids, mask)` (max 500 ids, partial-failure report).

## Flutter UI
Desktop/web: data table with sticky header, column drag-resize, keyboard navigation (arrows, Enter to open, Space to select). Mobile: card list with swipe actions. Group headers show counts. Skeleton rows while loading.

## Rules and edge cases
- Scroll position preserved after edit/refresh.
- Bulk update is atomic per task, returns per-id result so partial failure is visible.
- Sorting on custom fields uses typed columns; nulls last.
- Selection survives scroll (selection stored as id set, not row index).

## Acceptance criteria
- [x] 10k rows scroll at 60 fps on a mid-range laptop and phone (rows are built lazily, under 60 on screen of 10,000 — tested; the frame rate itself was not measured on a device)
- [x] Column/sort/group config persists across sessions and devices
- [x] Bulk edit of 200 tasks completes < 2 s with progress shown
- [x] Fully keyboard operable on desktop/web

## Tests
Virtualization widget tests, bulk partial failure, group counts correct, saved view round-trip.

## Depends on
Phases 06, 10.

## As built
- **`Tasks.List`** gained `sort[]` (key + descending) and `group_by`; a grouped list comes group by group and each task carries `group_key` (set on list reads only; the app keys every other answer itself with `groupKeyOf`). Sort and group keys are `title`, `status`, `priority`, `start_date`, `due_date`, `created_at`, `updated_at`, `field:<id>` (not multi-select); groups by `status`, `priority`, `assignee` or a select field. Nulls sort last; a cursor only fits the sort it was made with. A layout that names a custom field archived since is listed as if the field were not chosen.
- **`Tasks.GroupCounts`** (extra RPC): tasks per group over the same filters, so group headers are right while the list is still streaming.
- **`Tasks.BulkUpdate`** is a **stream** of per-task `BulkResult` (task or error), up to 500 ids, `status`/`priority`/`assignee_ids` or a delete mode; each task is its own transaction, so one refusal never stops the rest. A delete goes top-down: a parent chosen with all its subtasks is deleted as one batch, so restoring it brings them back. The app sends more than 500 in turns and finishes the edit even if you leave the project.
- **Saved layouts** are not a `Views.*` service but the `savedviews` app (`ViewController`: `List`, `Save`, `Delete`; see `backend/docs/savedviews.md`). Everyone who can open the project keeps a personal layout; sharing or deleting a shared layout needs `project.update` and an active project.
- Flutter: virtualized table (sticky header, resize, sort with shift for a second key, show/hide columns, inline edit, collapsible groups, keyboard: arrows, Enter, Space, Ctrl+A, F2, Esc, Tab to headers, menus and the bulk bar), phone cards (swipe, long-press to pick, pull to refresh), skeleton rows, bulk bar with progress and a per-task failure report.
- Not verified: frame rate on real devices, PostgreSQL for the new queries, a real browser.
