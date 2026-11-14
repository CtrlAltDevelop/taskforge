from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class TemplatesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.templates"
    label = "templates"
    verbose_name = "Templates"

    settings_spec = AppSettings(
        title="Templates",
        summary="Save a task tree or a whole project as a template and create new ones from it.",
        requirements=(),
    )
