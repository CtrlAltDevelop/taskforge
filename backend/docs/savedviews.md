# Saved views

Saved layouts of a project's list view (columns, widths, sort, grouping), personal or shared with the whole project. Always installed. gRPC only (`ViewController`: `List`, `Save`, `Delete`), so it has no REST routes. Phase 11; later view types reuse it through `kind`.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `SavedView`

``owner`` set: a personal layout only that person sees. ``owner`` empty and ``is_shared``:

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project` |
| `owner` | ForeignKey | → `accounts.User`, nullable |
| `kind` | Char |  |
| `name` | Char |  |
| `config` | JSON |  |
| `is_shared` | Boolean |  |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |
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

- **Who**: anyone who can open the project keeps personal layouts there, read-only roles and archived projects included (a layout is a preference, not an edit). A **shared** layout has no owner and needs `project.update` and an active project, to save and to delete.
- **Saving**: a new layout, or `view_id` plus `expected_version` (stale: `VERSION_CONFLICT` with the current `version`). A name is 1–60 characters and unique per owner and kind; a project keeps at most 50 layouts of one kind in one place (`VIEW_NAME_TAKEN`, `VIEW_LIMIT`). A personal layout becomes shared by saving it with `shared`; it cannot go back.
- **Kinds**: `list` (columns, widths, sort, `group_by`) and `board` (`group_by`, `swimlane`, `card_fields`, `limits` — a work-in-progress limit per column key; `config.clean_board`). A board layout travels as `BoardLayout` in `ViewSaveRequest.board` / `SavedView.board`; the app saves the person's own under the same fixed name as its list layout (a name is unique per kind).
- **Config**: `columns`, `widths`, `sort`, `group_by`, validated by `config.clean`; unknown keys or values are refused (`VIEW_INVALID`), not dropped. A custom field the layout names may be archived later; the task list then ignores that sort or group (see [tasks](tasks.md)).
- The app saves the person's own layout under a fixed name a moment after each change, and reads it back on any device.
