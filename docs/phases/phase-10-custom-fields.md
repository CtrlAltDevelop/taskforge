# Phase 10 — Custom Fields

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
- [ ] All types create/edit/validate
- [ ] Required field blocks task creation with clear errors
- [ ] Archive/restore keeps data
- [ ] Filtering by a field value uses an index (explain plan checked)

## Tests
Per-type validation, option remap, concurrency on same field, serialization round-trip over proto, Flutter input widgets.

## Depends on
Phase 06.
