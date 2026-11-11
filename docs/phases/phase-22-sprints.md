# Phase 22 — Sprints

**Status:** DONE

## Feature
Agile **sprints** for a project: backlog, sprint planning, start/complete, carry-over and a burndown chart.

## Why it exists
Jira Software’s sprints are the standard but heavy; ClickUp’s are shallow. We keep the useful 20%: a clear backlog, simple planning, honest burndown, and painless carry-over.

## How it works (plain words)
The project has a **Backlog** (tasks not in any sprint). A sprint has a name, goal, start and end. In planning view, drag tasks from the backlog into the sprint (or multi-select and “Add to sprint”); a capacity bar compares estimates (story points or hours) with the team’s capacity. **Start sprint** locks the scope baseline. During the sprint the board (phase 12) shows only its tasks. **Complete sprint** asks what to do with unfinished tasks: *move to next sprint* or *back to backlog*. Burndown is plotted daily from a snapshot taken at midnight (workspace time zone), with an ideal line.

## Scope
**In:** backlog list, sprint CRUD, one active sprint per project, planning drag/drop, estimates (points or hours), start/complete, carry-over, burndown + velocity of last 6 sprints, `currentSprint()` in TFQL.
**Out:** multi-team boards, release trains, cumulative-flow (later via dashboards 26).

## Data model
- `Sprint(id, project, name, goal, start_date, end_date, state: planned|active|completed, started_at, completed_at, capacity_points?, capacity_sec?)`
- `Task.sprint` (nullable FK), `Task.points` (decimal)
- `SprintSnapshot(sprint, date, remaining_points, remaining_tasks, scope_points)`

## API surface
- gRPC: `Sprints.List/Create/Update/Start/Complete`, `Sprints.AddTasks/RemoveTasks`, `Sprints.Burndown`, `Backlog.List`
- Daily snapshots: the management command `manage.py sprint_snapshots`, run by `make tick` (no Celery yet). It must run at least daily (every minute is fine and is what `make tick` does) and it back-fills any day it missed, so a missed midnight is repaired on the next run.

## Flutter UI
Backlog & sprint two-pane planning screen (stacked on mobile), capacity bar, sprint header with days left, burndown and velocity charts (both painted with the app's shared chart helpers in `app/lib/core/charts`: axes and labels; days written late by the back-fill are ringed), complete-sprint dialog. A sprint's capacity (points and/or hours) is kept on the sprint and set in the sprint form or from the capacity bar; with none set the bar uses the average velocity as a guide. The active sprint has a "Show on board" link, and the board has a "Current sprint" chip that adds `sprint = currentSprint()` to the board's filter.

## Rules and edge cases
- Only one active sprint per project; dates cannot overlap with another planned sprint unless warned.
- Scope added after start is marked and shown as a step in the burndown.
- Completing counts only tasks in *Done* category (phase 07) as finished.
- The baseline fixed at start counts only the tasks that are open then; tasks already Done are left out.
- Project feature toggle “Sprints” controls visibility.

## Acceptance criteria
- [ ] Plan → start → move cards → complete with carry-over works end-to-end
- [ ] Burndown matches hand-computed fixture including mid-sprint scope change
- [ ] Velocity chart shows last sprints
- [ ] Missed midnight snapshot is back-filled

## Tests
State machine, snapshot job + backfill, carry-over, TFQL placeholder, chart data builder.

## Depends on
Phases 07, 12, 14.
