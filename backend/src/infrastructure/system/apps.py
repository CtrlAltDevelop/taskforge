from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class SystemConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.system"
    label = "system"
    verbose_name = "System"

    settings_spec = AppSettings(
        title="System",
        summary=(
            "Version, health, metrics and error reporting for operators: GET /api/version, "
            "/api/health, a token-protected /metrics and the admin System page."
        ),
        requirements=(),
    )
