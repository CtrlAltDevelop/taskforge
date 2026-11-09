# Phase 08 — Subtasks

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
- [ ] Nest 8 levels; progress rolls up correctly
- [ ] Cycle attempt rejected
- [ ] Re-parent updates paths for the whole subtree
- [ ] Tree list of 5k tasks stays smooth (virtualized)

## Tests
Cycle detection, path rewrite, roll-up correctness under concurrent child updates, delete modes.

## Depends on
Phases 06, 07.
