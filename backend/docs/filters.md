# Filters (TFQL)

The text query language **TFQL**, its checker and compiler, and saved filters. Always installed. gRPC only (`QueryController`: `Validate`, `Suggest`; `FilterController`: `List`, `Save`, `Delete`; and a `filter_ast` on the task, board and calendar reads), so it has no REST routes. Phase 14. Code: `infrastructure/filters/` (`tfql.py` the grammar and parser, `language.py` meaning, AST and text, `compile.py` the ORM query, `query.py` what task calls use, `services.py`).

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `SavedFilter`

``ast`` holds field and value *ids* (so a rename never breaks it); the text is rendered from

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project`, nullable |
| `owner` | ForeignKey | → `accounts.User` |
| `name` | Char |  |
| `ast` | JSON |  |
| `visibility` | Char |  |
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

### The language

```
status in (Active, "In review") AND assignee = me AND due < +7d ORDER BY priority DESC
```

- **Conditions** are `field op value`, `field [NOT] IN (v, v…)` and `field IS [NOT] EMPTY`, joined by `AND`, `OR` and `NOT` (`NOT` binds tightest, then `AND`, then `OR`; parentheses group, at most 8 deep). `ORDER BY field [ASC|DESC], …` ends the query. Keywords are case-insensitive; field and value names are too.
- **Operators**: `=` `!=` `~` (contains) `!~` `<` `<=` `>` `>=`, `IN`, `NOT IN`, `IS EMPTY`, `IS NOT EMPTY`. A field takes only the operators that make sense for it.
- **Values**: a bare word (`Active`), a quoted string (`"In review"`, `\"` and `\\` escape), a number, a date `2026-11-05`, a relative date (`+7d`, `-2w`, `+1m`, `+1y`; `today`), `me`, `true`/`false`, `currentSprint()` (a placeholder until sprints exist: nothing is in it yet).
- **Fields**: `title` (text), `status`, `category` (`not_started` `active` `done` `cancelled`), `priority`, `assignee` (a username or `me`), `due`, `start`, `created`, `updated` (the last two compare by UTC day), `blocked` (true/false), `id` (a number, or `"WEB-12"` quoted), `sprint`, and every active custom field of the project by its name (quote a name with spaces: `"Story points" > 3`; a quoted name finds a custom field first, so a field named `status` is `"status"`). A multi-select field's `=` means "has", `IN` "has any of"; a checkbox `= false` also matches a box nobody ever touched.
- **Not equal** (`!=`, `NOT IN`, `!~`) also matches tasks that have no value. Text matches ignore case; `~` is a substring.
- **Limits**: 2,000 characters, depth 8, 50 conditions, 100 values in a list; `ORDER BY` names at most 3 fields, each once; a relative date reaches at most 36,500 days, 5,200 weeks, 1,200 months or 100 years. A filter's JSON that nests absurdly deep is `FILTER_INVALID`, never a crash.

### AST, text and sync

A query is parsed into an **AST** that names fields and values by id (a custom field is `cf:<uuid>`; a status, option or user by id), so a rename never breaks a saved filter; the text is rendered from it with today's names. `Validate` takes TFQL or an AST and answers `ok` with the AST and the normal text, or `errors` with `position` and `length` of what is wrong. An AST from a client is never trusted: it is written as text and read back (an unknown id is an error) and that normal form is what runs. Text → AST → text is lossless for every operator (the tests walk 70+ queries).

### Applying a filter

`Tasks.List`, `Tasks.GroupCounts`, `Board.Get` / `ListColumn` and `Calendar.ListRange` take `filter_ast` (the AST as JSON) and `today` (the viewer's `YYYY-MM-DD`, what relative dates count from; default the server's). The condition is added to the project's own live tasks, so a filter can only narrow what the caller may already see. Its `ORDER BY` orders a list that has no sort of its own. A bad filter is `INVALID_ARGUMENT` `FILTER_INVALID` with `position` and `length` trailers.

### Saved filters

A name (1–60 characters), the AST, and a visibility: `private` (the owner's), `project` (everyone who can open the project; needs `project.update` and an active project) or `workspace` (no project, so only the fields that need none; needs `workspace.update`). Names are unique per place, at most 100 per place, a stale save is `VERSION_CONFLICT`. A listed filter whose field was removed has empty text and is skipped by the app. A workspace-level filter (no project) is read with `Catalogue(None, workspace)`: only the fields that mean the same everywhere (not status, id, sprint or a custom field), people by username; it applies in a project too, and `Calendar.ListWorkspaceRange` takes it as `filter_ast`.

Suggestions (`Suggest`) offer the next field, the operators the field takes, its values (statuses, options, people, `me`, relative dates) and `AND` / `OR` / `ORDER BY`, replacing the word being typed.
