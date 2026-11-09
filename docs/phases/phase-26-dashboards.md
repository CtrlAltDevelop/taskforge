# Phase 26 — Dashboards and Reports

## Feature
Customizable **dashboards** made of widgets (charts, counters, lists) driven by saved filters.

## Why it exists
Dashboards are locked behind paid tiers or limited in count in both products, and widgets are slow. Ours are free, unlimited, and every number is traceable to the tasks behind it.

## How it works (plain words)
A dashboard is a grid of widgets. A widget has a **data source** (a saved TFQL filter or a built-in metric), a **measure** (count, sum of points/hours, average cycle time) and a **chart type** (number, bar, line, pie, table, burndown, workload). Clicking a chart segment opens the list of tasks behind it (“drill-down”). Dashboards can be personal, project or workspace-wide with sharing. Heavy aggregates are computed in SQL with caching (60 s) and refreshed on demand.

## Scope
**In:** dashboard CRUD, widget types above, drag/resize grid, drill-down, sharing & permissions, auto-refresh, default templates (Project overview, My work), export widget data as CSV.
**Out:** cross-workspace BI, SQL editor, scheduled email reports.

## Data model
- `Dashboard(id, workspace, project nullable, owner, name, visibility, layout jsonb)`
- `Widget(id, dashboard, type, config jsonb)` (config stores filter id, measure, group-by)
- `MetricCache` in Redis (no table).

## API surface
- gRPC: `Dashboards.List/Get/Save/Delete`, `Widgets.Data(widget_id) → series`, `Widgets.Drilldown(widget_id, bucket) → stream Task`
- Cycle time metric computed from status-change history (`TaskHistory` from phase 27 or the change log).

## Flutter UI
Edit mode with draggable/resizable grid, widget picker with live preview, charts via a single shared chart module (consistent colors, light/dark, accessible labels), responsive: stacked column on phones.

## Rules and edge cases
- Data passes through the permission filter: a shared dashboard shows each viewer only what they may see (never cached across users without the permission key).
- Max 20 widgets per dashboard; query timeout 5 s with friendly “too heavy” message.
- Time ranges are workspace-time-zone aware.

## Acceptance criteria
- [ ] Build a dashboard of 6 widget types and share it
- [ ] Drill-down count equals widget number
- [ ] Two users with different access see different numbers on the same dashboard
- [ ] Loads < 2 s with 100k tasks

## Tests
Aggregation correctness fixtures, permission-keyed cache, drill-down parity, chart golden tests.

## Depends on
Phases 14, 22 (burndown), 27 (history).
