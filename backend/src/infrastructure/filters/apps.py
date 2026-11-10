from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class FiltersConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.filters"
    label = "filters"
    verbose_name = "Filters"

    settings_spec = AppSettings(
        title="Filters",
        summary="The TFQL query language and saved filters, applied to a project's task views.",
        requirements=(),
    )
