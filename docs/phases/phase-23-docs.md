# Phase 23 — Docs (Wiki)

**Status:** DONE

## Feature
A built-in **docs** space: nested pages with a rich-text block editor, links to tasks, and page history.

## Why it exists
ClickUp Docs and Jira’s Confluence are separate, paid-ish and disconnected. Teams want specs and notes beside the work. Ours shares the task editor format, so a doc can embed live task references.

## How it works (plain words)
Each workspace (or project) has a doc tree: pages with child pages. A page is made of **blocks** — paragraph, headings, bullet/numbered/checklist, quote, code, table, divider, image, callout, and **task card** (typing `/task` or pasting a task URL shows a live card with status). Saving is automatic. Every save of meaningful change creates a **revision** you can browse and restore. Pages can be linked from tasks (“Related docs”) and mention other pages with `[[`. Permissions inherit from workspace/project and can be restricted per page.

## Scope
**In:** page tree, block editor, slash menu, task embeds, backlinks, revisions + restore, page permissions (inherit/restricted), search integration, export to Markdown.
**Out:** simultaneous multi-cursor co-editing (first version: last-writer with section-level merge and an “X is editing” lock hint; CRDT upgrade later), comments inline (reuse 17 later).

## Data model
- `Doc(id, workspace, project nullable, parent, title, icon, position, restricted, created_by, archived_at)`
- `DocContent(doc, blocks jsonb, version, updated_by, updated_at)`
- `DocRevision(doc, blocks, author, at)`; `DocLink(doc, task nullable, target_doc nullable)`

## API surface
- gRPC: `Docs.Tree`, `Get`, `Create`, `Update(expected_version)`, `Move`, `Archive`, `Revisions.List/Restore`, `Backlinks`
- WS: `doc.updated`, presence for “editing now”.

## Flutter UI
Left page tree with drag reorder, editor with floating toolbar & slash menu (works with touch and hardware keyboards), revision drawer, breadcrumb, share/restrict dialog. Uses a Flutter rich-text editor package (e.g. `appflowy_editor` or `super_editor`) — selection spike is the first task of the phase.

## Editor decision
Chosen: a **small in-house block editor** (`app/lib/features/docs/presentation/`). Nothing is converted: the server's blocks JSON is the model (`DocBlock` wraps the JSON object; edits make changed copies).

Spike (Flutter 3.47.9 / Dart 3.13.7, checked with `flutter pub add --dry-run`):
- `appflowy_editor` resolves but changes 30 dependencies (downgrades `xml`, adds `rich_clipboard_*` native plugins to every platform registrant). Its document tree needs a two-way converter to our schema; callout, task card and unknown blocks would be custom node builders, and unknown blocks only survive if the converter stores them.
- `super_editor` resolves only as the pre-release `0.3.0-dev.52` and pulls 46 changes including the `test` package. Same converter and custom-component work; touch toolbars and handles are still in flux.
- In-house: no new dependency or plugin. All block types, the `/` menu, the `[[` page picker, the floating toolbar, Markdown shortcuts and hardware shortcuts are plain Flutter text fields, so touch and keyboard both work. Unknown blocks, unknown inline nodes and unknown marks are kept as they came (only edited blocks are re-serialised). Merge and conflict work on block ids with no converter in between.
- Accepted trade-offs: no selection across blocks; marks apply to a selection inside one block. Real co-editing (CRDT) stays a later phase.

## Rules and edge cases
- Autosave debounced (1–2 s); version conflict opens a merge dialog.
- Block schema versioned for future migrations; unknown blocks render as placeholders, never dropped.
- Revisions throttled (one per 5 min of continuous edits) and pruned after N.
- Embedded task cards obey the viewer’s permissions (hidden if no access).

## Acceptance criteria
- [ ] Create nested pages, edit with all block types, reload shows identical content
- [ ] Restore an older revision
- [ ] Task embed shows live status and updates via realtime
- [ ] Markdown export round-trips basic blocks

## Tests
Block schema validation, revision throttle, embed permissions, editor widget tests, conflict flow.

## Depends on
Phases 06, 16, 20.
