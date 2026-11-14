"""Phase 34: creating goals (Owner, Admin, Member) and managing every goal (Owner, Admin)."""

from django.db import migrations

from infrastructure.workspaces.seed import grant_to_builtins

ADDED_GRANTS = {
    "goal.create": ("Owner", "Admin", "Member"),
    "goal.manage": ("Owner", "Admin"),
}


def grant(apps, schema_editor):  # type: ignore[no-untyped-def]
    role_model = apps.get_model("workspaces", "Role")
    grant_model = apps.get_model("workspaces", "RolePermission")
    for key, roles in ADDED_GRANTS.items():
        grant_to_builtins(role_model, grant_model, key, roles)


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0022_form_permission")]
    operations = [migrations.RunPython(grant, migrations.RunPython.noop)]
