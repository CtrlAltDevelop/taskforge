"""``can`` and ``require``: the only place a permission is decided.

Every service calls ``require`` (or ``can``) with the actor and the workspace;
adapters never decide. A non-member, a removed member and an unknown workspace
all get the same uniform 403 with no reason, so tenants cannot be probed. A
member who lacks a permission gets ``PermissionDenied`` carrying
``{permission, role, hint}`` -- REST envelope ``data`` / gRPC ``x-error-*-bin``
trailers.

There is no cache: one indexed query per check, and ``require`` returns the
``Grant`` it loaded so a service that needs the actor's keys again (escalation
checks) reuses it. Nothing outlives the call, so a role change applies at once.
"""

import uuid
from collections.abc import Iterable
from dataclasses import dataclass
from typing import Any

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces.models import (
    MemberStatus,
    Role,
    RolePermission,
    Workspace,
    WorkspaceMember,
)
from infrastructure.workspaces.registry import ALL_KEYS, OWNER


@dataclass(frozen=True, slots=True)
class Decision:
    allowed: bool
    permission: str
    role: str  # the actor's role name; "" when the actor is not a member
    hint: str  # "missing: x; your role: Y" when denied, "" when allowed


@dataclass(frozen=True, slots=True)
class Grant:
    """What an active member holds in one workspace."""

    role: Role
    keys: frozenset[str]


class PermissionDenied(ApiError):
    """403 with the reason: ``data = {permission, role, hint}``."""

    def __init__(self, permission: str, role: str, hint: str) -> None:
        super().__init__(
            hint,
            status=403,
            title=ResponseTitle.PERMISSION_DENIED_REASON,
            data={"permission": permission, "role": role, "hint": hint},
        )


def forbidden() -> ApiError:
    """The uniform refusal: identical for non-members and missing workspaces."""
    return ApiError("No access to that workspace.", status=403, title=ResponseTitle.FORBIDDEN)


def _workspace_id(resource: Any) -> uuid.UUID | None:
    raw = getattr(resource, "workspace_id", None) or getattr(resource, "pk", resource)
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        return None


def role_keys(role: Role) -> frozenset[str]:
    return frozenset(
        RolePermission.objects.filter(role=role).values_list("permission_key", flat=True)
    )


def grant_of(actor: Any, resource: Any) -> Grant | None:
    """The actor's role and keys in the resource's workspace, or None if not an active member."""
    workspace_id = _workspace_id(resource)
    if workspace_id is None or actor is None or not getattr(actor, "is_authenticated", False):
        return None
    member = (
        WorkspaceMember.objects.filter(
            workspace_id=workspace_id, user=actor, status=MemberStatus.ACTIVE
        )
        .select_related("role")
        .first()
    )
    return None if member is None else Grant(member.role, role_keys(member.role))


def _decision(permission: str, grant: Grant | None) -> Decision:
    if permission not in ALL_KEYS:
        raise ValueError(f"unknown permission key {permission!r}; add it to registry.py")
    if grant is None:
        return Decision(False, permission, "", "")
    if permission in grant.keys:
        return Decision(True, permission, grant.role.name, "")
    return Decision(False, permission, grant.role.name, _hint([permission], grant.role.name))


def _hint(missing: Iterable[str], role: str) -> str:
    return f"missing: {', '.join(missing)}; your role: {role}"


def can(actor: Any, permission: str, resource: Any = None) -> Decision:
    """Decide without raising. ``resource`` is a Workspace, or anything with ``workspace_id``.

    Phase 05+ passes a project/task here so per-project overrides can apply; for now
    only its workspace matters. ``None`` has no workspace, so it is denied.
    """
    return _decision(permission, grant_of(actor, resource))


def lock(workspace: Workspace) -> None:
    """Row-lock the workspace (inside a transaction) to serialise membership and role changes.

    Take it BEFORE ``require``: a demotion committed ahead of us is then visible to our grant
    load, so an actor demoted while queued cannot finish what they started.
    """
    Workspace.objects.select_for_update().filter(pk=workspace.pk).first()


def require(actor: Any, permission: str, workspace: Any) -> Grant:
    """Raise unless the actor holds ``permission`` in ``workspace``; return what they hold."""
    grant = grant_of(actor, workspace)
    decision = _decision(permission, grant)
    if grant is None:
        raise forbidden()
    if not decision.allowed:
        raise PermissionDenied(permission, decision.role, decision.hint)
    return grant


def require_holds(grant: Grant, keys: Iterable[str]) -> None:
    """Escalation guard: the actor may only hand out or touch what they hold themselves."""
    missing = sorted(set(keys) - grant.keys)
    if missing:
        raise PermissionDenied(missing[0], grant.role.name, _hint(missing, grant.role.name))


def builtin_role(name: str) -> Role:
    return Role.objects.get(workspace=None, is_builtin=True, name=name)


def is_owner_role(role: Role) -> bool:
    return role.is_builtin and role.name == OWNER


def owner_workspace_ids(actor: Any) -> set[uuid.UUID]:
    """Ids of the workspaces where the actor is an active Owner (for ``is_owner`` flags)."""
    rows = WorkspaceMember.objects.filter(
        user=actor, status=MemberStatus.ACTIVE, role__is_builtin=True, role__name=OWNER
    )
    return set(rows.values_list("workspace_id", flat=True))


def check(actor: Any, workspace: Any, keys: Iterable[str]) -> tuple[Grant, dict[str, bool]]:
    """Answer many keys with one load; unknown keys are simply False."""
    grant = grant_of(actor, workspace)
    if grant is None:
        raise forbidden()
    return grant, {key: key in grant.keys for key in keys}
