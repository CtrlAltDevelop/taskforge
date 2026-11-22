"""Every workspace rule. Transports render the answer; none re-decide it.

Each mutation names the permission it needs (``workspace.update``, ``workspace.delete``)
and goes through ``access.require``. A workspace the actor cannot touch -- not a
member, deleted, malformed or missing id -- is always the same 403, so ids
cannot be probed across tenants; a member lacking the permission gets the reason.
"""

import logging
import uuid
from datetime import timedelta
from typing import Any, Final

from django.core.files.base import ContentFile
from django.db import IntegrityError, transaction
from django.db.models import F
from django.utils import timezone

from infrastructure.audit import changes as audit_changes
from infrastructure.audit import context as audit_context
from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.locales import normalize_locale
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember
from infrastructure.workspaces.registry import OWNER
from infrastructure.workspaces.slugs import validate_slug

logger = logging.getLogger(__name__)

RESTORE_WINDOW: Final = timedelta(days=7)
NAME_MAX_LENGTH: Final = 80
LOGO_MAX_BYTES: Final = 2 * 1024 * 1024
LOGO_SIGNATURES: Final = ((b"\x89PNG\r\n\x1a\n", "png"), (b"\xff\xd8\xff", "jpg"))


def _slug_taken() -> ApiError:
    return ApiError("That URL name is already in use.", status=409, title=ResponseTitle.SLUG_TAKEN)


def _clean_name(name: str) -> str:
    cleaned = name.strip()
    if not cleaned or len(cleaned) > NAME_MAX_LENGTH:
        raise ApiError(f"The name must be 1-{NAME_MAX_LENGTH} characters.")
    return cleaned


def _find(
    actor: Any, workspace_id: str, permission: str, *, deleted: bool | None = False
) -> Workspace:
    """The workspace if the actor holds ``permission`` in it, else the uniform 403 / the reason."""
    try:
        pk = uuid.UUID(str(workspace_id))
    except ValueError:
        raise access.forbidden() from None
    rows = Workspace.objects.filter(pk=pk)
    if deleted is not None:
        rows = rows.filter(deleted_at__isnull=not deleted)
    workspace = rows.first()
    if workspace is None:
        raise access.forbidden()
    access.require(actor, permission, workspace)
    return workspace


def _versioned_update(
    workspace: Workspace, expected_version: int | None, **changes: Any
) -> Workspace:
    """Apply ``changes`` only if the row still has ``expected_version``; bump it."""
    before = audit_changes.snapshot(workspace)
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
    fresh = Workspace.objects.get(pk=workspace.pk)
    audit_changes.updated(fresh, before)
    return fresh


def create(actor: Any, name: str, slug: str) -> Workspace:
    name = _clean_name(name)
    slug = validate_slug(slug)
    try:
        with transaction.atomic():
            workspace = Workspace.objects.create(name=name, slug=slug, created_by=actor)
            WorkspaceMember.objects.create(
                workspace=workspace, user=actor, role=access.builtin_role(OWNER)
            )
            from infrastructure.chat import services as chat

            chat.workspace_created(workspace)  # #general, in the same transaction
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
    """Soft-deleted workspaces inside the restore window where the actor may restore them."""
    candidates = Workspace.objects.filter(
        deleted_at__gte=timezone.now() - RESTORE_WINDOW,
        members__user=actor,
        members__status=MemberStatus.ACTIVE,
    ).order_by("-deleted_at")
    return [w for w in candidates if access.can(actor, "workspace.delete", w).allowed]


def rename(actor: Any, workspace_id: str, name: str, expected_version: int) -> Workspace:
    workspace = _find(actor, workspace_id, "workspace.update")
    return _versioned_update(workspace, expected_version, name=_clean_name(name))


def change_slug(actor: Any, workspace_id: str, slug: str, expected_version: int) -> Workspace:
    workspace = _find(actor, workspace_id, "workspace.update")
    return _versioned_update(workspace, expected_version, slug=validate_slug(slug))


def update(
    actor: Any,
    workspace_id: str,
    expected_version: int,
    *,
    name: str | None = None,
    slug: str | None = None,
    default_locale: str | None = None,
) -> Workspace:
    """Rename, re-slug and/or change the default language in one transaction."""
    with transaction.atomic():
        workspace = _find(actor, workspace_id, "workspace.update")
        changes: dict[str, str] = {}
        if name is not None:
            changes["name"] = _clean_name(name)
        if slug is not None:
            changes["slug"] = validate_slug(slug)
        if default_locale is not None:
            language = normalize_locale(default_locale)
            if language is None:
                raise ApiError(
                    "default_locale must be one of the supported languages: en, fa, ar, ps.",
                    status=400,
                    title=ResponseTitle.VALIDATION_ERROR,
                )
            changes["default_locale"] = language
        return _versioned_update(workspace, expected_version, **changes)


def logo_extension(content: bytes) -> str | None:
    """``png``, ``jpg`` or ``webp`` by the file's own first bytes (never by what the client says),
    ``None`` for anything else or for more than ``LOGO_MAX_BYTES``."""
    if len(content) > LOGO_MAX_BYTES:
        return None
    extension = next((ext for sig, ext in LOGO_SIGNATURES if content.startswith(sig)), None)
    if extension is None and content[:4] == b"RIFF" and content[8:12] == b"WEBP":
        extension = "webp"
    return extension


def set_logo(
    actor: Any, workspace_id: str, content: bytes, expected_version: int | None = None
) -> Workspace:
    """Store an uploaded PNG/JPEG (checked by magic bytes, not client claims)."""
    workspace = _find(actor, workspace_id, "workspace.update")
    extension = logo_extension(content)
    if extension is None:
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
    workspace = _find(actor, workspace_id, "workspace.delete")
    if confirmation != workspace.name:
        raise ApiError(
            "Type the workspace name exactly to confirm.",
            title=ResponseTitle.CONFIRMATION_MISMATCH,
        )
    return _versioned_update(workspace, None, deleted_at=timezone.now())


def restore(actor: Any, workspace_id: str) -> Workspace:
    workspace = _find(actor, workspace_id, "workspace.delete", deleted=None)
    if workspace.deleted_at is None:
        raise ApiError("This workspace is not deleted.")
    if timezone.now() - workspace.deleted_at > RESTORE_WINDOW:
        raise ApiError("This workspace was deleted too long ago to restore.", status=410)
    return _versioned_update(workspace, None, deleted_at=None)


def purge_expired() -> int:
    """Hard-delete workspaces soft-deleted over 7 days ago, freeing their slugs.

    One workspace failing (logged by id only) never stops the others.
    """
    expired = Workspace.objects.filter(deleted_at__lt=timezone.now() - RESTORE_WINDOW)
    count = 0
    for workspace in expired:
        logo = workspace.logo.name
        try:
            with transaction.atomic(), audit_context.suppressed():
                # Thousands of cascaded rows are one event, not thousands of entries.
                recorder.record(
                    workspace_id=workspace.pk,
                    action="workspace.purged",
                    target_type="workspace",
                    target_id=workspace.pk,
                    actor_type="system",
                    changes={"name": workspace.name, "slug": workspace.slug},
                )
                workspace.delete()
            if logo:
                workspace.logo.storage.delete(logo)
        except Exception as failure:  # noqa: BLE001 - isolate the failure, keep purging
            logger.error("purge failed for workspace %s (%s)", workspace.pk, type(failure).__name__)
            continue
        count += 1
    return count
