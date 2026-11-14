from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class SecurityConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.security"
    label = "security"
    verbose_name = "Security"

    settings_spec = AppSettings(
        title="Security",
        summary=(
            "Workspace two-factor policy, trusted devices and OpenID Connect single sign-on. "
            "Secrets are encrypted with DJANGO_FIELD_ENCRYPTION_KEY."
        ),
        requirements=(),
    )
