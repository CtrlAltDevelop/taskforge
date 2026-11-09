"""Phase 06: the task permission keys. Owner, Admin and Member hold all three."""

from django.db import migrations

from infrastructure.workspaces.seed import grant_to_builtins

ADDED_GRANTS = {
    "task.create": ("Owner", "Admin", "Member"),
    "task.update": ("Owner", "Admin", "Member"),
    "task.delete": ("Owner", "Admin", "Member"),
}


def grant(apps, schema_editor):  # type: ignore[no-untyped-def]
    role_model = apps.get_model("workspaces", "Role")
    grant_model = apps.get_model("workspaces", "RolePermission")
    for key, roles in ADDED_GRANTS.items():
        grant_to_builtins(role_model, grant_model, key, roles)


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0009_project_permissions")]
    operations = [migrations.RunPython(grant, migrations.RunPython.noop)]
