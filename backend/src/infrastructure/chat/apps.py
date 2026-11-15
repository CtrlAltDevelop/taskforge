from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class ChatConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.chat"
    label = "chat"
    verbose_name = "Chat"

    settings_spec = AppSettings(
        title="Chat",
        summary="Channels, private groups and direct messages with threads and mentions.",
        requirements=(),
    )
