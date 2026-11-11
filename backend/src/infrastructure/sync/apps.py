from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class SyncConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.sync"
    label = "sync"
    verbose_name = "Realtime sync"

    settings_spec = AppSettings(
        title="Realtime sync",
        summary="The change log, the sync WebSocket (rooms, presence) and catch-up after a gap.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.sync import receivers

        receivers.connect()
