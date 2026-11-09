"""Roles: the four built-ins plus a workspace's custom roles.

Built-ins (``workspace`` NULL) are shared, read-only and cannot be deleted. A custom
role is a name plus a checklist of registry keys. ``role.view`` lists, ``role.manage``
creates/edits/deletes. Escalation rule: nobody may put into a role, or edit a role
holding, a permission they lack themselves. Deleting a custom role moves its members
to a role you name.
"""

from collections.abc import Iterable
from dataclasses import dataclass
from typing import Any, Final

from django.db import IntegrityError, transaction
from django.db.models import Count, F, Q
from django.db.models.functions import Lower

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Role, RolePermission, Workspace
from infrastructure.workspaces.registry import ALL_KEYS, BUILTIN_ROLES

NAME_MAX_LENGTH: Final = 60


@dataclass(frozen=True, slots=True)
class RoleView:
    role: Role
    permissions: list[str]
    member_count: int


def _no_such_role() -> ApiError:
    return ApiError("No such role.", status=404)


def visible_role(workspace: Workspace, role_id: str) -> Role:
    """A built-in or this workspace's role; any other id (another tenant's) is a 404."""
    try:
        pk = int(role_id)
    except (TypeError, ValueError):
        raise _no_such_role() from None
    role = Role.objects.filter(Q(workspace=workspace) | Q(workspace__isnull=True), pk=pk).first()
    if role is None:
        raise _no_such_role()
    return role


def _custom(workspace: Workspace, role_id: str) -> Role:
    role = visible_role(workspace, role_id)
    if role.is_builtin:
        raise ApiError(
            "Built-in roles cannot be changed or deleted.",
            status=403,
            title=ResponseTitle.ROLE_BUILTIN,
        )
    return role


def _clean_name(workspace: Workspace, name: str, current: Role | None = None) -> str:
    cleaned = name.strip()
    if not cleaned or len(cleaned) > NAME_MAX_LENGTH:
        raise ApiError(f"The role name must be 1-{NAME_MAX_LENGTH} characters.")
    taken = Role.objects.filter(Q(workspace=workspace) | Q(workspace__isnull=True)).annotate(
        folded=Lower("name")
    )
    if current is not None:
        taken = taken.exclude(pk=current.pk)
    if taken.filter(folded=cleaned.lower()).exists():
        raise ApiError(
            "A role with that name already exists.", status=409, title=ResponseTitle.ROLE_NAME_TAKEN
        )
    return cleaned


def _clean_keys(permissions: Iterable[str]) -> frozenset[str]:
    keys = frozenset(permissions)
    unknown = sorted(keys - ALL_KEYS)
    if unknown:
        raise ApiError(f"Unknown permissions: {', '.join(unknown)}.")
    return keys


def _write_keys(role: Role, keys: frozenset[str]) -> None:
    RolePermission.objects.filter(role=role).exclude(permission_key__in=keys).delete()
    for key in sorted(keys):
        RolePermission.objects.get_or_create(role=role, permission_key=key)


def list_roles(workspace: Workspace, actor: Any) -> list[RoleView]:
    access.require(actor, "role.view", workspace)
    rows = (
        Role.objects.filter(Q(workspace=workspace) | Q(workspace__isnull=True))
        .annotate(
            members_here=Count(
                "members",
                filter=Q(members__workspace=workspace, members__status=MemberStatus.ACTIVE),
            )
        )
        .prefetch_related("permissions")
    )
    order = {name: i for i, name in enumerate(BUILTIN_ROLES)}
    ranked = sorted(
        rows,
        key=lambda r: (
            order.get(r.name, len(order)) if r.is_builtin else len(order),
            r.name.lower(),
        ),
    )
    return [
        RoleView(r, sorted(p.permission_key for p in r.permissions.all()), r.members_here)
        for r in ranked
    ]


def view_of(workspace: Workspace, role: Role) -> RoleView:
    count = role.members.filter(workspace=workspace, status=MemberStatus.ACTIVE).count()
    return RoleView(role, sorted(access.role_keys(role)), count)


def _conflict() -> ApiError:
    return ApiError(
        "The role changed since you loaded it; reload and retry.",
        status=409,
        title=ResponseTitle.VERSION_CONFLICT,
    )


def _name_taken() -> ApiError:
    return ApiError(
        "A role with that name already exists.", status=409, title=ResponseTitle.ROLE_NAME_TAKEN
    )


def create_role(
    workspace: Workspace, actor: Any, name: str, permissions: Iterable[str]
) -> RoleView:
    with transaction.atomic():
        access.lock(workspace)
        grant = access.require(actor, "role.manage", workspace)
        keys = _clean_keys(permissions)
        access.require_holds(grant, keys)
        cleaned = _clean_name(workspace, name)
        try:
            with transaction.atomic():
                role = Role.objects.create(workspace=workspace, name=cleaned)
                _write_keys(role, keys)
        except IntegrityError:
            raise _name_taken() from None
        return view_of(workspace, role)


def update_role(
    workspace: Workspace,
    actor: Any,
    role_id: str,
    expected_version: int,
    name: str | None = None,
    permissions: Iterable[str] | None = None,
) -> RoleView:
    """Rename and/or replace the checklist (``permissions=None`` keeps it).

    Optimistic lock: a stale ``expected_version`` is a 409 VERSION_CONFLICT and changes nothing.
    """
    with transaction.atomic():
        access.lock(workspace)
        grant = access.require(actor, "role.manage", workspace)
        role = _custom(workspace, role_id)
        new_keys = None if permissions is None else _clean_keys(permissions)
        access.require_holds(grant, access.role_keys(role) | (new_keys or frozenset()))
        cleaned = None if name is None else _clean_name(workspace, name, role)
        try:
            with transaction.atomic():
                changes = {} if cleaned is None else {"name": cleaned}
                bumped = Role.objects.filter(pk=role.pk, version=expected_version).update(
                    version=F("version") + 1, **changes
                )
                if not bumped:
                    raise _conflict()
                if new_keys is not None:
                    _write_keys(role, new_keys)
        except IntegrityError:
            raise _name_taken() from None
        return view_of(workspace, Role.objects.get(pk=role.pk))


def delete_role(workspace: Workspace, actor: Any, role_id: str, reassign_to: str = "") -> None:
    """Delete a custom role; its members (any status) move to ``reassign_to``."""
    with transaction.atomic():
        access.lock(workspace)
        grant = access.require(actor, "role.manage", workspace)
        role = _custom(workspace, role_id)
        holders = role.members.all()
        if holders.exists():
            if not reassign_to:
                raise ApiError("Choose a role to move this role's members to.")
            target = visible_role(workspace, reassign_to)
            if target.pk == role.pk:
                raise ApiError("Choose a different role to move the members to.")
            access.require_holds(grant, access.role_keys(role) | access.role_keys(target))
            holders.update(role=target)
        role.delete()
