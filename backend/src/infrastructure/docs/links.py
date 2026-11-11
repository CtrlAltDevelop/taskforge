"""``DocLink`` rows: what a page points at, rebuilt from its body on every save."""

import uuid
from collections.abc import Iterable

from infrastructure.docs.models import Doc, DocLink, LinkKind
from infrastructure.tasks.models import Task


def sync(doc: Doc, doc_ids: Iterable[uuid.UUID], task_ids: Iterable[uuid.UUID]) -> None:
    """Make the ``mention`` and ``task_card`` rows of ``doc`` match the ids its body names.

    A mention of a page, or a card of a task, in another workspace (or of a page that does not
    exist) makes no row: the node stays in the body but points at nothing. ``related`` rows, made
    by hand, are never touched here.
    """
    pages = set(
        Doc.objects.filter(pk__in=list(doc_ids), workspace_id=doc.workspace_id)
        .exclude(pk=doc.pk)
        .values_list("pk", flat=True)
    )
    tasks = set(
        Task.objects.filter(pk__in=list(task_ids), workspace_id=doc.workspace_id).values_list(
            "pk", flat=True
        )
    )
    have = DocLink.objects.filter(doc=doc, kind__in=(LinkKind.MENTION, LinkKind.TASK_CARD))
    keep_mentions, keep_cards = set(), set()
    for row in have:
        if row.kind == LinkKind.MENTION and row.target_doc_id in pages:
            keep_mentions.add(row.target_doc_id)
        elif row.kind == LinkKind.TASK_CARD and row.task_id in tasks:
            keep_cards.add(row.task_id)
        else:
            row.delete()
    DocLink.objects.bulk_create(
        [DocLink(doc=doc, kind=LinkKind.MENTION, target_doc_id=p) for p in pages - keep_mentions]
        + [DocLink(doc=doc, kind=LinkKind.TASK_CARD, task_id=t) for t in tasks - keep_cards]
    )
