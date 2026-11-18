from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class HomeConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.home"
    label = "home"
    verbose_name = "Home"

    settings_spec = AppSettings(
        title="Home",
        summary="The Home summary, My work, first-run onboarding and the recently opened list.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.home import receivers  # noqa: F401
