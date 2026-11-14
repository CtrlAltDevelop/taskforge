from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class GoalsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.goals"
    label = "goals"
    verbose_name = "Goals"

    settings_spec = AppSettings(
        title="Goals",
        summary="Goals (OKRs) with key results that update from tasks or by check-ins.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.common import dueworkers
        from infrastructure.goals import receivers, recompute

        receivers.connect()
        dueworkers.register("goals.recompute", recompute.process_due)
