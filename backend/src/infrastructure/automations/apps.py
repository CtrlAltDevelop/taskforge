from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class AutomationsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.automations"
    label = "automations"
    verbose_name = "Automations"

    settings_spec = AppSettings(
        title="Automations",
        summary="When-if-then rules on a project's tasks, with run history and loop guards.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.automations import receivers

        receivers.connect()
