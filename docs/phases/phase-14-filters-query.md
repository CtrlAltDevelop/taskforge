# Phase 14 — Saved Filters and Query Language

**Status:** DONE

## Feature
A **visual filter builder** that compiles to a readable **text query language (TFQL)**, with saved, shareable filters usable in every view.

## Why it exists
Jira's JQL is powerful but intimidating; ClickUp's filters are easy but limited. We give both sides: click to build, or type for power — and they stay in sync.

## How it works (plain words)
A filter is a tree of conditions: `status in (Active) AND assignee = me AND due < +7d ORDER BY priority DESC`. The builder UI makes rows (field, operator, value) joined by AND/OR groups. Switching to "text mode" shows the same filter as TFQL; edits parse back to the builder or show a precise error with position. The server parses TFQL into an AST, validates it against the project's fields, then turns it into a safe ORM query (never string-concatenated SQL). Saved filters have a name, owner, and sharing (private/project/workspace).

## Scope
**In:** grammar, parser, AST validator, compile to ORM, fields: built-ins + custom fields, operators (=, !=, in, ~ contains, <, >, is empty, relative dates, `me`, `currentSprint()` placeholder), ORDER BY, saved filters CRUD, apply to List/Board/Calendar, autocomplete suggestions.
**Out:** cross-workspace queries, aggregate functions (dashboards phase 26 add their own).

## Data model
- `SavedFilter(id, workspace, project nullable, owner, name, tfql text, ast jsonb, visibility)`
- Views reference a filter id or inline AST.

## API surface
- gRPC: `Query.Validate(tfql) → ast | errors[position]`, `Query.Suggest(partial, cursor)`, `Filters.List/Save/Delete`; `Tasks.List` accepts `filter_ast`.

## Flutter UI
Filter bar with chips, "Advanced" toggle to a code editor with syntax highlighting and inline errors, saved filters dropdown. Same widget in all views.

## Rules and edge cases
- Parser uses a real grammar (e.g. Lark), with query depth/length limits to prevent abuse.
- Result is always intersected with what the user may see (permissions) — filters can't reveal private projects.
- Field renames don't break saved filters (AST stores field ids, text is re-rendered).
- Timeout guard on heavy queries (statement_timeout).

## Acceptance criteria
- [x] Builder ⇄ text round-trip is lossless for all supported operators
- [x] Invalid query gives position-accurate message
- [x] Injection attempts (quotes, SQL fragments) are inert
- [x] Same filter works in list, board and calendar

## Tests
Grammar table tests (100+ cases), round-trip property test, permission intersection, performance with indexes.

## Depends on
Phases 10, 11.

## As built
- **Language**: TFQL as in the spec (`backend/docs/filters.md` has the full reference): `=` `!=` `~` `!~` `<` `<=` `>` `>=`, `IN` / `NOT IN`, `IS [NOT] EMPTY`, `AND` / `OR` / `NOT` with parentheses, `ORDER BY` (at most 3 fields, once each), `me`, `today` and relative dates (`+7d`, `-2w`, `+1m`, `+1y`, up to about a century), `currentSprint()` (a placeholder that matches nothing until sprints, phase 22). Fields: title, status, category, priority, assignee, due, start, created, updated, blocked, id, sprint and every custom field. The parser is hand-written (positions, limits: 2,000 characters, depth 8, 50 conditions, 100 list values) instead of Lark, so there is no new dependency.
- **AST and text**: the AST names fields and values by id, so renames never break a saved filter; the text is rendered from it. A client's AST is never trusted: it is written as text and read back (`canonical`). `SavedFilter` therefore stores the AST only (`tfql` is rendered on read).
- **API**: `QueryController` (`Validate` answers in-band with `position`/`length`; `Suggest` offers fields, operators, values, keywords) and `FilterController` (`List`, `Save`, `Delete`) in a new `filters` app. `filter_ast` (+ the viewer's `today`) is taken by `Tasks.List`, `Tasks.GroupCounts`, `Board.Get` / `ListColumn` and `Calendar.ListRange`; the filter is added to the project's own live tasks, so it only narrows what the caller can already see, and its ORDER BY orders a list that has no sort of its own. Views do not store a filter id: the app sends the AST. On PostgreSQL a filtered read runs under `SET LOCAL statement_timeout` (5 s) and answers "narrow it down"; that path is unit tested with a faked error but was not run on PostgreSQL.
- **Saved filters**: private (owner), project (needs `project.update`, an active project) or workspace (no project, only the fields that need none, needs `workspace.update`; there is no screen to create one). Names unique per place, 100 per place, versioned saves.
- **Flutter**: a filter bar over the list, board and calendar (one active filter per project, kept while it is open): a Filter button opens the editor with a **Builder** (groups of conditions joined by All/Any, NOT, field/operator/value rows by field type, ORDER BY) and an **Advanced** text editor (highlighting, the server's problems underlined with their message, tap-to-insert suggestions). The two stay in sync through the server (`Validate`). A saved-filters menu, "Save as…" (private, or for the project with `project.update`) and a manage dialog. A filtered list is flat.
- **Kept filter**: the person's filter on a project is stored like a layout (a personal `SavedView` of kind `filter`: the AST and the saved filter it is). It is read when the project opens, read again through `Validate` (a filter whose field has been removed is dropped; the chip text follows today's names), and saved a moment after every change, so it is there on the next visit and on another device; the list, board and calendar wait for it, so their first read is already filtered.
- **Across projects**: the workspace calendar takes a filter too (`Calendar.ListWorkspaceRange` with `filter_ast`), built from the fields that mean the same in every project: title, status category, priority, assignee, due, start, created, updated, blocked (no status, task number, sprint or custom field). The same filter bar edits it; its filter lasts for the session. "Save as…" there keeps a filter private, or for the whole workspace with `workspace.update`; such a workspace-level filter is listed (and applies) in every project.
- Not done / not verified: PostgreSQL (the statement timeout, GIN lookups for multi-select) and a real browser/device were not run.
