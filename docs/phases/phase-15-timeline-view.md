# Phase 15 — Timeline (Gantt) View

**Status:** DONE

## Feature
A **timeline** showing tasks as bars on a time axis with dependency arrows, drag-to-reschedule, and critical-path highlighting.

## Why it exists
Jira's timeline/roadmap sits behind higher tiers; ClickUp's Gantt is slow with many tasks and hard on touch. Ours is canvas-rendered for speed and free.

## How it works (plain words)
Rows are tasks (tree-aware from phase 08) or grouped by assignee; the horizontal axis is time (day/week/month/quarter zoom). A bar spans start→due. Dragging moves it; dragging an edge resizes. Arrows show blocking links (09). If you move a blocker later than its dependent starts, the app offers **Shift dependents** (cascade) or **Keep** (show conflict in red). The **critical path** (longest chain of dependent tasks) is highlighted on request.

## Scope
**In:** zoom levels, bars, milestones (zero-length tasks), dependency arrows, drag/resize, cascade shift, critical path, today line, group by assignee/status, export as image.
**Out:** resource leveling (36), baselines (later).

## Data model
No new tables; uses task dates + links. `SavedView(kind='timeline')` stores zoom/grouping. Optional `Task.is_milestone`.

## API surface
- gRPC: `Timeline.Get(range, view) → tasks + links (stream)`, `Timeline.PreviewShift(task, new_dates) → affected[]`, `Timeline.ApplyShift(...)` (single transaction).

## Flutter UI
CustomPainter/Canvas-based chart with horizontal and vertical virtualization, left tree panel synced to scroll, touch pinch to zoom, mouse wheel + modifier to zoom. Tooltips with dates; accessibility list fallback.

## Rules and edge cases
- Cascade preview is computed server-side (source of truth) and shown before applying.
- Weekends/holidays: working-day calendar option per workspace (skips non-working days in cascade).
- Tasks without dates sit in an "unscheduled" lane.
- Cycles cannot exist (09), but data errors must not crash the layout engine.

## Acceptance criteria
- [x] 2,000 bars + arrows pan/zoom at 60 fps (a frame paints only the viewport; a unit test paints 2,000 bars and arrows well inside a frame budget; frame rate on a real device was not measured)
- [x] Cascade shift previews and applies atomically
- [x] Critical path correct on test fixtures
- [x] Usable on tablet touch (long-press drag, pinch, list fallback; tested with touch pointers on a tablet-sized screen)

## Tests
Critical-path algorithm, cascade with working-day calendar, layout unit tests, golden image tests.

## Depends on
Phases 08, 09, 13.

## As built
- **Milestone** is a task with exactly one date (a point, drawn as a diamond); a task whose start equals its due date is a one-day bar. No `is_milestone` column.
- **API** (`TimelineController`, reference in `backend/docs/tasks.md`): `Get` (tasks and links, streamed, up to 1,100 days), `PreviewShift`, `ApplyShift` (one transaction, refused as `ABORTED` when the cascade is not the one previewed), plus `CriticalPath` and `GetWorkingDays` / `SetWorkingDays`. The scheduling rules are in `schedule.py`, free of the database.
- **Working days** are the one new table (`WorkingCalendarSetting`: weekdays and holidays per workspace), because nothing stored workspace settings; editing needs `workspace.update` (a dialog on the timeline). A cascade skips days off.
- **Cascade scope**: dependents through any chain, in projects the caller can open and that are not archived; finished tasks stay put. "Keep" moves only the task and the broken link shows in red.
- **Flutter**: a canvas painter that draws only the viewport (rows by scroll offset, bars by clip), a left name panel scrolled in step, drag to move and drag an end to resize (mouse and pen at once; touch after a long press, so a drag still scrolls), Ctrl/Cmd + wheel and pinch to zoom, a today line, shaded days off, arrows (red when a link is broken, also red for the critical path), grouping by assignee (a task with several assignees sits under its first) or status, "Hide done", export as a PNG (cut at 8,000 px a side), and a plain list for screen readers and phones. The date tooltip is a line under the chart (hover or drag shows the task and dates). Unscheduled tasks open in the same tray as the calendar's ("Unscheduled" button), scheduled with a date picker.
- Not verified: frame rate on a real device (profile mode) and a real browser; PostgreSQL (the project lock order is a no-op on SQLite).
