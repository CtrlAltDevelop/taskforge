"""Phase 05: the project permission keys. Owner and Admin hold all; Member may create."""

from django.db import migrations

from infrastructure.workspaces.seed import grant_to_builtins

ADDED_GRANTS = {
    "project.create": ("Owner", "Admin", "Member"),
    "project.update": ("Owner", "Admin"),
    "project.archive": ("Owner", "Admin"),
    "project.member.manage": ("Owner", "Admin"),
    "project.view_private": ("Owner", "Admin"),
}


def grant(apps, schema_editor):  # type: ignore[no-untyped-def]
    role_model = apps.get_model("workspaces", "Role")
    grant_model = apps.get_model("workspaces", "RolePermission")
    for key, roles in ADDED_GRANTS.items():
        grant_to_builtins(role_model, grant_model, key, roles)


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0008_invitation_role")]
    operations = [migrations.RunPython(grant, migrations.RunPython.noop)]
