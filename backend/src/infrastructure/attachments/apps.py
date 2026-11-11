from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class AttachmentsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.attachments"
    label = "attachments"
    verbose_name = "Attachments"

    settings_spec = AppSettings(
        title="Attachments",
        summary="Files on tasks and comments: chunked uploads, thumbnails, signed links.",
        requirements=(),
    )
