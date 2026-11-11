from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class SearchConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.search"
    label = "search"
    verbose_name = "Search"

    settings_spec = AppSettings(
        title="Search",
        summary="One search box over tasks, comments, projects and people, permission-filtered.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.search import receivers

        receivers.connect()
