# Phase 20 — Global Search

**Status:** DONE

## Feature
One search box that finds **tasks, comments, projects, people and docs** quickly, respecting permissions.

## Why it exists
Finding things is where Jira feels slowest and ClickUp’s results are often irrelevant. Search must be instant, typo-tolerant, and never show things you can’t access.

## How it works (plain words)
Typing in the search box sends a debounced request. The server uses PostgreSQL full-text search (`tsvector` + GIN index, with trigram `pg_trgm` for typos and partial words) — no extra service needed. Results are grouped by type with highlighted snippets, ranked by match quality, recency and whether you’re assigned. Typing an id like `WEB-12` jumps straight to that task. Operators such as `in:project`, `assignee:me`, `status:open` combine with text.

## Scope
**In:** index tasks (title, description text, display id), comments, projects, members, docs (when 23 exists); ranking; highlight; id jump; recent searches; filter chips; permission filtering.
**Out:** attachment content search, semantic/AI search, separate engines (Elasticsearch) — revisit only if scale demands.

## Data model
- `search_vector` columns (generated) on Task/Comment/Project/Doc with GIN indexes; trigram indexes on titles.
- `SearchHistory(user, query, at)` capped to 20.

## API surface
- gRPC: `Search.Query(text, types[], filters, cursor)`, `Search.Recent`
- Updating vectors via DB generated columns or triggers, so no reindex job is needed for normal edits; `manage.py reindex` for bulk.

## Flutter UI
Search overlay (shortcut `/` or `Cmd/Ctrl+K` integration with phase 25), grouped results, keyboard up/down/Enter, empty state with tips, debounce 200 ms with request cancellation.

## Rules and edge cases
- Permission filter applied in SQL (join to accessible projects), not after the fact — otherwise pagination leaks counts.
- Languages: use `simple` config + trigram so Persian/Arabic/Latin all work; per-language stemming optional.
- Strip rich-text markup before indexing.
- Rate limit queries per user.

## Acceptance criteria
- [ ] p95 < 150 ms on 200k tasks
- [ ] Typos (“desing”) still find “design”
- [ ] Private project content never appears for non-members
- [ ] Persian and English content both searchable

## Tests
Ranking fixtures, permission matrix, id-jump, RTL text queries, EXPLAIN uses indexes.

## Depends on
Phases 05, 06, 17.

## Contract (as built)
New backend app `infrastructure.search` (gRPC package `config.search`, stubs in `app/lib/gen/infrastructure/search/grpc/`). Full description: `backend/docs/search.md`.

| RPC | Request | Answer |
|---|---|---|
| `SearchController.Query` | `workspace_id`, `text`, `types[]` (task, comment, project, member; none = all), `cursor`, `page_size` (default 8, max 50) | `SearchResults{tasks, comments, projects, members, jump, next_cursor}`; each `Hit` carries `title_marks`/`snippet_marks` (UTF-16 spans) |
| `SearchController.Remember` | `workspace_id`, `text` | `{ok}`: keeps a recent search (call when a result is opened) |
| `SearchController.Recent` | `workspace_id` | `{queries[]}`, newest first, at most 20 |

Built differently from the plan:
- **Filters are operators in the text** (`in:KEY`, `assignee:me`, `status:open|done|closed|<name>`), not a separate `filters` field; the filter chips add and remove them. With an operator, people and projects are left out.
- **One index table for tasks and comments** (`SearchEntry`, folded text, kept current by the task/comment change signals; `manage.py reindex` for bulk) instead of generated columns on each model: task descriptions are JSON rich text, so the text has to be extracted in Python. The PostgreSQL `search_vector` (generated column, GIN) and the title trigram index sit on that table. Projects and people are scanned with `icontains` (small tables); people need `member.view`.
- **Persian/Arabic:** the `simple` config plus a one-character-for-one-character fold (Arabic yeh/kaf, digits).
- **Cursor** is an offset, the same for every group; ask again with one type to page that group.
- **Request cancellation:** the app waits 200 ms after typing stops and drops any answer a newer question has overtaken; the in-flight gRPC call itself is not cancelled.
- **Rate limit:** `SEARCH_RATE_PER_MINUTE` (120) per person, counted in Django's cache (per process unless the cache is Redis).
- **Hotkeys:** `/` (not while typing in a field) and Ctrl/Cmd+K; a Search row in the sidebar. Phase 25's command palette can reuse the overlay.
- **Not verified here:** no PostgreSQL was available, so typo tolerance, index use (`tests/test_postgres.py`, skipped on SQLite) and the p95 < 150 ms target on 200k tasks were reasoned, not measured. On SQLite search is substring-only. Run `DJANGO_DB_ENGINE=django.db.backends.postgresql` before relying on them.
- Docs search joins the index in phase 23.
