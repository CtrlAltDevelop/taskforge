# Phase 14 — Saved Filters and Query Language

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
- [ ] Builder ⇄ text round-trip is lossless for all supported operators
- [ ] Invalid query gives position-accurate message
- [ ] Injection attempts (quotes, SQL fragments) are inert
- [ ] Same filter works in list, board and calendar

## Tests
Grammar table tests (100+ cases), round-trip property test, permission intersection, performance with indexes.

## Depends on
Phases 10, 11.
