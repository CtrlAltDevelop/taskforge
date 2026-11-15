"""Phase 43: chat. Everyone but a Viewer (guests) reads, posts and creates; Owner and Admin hold
all of them and so may also archive and moderate other people's spaces."""

from django.db import migrations

from infrastructure.workspaces.seed import grant_to_builtins

ADDED_GRANTS = {
    "chat.read": ("Owner", "Admin", "Member"),
    "chat.post": ("Owner", "Admin", "Member"),
    "chat.manage": ("Owner", "Admin", "Member"),
}


def grant(apps, schema_editor):  # type: ignore[no-untyped-def]
    role_model = apps.get_model("workspaces", "Role")
    grant_model = apps.get_model("workspaces", "RolePermission")
    for key, roles in ADDED_GRANTS.items():
        grant_to_builtins(role_model, grant_model, key, roles)


class Migration(migrations.Migration):
    dependencies = [("workspaces", "0026_security_permissions")]
    operations = [migrations.RunPython(grant, migrations.RunPython.noop)]
