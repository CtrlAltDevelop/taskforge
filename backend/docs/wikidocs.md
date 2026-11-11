# Docs

A wiki: nested pages of blocks, task embeds, backlinks, revisions, export.

The app label is `wikidocs` (the word `docs` is taken by the project's documentation tooling), so
its tables are `wikidocs_*` and its gRPC file is `wikidocs.proto`. Pages live in the workspace or in
one project and form a tree (at most ten levels). A page body is a versioned list of blocks (schema
version 1) that every save checks and rebuilds: unknown block types are kept untouched, text is only
ever text, links must be http, https or mailto. Saves are optimistic: the editor sends the version it
loaded and a stale save is refused with `VERSION_CONFLICT`, carrying the server's version and (when
small) its blocks so the client can offer a merge. Revisions are one per burst of editing (five
minutes, per author) and only the newest `DOCS_REVISION_KEEP` (default 50) are kept.

Who may open a page: `workspace.view`, plus the project's visibility for a project page, plus the
page's own restriction. A restricted page is open to its creator, the people listed on it and
holders of `doc.manage`; the restriction applies to every page below it as well. Anything a caller
may not open is a 404, in every call and in search. Changing pages needs `doc.edit`; restricting
them needs `doc.manage`. Task cards in a body are resolved per viewer: a task the viewer cannot open
comes back as a hidden card, and the card stays in the body so a save never drops it. `[[` mentions
and task cards become link rows on every save, which is what backlinks and a task's related docs
read. Changes are announced as `doc.created`, `doc.updated` and `doc.moved` live-sync events (ids
and a version only), and a page's "editing now" roster uses the same presence store as tasks.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Doc`

A page. ``project`` is empty for a workspace-level page; a page and all its ancestors are in

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project`, nullable |
| `parent` | ForeignKey | → `wikidocs.Doc`, nullable |
| `title` | Char |  |
| `icon` | Char |  |
| `position` | PositiveInteger |  |
| `restricted` | Boolean |  |
| `created_by` | ForeignKey | → `accounts.User` |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |
| `archived_at` | DateTime | nullable |

#### `DocAccess`

A person allowed into a restricted page (and so its subpages).

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `doc` | ForeignKey | → `wikidocs.Doc` |
| `user` | ForeignKey | → `accounts.User` |

#### `DocContent`

The body: ``blocks`` (a JSON list, ``schema_version`` says how to read it). ``version`` is

| Field | Type | Notes |
| --- | --- | --- |
| `doc` | OneToOne | primary key, → `wikidocs.Doc` |
| `blocks` | JSON |  |
| `schema_version` | PositiveSmallInteger |  |
| `version` | PositiveInteger |  |
| `updated_by` | ForeignKey | → `accounts.User`, nullable |
| `updated_at` | DateTime |  |

#### `DocLink`

What a page points at. ``mention`` and ``task_card`` rows are rebuilt from the body on every

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `doc` | ForeignKey | → `wikidocs.Doc` |
| `kind` | Char |  |
| `task` | ForeignKey | → `tasks.Task`, nullable |
| `target_doc` | ForeignKey | → `wikidocs.Doc`, nullable |

#### `DocRevision`

A snapshot. Saves by one person within ``REVISION_WINDOW`` of a revision's start fold into

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `doc` | ForeignKey | → `wikidocs.Doc` |
| `title` | Char |  |
| `blocks` | JSON |  |
| `schema_version` | PositiveSmallInteger |  |
| `version` | PositiveInteger |  |
| `author` | ForeignKey | → `accounts.User`, nullable |
| `at` | DateTime |  |
| `saved_at` | DateTime |  |
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
