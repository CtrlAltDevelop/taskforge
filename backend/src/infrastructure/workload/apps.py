from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class WorkloadConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.workload"
    label = "workload"
    verbose_name = "Workload"

    settings_spec = AppSettings(
        title="Workload",
        summary="Capacity, time off and holidays, and a per-person view of load against capacity.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.workload import receivers

        receivers.connect()
