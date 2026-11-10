# Custom fields

Typed, per-project fields (text, number, select, multi-select, date, checkbox, URL, user, money) whose values live on tasks. Always installed. gRPC only (`FieldController`, plus `field_values` on `TaskController.Create` / `Update` and `Task.fields`), so it has no REST routes. Phase 10.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `FieldDefinition`

A typed field a project defines for its tasks.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `project` | ForeignKey | → `projects.Project` |
| `name` | Char |  |
| `type` | Char |  |
| `options` | JSON |  |
| `required` | Boolean |  |
| `default` | Char |  |
| `hidden_views` | JSON |  |
| `position` | PositiveInteger |  |
| `version` | PositiveInteger |  |
| `archived_at` | DateTime | nullable |
| `created_at` | DateTime |  |

#### `FieldValue`

The value one task holds for one field.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `task` | ForeignKey | → `tasks.Task` |
| `field` | ForeignKey | → `customfields.FieldDefinition` |
| `value_text` | Char |  |
| `value_number` | Decimal | nullable |
| `value_date` | Date | nullable |
| `value_json` | JSON | nullable |
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

### Layout

`infrastructure/customfields`: `models.py` (`FieldDefinition`, `FieldValue`), `types.py` (what each type accepts and its wire form; pure), `services.py` (definitions: list, create, update with remap, reorder, archive, restore, purge), `values.py` (task values: validation, required and defaults, saving, reading onto tasks; called by `tasks.services` inside its transaction), `queries.py` (find tasks by a field value), `signals.py`, `grpc/`, `management/commands/purge_fields.py`.

### Definitions

- **Permission**: reading needs `workspace.view` and a visible project; create, edit, reorder, archive and restore need `project.update` (a project's creator holds it for their own project) and a project that is not archived (`PROJECT_ARCHIVED`). Listing archived fields (`include_archived`) needs `project.update` too.
- **Rules**: name 1-60 characters, unique per project ignoring case among active fields (`FIELD_NAME_TAKEN`); at most **50 active fields** (`FIELD_LIMIT`); select types need 1-100 options with distinct labels and `#RRGGBB` or empty colours (option ids are assigned by the server). A definition is edited whole and guarded by its `version` (`VERSION_CONFLICT`).
- **Type changes** are allowed only between `text` and `url` (existing values are re-checked; any that would be invalid refuse the change). Anything else: create a new field.
- **Removing an option** that values still use needs a remap: `OPTION_NEEDS_REMAP` (`FAILED_PRECONDITION`, trailer `x-error-options-bin` = JSON `{option id: number of values}`); resend with `remaps` (removed option -> a kept option, or empty to clear). A multi-select drops or replaces just that option. The default follows the remap. Each changed task counts an edit of that field.
- **Archive** sets `archived_at`; the field disappears from tasks and stops being required, but its values stay. **Restore** brings it back (checked against the name and the 50 limit again) within `RESTORE_DAYS` = 30; `manage.py purge_fields` (run daily) deletes older ones with their values. Archive and restore count an edit on every task holding a value.
- `hidden_views` (`list`, `board`, `calendar`, `timeline`) names the views that do not show the field. The task list reads it today; the other views arrive with their phases.

### Values

A value is one string, its *wire form*: text and url as typed; number and money as decimal strings, never floats (money is `12.50 USD`); select as an option id; multi-select as option ids joined by commas (stored in option order); date `YYYY-MM-DD`; checkbox `true` / `false`; user as a user id (an active workspace member who can open the project). Empty clears it. Limits: text 500 characters, URL 2000 ASCII characters (percent-encoded), number 6 decimal places, money 4, at most 18 integer digits.

Storage uses one indexed column per kind: `value_text` (text, url, select option, user, money currency), `value_number` (number, money amount, checkbox 0/1), `value_date`, `value_json` (multi-select ids; a GIN index on PostgreSQL). `(task, field)` is unique.

- **Create**: `field_values` on `Task.Create`. Defaults fill the fields not sent; a required field with neither a value nor a default refuses the whole create with `FIELD_REQUIRED` (trailer `x-error-fields-bin` = JSON list of every missing field id) and burns no task number.
- **Update**: `field_values` on `Task.Update` change only the fields sent. Clearing a required field is `FIELD_REQUIRED`; a task made before the field became required can still be edited. An edit conflicts **per field**: `Task.field_versions["field:<id>"]`, so different fields merge and the same field is `VERSION_CONFLICT` with `x-error-field-bin` = `field:<id>`.
- **Read**: `Task.fields` lists `{field_id, value}` for the active fields that have a value, on every `Get`, `List`, `ListChildren` and `ListTrash`.
- An unknown, archived or other project's field id is `FIELD_INVALID`.

### Filtering

`queries.tasks_with_value(field, operator, raw)`: `eq` for any type, `gt gte lt lte` for number, money and date, `has` for a multi-select option. Each lookup is a single indexed read of `FieldValue` (an `EXPLAIN` check runs in the PostgreSQL test run). Phase 14's query language builds on it.

### gRPC contract (`config.customfields`)

All requests carry `workspace_id` and `project_id`. `Field{id, project_id, name, type, options[FieldOptionResponse{id, label, color}], required, default, hidden_views[], position, version, archived_at}`; `List(include_archived)` and `Reorder(ids[])` answer `FieldList`; `Create`, `Update` (optional attributes by `HasField`, `set_options` / `set_hidden_views`, `expected_version`, `remaps[OptionRemap{from_option, to_option}]`), `Archive` and `Restore` (both with `expected_version`) answer `Field`. On tasks: `TaskFieldValue{field_id, value}` in `Task.fields`, `TaskCreateRequest.field_values` and `TaskUpdateRequest.field_values`.

Errors as in [projects](projects.md), plus `FIELD_INVALID`, `FIELD_REQUIRED`, `FIELD_NAME_TAKEN`, `FIELD_LIMIT` and `OPTION_NEEDS_REMAP` above. After a change `signals.fields_changed(sender=FieldDefinition, project_id, workspace_id, version)` is sent on commit for phase 16.
