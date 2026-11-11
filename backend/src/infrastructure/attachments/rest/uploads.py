"""Uploading a file: open a session, send chunks (in any order, again if need be), complete.

Files go over REST, not gRPC, because HTTP tooling (multipart, resume, browser drag-and-drop) suits
them. Every call is the signed-in uploader's own; the rules live in
``infrastructure.attachments.services``.
"""

from uuid import UUID

from django.http import HttpRequest
from ninja import Router

from infrastructure.attachments import services
from infrastructure.attachments.models import Attachment, UploadSession
from infrastructure.attachments.rest.schemas import AttachmentOut, ChunkOut, UploadIn, UploadOut
from infrastructure.auth.core.sessions import api_auth
from infrastructure.common.errors import ApiError
from infrastructure.workspaces.scoping import require_workspace

router = Router()


def session_out(session: UploadSession) -> UploadOut:
    return UploadOut(
        id=str(session.pk),
        chunk_size=session.chunk_size,
        chunk_count=session.chunk_count,
        received=list(session.received),
        expires_at=session.expires_at.isoformat(),
    )


def attachment_out(row: Attachment) -> AttachmentOut:
    return AttachmentOut(
        id=str(row.pk),
        task_id=str(row.task_id),
        comment_id=str(row.comment_id or ""),
        uploader_id=str(row.uploader_id),
        filename=row.filename,
        mime=row.mime,
        size=row.size,
        has_thumb=bool(row.thumb_key),
        created_at=row.created_at.isoformat(),
    )


@router.post("", response=UploadOut, auth=api_auth, summary="Open an upload of a file on a task")
def create_upload(request: HttpRequest, payload: UploadIn) -> UploadOut:
    workspace = require_workspace(request.user, str(payload.workspace_id))
    session = services.start_upload(
        request.user,
        workspace,
        str(payload.project_id),
        str(payload.task_id),
        payload.filename,
        payload.size,
        comment_id=str(payload.comment_id or ""),
    )
    return session_out(session)


@router.get("/{upload_id}", response=UploadOut, auth=api_auth, summary="Which chunks have arrived")
def upload_status(request: HttpRequest, upload_id: UUID) -> UploadOut:
    return session_out(services.upload_status(request.user, str(upload_id)))


@router.put(
    "/{upload_id}/chunk/{n}",
    response=ChunkOut,
    auth=api_auth,
    summary="Send one chunk (the raw bytes as the body); sending it again replaces it",
)
def put_chunk(request: HttpRequest, upload_id: UUID, n: int) -> ChunkOut:
    session = services.upload_status(request.user, str(upload_id))
    if int(request.META.get("CONTENT_LENGTH") or 0) > session.chunk_size:
        raise ApiError(f"A chunk is at most {session.chunk_size} bytes.", 413)
    # One byte more than a chunk can hold, so a body that is too long is seen as too long.
    data = request.read(session.chunk_size + 1)
    return ChunkOut(received=services.put_chunk(request.user, str(upload_id), n, data))


@router.post(
    "/{upload_id}/complete",
    response=AttachmentOut,
    auth=api_auth,
    summary="Assemble the chunks into the attachment",
)
def complete(request: HttpRequest, upload_id: UUID) -> AttachmentOut:
    return attachment_out(services.complete(request.user, str(upload_id)))


@router.delete("/{upload_id}", response=dict, auth=api_auth, summary="Cancel an upload")
def cancel(request: HttpRequest, upload_id: UUID) -> dict[str, bool]:
    services.cancel(request.user, str(upload_id))
    return {"cancelled": True}
