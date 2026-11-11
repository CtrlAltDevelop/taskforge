from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class SprintsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.sprints"
    label = "sprints"
    verbose_name = "Sprints"

    settings_spec = AppSettings(
        title="Sprints",
        summary="Time-boxed sprints, a backlog, carry-over, burndown and velocity.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.sprints import receivers

        receivers.connect()
