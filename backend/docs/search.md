# Search

One search box over tasks, comments, projects and people, always limited to what the caller may open. Always installed. gRPC only (`SearchController`). Phase 20.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `SearchEntry`

The searchable text of one task (title, description) or one comment, folded (see

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `task` | ForeignKey | → `tasks.Task` |
| `kind` | Char |  |
| `ref_id` | UUID |  |
| `title` | Char |  |
| `body` | Text |  |
| `updated_at` | DateTime |  |

#### `SearchHistory`

A query the person chose a result for, newest first, at most ``HISTORY_LIMIT`` each.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `user` | ForeignKey | → `accounts.User` |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `query` | Char |  |
| `at` | DateTime |  |
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

### What is indexed

`SearchEntry` holds one row per live task (title and description text) and per live comment, **folded**: lower-cased, Arabic yeh/kaf mapped to Persian, Arabic-Indic and Persian digits to ASCII, always one character for one character so a match position is the same in the original text. `receivers.py` refreshes it after the commit of any task or comment change, so no reindex job is needed for normal edits; `manage.py reindex [--workspace ID]` rebuilds it after an import or restore (migration 0002 runs it once for existing data). The row has no project, status or assignee: those are read from the live task, so moving a task, renaming a project or a workflow change needs no reindex. Projects and people are not indexed; they are scanned with `icontains` (small tables).

### Matching and ranking

On **PostgreSQL** the migration adds a generated `search_vector` (`simple` config, title weight A, body B) with a GIN index, and a trigram GIN index on the title. A query matches when every word is a prefix in the vector, or (words of 4+ letters) when every word is word-similar to the title (`pg_trgm.word_similarity_threshold` 0.35: "desing" finds "design"). Score = `ts_rank_cd` + title similarity + a recency decay (30 days) + 0.3 when the task is assigned to the caller. Each search runs in a transaction with `statement_timeout` = `SEARCH_TIMEOUT_MS`. On **SQLite** (development, most tests) it is substring matching with no typo tolerance: title hits first, then assigned to you, then newest. Comments are not typo-tolerant on either.

### Permissions

The caller's visible projects (`Project.objects.visible_to`) are a subquery of the search itself, so a page is never short and nothing leaks through counts or cursors; a private project's tasks and comments never reach a non-member, and the id jump obeys the same rule. `workspace.view` is required; people are listed only to callers who hold `member.view`.

### Query text

Words are ANDed. Operators in the text narrow tasks and comments (people and projects are then left out): `in:KEY` (project key, or the start of its name), `assignee:me` (or part of a name or email), `status:open|done|closed` (or a status name). With only operators the answer lists the matching tasks, newest first. Text that is an id (`WEB-12`) also comes back as `jump`. Over 200 characters, an unknown type or a bad cursor is INVALID_ARGUMENT. `SEARCH_RATE_PER_MINUTE` (120, 0 = off) per person: past it RESOURCE_EXHAUSTED (`RATE_LIMITED`).

### gRPC

`Query(workspace_id, text, types[], cursor, page_size)` answers `tasks`, `comments`, `projects`, `members` (each a `Hit` with `title_marks`/`snippet_marks` in UTF-16 units), `jump` (empty `id` when none) and `next_cursor` (an offset valid for every group; ask again with one type to page that group). `Remember(text)` keeps a recent search (call it when a result is opened; at most 20, newest first), `Recent()` lists them. Filters travel as operators in the text, not as a separate field.

### Settings

`DJANGO_SEARCH_RATE_PER_MINUTE`, `DJANGO_SEARCH_TIMEOUT_MS` (2000).

Known limits: the PostgreSQL path and the p95 target have not been run against PostgreSQL or 200k tasks (`tests/test_postgres.py` is skipped without it); docs join the index with phase 23.
