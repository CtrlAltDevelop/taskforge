from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class TimeTrackingConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.timetracking"
    label = "timetracking"
    verbose_name = "Time tracking"

    settings_spec = AppSettings(
        title="Time tracking",
        summary="A server-side timer, manual entries, estimates and weekly timesheets.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.timetracking import receivers

        receivers.connect()
