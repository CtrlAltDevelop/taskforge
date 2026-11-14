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
    Permission("project.create", "Create projects"),
    Permission("project.update", "Edit a project: name, key, look, visibility, features"),
    Permission("project.archive", "Archive and restore projects"),
    Permission("project.member.manage", "Add and remove members of private projects"),
    Permission("project.view_private", "List the workspace's private projects (admin list)"),
    Permission("task.create", "Create tasks"),
    Permission("task.update", "Edit tasks and their assignees"),
    Permission("task.delete", "Delete and restore tasks"),
    Permission("task.attachment_manage", "Delete anyone's attachments"),
    Permission("comment.create", "Write comments and react to them"),
    Permission("comment.moderate", "Delete anyone's comments and pin them"),
    Permission("time.log", "Track time and log your own time entries"),
    Permission("time.edit_others", "See and edit other people's time entries and timesheets"),
    Permission("sprint.manage", "Plan, start and complete sprints and move tasks in and out"),
    Permission("doc.edit", "Create, edit, move, archive and restore pages and their history"),
    Permission("doc.manage", "Restrict pages, choose who may open them, open any restricted page"),
    Permission("automation.manage", "Create, edit, switch on and off, test and delete automations"),
    Permission("audit.view", "Read and export the workspace audit log"),
    Permission(
        "dashboard.manage", "Share dashboards with a project or the workspace, edit shared ones"
    ),
    Permission("data.manage", "Import projects from other tools, undo an import, export data"),
    Permission("webhook.manage", "Create, edit and delete webhooks and see what was sent"),
    Permission("form.manage", "Create, edit and delete intake forms and read their submissions"),
    Permission("goal.create", "Create goals and key results"),
    Permission(
        "goal.manage", "Edit, delete and see every goal, private ones too, and manage folders"
    ),
    Permission("template.create", "Save tasks and projects as templates"),
    Permission("template.manage", "Edit and delete every shared template"),
)
ALL_KEYS: Final = frozenset(p.key for p in PERMISSIONS)

TASK_KEYS = frozenset({"task.create", "task.update", "task.delete"})
_VIEWER_KEYS = frozenset({"workspace.view", "member.view", "role.view"})
BUILTIN_GRANTS: Final[dict[str, frozenset[str]]] = {
    OWNER: ALL_KEYS,
    ADMIN: ALL_KEYS - {"workspace.delete"},
    MEMBER: _VIEWER_KEYS
    | {
        "member.invite",
        "project.create",
        "comment.create",
        "time.log",
        "sprint.manage",
        "doc.edit",
        "goal.create",
        "template.create",
        *TASK_KEYS,
    },  # 03: any member may invite
    VIEWER: _VIEWER_KEYS,
}


def areas() -> list[tuple[str, list[Permission]]]:
    """Permissions grouped by area, in registry order (for the matrix screen)."""
    grouped: dict[str, list[Permission]] = {}
    for permission in PERMISSIONS:
        grouped.setdefault(permission.area, []).append(permission)
    return list(grouped.items())
