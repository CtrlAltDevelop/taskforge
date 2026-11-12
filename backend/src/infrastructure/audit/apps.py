from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class AuditConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.audit"
    label = "audit"
    verbose_name = "Audit log"

    settings_spec = AppSettings(
        title="Audit log",
        summary="An append-only record of who changed what, per workspace and per task.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.audit import receivers

        receivers.connect()
