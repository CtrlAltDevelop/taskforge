"""Catching up after a gap: what changed since a cursor, the cursor to start from, and trimming.

A cursor is a change-log id. A client keeps the last one it saw; after a dropped socket it asks for
everything after it and refetches only what those entries name. Entries are hints (type, ids, a
version), so reading them needs only workspace membership, and a private project's entries are left
out for those who cannot open it -- the cursor still moves past them.
"""

from dataclasses import dataclass
from datetime import timedelta
from typing import Any, Final

from django.db.models import Max
from django.utils import timezone

from infrastructure.projects.models import Project
from infrastructure.sync.models import ChangeLog, TrimMark
from infrastructure.sync.publish import RETENTION_DAYS
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "workspace.view"
DEFAULT_LIMIT: Final = 1000
MAX_LIMIT: Final = 5000


@dataclass(frozen=True, slots=True)
class Page:
    """``entries`` after the cursor the caller may see, oldest first. ``latest`` is the cursor to
    continue from (past entries left out too), ``more`` says the page was full, and ``gap`` says the
    cursor is older than the log still holds: nothing is listed and the caller must read its
    screens again."""

    entries: list[ChangeLog]
    latest: int
    more: bool
    gap: bool


def head(actor: Any, workspace: Workspace) -> int:
    """The workspace's latest cursor (0 when nothing was ever logged): where a client that has just
    read its screens starts listening from."""
    access.require(actor, VIEW, workspace)
    return int(ChangeLog.objects.filter(workspace=workspace).aggregate(m=Max("id"))["m"] or 0)


def since(
    actor: Any, workspace: Workspace, cursor: int, limit: int = DEFAULT_LIMIT, overlap: int = 0
) -> Page:
    access.require(actor, VIEW, workspace)
    size = max(1, min(limit or DEFAULT_LIMIT, MAX_LIMIT))
    mark = TrimMark.objects.filter(pk=1).first()
    if mark is not None and 0 < cursor < mark.upto:
        return Page([], head(actor, workspace), False, True)
    raw = list(
        ChangeLog.objects.filter(
            workspace=workspace, id__gt=max(cursor - max(overlap, 0), 0)
        ).order_by("id")[: size + 1]
    )
    more = len(raw) > size
    raw = raw[:size]
    visible = {
        pk for pk in Project.objects.visible_to(actor, workspace).values_list("pk", flat=True)
    }
    spaces = (
        _readable_spaces(actor, workspace) if any(r.entity_type == "chat" for r in raw) else set()
    )
    entries = [r for r in raw if _listed(r, actor, workspace, visible, spaces)]
    return Page(entries, raw[-1].pk if raw else max(cursor, 0), more, False)


def _readable_spaces(actor: Any, workspace: Workspace) -> set[str]:
    from infrastructure.chat import access as chat_access

    if "chat.read" not in (g.keys if (g := access.grant_of(actor, workspace)) else ()):
        return set()
    ids = chat_access.visible_spaces(actor, workspace).values_list("pk", flat=True)
    return {str(i) for i in ids}


def _listed(
    row: ChangeLog, actor: Any, workspace: Workspace, visible: set[Any], spaces: set[str]
) -> bool:
    """A project's entries for those who can open it; a workspace-level one for everyone, except an
    access change aimed at somebody else and a chat entry for a space the caller cannot read."""
    if row.project is not None:
        return row.project in visible
    if row.entity_type == "chat":
        if row.action == "read":
            return row.actor == str(actor.pk)
        return str(row.entity_id) in spaces
    if row.entity_type in ("notification", "timer"):
        return str(row.entity_id) == str(actor.pk)  # only ever about the person themselves
    if row.entity_type == "access":
        return str(row.entity_id) in (str(actor.pk), str(workspace.pk))
    return True


def trim(days: int = RETENTION_DAYS) -> int:
    """Delete entries older than ``days`` and remember how far, so a client behind that point is
    told to read again. Returns how many were deleted."""
    old = ChangeLog.objects.filter(at__lt=timezone.now() - timedelta(days=days))
    top = old.aggregate(m=Max("id"))["m"]
    if top is None:
        return 0
    count, _ = old.delete()
    TrimMark.objects.bulk_create([TrimMark(pk=1)], ignore_conflicts=True)  # two trims may race
    TrimMark.objects.filter(pk=1, upto__lt=top).update(upto=top)
    return int(count)
