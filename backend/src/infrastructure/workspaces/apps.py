from django.apps import AppConfig

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
