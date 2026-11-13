from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class FormsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.forms"
    label = "forms"
    verbose_name = "Intake forms"

    settings_spec = AppSettings(
        title="Intake forms",
        summary="Public forms that let people outside the workspace create tasks.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.forms import receivers

        receivers.connect()
