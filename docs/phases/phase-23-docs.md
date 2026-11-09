# Phase 23 — Docs (Wiki)

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
