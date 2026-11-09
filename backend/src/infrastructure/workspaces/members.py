"""Who is in a workspace: listing, removing, leaving, changing roles.

Permissions: ``member.view`` lists, ``member.remove`` removes, ``member.set_role``
changes a role; leaving is self-service. Nobody may act on a member whose role holds
permissions they lack themselves (so an Admin cannot remove or demote an Owner).
The last Owner can be neither demoted, removed nor leave (``OWNER_PROTECTED``); with
another Owner present an Owner may. Every change takes the workspace row lock *before*
loading the actor's grant, so two owners cannot remove each other at once and a demotion
queued ahead of an action is seen by it.
"""

import uuid
from typing import Any

from django.db import transaction
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import access, roles
from infrastructure.workspaces.models import (
    Invitation,
    MemberStatus,
    Workspace,
    WorkspaceMember,
)
from infrastructure.workspaces.registry import OWNER


def _owner_protected() -> ApiError:
    return ApiError(
        "The last owner cannot be demoted, removed or leave. Make someone else an owner first.",
        status=403,
        title=ResponseTitle.OWNER_PROTECTED,
    )


def _active(workspace: Workspace) -> Any:
    return WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE)


def _guard_last_owner(workspace: Workspace, target: WorkspaceMember) -> None:
    """Refuse if ``target`` is the only active Owner (call inside the locked transaction)."""
    owners = _active(workspace).filter(role__is_builtin=True, role__name=OWNER).count()
    if access.is_owner_role(target.role) and owners <= 1:
        raise _owner_protected()


def _target(workspace: Workspace, user_id: str) -> WorkspaceMember:
    try:
        pk = uuid.UUID(str(user_id))
    except ValueError:
        raise ApiError("No such member.", status=404) from None
    member = _active(workspace).select_related("role").filter(user_id=pk).first()
    if member is None:
        raise ApiError("No such member.", status=404)
    return member


def list_members(workspace: Workspace, actor: Any) -> list[WorkspaceMember]:
    access.require(actor, "member.view", workspace)
    return list(
        _active(workspace).select_related("user__profile", "role").order_by("joined_at", "pk")
    )


def _deactivate(workspace: Workspace, member: WorkspaceMember) -> None:
    """Mark removed and kill every pending invitation the user created in this workspace."""
    now = timezone.now()
    WorkspaceMember.objects.filter(pk=member.pk).update(status=MemberStatus.REMOVED, removed_at=now)
    Invitation.objects.filter(
        workspace=workspace, created_by_id=member.user_id, revoked_at__isnull=True
    ).update(revoked_at=now)


def remove(workspace: Workspace, actor: Any, user_id: str) -> None:
    with transaction.atomic():
        access.lock(workspace)  # before loading the grant, so a demotion ahead of us is honoured
        grant = access.require(actor, "member.remove", workspace)
        target = _target(workspace, user_id)
        access.require_holds(grant, access.role_keys(target.role))
        _guard_last_owner(workspace, target)
        _deactivate(workspace, target)


def leave(workspace: Workspace, actor: Any) -> None:
    """Self-service: no permission key, but the last Owner still cannot leave."""
    with transaction.atomic():
        access.lock(workspace)
        member = _active(workspace).select_related("role").filter(user=actor).first()
        if member is None:
            raise access.forbidden()
        _guard_last_owner(workspace, member)
        _deactivate(workspace, member)


def set_role(workspace: Workspace, actor: Any, user_id: str, role_id: str) -> WorkspaceMember:
    with transaction.atomic():
        access.lock(workspace)  # before loading the grant, so a demotion ahead of us is honoured
        grant = access.require(actor, "member.set_role", workspace)
        role = roles.visible_role(workspace, role_id)
        target = _target(workspace, user_id)
        if target.role_id == role.pk:
            return target
        access.require_holds(grant, access.role_keys(target.role))
        access.require_holds(grant, access.role_keys(role))
        if not access.is_owner_role(role):
            _guard_last_owner(workspace, target)
        WorkspaceMember.objects.filter(pk=target.pk).update(role=role)
    return _target(workspace, user_id)
