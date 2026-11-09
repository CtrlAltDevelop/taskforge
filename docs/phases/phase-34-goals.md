# Phase 34 — Goals (OKRs)

**Status:** TODO

## Feature
Set **goals** with measurable **key results** that update automatically from tasks or manually.

## Why it exists
ClickUp Goals are useful but limited on free plans; Jira has no native OKRs. Teams want to connect daily tasks to bigger outcomes and see progress without spreadsheets.

## How it works (plain words)
A **Goal** (objective) has an owner, period (e.g. Q1) and a list of **Key Results**. Each key result is one of: **number** (from 0 to target), **percentage**, **true/false**, or **linked tasks** (progress = done tasks / total in a TFQL filter or hand-picked list). Linked key results update live as tasks complete. Goal progress is the average (or weighted) progress of its key results. Goals can be grouped into folders and nested (company → team goals). A check-in note can be added each time progress is updated, making a history trail.

## Scope
**In:** goal CRUD, periods, folders, key results (4 types), auto progress from tasks, manual check-ins with notes, weights, status (on track / at risk / off track — computed hint + manual override), goal list/detail, owner & contributors.
**Out:** scoring methodologies beyond simple weighted average, external data connectors.

## Data model
- `Goal(id, workspace, parent nullable, folder, name, description, owner, period_start, period_end, status_override)`
- `KeyResult(id, goal, name, type, start_value, target_value, current_value, filter_ast nullable, weight)`
- `KeyResultTask(kr, task)`; `CheckIn(kr, user, value, note, at)`

## API surface
- gRPC: `Goals.List/Get/Create/Update/Delete`, `KeyResults.*`, `CheckIns.Add/List`; Progress for linked KRs recomputed on task events (Celery, debounced).
- Event: `goal.progress_changed` (for notifications 19 / dashboards 26).

## Flutter UI
Goals list with progress bars and status chips, detail with key result rows, check-in dialog with sparkline history, task detail shows “Contributes to: Goal › KR”.

## Rules and edge cases
- Progress clamps to 0–100%; decreasing numbers allowed (e.g. reduce bugs from 40 to 10) by start/target direction.
- “At risk” hint compares progress against elapsed time of the period.
- Permission: goal visible to workspace unless private; only owner/admin edits.
- Deleting a linked task doesn’t crash progress (removed from the denominator).

## Acceptance criteria
- [ ] Linked-task KR updates when tasks complete
- [ ] Number KR works for both increase and decrease targets
- [ ] Nested goals roll up
- [ ] Check-in history visible

## Tests
Progress math (both directions, zero denominators), rollup, risk hint, debounce job.

## Depends on
Phases 14, 19; fits with 26 widgets.
