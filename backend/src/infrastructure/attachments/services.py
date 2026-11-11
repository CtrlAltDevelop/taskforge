"""Attachments: starting, feeding and completing an upload; listing, deleting; signed links.

An upload is a session (``start_upload``), chunks (``put_chunk``, any order, repeatable, so a
dropped connection resumes from ``upload_status``) and a ``complete`` that assembles them, checks
what the *content* is (never the name), optionally scans it, thumbnails it and stores it under its
sha256 so identical bytes are kept once. Every call re-checks that the caller may still write to
the task. A file is read through a short-lived signed token (``link_token`` / ``resolve_token``)
that is only ever handed to someone who passed the membership check.
"""

import hashlib
import logging
import tempfile
import unicodedata
import uuid
from datetime import timedelta
from pathlib import Path
from typing import Any, Final

from django.conf import settings
from django.core import signing
from django.core.files.base import ContentFile, File
from django.core.files.storage import default_storage
from django.db import transaction
from django.db.models import Count, Sum
from django.utils import timezone

from infrastructure.attachments import scan, sniff, thumbs
from infrastructure.attachments.models import Attachment, UploadSession
from infrastructure.attachments.signals import announce
from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace
from infrastructure.workspaces.scoping import require_workspace

logger = logging.getLogger(__name__)

WRITE: Final = "task.update"
MANAGE: Final = "task.attachment_manage"
COMMENT_WRITE: Final = "comment.create"
LINK_SALT: Final = "attachments.link"
BLOCK: Final = 64 * 1024
NAME_MAX: Final = 255
PURGE_BATCH: Final = 100  # an upload start also clears out this many expired uploads


def not_found() -> ApiError:
    return ApiError("No such file.", status=404)


def refused(reason: str, status: int = 422) -> ApiError:
    return ApiError(reason, status, title=ResponseTitle.ATTACHMENT_REFUSED, data={"reason": reason})


# -- keys ----------------------------------------------------------------------------------------


def chunk_key(session: UploadSession, n: int) -> str:
    return f"attachments/tmp/{session.pk}.{n}"  # flat: no folders to leave behind


def blob_key(workspace_id: Any, sha256: str) -> str:
    # Per workspace: identical bytes are stored once *within* a workspace, never shared across
    # tenants (one tenant's delete cannot touch another's file, nor tell it already has the bytes).
    return f"attachments/blobs/{workspace_id}/{sha256[:2]}/{sha256}"


def thumb_key(workspace_id: Any, sha256: str) -> str:
    return f"attachments/thumbs/{workspace_id}/{sha256[:2]}/{sha256}.jpg"


# -- looking things up ---------------------------------------------------------------------------


def _uuid(raw: Any) -> uuid.UUID:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise not_found() from None


def _task(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, *, write: bool = False
) -> tuple[Project, Task]:
    project = task_services.project_for_view(actor, workspace, project_id)
    if write:
        access.require(actor, WRITE, workspace)
        projects.writable(project)
    task = Task.objects.filter(project=project, pk=_uuid(task_id), deleted_at__isnull=True).first()
    if task is None:
        raise task_services.not_found()
    return project, task


def _load(
    actor: Any, workspace: Workspace, project_id: str, attachment_id: str, *, lock: bool = False
) -> tuple[Project, Attachment]:
    project = task_services.project_for_view(actor, workspace, project_id)
    rows = Attachment.objects.filter(
        pk=_uuid(attachment_id),
        workspace=workspace,
        task__project=project,
        task__deleted_at__isnull=True,
    ).select_related("task")
    row = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if row is None:
        raise not_found()
    return project, row


def list_for_task(
    actor: Any, workspace: Workspace, project_id: str, task_id: str
) -> list[Attachment]:
    _, task = _task(actor, workspace, project_id, task_id)
    return list(
        Attachment.objects.filter(task=task, deleted_at__isnull=True).order_by("created_at", "id")
    )


# -- starting an upload --------------------------------------------------------------------------


def _human(size: int) -> str:
    return f"{size // (1024 * 1024)} MB" if size >= 1024 * 1024 else f"{size // 1024 or 1} KB"


def _clean_name(raw: str) -> str:
    """The file name without any folder, control characters or surrounding space."""
    name = unicodedata.normalize("NFKC", raw).replace("\\", "/").rsplit("/", 1)[-1]
    # Control and format characters (zero-width, right-to-left override) and trailing dots/spaces
    # (Windows drops them, turning "a.exe." into a program) never belong in a name.
    name = "".join(ch for ch in name if unicodedata.category(ch) not in ("Cc", "Cf", "Zl", "Zp"))
    name = name.strip().rstrip(". ")
    if name in (".", ".."):
        return ""
    if len(name) > NAME_MAX:
        stem, dot, ext = name.rpartition(".")
        name = (
            (stem[: NAME_MAX - len(ext) - 1] + dot + ext)
            if dot and len(ext) < 20
            else name[:NAME_MAX]
        )
    return name


def _comment_for(actor: Any, workspace: Workspace, task: Task, comment_id: str) -> Comment | None:
    if not comment_id:
        return None
    access.require(actor, COMMENT_WRITE, workspace)
    comment = Comment.objects.filter(
        pk=_uuid(comment_id), task=task, workspace=workspace, deleted_at__isnull=True
    ).first()
    if comment is None:
        raise not_found()
    if comment.author_id != actor.pk:
        raise access.PermissionDenied(COMMENT_WRITE, "", "Only the author can attach to a comment.")
    return comment


def _used_bytes(workspace: Workspace) -> int:
    live = Attachment.objects.filter(workspace=workspace, deleted_at__isnull=True).aggregate(
        total=Sum("size")
    )["total"]
    # Expired sessions count until they are purged: their chunks are still on disk.
    pending = UploadSession.objects.filter(workspace=workspace).aggregate(
        total=Sum("expected_size")
    )["total"]
    return int(live or 0) + int(pending or 0)


def start_upload(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    filename: str,
    size: int,
    *,
    comment_id: str = "",
) -> UploadSession:
    """Open an upload of ``size`` bytes on a task (or one of its comments). Refuses what could
    never be kept (too big, empty, a program by name, over the workspace quota)."""
    _, task = _task(actor, workspace, project_id, task_id, write=True)
    name = _clean_name(filename)
    if not name:
        raise refused("The file needs a name.")
    if size <= 0:
        raise refused("The file is empty.")
    limit = settings.ATTACHMENT_MAX_BYTES
    if limit and size > limit:
        raise ApiError(
            f"A file can be at most {_human(limit)}.",
            413,
            title=ResponseTitle.ATTACHMENT_TOO_BIG,
        )
    if not settings.ATTACHMENT_ALLOW_EXECUTABLES and sniff.is_script_name(name):
        raise refused("Programs and scripts are not accepted.")
    comment = _comment_for(actor, workspace, task, comment_id)
    purge_expired(limit=PURGE_BATCH)
    if (
        UploadSession.objects.filter(uploader=actor, workspace=workspace).count()
        >= settings.ATTACHMENT_MAX_OPEN_UPLOADS
    ):
        raise ApiError(
            "Too many uploads are open; finish or cancel some first.",
            429,
            title=ResponseTitle.ATTACHMENT_QUOTA,
        )
    with transaction.atomic():
        Workspace.objects.select_for_update().filter(pk=workspace.pk).first()  # one at a time
        quota = settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES
        if quota and _used_bytes(workspace) + size > quota:
            raise ApiError(
                "The workspace has used all its storage.",
                409,
                title=ResponseTitle.ATTACHMENT_QUOTA,
            )
        now = timezone.now()
        session = UploadSession.objects.create(
            workspace=workspace,
            task=task,
            comment=comment,
            uploader=actor,
            filename=name,
            expected_size=size,
            chunk_size=settings.ATTACHMENT_CHUNK_BYTES,
            created_at=now,
            expires_at=now + timedelta(hours=settings.ATTACHMENT_UPLOAD_TTL_HOURS),
        )
    return session


# -- chunks --------------------------------------------------------------------------------------


def _session(actor: Any, session_id: str, *, write: bool = False) -> UploadSession:
    """The caller's own, unexpired session (anybody else's is NOT_FOUND). With ``write`` the
    caller must still be allowed to add to the task."""
    session = (
        UploadSession.objects.filter(pk=_uuid(session_id), uploader=actor)
        .select_related("task", "workspace")
        .first()
    )
    if session is None:
        raise not_found()
    workspace = require_workspace(actor, str(session.workspace_id))
    if session.expires_at <= timezone.now():
        raise ApiError("That upload expired.", 404, title=ResponseTitle.UPLOAD_EXPIRED)
    if write:
        _task(actor, workspace, str(session.task.project_id), str(session.task_id), write=True)
    return session


def upload_status(actor: Any, session_id: str) -> UploadSession:
    return _session(actor, session_id)


def put_chunk(actor: Any, session_id: str, n: int, data: bytes) -> list[int]:
    """Store chunk ``n`` (zero-based; again is fine, it replaces). Every chunk is ``chunk_size``
    bytes except the last, which is what remains. Returns the chunks received so far."""
    session = _session(actor, session_id, write=True)
    if not 0 <= n < session.chunk_count:
        raise refused(f"There is no chunk {n}.", 400)
    last = n == session.chunk_count - 1
    expected = session.expected_size - session.chunk_size * n if last else session.chunk_size
    if len(data) != expected:
        raise refused(f"Chunk {n} must be {expected} bytes, not {len(data)}.", 400)
    key = chunk_key(session, n)
    with transaction.atomic():
        # The row lock is held across the write, so two requests for the same chunk cannot both
        # write it (a storage would rename the loser), and a cancel or complete that got there
        # first leaves nothing behind.
        row = UploadSession.objects.select_for_update().filter(pk=session.pk).first()
        if row is None:
            raise not_found()
        if default_storage.exists(key):
            default_storage.delete(key)
        default_storage.save(key, ContentFile(data))
        if n not in row.received:
            row.received = sorted({*row.received, n})
            row.save(update_fields=["received"])
    return list(row.received)


def _drop_chunks(session: UploadSession) -> None:
    for n in range(session.chunk_count):
        default_storage.delete(chunk_key(session, n))


def cancel(actor: Any, session_id: str) -> None:
    session = _session(actor, session_id)
    _drop_chunks(session)
    session.delete()


def _discard(session: UploadSession) -> None:
    _drop_chunks(session)
    session.delete()


# -- completing ----------------------------------------------------------------------------------


def _assemble(session: UploadSession, target: Any) -> tuple[str, int, bytes]:
    """Write the chunks, in order, to ``target``; returns their sha256, size and first bytes."""
    digest = hashlib.sha256()
    total = 0
    head = b""
    for n in range(session.chunk_count):
        with default_storage.open(chunk_key(session, n)) as part:
            while block := part.read(BLOCK):
                target.write(block)
                digest.update(block)
                total += len(block)
                if len(head) < sniff.HEAD_BYTES:
                    head += block[: sniff.HEAD_BYTES - len(head)]
    target.flush()
    return digest.hexdigest(), total, head


def _keep(key: str, source: Any, size: int) -> str:
    """Store ``source`` at ``key`` unless those exact bytes are already there (a stored file of a
    different size is a leftover of an interrupted write and is replaced)."""
    if default_storage.exists(key):
        if default_storage.size(key) == size:
            return key
        default_storage.delete(key)
    return default_storage.save(key, source)


def complete(actor: Any, session_id: str) -> Attachment:
    """Assemble the chunks into the attachment, or refuse the file (422, nothing is kept)."""
    session = _session(actor, session_id, write=True)
    if (
        session.comment_id
        and not Comment.objects.filter(pk=session.comment_id, deleted_at__isnull=True).exists()
    ):
        _discard(session)  # the comment was removed while the file was on its way
        raise not_found()
    missing = [n for n in range(session.chunk_count) if n not in session.received]
    if missing:
        raise _incomplete(missing)
    workspace_id = session.workspace_id
    with tempfile.NamedTemporaryFile(prefix="attachment-") as tmp:
        try:
            sha256, size, head = _assemble(session, tmp)
        except FileNotFoundError:  # a chunk was replaced under us: the client sends it again
            raise _incomplete(list(range(session.chunk_count))) from None
        found = sniff.sniff(head, session.filename)
        problem = _problem(session, size, found, Path(tmp.name))
        if problem is not None:
            if problem.status == 422:  # a refused file is gone; a scanner outage can be retried
                _discard(session)
            raise problem
        thumbnail = (
            thumbs.make_isolated(Path(tmp.name), found.mime) if found.thumbnailable else None
        )
        tmp.seek(0)
        stored = _keep(blob_key(workspace_id, sha256), File(tmp), size)
        kept_thumb = (
            _keep(thumb_key(workspace_id, sha256), ContentFile(thumbnail), len(thumbnail))
            if thumbnail
            else ""
        )
        with transaction.atomic():
            # The workspace lock serializes this with ``delete``'s clean-up: either the other
            # attachment holding these bytes is deleted first (and the bytes are put back here),
            # or this row exists before that check runs.
            Workspace.objects.select_for_update().filter(pk=workspace_id).first()
            locked = UploadSession.objects.select_for_update().filter(pk=session.pk).first()
            if locked is None:  # completed or cancelled by another request meanwhile
                raise not_found()
            tmp.seek(0)
            stored = _keep(blob_key(workspace_id, sha256), File(tmp), size)
            if thumbnail:
                kept_thumb = _keep(
                    thumb_key(workspace_id, sha256), ContentFile(thumbnail), len(thumbnail)
                )
            attachment = Attachment.objects.create(
                workspace=session.workspace,
                task=session.task,
                comment=session.comment,
                uploader=actor,
                filename=session.filename,
                mime=found.mime,
                size=size,
                storage_key=stored,
                sha256=sha256,
                thumb_key=kept_thumb,
            )
            locked.delete()
            announce(attachment, "added")
    _drop_chunks(session)
    return attachment


def _incomplete(missing: list[int]) -> ApiError:
    return ApiError(
        "Some chunks have not arrived.",
        409,
        title=ResponseTitle.UPLOAD_INCOMPLETE,
        data={"missing": ",".join(str(n) for n in missing)},
    )


def _problem(
    session: UploadSession, size: int, found: sniff.Sniffed, path: Path
) -> ApiError | None:
    if size != session.expected_size:
        return refused("The file is not the size that was announced.")
    if found.executable and not settings.ATTACHMENT_ALLOW_EXECUTABLES:
        return refused("Programs and scripts are not accepted.")
    try:
        verdict = scan.scan(path, settings.ATTACHMENT_CLAMAV_ADDRESS)
    except scan.ScanTooLarge:
        return refused("The file is too large for the virus scanner to check.")
    except scan.ScanUnavailable:
        logger.warning("virus scanner unavailable; refusing %s", session.pk)
        return ApiError(
            "The file could not be checked for viruses; try again later.",
            503,
            title=ResponseTitle.ATTACHMENT_REFUSED,
        )
    if verdict:
        return refused(f"The virus scanner flagged the file ({verdict}).")
    return None


# -- deleting, usage -----------------------------------------------------------------------------


def _release(storage_key: str, thumbnail_key: str) -> None:
    """Remove stored bytes that no live attachment points at any more."""
    # Called with the workspace row locked, as ``complete`` takes it before it puts a row in.
    for column, key in (("storage_key", storage_key), ("thumb_key", thumbnail_key)):
        if key and not Attachment.objects.filter(**{column: key}, deleted_at__isnull=True).exists():
            default_storage.delete(key)


def delete(actor: Any, workspace: Workspace, project_id: str, attachment_id: str) -> Attachment:
    """Remove an attachment: its uploader, or anyone with ``task.attachment_manage``, in a project
    that is not archived. The row stays (soft delete); the bytes go once nothing else uses them."""
    with transaction.atomic():
        Workspace.objects.select_for_update().filter(pk=workspace.pk).first()  # see ``complete``
        project, row = _load(actor, workspace, project_id, attachment_id, lock=True)
        projects.writable(project)
        if row.uploader_id != actor.pk:
            access.require(actor, MANAGE, workspace)
        else:
            access.require(actor, WRITE, workspace)
        if row.is_deleted:
            return row
        _remove(row)
    return row


def _remove(row: Attachment) -> None:
    """Soft-delete ``row`` (caller holds the workspace lock) and drop bytes nobody else uses."""
    row.deleted_at = timezone.now()
    row.save(update_fields=["deleted_at"])
    announce(row, "deleted")
    _release(row.storage_key, row.thumb_key)


def remove_for_comment(comment: Comment) -> None:
    """A removed comment takes its files with it."""
    with transaction.atomic():
        Workspace.objects.select_for_update().filter(pk=comment.workspace_id).first()
        for row in Attachment.objects.filter(
            comment=comment, deleted_at__isnull=True
        ).select_related("task"):
            _remove(row)


def usage(actor: Any, workspace: Workspace) -> dict[str, int]:
    access.require(actor, "workspace.view", workspace)
    live = Attachment.objects.filter(workspace=workspace, deleted_at__isnull=True).aggregate(
        used=Sum("size"), count=Count("id")
    )
    return {
        "used_bytes": int(live["used"] or 0),
        "quota_bytes": settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES,
        "file_count": int(live["count"]),
        "max_file_bytes": settings.ATTACHMENT_MAX_BYTES,
    }


# -- signed links --------------------------------------------------------------------------------


def workspace_of(actor: Any, attachment_id: str) -> Workspace:
    """The workspace of an attachment the caller belongs to. A file that does not exist and one in
    somebody else's workspace look the same (403)."""
    try:
        pk = uuid.UUID(str(attachment_id))
    except ValueError:
        raise access.forbidden() from None
    workspace_id = (
        Attachment.objects.filter(pk=pk, deleted_at__isnull=True, task__deleted_at__isnull=True)
        .values_list("workspace_id", flat=True)
        .first()
    )
    if workspace_id is None:
        raise access.forbidden()
    return require_workspace(actor, str(workspace_id))


def link_token(actor: Any, workspace: Workspace, attachment_id: Any, *, thumb: bool) -> str:
    """A token for ``GET /files/{id}/raw``, valid ``ATTACHMENT_LINK_TTL_SECONDS``. Only someone who
    can open the task gets one."""
    row = (
        Attachment.objects.filter(
            pk=_uuid(attachment_id),
            workspace=workspace,
            deleted_at__isnull=True,
            task__deleted_at__isnull=True,
        )
        .select_related("task")
        .first()
    )
    if row is None:
        raise not_found()
    task_services.project_for_view(actor, workspace, str(row.task.project_id))
    if thumb and not row.thumb_key:
        raise not_found()
    return signing.dumps({"a": str(row.pk), "t": bool(thumb)}, salt=LINK_SALT)


def resolve_token(token: str) -> tuple[Attachment, bool]:
    """The attachment a link token opens (and whether it is the thumbnail), or 403 / 404."""
    try:
        payload = signing.loads(token, salt=LINK_SALT, max_age=settings.ATTACHMENT_LINK_TTL_SECONDS)
    except signing.SignatureExpired:
        raise ApiError("This link has expired.", 403, title=ResponseTitle.LINK_EXPIRED) from None
    except signing.BadSignature:
        raise ApiError("This link is not valid.", 403) from None
    row = Attachment.objects.filter(
        pk=payload["a"], deleted_at__isnull=True, task__deleted_at__isnull=True
    ).first()
    thumb = bool(payload["t"])
    if row is None or (thumb and not row.thumb_key):
        raise not_found()
    return row, thumb


# -- clean-up ------------------------------------------------------------------------------------


def purge_expired(limit: int | None = None) -> int:
    """Remove uploads that were never completed (their chunks too); returns how many."""
    rows = UploadSession.objects.filter(expires_at__lte=timezone.now()).order_by("expires_at")
    stale = list(rows[:limit] if limit else rows)
    for session in stale:
        _discard(session)
    return len(stale)
