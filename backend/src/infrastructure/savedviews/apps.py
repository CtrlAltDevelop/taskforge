from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class SavedViewsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.savedviews"
    label = "savedviews"
    verbose_name = "Saved views"

    settings_spec = AppSettings(
        title="Saved views",
        summary="Per-user and shared layouts (columns, sort, grouping) for a project's views.",
        requirements=(),
    )
