# Phase 20 — Global Search

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
