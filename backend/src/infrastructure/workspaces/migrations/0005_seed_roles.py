"""Seed the built-in roles and give every existing member one.

Owner if the member is the workspace's creator, otherwise Member. Removed members
get one too so the next migration can make the column required.

The grants are frozen here as of phase 04 on purpose: a migration must not read the
live registry. A permission key added later is granted by its own migration, which
declares ``ADDED_GRANTS`` (see ``registry.py``).
"""

from django.db import migrations

from infrastructure.workspaces.seed import seed_builtin_roles

_VIEWER = frozenset({"workspace.view", "member.view", "role.view"})
_ALL = frozenset(
    {
        "workspace.view",
        "workspace.update",
        "workspace.delete",
        "member.view",
        "member.invite",
        "member.remove",
        "member.set_role",
        "role.view",
        "role.manage",
    }
)
INITIAL_GRANTS = {
    "Owner": _ALL,
    "Admin": _ALL - {"workspace.delete"},
    "Member": _VIEWER | {"member.invite"},
    "Viewer": _VIEWER,
}


def forwards(apps, schema_editor):  # type: ignore[no-untyped-def]
    role_model = apps.get_model("workspaces", "Role")
    seed_builtin_roles(role_model, apps.get_model("workspaces", "RolePermission"), INITIAL_GRANTS)
    owner = role_model.objects.get(workspace=None, name="Owner")
    member = role_model.objects.get(workspace=None, name="Member")
    members = apps.get_model("workspaces", "WorkspaceMember").objects
    for row in members.select_related("workspace"):
        row.role = owner if row.user_id == row.workspace.created_by_id else member
        row.save(update_fields=["role"])


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0004_roles")]
    operations = [migrations.RunPython(forwards, migrations.RunPython.noop)]
