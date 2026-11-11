"""Reading and changing a person's inbox. Everything here is the caller's own, in one workspace
(or, for the badge, in all of them); one for a task the caller can no longer open is never shown or
counted."""

import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any, Final

from django.db.models import Q, QuerySet
from django.utils import timezone

from infrastructure.comments import mentions
from infrastructure.common.errors import ApiError
from infrastructure.inbox import kinds
from infrastructure.inbox.models import Notification
from infrastructure.inbox.notify import announce_changed
from infrastructure.projects.models import Project
from infrastructure.workspaces.models import MemberStatus, Workspace

PAGE_DEFAULT: Final = 30
PAGE_MAX: Final = 100
SNOOZE_MAX_DAYS: Final = 366
FILTERS: Final = ("all", "unread", "mentions", "assigned", "snoozed", "archived")


@dataclass(frozen=True, slots=True)
class Page:
    notifications: list[Notification]
    cursor: str
    unread: int


def name_of(user: Any) -> str:
    return mentions.display_name(user)


def _mine(actor: Any, workspace: Workspace) -> QuerySet[Notification]:
    """The caller's listable notifications in ``workspace``: the inbox is on for them and they can
    still open the project they are about."""
    visible = Project.objects.visible_to(actor, workspace).values("pk")
    return (
        Notification.objects.filter(user=actor, workspace=workspace, in_inbox=True)
        .filter(Q(project_id__isnull=True) | Q(project_id__in=visible))
        .filter(Q(task__isnull=True) | Q(task__deleted_at__isnull=True))  # not for the trash
    )


def _filtered(rows: QuerySet[Notification], filter_: str, now: datetime) -> QuerySet[Notification]:
    awake = Q(snoozed_until__isnull=True) | Q(snoozed_until__lte=now)
    if filter_ == "archived":
        return rows.filter(archived_at__isnull=False)
    if filter_ == "snoozed":
        return rows.filter(archived_at__isnull=True, snoozed_until__gt=now)
    rows = rows.filter(awake, archived_at__isnull=True)
    if filter_ == "unread":
        return rows.filter(read_at__isnull=True)
    if filter_ in kinds.FILTERS:
        return rows.filter(type__in=kinds.FILTERS[filter_])
    return rows


def _unread(actor: Any, workspace: Workspace, now: datetime) -> int:
    return _filtered(_mine(actor, workspace), "unread", now).count()


def _cursor(raw: str) -> tuple[datetime, uuid.UUID] | None:
    if not raw:
        return None
    stamp, _, ident = raw.partition("|")
    try:
        return datetime.fromisoformat(stamp), uuid.UUID(ident)
    except ValueError:
        raise ApiError("That is not a place in the inbox.") from None


def list_page(
    actor: Any, workspace: Workspace, filter_: str, *, before: str = "", limit: int = 0
) -> Page:
    """Newest activity first. ``cursor`` is what to pass as ``before`` for the next page."""
    if filter_ not in FILTERS:
        raise ApiError(f"The filter is one of {', '.join(FILTERS)}.")
    now = timezone.now()
    size = max(1, min(limit or PAGE_DEFAULT, PAGE_MAX))
    rows = _filtered(_mine(actor, workspace), filter_, now).select_related("actor")
    place = _cursor(before)
    if place is not None:
        stamp, ident = place
        rows = rows.filter(Q(updated_at__lt=stamp) | Q(updated_at=stamp, id__lt=ident))
    found = list(rows.order_by("-updated_at", "-id")[: size + 1])
    page = found[:size]
    more = len(found) > size
    cursor = f"{page[-1].updated_at.isoformat()}|{page[-1].pk}" if more and page else ""
    return Page(page, cursor, _unread(actor, workspace, now))


def _ids(raw: list[str]) -> list[uuid.UUID]:
    try:
        return [uuid.UUID(str(i)) for i in raw]
    except ValueError:
        raise ApiError("That is not a notification.", 404) from None


def _touch(actor: Any, workspace: Workspace, rows: QuerySet[Notification], **changes: Any) -> int:
    count = rows.update(**changes)
    if count:
        announce_changed(actor.pk, workspace.pk)
    return count


def mark_read(actor: Any, workspace: Workspace, ids: list[str], *, all_: bool, read: bool) -> int:
    """Mark ``ids`` (or everything, with ``all_``) read, or unread. Returns what is unread now."""
    now = timezone.now()
    rows = Notification.objects.filter(user=actor, workspace=workspace)
    if not all_:
        rows = rows.filter(pk__in=_ids(ids))
    _touch(actor, workspace, rows, read_at=now if read else None)
    return _unread(actor, workspace, now)


def snooze(actor: Any, workspace: Workspace, notification_id: str, until: str) -> Notification:
    """Hide a notification until ``until`` (ISO 8601 with a zone), when it comes back unread. An
    empty ``until`` ends the snooze."""
    now = timezone.now()
    when: datetime | None = None
    if until:
        try:
            when = datetime.fromisoformat(until)
        except ValueError:
            raise ApiError("The time to come back must be a date and time.") from None
        if when.tzinfo is None:
            raise ApiError("The time to come back needs a time zone.")
        if when <= now:
            raise ApiError("Pick a time in the future.")
        if when > now + timedelta(days=SNOOZE_MAX_DAYS):
            raise ApiError("A notification can be snoozed for at most a year.")
    [pk] = _ids([notification_id])
    rows = Notification.objects.filter(user=actor, workspace=workspace, pk=pk)
    changes: dict[str, Any] = {"snoozed_until": when}
    if when is not None:
        changes["read_at"] = None  # it comes back as something new
    if not _touch(actor, workspace, rows, **changes):
        raise ApiError("That is not a notification.", 404)
    return Notification.objects.select_related("actor").get(pk=pk)


def archive(actor: Any, workspace: Workspace, ids: list[str], *, archived: bool) -> int:
    rows = Notification.objects.filter(user=actor, workspace=workspace, pk__in=_ids(ids))
    _touch(actor, workspace, rows, archived_at=timezone.now() if archived else None)
    return _unread(actor, workspace, timezone.now())


def unread_count(actor: Any, workspace: Workspace | None) -> int:
    """What is unread in ``workspace``, or in every workspace the caller belongs to."""
    now = timezone.now()
    if workspace is not None:
        return _unread(actor, workspace, now)
    memberships = Workspace.objects.filter(
        deleted_at__isnull=True, members__user=actor, members__status=MemberStatus.ACTIVE
    )
    return sum(_unread(actor, w, now) for w in memberships)


def wake_snoozed(now: datetime | None = None) -> int:
    """Bring back notifications whose snooze has ended (unread, newest again). Returns how many."""
    now = now or timezone.now()
    woken = 0
    for row in Notification.objects.filter(snoozed_until__lte=now):
        Notification.objects.filter(pk=row.pk).update(
            snoozed_until=None, read_at=None, updated_at=now
        )
        announce_changed(row.user_id, row.workspace_id)
        woken += 1
    return woken
