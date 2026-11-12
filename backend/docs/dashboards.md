# Dashboards

Dashboards of chart widgets driven by TFQL filters, with drill-down to the tasks.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Dashboard`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project`, nullable |
| `owner` | ForeignKey | → `accounts.User` |
| `name` | Char |  |
| `visibility` | Char |  |
| `layout` | JSON |  |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |

#### `Widget`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `dashboard` | ForeignKey | → `dashboards.Dashboard` |
| `type` | Char |  |
| `title` | Char |  |
| `config` | JSON |  |
| `position` | PositiveSmallInteger |  |
| `version` | PositiveInteger |  |
<!-- /generated:models -->

## Admin

<!-- generated:admin -->
_This app registers nothing in the admin._
<!-- /generated:admin -->

## Setup

<!-- generated:settings -->
_This app requires no settings of its own._
<!-- /generated:settings -->

## Usage

- **Shape**: a `Dashboard` (name, visibility, a 12-column `layout`) holds up to 20 `Widget`s. A widget is a `type` (`number`, `bar`, `line`, `pie`, `table`, `burndown`, `workload`) and a `config`, checked when saved (`config.normalise`): the data source (a saved filter, live, or TFQL text), a `measure` (`count`, `points`, `estimate_hours`, `logged_hours`, `cycle_days`), a grouping (`status`, `category`, `assignee`, `priority`, `project`, `sprint`, `created_day`, `created_week`, `due_week`), a `scope` (all, open, done), and the bucket `limit` / `range_days`.
- **Who sees what**: `personal` (the owner), `project` (whoever can open the project), `workspace` (every member). Sharing and changing someone else's shared dashboard need `dashboard.manage` (Owner, Admin); anyone with `workspace.view` makes personal ones. A dashboard you may not open is a 404.
- **Per-viewer numbers**: every query starts from the open projects and the private ones the viewer belongs to, so one shared dashboard shows each viewer their own numbers. The 60-second cache is keyed by widget version, **viewer**, day and UTC offset, so one person's number is never served to another; `Widget.Data(refresh)` drops it.
- **Days**: `today` and `utc_offset_minutes` come from the caller; buckets of days and weeks, and relative dates in a filter, count from them.
- **Drill-down**: `Widget.Drilldown(widget_id, bucket)` streams the tasks of exactly that bucket (or of the whole number with an empty bucket): the same query plus one filter, so its count is the number shown.
- **Cycle time** is the average days from creation to the last move into a done status, read from the audit history (`task.status_changed`, phase 27). A task finished without a recorded move is left out; more than 20 000 finished tasks are read as 20 000 and the widget says `truncated`.
- **Limits**: every widget runs under the 5 s statement limit on PostgreSQL (`DASHBOARD_TOO_HEAVY`); a drill-down returns at most 5 000 tasks and says `truncated` past that; a change of a dashboard must send `expected_version`.
- **Templates**: `Dashboard.FromTemplate` makes a personal dashboard of six widgets: `project_overview` (needs a project) or `my_work` (`assignee = me`).
- **Export**: `Widget.Export` gives a widget's buckets or series as CSV (cells that start `= + - @` are quoted).
