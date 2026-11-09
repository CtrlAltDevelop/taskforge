from typing import Any

from django.apps import AppConfig
from django.db import connections
from django.db.models.signals import post_migrate

from infrastructure.common.appsettings import AppSettings


class WorkspacesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.workspaces"
    label = "workspaces"
    verbose_name = "Workspaces"

    settings_spec = AppSettings(
        title="Workspaces",
        summary="The top-level tenant container; every project and task belongs to one.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.workspaces import invite_mail  # noqa: F401  (connects the receiver)

        post_migrate.connect(_reseed_builtin_roles, sender=self)


def _reseed_builtin_roles(using: str = "default", **kwargs: Any) -> None:
    """Recreate missing built-in roles after a flush (the test suite); never edits existing ones.

    Migration 0005 seeds real databases; this only matters where tables are emptied. Grants come
    from the migrations (``migrated_grants``), not the live registry, so a key added without
    a migration is not papered over here.
    """
    from infrastructure.workspaces.models import Role, RolePermission
    from infrastructure.workspaces.seed import migrated_grants, seed_builtin_roles

    if Role._meta.db_table not in connections[using].introspection.table_names():
        return  # migrated back below the roles migration
    seed_builtin_roles(Role, RolePermission, migrated_grants())
