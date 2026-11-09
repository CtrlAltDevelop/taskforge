# Phase 12 — Board (Kanban) View

**Status:** TODO

## Feature
A **Kanban board** where columns are statuses (or another field) and cards are tasks, with drag-and-drop and WIP limits.

## Why it exists
Jira boards feel heavy and break when workflows change; ClickUp boards stutter with many cards. Ours loads each column lazily and keeps ordering stable and conflict-free.

## How it works (plain words)
Each column is a status (default) or a group by assignee / priority / select field. Cards show title, id, assignee avatar, due date, priority, blocked lock and subtask progress. Dragging a card sends one `Move(task, to_column, before_id/after_id)` request. Order uses fractional ranks, so moving a card changes only that card — two people dragging at once never corrupt order. Columns load 30 cards then more on scroll. **WIP limit** per column turns the header red when exceeded.

## Scope
**In:** columns by status/field, drag-drop across and within columns, lazy column paging, WIP limits, swimlanes (group rows by assignee), card field chooser, quick-add per column, collapse column.
**Out:** sprint board (22 reuses this view), live multi-user updates (16).

## Data model
- `SavedView.config` holds group field, card fields, WIP limits, swimlane.
- `Task.position` (rank string) per project; per-board ordering uses the same rank.

## API surface
- gRPC: `Board.Get(view) → columns with counts`, `Board.ListColumn(column, cursor)`, `Tasks.Move(task, target_status, after_task)` (checks workflow transitions from phase 07).

## Flutter UI
Horizontal scrolling columns, drag with auto-scroll at edges, drop indicator; touch long-press to pick up on mobile; "Move to…" menu as accessible alternative. Rejected move animates the card back with the reason.

## Rules and edge cases
- Disallowed transition: card snaps back + toast with reason.
- Rank rebalancing runs server-side when gaps get too small; clients never compute global order.
- Dragging into a *Done* column of a blocked task triggers the dependency warning (09).
- Empty column shows drop zone hint.

## Acceptance criteria
- [ ] Drag within/between columns persists and survives reload
- [ ] Two simultaneous drags in the same column both succeed with sane order
- [ ] 1,000 cards in one column stay smooth
- [ ] Keyboard-accessible move alternative exists

## Tests
Rank insertion/rebalance, transition rejection, concurrent moves, Flutter drag simulation.

## Depends on
Phases 07, 11.
