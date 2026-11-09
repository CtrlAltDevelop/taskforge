"""Who is in a workspace, and removing or leaving.

Until phase 04: any active member lists; only the owner (``created_by``) removes;
the owner can neither leave nor be removed (ownership transfer is out of scope).
"""

import uuid
from typing import Any

from django.db import transaction
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces.models import Invitation, MemberStatus, Workspace, WorkspaceMember


def _owner_protected() -> ApiError:
    return ApiError(
        "The workspace owner cannot be removed or leave.",
        status=403,
        title=ResponseTitle.OWNER_PROTECTED,
    )


def list_members(workspace: Workspace) -> list[WorkspaceMember]:
    return list(
        WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE)
        .select_related("user__profile")
        .order_by("joined_at", "pk")
    )


def _deactivate(workspace: Workspace, user_id: Any) -> None:
    """Mark removed and kill every pending invitation the user created in this workspace."""
    now = timezone.now()
    with transaction.atomic():
        updated = WorkspaceMember.objects.filter(
            workspace=workspace, user_id=user_id, status=MemberStatus.ACTIVE
        ).update(status=MemberStatus.REMOVED, removed_at=now)
        if updated == 0:
            raise ApiError("No such member.", status=404)
        Invitation.objects.filter(
            workspace=workspace, created_by_id=user_id, revoked_at__isnull=True
        ).update(revoked_at=now)


def remove(workspace: Workspace, actor: Any, user_id: str) -> None:
    if workspace.created_by_id != actor.pk:
        raise ApiError("Only the owner can remove members.", status=403)
    try:
        target = uuid.UUID(str(user_id))
    except ValueError:
        raise ApiError("No such member.", status=404) from None
    if target == workspace.created_by_id:
        raise _owner_protected()
    _deactivate(workspace, target)


def leave(workspace: Workspace, actor: Any) -> None:
    if workspace.created_by_id == actor.pk:
        raise _owner_protected()
    _deactivate(workspace, actor.pk)
