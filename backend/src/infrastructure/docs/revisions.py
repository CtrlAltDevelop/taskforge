"""A page's history: one revision per burst of editing, the oldest pruned.

A save by the person who made the newest revision, within ``REVISION_WINDOW`` of when that
revision *began*, folds into it (so a long editing session is one revision per five minutes, not
one per autosave). A save by someone else, a later one, or a restore starts a new revision. Only
the newest ``keep()`` are retained.
"""

from datetime import timedelta
from typing import Any, Final

from django.conf import settings
from django.utils import timezone

from infrastructure.docs.models import Doc, DocContent, DocRevision

REVISION_WINDOW: Final = timedelta(minutes=5)
DEFAULT_KEEP: Final = 50


def keep() -> int:
    return max(int(getattr(settings, "DOCS_REVISION_KEEP", DEFAULT_KEEP)), 1)


def record(doc: Doc, content: DocContent, actor: Any, *, new: bool = False) -> DocRevision:
    """Capture the page as it now is; ``new`` always starts a revision (a restore, a creation)."""
    now = timezone.now()
    last = DocRevision.objects.filter(doc=doc).order_by("-id").first()
    values = {
        "title": doc.title,
        "blocks": content.blocks,
        "schema_version": content.schema_version,
        "version": content.version,
        "saved_at": now,
    }
    if (
        not new
        and last is not None
        and last.author_id == actor.pk
        and now - last.at < REVISION_WINDOW
    ):
        for name, value in values.items():
            setattr(last, name, value)
        last.save(update_fields=list(values))
        return last
    made = DocRevision.objects.create(doc=doc, author=actor, at=now, **values)
    prune(doc)
    return made


def prune(doc: Doc) -> int:
    stale = list(
        DocRevision.objects.filter(doc=doc).order_by("-id").values_list("pk", flat=True)[keep() :]
    )
    if stale:
        DocRevision.objects.filter(pk__in=stale).delete()
    return len(stale)
