"""Phase 37: managing the workspace's two-factor policy and single sign-on (Owner, Admin)."""

from django.db import migrations

from infrastructure.workspaces.seed import grant_to_builtins

ADDED_GRANTS = {
    "security.manage": ("Owner", "Admin"),
}


def grant(apps, schema_editor):  # type: ignore[no-untyped-def]
    role_model = apps.get_model("workspaces", "Role")
    grant_model = apps.get_model("workspaces", "RolePermission")
    for key, roles in ADDED_GRANTS.items():
        grant_to_builtins(role_model, grant_model, key, roles)


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0025_workload_permissions")]
    operations = [migrations.RunPython(grant, migrations.RunPython.noop)]
