from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class WorkflowsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.workflows"
    label = "workflows"
    verbose_name = "Workflows"

    settings_spec = AppSettings(
        title="Workflows",
        summary="Per-project statuses, categories and optional transition rules.",
        requirements=(),
    )
