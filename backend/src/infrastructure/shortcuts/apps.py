from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class ShortcutsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.shortcuts"
    label = "shortcuts"
    verbose_name = "Shortcuts"

    settings_spec = AppSettings(
        title="Shortcuts",
        summary="Each person's own keyboard shortcuts, synced across devices.",
        requirements=(),
    )
