# Phase 18 — Attachments

**Status:** DONE

## Feature
Attach **files and images** to tasks (and comments), with upload progress, preview and secure download.

## Why it exists
Attachments often hit storage caps or fail on mobile in the incumbents. Uploads are the one thing that suits REST better than gRPC (multipart, resumable, browser-friendly), so this phase uses Ninja on purpose.

## How it works (plain words)
The user drops a file (or pastes a screenshot). The app asks the server for an **upload session** and then sends the file in chunks directly to storage (S3-compatible, or local disk in dev). When complete, the server verifies size and type, scans it (optional ClamAV), generates a thumbnail for images/PDF first page, and links the file to the task. Downloads go through short-lived signed URLs after a permission check, so files are never publicly guessable.

## Scope
**In:** upload (drag-drop, picker, paste, camera on mobile), chunked/resumable upload, size/type limits, image/PDF thumbnails, preview (image, PDF, video, text), download, delete, per-workspace storage usage display.
**Out:** file versioning, online office editing, comments-embedded galleries beyond basic.

## Data model
- `Attachment(id, workspace, task, comment nullable, uploader, filename, mime, size, storage_key, sha256, thumb_key, status, created_at, deleted_at)`
- `UploadSession(id, uploader, expected_size, chunk_size, received, expires_at)`

## API surface
- REST (Ninja): `POST /api/uploads` (create session), `PUT /api/uploads/{id}/chunk/{n}`, `POST /api/uploads/{id}/complete`, `GET /api/files/{id}` (302 to signed URL)
- gRPC: `Attachments.List(task)`, `Delete`
- Event: `attachment.added`

## Flutter UI
Drop zone, progress bars with cancel/retry, thumbnails grid, lightbox preview, “Add” from camera/gallery on mobile; works with `file_picker` on all platforms and web drag-drop.

## Rules and edge cases
- Server decides allowed types by content sniffing, not by extension; blocks executables by default (configurable).
- Max size default 100 MB (config); quota per workspace.
- Dedupe by sha256 at storage level; each attachment still has own permission row.
- Orphaned uploads purged by Celery after 24 h.
- Files served with `Content-Disposition: attachment` for risky types to avoid XSS.

## Acceptance criteria
- [x] 1 GB-class upload completes with resume after network drop (run for real: 1 GiB in 205 chunks against a live server with `DJANGO_ATTACHMENT_MAX_MB=2048`; the server was killed and restarted after 68 chunks, the upload resumed from the 68 kept and the stored sha256 matched; not a flaky mobile network)
- [x] Non-members get 403 even with a leaked URL after expiry
- [x] Thumbnails generated for jpg/png/pdf
- [x] Works on web, Android/iOS, desktop (one Flutter codebase, widget-tested; iOS camera/photo and macOS file-access permissions declared; **not run on a device or in a browser**; pasting an image works on native only)

## Tests
Chunk assembly, resume, MIME sniff spoofing, signed URL expiry, quota, cleanup task.

## Depends on
Phases 06, 17.

## Contract (as built)
REST lives under `/api/v1` and answers in the usual envelope (`{"title", "message", "data"}`; see `backend/docs/responses.md`); every call but `raw` carries the bearer token. Sizes are bytes, chunk numbers are zero-based.

| Call | Body / query | Answer |
|---|---|---|
| `POST /uploads` | JSON `{workspace_id, project_id, task_id, comment_id?, filename, size}` | `{id, chunk_size, chunk_count, received: [], expires_at}`. 413 `ATTACHMENT_TOO_BIG`, 409 `ATTACHMENT_QUOTA` (workspace full), 429 `ATTACHMENT_QUOTA` (too many uploads open: 10 per person), 422 `ATTACHMENT_REFUSED` (empty, a blocked name) |
| `GET /uploads/{id}` | | same shape; `received` is what to skip when resuming. 404 once expired or done |
| `PUT /uploads/{id}/chunk/{n}` | raw bytes (`application/octet-stream`); every chunk is `chunk_size` bytes except the last, which is what remains | `{received: [...]}`. Sending a chunk again replaces it. 413 when the body is longer than `chunk_size`, 400 when the size or number is wrong, 404 `UPLOAD_EXPIRED` / unknown (or cancelled) |
| `POST /uploads/{id}/complete` | | the attachment (below). 409 `UPLOAD_INCOMPLETE` with `data.missing` (chunk numbers) if something is missing; 422 `ATTACHMENT_REFUSED` when the content is not accepted (`data.reason`; the upload is dropped); 503 `ATTACHMENT_REFUSED` when the virus scanner is configured but down (the upload is kept: try again); 404 if the comment it was for was removed meanwhile |
| `DELETE /uploads/{id}` | | cancels and removes the chunks |
| `GET /files/{id}/link?thumb=0\|1` | | `{url, expires_at}`: a signed link valid `ATTACHMENT_LINK_TTL_SECONDS` (default 120 s). 403 for a non-member **and** for a file that does not exist (same answer on purpose); 404 when the file exists but has no thumbnail |
| `GET /files/{id}` | | 302 to a signed link (for a browser that sends the token) |
| `GET /files/{id}/raw?token=…` | no bearer; the token is the only credential | the bytes. `Content-Disposition: inline` for images, PDF, video and text, `attachment` for everything else; `X-Content-Type-Options: nosniff`. 403 `LINK_EXPIRED` once the token is old. A `Range` is honoured (206; 416 outside the file); one it cannot serve is ignored (200) |

The attachment as REST returns it: `{id, task_id, comment_id, uploader_id, filename, mime, size, has_thumb, created_at}` (the same fields as the gRPC `Attachment`). gRPC `AttachmentController`: `List(workspace_id, project_id, task_id)`, `Delete(workspace_id, project_id, id)`, `Usage(workspace_id)` (`used_bytes`, `quota_bytes` (0 = none), `file_count`, `max_file_bytes`). Live event: `attachment.added` / `attachment.deleted`, whose `entity_id` is the **task**.

Rules the client may rely on: a comment's attachments are uploaded with that `comment_id` (only its author may); anything uploaded to a task is shown with the task. Thumbnails are JPEG, at most 320 px, for png/jpeg/gif/webp and the first page of a PDF.

## As built
- **Backend**: an `attachments` app (REST `/uploads` and `/files`, gRPC `AttachmentController`), reference `backend/docs/attachments.md`. New permission `task.attachment_manage` (Owner, Admin) to delete other people's files; uploading needs `task.update`; a comment's files, `comment.create` and being its author.
- **Content, not names**: a small magic-byte sniffer decides the type; programs and scripts are refused by content and by name; only images, PDF, video and plain text are ever served inline.
- **Thumbnails** run in a child process with a memory cap and a deadline (a hostile PDF cannot take the worker down); Pillow and pypdfium2 are the optional `backend[media]` extra.
- **Storage**: identical bytes are stored once **per workspace** (not across tenants). Clean-up of the bytes is serialized with new uploads under the workspace row lock. Deleting a comment deletes its files.
- **Not Celery**: the project has no Celery yet, so the 24 h purge is `manage.py purge_uploads` (to be scheduled) plus a bounded purge on every upload start. The `status` column of the data model is not needed: an `Attachment` row exists only once its file is stored.
- **Comments**: files can be attached when writing a comment (uploaded after the comment is created, with its id) and show under that comment; the task grid lists only files without a comment. Deleting a comment deletes its files.
- **Flutter**: chunked, resumable uploads (one at a time, three tries per chunk), drop zone (`desktop_drop`), picker (`file_picker`), camera/gallery (`image_picker`), pasted images (`pasteboard`, native only: the web cannot receive the browser's paste of an image), thumbnails, a viewer (images with zoom, text, video via `video_player`; PDFs and other files open through the system with `url_launcher`: no in-app PDF renderer), delete and a storage usage line.
- Not verified: a device camera or photo library, a real browser (CORS on `/raw`, drag-and-drop), real video playback, PostgreSQL (the workspace row locks only matter there), a real ClamAV, thumbnails of hostile files beyond the tests. The Flutter gRPC adapter is only partly covered.
