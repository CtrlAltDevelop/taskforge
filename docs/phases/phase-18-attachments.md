# Phase 18 — Attachments

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
- [ ] 1 GB-class upload completes with resume after network drop
- [ ] Non-members get 403 even with a leaked URL after expiry
- [ ] Thumbnails generated for jpg/png/pdf
- [ ] Works on web, Android/iOS, desktop

## Tests
Chunk assembly, resume, MIME sniff spoofing, signed URL expiry, quota, cleanup task.

## Depends on
Phases 06, 17.
