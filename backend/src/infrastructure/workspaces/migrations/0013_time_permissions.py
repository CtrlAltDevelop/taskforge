"""Phase 21: logging time (Owner, Admin, Member) and managing other people's time (Owner, Admin)."""

from django.db import migrations

from infrastructure.workspaces.seed import grant_to_builtins

ADDED_GRANTS = {
    "time.log": ("Owner", "Admin", "Member"),
    "time.edit_others": ("Owner", "Admin"),
}


def grant(apps, schema_editor):  # type: ignore[no-untyped-def]
    role_model = apps.get_model("workspaces", "Role")
    grant_model = apps.get_model("workspaces", "RolePermission")
    for key, roles in ADDED_GRANTS.items():
        grant_to_builtins(role_model, grant_model, key, roles)


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0012_attachment_permission")]
    operations = [migrations.RunPython(grant, migrations.RunPython.noop)]
