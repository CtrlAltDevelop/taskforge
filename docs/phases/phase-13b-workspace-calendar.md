# Phase 13b — Workspace Calendar

**Status:** DONE

## Feature
One **calendar across every project** the person can open, with each task coloured by its project.

## Why it exists
Phase 13's calendar shows one project, so it cannot colour by project and cannot answer "what is due this week, everywhere". People who sit across several projects need that on one screen without opening each.

## How it works (plain words)
A workspace-level Calendar screen shows the same month / week / day views as the project calendar, but the tasks come from all projects the viewer may open. A legend names each project's colour; the viewer can colour by project (default), status or priority and hide projects. Dragging a bar or resizing it changes that task's dates exactly as in the project calendar (the task's own project decides whether it is allowed). There is no unscheduled tray: "unscheduled" is per project.

## Scope
**In:** workspace range query across visible projects, month/week/day/agenda reuse, colour by project (+ status/priority), project filter chips, drag to move/resize, link warning, due time display.
**Out:** saved layouts for this screen (it keeps the choice for the session), unscheduled tray, filtering beyond project (14).

## Data model
No new tables.

## API surface
- gRPC: `CalendarController.ListWorkspaceRange(workspace_id, range_start, range_end, include_done, project_ids[]) → stream Task`. Only projects visible to the caller; `project_ids` narrows (an id the caller cannot open is ignored).

## Flutter UI
A "Calendar" entry on the home screen opens `/calendar`. Same layouts as phase 13 (phone agenda, tablet/desktop grid); legend row of project chips that toggle visibility.

## Rules and edge cases
- Tasks of private projects the caller is not in never appear.
- Dates stay date-only; the same warnings as phase 13.
- A refused move (no permission in that project) puts the bar back with the reason.

## Acceptance criteria
- [x] Tasks of every visible project appear, none of a hidden one
- [x] Colour by project with a legend; projects can be hidden
- [x] Drag/resize works per task permission
- [x] Works on phone, tablet and desktop layouts

## Tests
Visibility of private/archived projects, `project_ids` narrowing, cross-project range paging, Flutter legend/colour/drag.

## Depends on
Phases 05, 13.

## As built
- **API**: `CalendarController.ListWorkspaceRange(workspace_id, range_start, range_end, include_done, project_ids[])` — a server stream of the live tasks (subtasks included, with `blockers_due`/`blocks_due`) that fall on the range, across every non-archived project the caller can open. `project_ids` only narrows that set (an id the caller cannot open, or from another workspace, is ignored). Chunks follow the last task id, so nothing is capped or repeated. Needs `workspace.view`; writes stay `TaskController.Update`, so each task's own project decides. `backend/docs/tasks.md` ("The calendar").
- **App**: `/calendar`, opened from a Calendar tile on the home screen. It is the phase 13 `CalendarView` with scope "every project": colour by project (default; a project's own colour, else a palette), status or priority; a legend of project chips that hide/show a project without reading again; no tray. Choices (mode, colour, hidden projects, the month) last while the app runs but are not saved, as there is no project to store a layout under. Opening a task goes to its project's screen with that task's detail.
- Not done: saving this screen's layout; a tray (unscheduled is per project); filtering beyond projects (14); a per-project permission check on the client (a refused move is rolled back with the reason).
