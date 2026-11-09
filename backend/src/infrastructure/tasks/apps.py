from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class TasksConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.tasks"
    label = "tasks"
    verbose_name = "Tasks"

    settings_spec = AppSettings(
        title="Tasks",
        summary="Tasks inside a project: fields, assignees, soft delete and a streamed list.",
        requirements=(),
    )
