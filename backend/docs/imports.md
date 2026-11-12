# Import and export

Bring projects in from Jira, ClickUp or CSV, undo an import, and export everything as open files.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/exports/download` | None | The export zip, with a signed token |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `ExportJob`

An export being built (or built): a project, or every project the person can open.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project`, nullable |
| `scope` | Char |  |
| `status` | Char |  |
| `file_key` | Char |  |
| `file_size` | BigInteger |  |
| `filename` | Char |  |
| `stats` | JSON |  |
| `error` | Char |  |
| `created_by` | ForeignKey | → `accounts.User` |
| `created_at` | DateTime |  |
| `finished_at` | DateTime | nullable |

#### `ImportJob`

One import. ``mapping`` is what the person chose (see ``mapping.py``), ``analysis`` what the

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project`, nullable |
| `source` | Char |  |
| `status` | Char |  |
| `filename` | Char |  |
| `file_key` | Char |  |
| `file_size` | BigInteger |  |
| `member` | Char |  |
| `mapping` | JSON |  |
| `analysis` | JSON |  |
| `stats` | JSON |  |
| `error_report` | JSON |  |
| `error` | Char |  |
| `phase` | Char |  |
| `total` | PositiveInteger |  |
| `done` | PositiveInteger |  |
| `attempts` | PositiveSmallInteger |  |
| `created_by` | ForeignKey | → `accounts.User` |
| `created_at` | DateTime |  |
| `started_at` | DateTime | nullable |
| `finished_at` | DateTime | nullable |
| `heartbeat_at` | DateTime | nullable |
| `run_token` | UUID | nullable |
| `version` | PositiveInteger |  |

#### `ImportedRef`

That source entity ``source_id`` of ``entity_type`` became (or is) row ``entity_id``.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `job` | ForeignKey | → `imports.ImportJob` |
| `family` | Char |  |
| `entity_type` | Char |  |
| `source_id` | Char |  |
| `entity_id` | UUID |  |
| `meta` | JSON |  |

#### `PlaceholderAssignment`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `task` | ForeignKey | → `tasks.Task` |
| `placeholder` | ForeignKey | → `imports.PlaceholderUser` |

#### `PlaceholderUser`

Someone a file names who is not (yet) a member. Their tasks wait on ``PlaceholderAssignment``

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `key` | Char |  |
| `name` | Char |  |
| `source_email` | Char |  |
| `claimed_by` | ForeignKey | → `accounts.User`, nullable |
| `created_at` | DateTime |  |
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

- **Who**: everything needs `data.manage` (Owner, Admin). A job belongs to one workspace; an id from another is a 404. The target of an import must be a project the importer can open (a private project they are not in is refused); an export holds only the projects the exporter can open, and its download link stops working when the exporter loses the right.
- **Flow**: `POST /imports/upload` (multipart, `workspace_id`, `file`, optional `source`) stores the file and detects its source (a zip is opened and its one `.csv`/`.json` used, or its one `tasks.json` when a TaskForge project export holds that beside its spreadsheet; a workspace export holds one per project, and `Analyze` then asks for `member`). gRPC `Import.Analyze` reads it once and proposes the mapping; `DryRun` shows counts and warnings; `Start` runs it in a background thread (no Celery yet: `imports_tick` in `make tick` resumes a run whose process died); `Progress` streams; `Cancel`; `Undo`.
- **Sources**: Jira CSV and JSON (issues, sub-tasks and epics, sprints, comments, links, labels, story points, attachment manifest), ClickUp CSV and JSON (tasks, sub-tasks, assignees, tags, comments, dependencies), any CSV (every column mapped by hand) and TaskForge's own export. Parsers are streams (constant memory); a bad row is a problem in the report, never fatal.
- **Mapping**: `target` (a project, or a name and key for a new one), `columns` (CSV), `statuses` (to a project status or `new`, made when missing), `priorities`, `users` (a member, `placeholder` or `skip`; matched by email or sign-in name), `labels` (a multi-select field `Labels`, at most 100 options).
- **What a run does**: statuses, fields, sprints and placeholders are made first; tasks are made level by level (parents before children) in chunks of 200, each chunk one transaction with its `ImportedRef` rows, using bulk inserts, so a run stopped anywhere leaves whole chunks and starting it again skips what is there. Source dates and authors are kept (an author who is not a member becomes the importer, named in the text of a comment). Text is converted from HTML, Jira markup, Markdown or Atlassian documents to our rich text; scripts and non-http(s)/mailto links are dropped. Sprints that are closed import as completed, the rest as planned. Blocking links that would form a loop are skipped with a warning. Tasks are numbered level by level, not in file order.
- **One run owns a job**: starting sets a `run_token`; every chunk and every thousand rows read beat the heartbeat under that token, so a tick never takes a live run for dead, and a run that lost its job stops without writing. A clash on a task's ref rolls its chunk back instead of leaving a task without one.
- **Idempotent**: `ImportedRef` is unique per `(workspace, source family, entity type, source id)`, so the same issue is never imported twice into a workspace, from any file. An issue that appears twice in a file keeps the first.
- **Undo**: removes the tasks, comments, links, sprints, labels field, statuses, placeholders (and a project the import made) that the job created. A task a person has worked on since (a sub-task, a comment, a file, logged time) is kept with the chain above it, a sprint or field somebody used stays, and the answer says how many tasks were kept.
- **People**: a person who is not a member becomes a `PlaceholderUser`; their tasks wait in `PlaceholderAssignment` and pass to them when they join with the same email, or when an admin claims it (`ClaimPlaceholder`).
- **History**: every imported task has a `task.imported` audit line (shown in its Activity) with the source, the original key, who wrote it there and when; a task whose reporter is not a member keeps the importer as its author and the line names the reporter. Tasks made into a running sprint are scope changes on its burndown. Parents are only taken from the same project; a parent chain deeper than 24 levels or a loop is flattened with a warning.
- **Audit**: one `import.completed` entry (and `import.uploaded`, `import.cancelled`, `import.undone`, `export.created`), recorded as the system; the per-row entries of bulk writes are not made. Imported tasks and comments are indexed for search in the same transaction, and one `project.updated` event makes open clients read the project again.
- **Export**: `Export.Start` builds `tasks.json` (the importable shape), `tasks.csv`, `comments.json`, `attachments.json` (a manifest) and `README.md` per project (one folder per project for the whole workspace, plus `workspace.json`) as a stream, then `Export.Status` returns a signed `download_path` (`GET /exports/download?token=`, no bearer, valid `EXPORT_LINK_TTL_SECONDS`). Exports run on their own worker (never behind an import) and spool their side files to disk, so memory stays flat. Zips are removed after a day (`purge_exports`, in `make purge`). Every text cell of the CSV that starts like a formula is quoted.
- **Limits**: `IMPORTS_MAX_BYTES` (1 GB) per upload, 2 GB inflated per zip member, one cell 1 MB and one physical line 2 MB, one JSON entry 64 MB, 1000 problems kept per job.
