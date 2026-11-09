# Phase 11 — List View

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
- [ ] 10k rows scroll at 60 fps on a mid-range laptop and phone
- [ ] Column/sort/group config persists across sessions and devices
- [ ] Bulk edit of 200 tasks completes < 2 s with progress shown
- [ ] Fully keyboard operable on desktop/web

## Tests
Virtualization widget tests, bulk partial failure, group counts correct, saved view round-trip.

## Depends on
Phases 06, 10.
