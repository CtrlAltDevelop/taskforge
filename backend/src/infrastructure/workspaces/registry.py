"""The one list of permission keys, and what each built-in role holds.

Single source of truth for the matrix screen, ``require`` and the tests. The database
is seeded by migrations, never from this file. To add a key:

1. add it to ``PERMISSIONS`` and to ``BUILTIN_GRANTS`` below;
2. write a migration that calls ``seed.grant_to_builtins(Role, RolePermission, key, roles)``
   and declares ``ADDED_GRANTS = {"<key>": ("Owner", "Admin")}`` at module level.

``test_registry_grants_are_exactly_what_the_migrations_ship`` fails until both agree.
"""

from dataclasses import dataclass
from typing import Final

OWNER: Final = "Owner"
ADMIN: Final = "Admin"
MEMBER: Final = "Member"
VIEWER: Final = "Viewer"
BUILTIN_ROLES: Final = (OWNER, ADMIN, MEMBER, VIEWER)  # display order


@dataclass(frozen=True, slots=True)
class Permission:
    key: str
    label: str

    @property
    def area(self) -> str:
        return self.key.split(".", 1)[0]


PERMISSIONS: Final = (
    Permission("workspace.view", "See the workspace"),
    Permission("workspace.update", "Rename, change the URL name or logo"),
    Permission("workspace.delete", "Delete, restore and list deleted workspaces"),
    Permission("member.view", "See members"),
    Permission("member.invite", "Invite people, manage invitations"),
    Permission("member.remove", "Remove members"),
    Permission("member.set_role", "Change a member's role"),
    Permission("role.view", "See roles and the permission matrix"),
    Permission("role.manage", "Create, edit and delete custom roles"),
)
ALL_KEYS: Final = frozenset(p.key for p in PERMISSIONS)

_VIEWER_KEYS = frozenset({"workspace.view", "member.view", "role.view"})
BUILTIN_GRANTS: Final[dict[str, frozenset[str]]] = {
    OWNER: ALL_KEYS,
    ADMIN: ALL_KEYS - {"workspace.delete"},
    MEMBER: _VIEWER_KEYS | {"member.invite"},  # phase 03: any member may invite
    VIEWER: _VIEWER_KEYS,
}


def areas() -> list[tuple[str, list[Permission]]]:
    """Permissions grouped by area, in registry order (for the matrix screen)."""
    grouped: dict[str, list[Permission]] = {}
    for permission in PERMISSIONS:
        grouped.setdefault(permission.area, []).append(permission)
    return list(grouped.items())
