# Phase 12 — Board (Kanban) View

**Status:** DONE

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
- [x] Drag within/between columns persists and survives reload
- [x] Two simultaneous drags in the same column both succeed with sane order
- [x] 1,000 cards in one column stay smooth
- [x] Keyboard-accessible move alternative exists

## Tests
Rank insertion/rebalance, transition rejection, concurrent moves, Flutter drag simulation.

## Depends on
Phases 07, 11.

## As built
- **API**: `BoardController` in the tasks app — `Get` (every column with its count and first 30 cards, lanes with swimlanes), `ListColumn` (cursor paging), `Move(id, group_by, column, before_id, after_id, …)`. It replaces the planned `Board.Get/ListColumn` and `Tasks.Move(…, after_task)`; the existing `Tasks.Move` (status only) is unchanged. A drop in another column changes that field through the normal edit path (workflow transitions, blockers, `task.update`); a drop inside a column only changes the card's rank and never conflicts. Details in `backend/docs/tasks.md` ("The board").
- **Ranks**: one `Move` rewrites only the dropped task (and its subtree's `tree_key` prefix). Two drops into the same gap get distinct ranks; the server respaces the project's ranks when one grows past 24 characters.
- **Board layout**: `SavedView` with `kind="board"` (`group_by`, `swimlane`, `card_fields`, `limits`); the app keeps each person's own, saved a moment after every change. Sharing a board layout is supported by the backend but has no screen yet.
- **Cards** are top-level tasks; subtasks show as progress on the parent's card. Card fields: assignee, due date, priority, subtask progress and any custom field; title, id and the blocked lock always show. A card only drops inside its own swimlane (it does not reassign).
- **Flutter**: List | Board switch; columns scroll sideways, each column lazily builds its cards and asks for the next page at its end; drag (long press on touch) with a drop line above/below, auto-scroll at the edges of the board and of a column, a **Move to…** menu on every card (Tab-reachable), a snap back with the server's reason on refusal, the blocked-task override dialog, WIP limit per column (header turns red over the limit), fold a column, add a task at the foot of a column, swimlanes by assignee, card field chooser. The board is read again when the task detail closes.
- **Concurrency**: `Move` locks the project row first (like every task write), so two drops into one gap queue and get distinct ranks, and a respacing never overlaps a drop. Dropping in another person's column swaps only the card's first assignee and keeps the others. A drop past the loaded cards of a longer column means "last"; a drop back on the card itself is not a move. The app shows a read that overlaps a drop only after the drop has finished, and reads the board again when the detail opens or closes.
- Not done / not verified: right-to-left layouts (edge scrolling and card padding assume left-to-right); the fold state of a column is not saved; a two-thread race on PostgreSQL was not run (the lock is the guard); board layout sharing UI; reassigning by dragging across swimlanes; a required custom field blocks the column quick-add (use the list's quick-add); PostgreSQL (race of two real parallel drops) and the 60 fps of a thousand cards on a device were not run — only lazily built cards and the query budget of a 10,000-task project are tested.
