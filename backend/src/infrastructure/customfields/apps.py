from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class CustomFieldsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.customfields"
    label = "customfields"
    verbose_name = "Custom fields"

    settings_spec = AppSettings(
        title="Custom fields",
        summary="Typed per-project fields whose values live on tasks.",
        requirements=(),
    )
