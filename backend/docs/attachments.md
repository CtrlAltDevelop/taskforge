# Attachments

Files on tasks and on comments: chunked, resumable uploads over REST, content checks, thumbnails, signed download links, per-workspace storage. Always installed. REST (`/api/v1/uploads`, `/api/v1/files`) for the bytes, gRPC (`AttachmentController`) for listing and deleting. Phase 18.

## Routes

<!-- generated:routes -->
| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/files/{attachment_id}` | Bearer | Redirect to a signed link to the file |
| `GET` | `/api/v1/files/{attachment_id}/link` | Bearer | A signed link to the file (or its thumbnail), valid for a short while |
| `GET` | `/api/v1/files/{attachment_id}/raw` | None | The bytes, with a signed token |
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Attachment`

A stored file. ``storage_key`` is derived from ``sha256`` (the same bytes are stored once,

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `task` | ForeignKey | → `tasks.Task` |
| `comment` | ForeignKey | → `comments.Comment`, nullable |
| `uploader` | ForeignKey | → `accounts.User` |
| `filename` | Char |  |
| `mime` | Char |  |
| `size` | BigInteger |  |
| `storage_key` | Char |  |
| `sha256` | Char |  |
| `thumb_key` | Char |  |
| `created_at` | DateTime |  |
| `deleted_at` | DateTime | nullable |

#### `UploadSession`

An upload in progress. The chunks wait in storage under ``attachments/tmp/<id>.<n>``;

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `task` | ForeignKey | → `tasks.Task` |
| `comment` | ForeignKey | → `comments.Comment`, nullable |
| `uploader` | ForeignKey | → `accounts.User` |
| `filename` | Char |  |
| `expected_size` | BigInteger |  |
| `chunk_size` | PositiveInteger |  |
| `received` | JSON |  |
| `created_at` | DateTime |  |
| `expires_at` | DateTime |  |
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

### Permissions

Reading needs a task the caller can open. Uploading needs **`task.update`** and a project that is not archived (to a comment: `comment.create`, and only its author). Deleting is the uploader's, or needs **`task.attachment_manage`** (Owner, Admin); also in an unarchived project. `Usage` is open to every member.

### The upload

1. `POST /uploads` `{workspace_id, project_id, task_id, comment_id?, filename, size}` opens a session and answers `chunk_size` and `chunk_count`. Refused up front: empty, over `ATTACHMENT_MAX_MB` (413), a program or script by name, over the workspace quota (409; files still arriving count).
2. `PUT /uploads/{id}/chunk/{n}` sends chunk `n` (raw bytes). Chunks may arrive in any order and be repeated. `GET /uploads/{id}` lists `received`, which is how an upload resumes after a dropped connection.
3. `POST /uploads/{id}/complete` assembles the chunks in order (never in memory, so a 1 GB file is fine), takes its sha256, **sniffs the content** (the name is never trusted: a program called `holiday.png` is refused), optionally streams it to ClamAV, thumbnails it and stores it. Missing chunks: 409 `UPLOAD_INCOMPLETE` with `data.missing`.

Chunks live as `attachments/tmp/<session>.<n>` in the default storage; sessions expire after `ATTACHMENT_UPLOAD_TTL_HOURS` and `manage.py purge_uploads` (daily; also run by about one upload start in 200) removes them. There is no Celery in this project yet, so the purge is a command to schedule.

### Storage

The bytes are kept at `attachments/blobs/<workspace>/<sha[:2]>/<sha256>` in whatever `STORAGES["default"]` is, so identical files are stored once per workspace (never shared between tenants); every attachment row still has its own permissions. The bytes are removed when the last live attachment pointing at them is deleted; that clean-up and the completion of a new upload take the same workspace row lock, so one cannot remove what the other has just reused. Deleting a comment deletes its files. The thumbnail (JPEG, at most 320 px) is made for png, jpeg, gif, webp (Pillow) and the first page of a PDF (pypdfium2); install `backend[media]`. Without them uploads work with no thumbnails. Thumbnails are made in a child process (`thumbs.make_isolated`) with a memory cap and a 20 s deadline, so a hostile file cannot crash or hang the web worker.

### Reading

`GET /files/{id}/link?thumb=0|1` (bearer, member of the workspace) returns a signed URL valid `ATTACHMENT_LINK_TTL_SECONDS`; `GET /files/{id}/raw?token=…` needs no bearer so images and video players can use it, and answers byte ranges (so video seeks). After the token expires it is 403 `LINK_EXPIRED`, and a non-member never gets one. Images, PDF, video and plain text are served inline; everything else (HTML, SVG, archives, unknown) is always `Content-Disposition: attachment`, with `X-Content-Type-Options: nosniff` and a sandboxing `Content-Security-Policy` on every response.

### Settings

`DJANGO_ATTACHMENT_MAX_MB` (100), `DJANGO_ATTACHMENT_WORKSPACE_QUOTA_MB` (10240), `DJANGO_ATTACHMENT_CHUNK_BYTES` (5 MB), `DJANGO_ATTACHMENT_UPLOAD_TTL_HOURS` (24), `DJANGO_ATTACHMENT_LINK_TTL_SECONDS` (120), `DJANGO_ATTACHMENT_ALLOW_EXECUTABLES` (`1` turns the program block off), `DJANGO_ATTACHMENT_CLAMAV_ADDRESS` (`host:port` of a clamd on a private network; unset = no scan; set but unreachable = 503 and the upload is kept for a retry; **set clamd's `StreamMaxLength` to at least `ATTACHMENT_MAX_MB`**, or a larger file is refused as too large to scan), `DJANGO_ATTACHMENT_MAX_OPEN_UPLOADS` (10 per person and workspace).

**Deploy**: put a body-size limit of about the chunk size (plus a little) on `/api/v1/uploads` at the reverse proxy: Django's ASGI server spools a request body to disk before the view can refuse it. Keep `token=` out of access logs (it is a bearer for `ATTACHMENT_LINK_TTL_SECONDS`).

### gRPC

`List(task)`, `Delete(id)`, `Usage(workspace)` (`used_bytes`, `quota_bytes`, `file_count`, `max_file_bytes`). Live: `attachment.added|deleted`, whose `entity_id` is the **task**.
