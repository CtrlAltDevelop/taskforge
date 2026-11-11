from django.apps import AppConfig

from infrastructure.common.appsettings import AppSettings


class DocsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "infrastructure.docs"
    label = "wikidocs"  # not "docs": that word is taken by the project's own documentation tooling
    verbose_name = "Docs"

    settings_spec = AppSettings(
        title="Docs",
        summary="A wiki: nested pages of blocks, task embeds, backlinks, revisions, export.",
        requirements=(),
    )
