# Phase 08 — Subtasks

**Status:** DONE

## Feature
Tasks can have **subtasks** nested to any depth, with progress roll-up and tree-aware moves.

## Why it exists
Jira limits hierarchy (Epic → Story → Sub-task, fixed levels); ClickUp supports nesting but the UI gets cluttered and roll-ups are inconsistent. We use one rule: *a task can have a parent task*, and the UI shows it cleanly.

## How it works (plain words)
Any task can be a child of another. The parent shows a progress bar (done children / total, weighted optionally by estimate). Children appear as an indented tree in lists and as a checklist in the task detail. Dragging a task onto another makes it a child. Completing a parent with open children asks: *complete all* / *leave open* (or is blocked if the workflow condition "all subtasks done" is on).

## Scope
**In:** `parent` link, unlimited depth (soft limit 8 in UI), breadcrumbs, roll-up progress, expand/collapse, re-parent, convert task ↔ subtask, workflow condition "all subtasks done".
**Out:** dependencies (09), cross-project parents (not allowed).

## Data model
- `Task.parent` (nullable FK, same project), `Task.depth`, `Task.path` (materialized path or ltree) for fast subtree queries
- `Task.progress_done`, `progress_total` maintained by service on change

## API surface
- gRPC: `Tasks.SetParent`, `Tasks.ListChildren`, `Tasks.List` gains `include_subtasks` and returns tree order
- Event: `task.reparented`

## Flutter UI
Indented tree rows with chevrons, progress ring on parents, "Add subtask" inline, drag-to-nest (desktop/web) and "Move under…" menu (mobile). Breadcrumb `WEB-3 › WEB-9 › WEB-14` in detail.

## Rules and edge cases
- **Cycle prevention:** cannot parent a task under its own descendant (checked server-side).
- Same project only; moving a subtree between projects moves all descendants and renumbers.
- Deleting a parent: choose *delete subtree* or *promote children*.
- Roll-up recalculated on child status/delete/move, in the same transaction.

## Acceptance criteria
- [x] Nest 8 levels; progress rolls up correctly
- [x] Cycle attempt rejected
- [x] Re-parent updates paths for the whole subtree
- [x] Tree list of 5k tasks stays smooth (virtualized)

## Tests
Cycle detection, path rewrite, roll-up correctness under concurrent child updates, delete modes.

## Depends on
Phases 06, 07.

## As built (differs from the plan)
- `Task` gains `parent` (nullable self FK, same project), `depth`, `path`, `tree_key`, `progress_done`, `progress_total`. `path` is a chain of ids for subtree queries; `tree_key` is a chain of sibling ranks joined with `0` (not a punctuation separator, which collations may ignore) that orders the list. A hard depth cap of 24 on the server; the app stops offering more at 8 (the soft limit).
- Progress counts every descendant at any depth (not only direct children), maintained by the service in the same transaction. It is not weighted by estimate (there are no estimates yet). The app computes the ring from the loaded tree, so it is right immediately after an optimistic edit.
- `Tasks.SetParent`, `Tasks.ListChildren`, `List(include_subtasks)` (tree order, top level only by default), `Delete(mode)`, `Move(include_subtasks)` are as planned or implied; the event is `task_changed` with action `reparented`.
- Delete asks `subtree` or `promote` (a task with subtasks cannot be deleted without choosing). A subtree delete stamps every task with one `deleted_at`, so Restore brings the batch back and leaves separately-deleted ones in the trash.
- "Complete all / leave open" is `Move(include_subtasks)` (all or nothing under the workflow's rules) or a plain move; the workflow condition `require_subtasks_done` blocks a move while any subtask is open, and is part of the workflow editor (and its conflict merge).
- UI: indented tree rows with chevrons, a progress ring on parents, "Add subtask" inline from the row menu or the detail checklist, "Move under…" and "Make top level" in the row menu (every width), a breadcrumb `WEB-3 › WEB-9 › WEB-14` and a checklist of direct subtasks in the detail. On wide screens a row is moved by pressing and holding it and dragging it onto another (an ordinary drag still scrolls the list). The list builds rows lazily (5,000 tasks).
- Code review found and fixed: a workflow save that changes a status category or migrates tasks now recounts every parent's progress (one pass over the project, not a query per task); "complete all" only moves open subtasks (done and cancelled ones are left alone) and only waives the "all subtasks done" condition when the target is a done status; the subtree index uses `varchar_pattern_ops` on PostgreSQL so prefix queries use it under any collation; a restore that re-roots a task announces `reparented`; the app no longer touches a closed panel after an add finishes.
- `Tasks.List` returns only top-level tasks unless `include_subtasks` is set (a proto3 bool defaults to false); the app sets it, and there is no other consumer yet.
- The cycle refusal has its own error title (`SUBTASK_CYCLE`), and Undo after a *promote* delete puts the former children back under the task (best effort: one that has gone or moved elsewhere is left alone).
- Not done: moving a subtree between projects (tasks cannot change project yet), weighting progress by estimate.
- Run on PostgreSQL (tasks, workflows and projects suites, including the parallel-children race, the first-use workflow race, and the migrations on a database that already has tasks); not run in a real browser or on a device.
