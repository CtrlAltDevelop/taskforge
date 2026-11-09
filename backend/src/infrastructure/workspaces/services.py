"""Every workspace rule. Transports render the answer; none re-decide it.

Mutations are owner-only (``created_by``); with one member that is everyone
until roles arrive in phase 04. A workspace the actor cannot touch -- not a
member, deleted, malformed or missing id -- is always the same 403, so ids
cannot be probed across tenants.
"""

import uuid
from datetime import timedelta
from typing import Any, Final

from django.core.files.base import ContentFile
from django.db import IntegrityError, transaction
from django.db.models import F
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember
from infrastructure.workspaces.slugs import validate_slug

RESTORE_WINDOW: Final = timedelta(days=7)
NAME_MAX_LENGTH: Final = 80
LOGO_MAX_BYTES: Final = 2 * 1024 * 1024
LOGO_SIGNATURES: Final = ((b"\x89PNG\r\n\x1a\n", "png"), (b"\xff\xd8\xff", "jpg"))


def _forbidden() -> ApiError:
    return ApiError("No access to that workspace.", status=403, title=ResponseTitle.FORBIDDEN)


def _slug_taken() -> ApiError:
    return ApiError("That URL name is already in use.", status=409, title=ResponseTitle.SLUG_TAKEN)


def _clean_name(name: str) -> str:
    cleaned = name.strip()
    if not cleaned or len(cleaned) > NAME_MAX_LENGTH:
        raise ApiError(f"The name must be 1-{NAME_MAX_LENGTH} characters.")
    return cleaned


def _find(actor: Any, workspace_id: str, *, deleted: bool | None = False) -> Workspace:
    """The actor's own workspace (owner only), or the one uniform 403."""
    try:
        pk = uuid.UUID(str(workspace_id))
    except ValueError:
        raise _forbidden() from None
    rows = Workspace.objects.filter(pk=pk, members__user=actor, members__status=MemberStatus.ACTIVE)
    if deleted is not None:
        rows = rows.filter(deleted_at__isnull=not deleted)
    workspace = rows.first()
    if workspace is None or workspace.created_by_id != actor.pk:
        raise _forbidden()
    return workspace


def _versioned_update(
    workspace: Workspace, expected_version: int | None, **changes: Any
) -> Workspace:
    """Apply ``changes`` only if the row still has ``expected_version``; bump it."""
    rows = Workspace.objects.filter(pk=workspace.pk)
    if expected_version is not None:
        rows = rows.filter(version=expected_version)
    try:
        with transaction.atomic():  # savepoint: a slug clash must not poison the caller's tx
            updated = rows.update(version=F("version") + 1, **changes)
    except IntegrityError:
        raise _slug_taken() from None
    if updated == 0:
        current = Workspace.objects.get(pk=workspace.pk).version
        raise ApiError(
            f"The workspace changed (now version {current}); reload and retry.",
            status=409,
            title=ResponseTitle.VERSION_CONFLICT,
        )
    return Workspace.objects.get(pk=workspace.pk)


def create(actor: Any, name: str, slug: str) -> Workspace:
    name = _clean_name(name)
    slug = validate_slug(slug)
    try:
        with transaction.atomic():
            workspace = Workspace.objects.create(name=name, slug=slug, created_by=actor)
            WorkspaceMember.objects.create(workspace=workspace, user=actor)
    except IntegrityError:
        raise _slug_taken() from None
    return workspace


def list_mine(actor: Any) -> list[Workspace]:
    return list(
        Workspace.objects.filter(
            deleted_at__isnull=True, members__user=actor, members__status=MemberStatus.ACTIVE
        ).order_by("created_at")
    )


def list_deleted(actor: Any) -> list[Workspace]:
    """The actor's own soft-deleted workspaces still inside the restore window."""
    return list(
        Workspace.objects.filter(
            deleted_at__gte=timezone.now() - RESTORE_WINDOW,
            members__user=actor,
            members__status=MemberStatus.ACTIVE,
            created_by=actor,
        ).order_by("-deleted_at")
    )


def rename(actor: Any, workspace_id: str, name: str, expected_version: int) -> Workspace:
    workspace = _find(actor, workspace_id)
    return _versioned_update(workspace, expected_version, name=_clean_name(name))


def change_slug(actor: Any, workspace_id: str, slug: str, expected_version: int) -> Workspace:
    workspace = _find(actor, workspace_id)
    return _versioned_update(workspace, expected_version, slug=validate_slug(slug))


def update(
    actor: Any,
    workspace_id: str,
    expected_version: int,
    *,
    name: str | None = None,
    slug: str | None = None,
) -> Workspace:
    """Rename and/or re-slug in one transaction: both apply or neither does."""
    with transaction.atomic():
        workspace = _find(actor, workspace_id)
        changes: dict[str, str] = {}
        if name is not None:
            changes["name"] = _clean_name(name)
        if slug is not None:
            changes["slug"] = validate_slug(slug)
        return _versioned_update(workspace, expected_version, **changes)


def set_logo(
    actor: Any, workspace_id: str, content: bytes, expected_version: int | None = None
) -> Workspace:
    """Store an uploaded PNG/JPEG (checked by magic bytes, not client claims)."""
    workspace = _find(actor, workspace_id)
    extension = next((ext for sig, ext in LOGO_SIGNATURES if content.startswith(sig)), None)
    if extension is None and content[:4] == b"RIFF" and content[8:12] == b"WEBP":
        extension = "webp"
    if extension is None or len(content) > LOGO_MAX_BYTES:
        raise ApiError(
            "The logo must be a PNG, JPEG or WebP image of at most 2 MB.",
            title=ResponseTitle.UPLOAD_INVALID,
        )
    previous = workspace.logo.name
    new_name = workspace.logo.storage.save(
        f"workspaces/logos/{workspace.pk}-{uuid.uuid4().hex[:8]}.{extension}", ContentFile(content)
    )
    try:
        updated = _versioned_update(workspace, expected_version, logo=new_name)
    except ApiError:
        workspace.logo.storage.delete(new_name)
        raise
    if previous:
        workspace.logo.storage.delete(previous)
    return updated


def delete(actor: Any, workspace_id: str, confirmation: str) -> Workspace:
    workspace = _find(actor, workspace_id)
    if confirmation != workspace.name:
        raise ApiError(
            "Type the workspace name exactly to confirm.",
            title=ResponseTitle.CONFIRMATION_MISMATCH,
        )
    return _versioned_update(workspace, None, deleted_at=timezone.now())


def restore(actor: Any, workspace_id: str) -> Workspace:
    workspace = _find(actor, workspace_id, deleted=None)
    if workspace.deleted_at is None:
        raise ApiError("This workspace is not deleted.")
    if timezone.now() - workspace.deleted_at > RESTORE_WINDOW:
        raise ApiError("This workspace was deleted too long ago to restore.", status=410)
    return _versioned_update(workspace, None, deleted_at=None)


def purge_expired() -> int:
    """Hard-delete workspaces soft-deleted over 7 days ago, freeing their slugs."""
    expired = Workspace.objects.filter(deleted_at__lt=timezone.now() - RESTORE_WINDOW)
    count = 0
    for workspace in expired:
        if workspace.logo:
            workspace.logo.storage.delete(workspace.logo.name)
        workspace.delete()
        count += 1
    return count
