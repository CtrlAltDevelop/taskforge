from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class ImportsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.imports"
    label = "imports"
    verbose_name = "Import and export"

    settings_spec = AppSettings(
        title="Import and export",
        summary="Bring projects in from Jira, ClickUp or CSV, undo an import, export everything.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.imports import receivers

        receivers.connect()
