from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class DeveloperConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.developer"
    label = "developer"
    verbose_name = "Developer: API tokens and webhooks"

    settings_spec = AppSettings(
        title="API tokens and webhooks",
        summary="A public REST API for scripts and integrations, and signed outgoing webhooks.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.common import dueworkers
        from infrastructure.developer import delivery, receivers

        receivers.connect()
        dueworkers.register("webhooks.retry", delivery.retry_due)
