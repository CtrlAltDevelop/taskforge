# Phase 15 — Timeline (Gantt) View

**Status:** TODO

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
- [ ] 2,000 bars + arrows pan/zoom at 60 fps
- [ ] Cascade shift previews and applies atomically
- [ ] Critical path correct on test fixtures
- [ ] Usable on tablet touch

## Tests
Critical-path algorithm, cascade with working-day calendar, layout unit tests, golden image tests.

## Depends on
Phases 08, 09, 13.
