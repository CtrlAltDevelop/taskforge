from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class DashboardsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.dashboards"
    label = "dashboards"
    verbose_name = "Dashboards"

    settings_spec = AppSettings(
        title="Dashboards",
        summary="Dashboards of chart widgets driven by TFQL filters, with drill-down to the tasks.",
        requirements=(),
    )
