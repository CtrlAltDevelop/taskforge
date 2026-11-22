# Phase 26 — Dashboards and Reports

**Status:** DONE

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
- Time ranges are time-zone aware: a workspace has no time zone of its own, so a "day" is the **viewer's** (the app sends `today` and its UTC offset; a fixed offset does not follow a daylight-saving change inside the range).

## Acceptance criteria
- [x] Build a dashboard of 6 widget types and share it
- [x] Drill-down count equals widget number (for the count measure, for every grouping; a list past 5 000 tasks says it was cut short; a sum or an average has no task count to equal)
- [x] Two users with different access see different numbers on the same dashboard
- [x] Loads < 2 s with 100k tasks — six widgets over 100 000 tasks run in about a second on SQLite; **not run on PostgreSQL**

## Tests
Aggregation correctness fixtures, permission-keyed cache, drill-down parity, chart golden tests.

## Depends on
Phases 14, 22 (burndown), 27 (history).

## Built
- Backend: new `dashboards` app (`Dashboard`, `Widget`). Widgets are checked when saved (`config.normalise`): eight types (the eighth, `goals`, shows the viewer's goals at their progress; see phase 34), five measures (count, points, estimated and logged hours, cycle time read from the audit history), nine groupings, a scope (all/open/done), a TFQL source (a saved filter stays a live link, or text). Every query starts from the projects the viewer may open, so a shared dashboard shows each viewer their own numbers; the 60 s cache is keyed by widget version, viewer, day and UTC offset. Every computation runs under the 5 s statement limit (PostgreSQL), reported as `DASHBOARD_TOO_HEAVY`. A drill-down is the same query plus one bucket filter (so its count is the number shown), capped at 5 000 tasks and flagged `truncated`. Limits: 20 widgets, 50 buckets. Personal dashboards need only `workspace.view`; sharing, and changing someone else's shared dashboard, need `dashboard.manage` (Owner, Admin). A change of a dashboard must name the version it changes. Dashboards and widgets are audited.
- gRPC: `DashboardController.List/Get/Save/Delete/FromTemplate`, `WidgetController.Data/Preview/Drilldown(stream)/Export`; in the permission matrix and the audit coverage test.
- App: `features/dashboards` (screen at `/dashboards` and `/projects/:id/dashboards`, a 12-column grid with drag-to-move and drag-to-resize that pushes what it lands on down, stacked on a phone; widget editor with live preview; drill-down list; sharing dialog; CSV copy/save; templates "Project overview" and "My work"; reads again every minute, or on Refresh past the cache) and one shared chart module `core/charts/dashboard_charts.dart` (bars, pie, lines, table, number; one palette in both themes; every chart has a semantics label and buttons for its buckets).
- Chart golden tests are replaced by widget and semantics tests of every chart in both themes (`test/core/charts/dashboard_charts_test.dart`: labels, tappable buckets, palette per brightness); goldens depend on fonts the CI image does not pin. The 60 s auto-refresh has its own widget test (it re-reads, and stops when the screen is left).
- A burndown widget's drill-down lists the open tasks of its sprint in the chart's own project (the widget's total is their remaining points).
- Review fixes: a time axis keeps its newest buckets; a workspace-wide dashboard filed under a private project is for that project's people only; cycle time counts a move made together with another edit and uses the audit table's index; saving as a manager does not re-check the owner's private filter, and an owner whose `dashboard.manage` was taken away can still save without widening who sees it; a bucket the grouping could not have made is a 400; the drill-down is under the time limit; the cache key includes the project; the list resolves the caller's grant once; a filter over 2 000 characters is refused, not cut; the app asks for the day at every read, refreshes only the widget (or the dashboard) you asked about, draws a burndown's whole axis, never lets a card be dragged to nothing, and makes random widget ids.
- Cycle time is averaged in Python over at most 20 000 finished tasks (a sample says `truncated`): the SQL form needs a UUID-to-text cast that differs between SQLite and PostgreSQL and was not verifiable here. The scale test now includes a cycle-time widget.
- Not verified: the statement-timeout path on PostgreSQL (stubbed on SQLite), the timing on PostgreSQL, a real browser or device.

- App: the widget editor's Goals kind hides measure, grouping and the TFQL box, and offers scope and a limit (5, 10, 12, 20); the card draws one bar per goal in percent.
