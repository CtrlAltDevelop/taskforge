from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class ProjectsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.projects"
    label = "projects"
    verbose_name = "Projects"

    settings_spec = AppSettings(
        title="Projects",
        summary="Projects inside a workspace: key, visibility, archive, favorites and features.",
        requirements=(),
    )
