# Phase 10 — Custom Fields

**Status:** DONE

## Feature
Admins define extra **typed fields** (text, number, select, multi-select, date, checkbox, URL, user, money) on a project; tasks store values for them.

## Why it exists
Teams need fields like "Customer", "Story points", "Environment". Jira's custom fields are global and slow the whole site; ClickUp caps them on free plans. Ours are per-project, free and indexed so they stay fast.

## How it works (plain words)
In Project settings → Fields, add a field: pick a type, name, options (for selects), whether required, default. The field appears on task detail, can be a column in List/Table, a filter in queries (phase 14) and a group-by on boards. Values are typed and validated server-side. Deleting a field archives it first (values kept 30 days) so you can undo.

## Scope
**In:** field types above, CRUD, reorder, required/default, options with colors, show/hide per view, validation, archive/restore.
**Out:** formulas/rollups (later), cross-project shared fields (templates in 35 cover reuse).

## Data model
- `FieldDefinition(id, project, name, type, options jsonb, required, default jsonb, position, archived_at)`
- `FieldValue(task, field, value_text, value_number, value_date, value_json)` — typed columns so each can be indexed
- Unique `(task, field)`.

## API surface
- gRPC: `Fields.List/Create/Update/Archive/Restore`, task payload includes `fields` map; `Tasks.Update` accepts `field_values` in the mask.

## Flutter UI
Field editor (type picker, options list with color chips), generic `FieldInput` widget per type (date picker, dropdown, chips…), columns chooser. Required missing values highlight on save.

## Rules and edge cases
- Changing a type is allowed only between compatible types (text↔url); otherwise create a new field.
- Removing a select option asks to remap existing values.
- Numeric precision for money uses decimal strings, never float.
- Max 50 active fields per project (keeps UI/queries healthy).

## Acceptance criteria
- [x] All types create/edit/validate
- [x] Required field blocks task creation with clear errors
- [x] Archive/restore keeps data
- [x] Filtering by a field value uses an index (explain plan checked)

## Tests
Per-type validation, option remap, concurrency on same field, serialization round-trip over proto, Flutter input widgets.

## Depends on
Phase 06.

## As built
- `FieldController` (`List`, `Create`, `Update`, `Reorder`, `Archive`, `Restore`) in a new `customfields` app; `Reorder` is an extra call the editor needs. Definitions are managed with `project.update`, read with `workspace.view`. Each definition has a `version` (stale save: `VERSION_CONFLICT`) and `hidden_views` (the "show in" switches). Full rules: `backend/docs/customfields.md`.
- Values travel as one string per field (money `12.50 USD`, multi-select ids joined by commas, never floats) in `Task.fields`, `TaskCreateRequest.field_values` and `TaskUpdateRequest.field_values`. An edit conflicts per field through `field_versions["field:<id>"]`, so different fields merge. Required fields without a default refuse the create (`FIELD_REQUIRED`, every missing field named); the app asks for them in a dialog and highlights gaps.
- Text and URL values are capped (500 / 2000 ASCII characters) so they fit an index entry. Filtering is `queries.tasks_with_value` (eq, ranges, multi-select `has`); an `EXPLAIN` test on PostgreSQL checks each lookup uses an index (a GIN index serves multi-select).
- Archive keeps values; `manage.py purge_fields` (daily) deletes fields archived more than 30 days.
- Run on PostgreSQL (the whole backend suite, including index plans and a parallel same-field edit race); not run in a real browser or on a device.
- Also fixed on the way: `Profile.fill_blanks` now clips provider values to their columns (PostgreSQL refused an over-long social name), and the status-migration test re-applies every app after rolling tasks back.
- Left to later phases: real list columns and the column chooser (11), group-by and card fields on the board (12), filter UI and query language over fields (14), the `fields_changed` WebSocket event (16).
