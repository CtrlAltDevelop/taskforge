from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class InboxConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.inbox"
    label = "inbox"
    verbose_name = "Notifications"

    settings_spec = AppSettings(
        title="Notifications",
        summary="Inbox, watchers, preferences, quiet hours, push and email digests.",
        requirements=(),
    )

    def ready(self) -> None:
        from infrastructure.inbox import receivers

        receivers.connect()
