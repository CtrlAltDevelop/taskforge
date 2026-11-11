from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class CommentsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.comments"
    label = "comments"
    verbose_name = "Comments"

    settings_spec = AppSettings(
        title="Comments",
        summary="Threaded task comments with mentions, reactions and edit history.",
        requirements=(),
    )
