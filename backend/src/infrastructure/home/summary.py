"""The Home screen's one call: counts and short lists for the viewer, scoped like dashboards.

Everything is read through ``Project.objects.visible_to``, so a private project the viewer cannot
open never reaches a count or an item. Sample tasks (the onboarding starter's) are left out of the
counts and the lists. The answer is cached 30 s under a key that names the viewer, the workspace
and the viewer's day, and costs a fixed number of queries whatever the size of the workspace.
"""

import time
import uuid
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta
from datetime import timezone as dt_timezone
from typing import Any, Final

from django.core.cache import cache
from django.db.models import Count, F, Q
from django.utils import timezone

from infrastructure.chat.models import ChatMember
from infrastructure.common.errors import ApiError
from infrastructure.dashboards import services as dashboards
from infrastructure.home.models import DashboardPin, RecentItem
from infrastructure.inbox import services as inbox
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.timetracking import services as timetracking
from infrastructure.timetracking.models import TimeEntry
from infrastructure.workflows.models import Category
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

CACHE_SECONDS: Final = 30
TOP: Final = 5
RECENT_SHOWN: Final = 8
RECENT_KEEP: Final = 30
PINS_SHOWN: Final = 12
OPEN: Final = (Category.NOT_STARTED, Category.ACTIVE)
MAX_OFFSET_MINUTES: Final = 14 * 60


@dataclass(frozen=True, slots=True)
class Item:
    task_id: str
    project_id: str
    project_key: str
    number: int
    title: str
    status_name: str
    status_category: str
    priority: str
    due_date: str


@dataclass(frozen=True, slots=True)
class Mention:
    id: str
    type: str
    task_id: str
    actor_id: str
    created_at: str
    read: bool
    payload: dict[str, Any]


@dataclass(frozen=True, slots=True)
class Day:
    date: str
    seconds: int


@dataclass(frozen=True, slots=True)
class Pin:
    dashboard_id: str
    name: str
    project_id: str


@dataclass(slots=True)
class Summary:
    today_count: int = 0
    overdue_count: int = 0
    in_progress_count: int = 0
    due_items: list[Item] = field(default_factory=list)  # overdue and due today, oldest first
    in_progress_items: list[Item] = field(default_factory=list)
    recent: list[Item] = field(default_factory=list)
    mentions: list[Mention] = field(default_factory=list)
    unread_notifications: int = 0
    unread_chat: int = 0
    week: list[Day] = field(default_factory=list)  # Monday to Sunday of the viewer's week
    pinned_dashboards: list[Pin] = field(default_factory=list)
    computed_at: str = ""


def parse_day(raw: str) -> date:
    if not raw:
        return timezone.localdate()
    try:
        return date.fromisoformat(raw)
    except ValueError:
        raise ApiError("today is a date like 2026-11-05.") from None


def clean_offset(minutes: int) -> int:
    if abs(minutes) > MAX_OFFSET_MINUTES:
        raise ApiError("utc_offset_minutes is out of range.")
    return minutes


def visible_project_ids(actor: Any, workspace: Workspace) -> Any:
    """A subquery of the live projects the viewer can open (never evaluated on its own)."""
    return (
        Project.objects.visible_to(actor, workspace).filter(archived_at__isnull=True).values("pk")
    )


def item_of(task: Task) -> Item:
    return Item(
        task_id=str(task.pk),
        project_id=str(task.project_id),
        project_key=task.project.key,
        number=task.number,
        title=task.title,
        status_name=task.status.name,
        status_category=task.status.category,
        priority=task.priority,
        due_date=task.due_date.isoformat() if task.due_date else "",
    )


def _items(rows: Any) -> list[Item]:
    return [item_of(t) for t in rows.select_related("project", "status")]


def _counts_and_lists(actor: Any, workspace: Workspace, today: date, summary: Summary) -> None:
    mine = Task.objects.filter(
        workspace=workspace,
        project__in=visible_project_ids(actor, workspace),
        deleted_at__isnull=True,
        is_sample=False,
        assignees__user=actor,
        status__category__in=OPEN,
    )
    totals = mine.aggregate(
        today=Count("pk", filter=Q(due_date=today)),
        overdue=Count("pk", filter=Q(due_date__lt=today)),
        active=Count("pk", filter=Q(status__category=Category.ACTIVE)),
    )
    summary.today_count = totals["today"]
    summary.overdue_count = totals["overdue"]
    summary.in_progress_count = totals["active"]
    summary.due_items = _items(
        mine.filter(due_date__lte=today).order_by("due_date", "number")[:TOP]
    )
    summary.in_progress_items = _items(
        mine.filter(status__category=Category.ACTIVE).order_by("-updated_at", "pk")[:TOP]
    )


def _recent(actor: Any, workspace: Workspace) -> list[Item]:
    order = list(
        RecentItem.objects.filter(user=actor, workspace=workspace)
        .order_by("-opened_at")
        .values_list("task_id", flat=True)[:RECENT_SHOWN]
    )
    tasks = Task.objects.filter(
        pk__in=order,
        project__in=visible_project_ids(actor, workspace),
        deleted_at__isnull=True,
    ).select_related("project", "status")
    rank = {tid: i for i, tid in enumerate(order)}
    return [item_of(t) for t in sorted(tasks, key=lambda t: rank[t.pk])]


def _unread_chat(actor: Any, workspace: Workspace) -> int:
    rows = (
        ChatMember.objects.filter(
            user=actor,
            space__workspace=workspace,
            space__archived_at__isnull=True,
            muted_completely=False,
        )
        .filter(
            Q(space__project__isnull=True)
            | Q(space__project__in=visible_project_ids(actor, workspace))
        )
        .annotate(
            n=Count(
                "space__messages",
                filter=Q(
                    space__messages__created_at__gt=F("last_read_at"),
                    space__messages__deleted_at__isnull=True,
                )
                & ~Q(space__messages__author=actor),
            )
        )
    )
    return sum(rows.values_list("n", flat=True))


def _mentions(actor: Any, workspace: Workspace, summary: Summary) -> None:
    page = inbox.list_page(actor, workspace, "mentions", limit=TOP)
    summary.unread_notifications = page.unread
    summary.mentions = [
        Mention(
            id=str(n.pk),
            type=n.type,
            task_id=str(n.task_id or ""),
            actor_id=str(n.actor_id or ""),
            created_at=n.updated_at.isoformat(),
            read=n.read_at is not None,
            payload=n.payload,
        )
        for n in page.notifications
    ]


def _week(actor: Any, workspace: Workspace, today: date, offset: int) -> list[Day]:
    """Seconds logged per day of the viewer's Monday-to-Sunday week. An entry counts on the day it
    started (ponytail: one that runs past midnight is not split across days)."""
    monday = today - timedelta(days=today.weekday())
    zone = dt_timezone(timedelta(minutes=offset))
    start = datetime.combine(monday, datetime.min.time(), tzinfo=zone)
    entries = TimeEntry.objects.filter(
        user=actor,
        workspace=workspace,
        started_at__gte=start,
        started_at__lt=start + timedelta(days=7),
        task__deleted_at__isnull=True,
        task__is_sample=False,
        task__project__in=visible_project_ids(actor, workspace),
    )
    now = timezone.now()
    seconds = dict.fromkeys(range(7), 0)
    for entry in entries:
        day = (entry.started_at.astimezone(zone).date() - monday).days
        seconds[day] += timetracking.seconds_of(entry, now)
    return [Day((monday + timedelta(days=i)).isoformat(), seconds[i]) for i in range(7)]


def _pins(actor: Any, workspace: Workspace) -> list[Pin]:
    pinned = DashboardPin.objects.filter(user=actor, workspace=workspace)
    rows = dashboards.visible_to(actor, workspace).filter(pk__in=pinned.values("dashboard_id"))
    order = {
        d: i
        for i, d in enumerate(pinned.order_by("created_at").values_list("dashboard_id", flat=True))
    }
    return [
        Pin(str(d.pk), d.name, str(d.project_id or ""))
        for d in sorted(rows, key=lambda d: order[d.pk])[:PINS_SHOWN]
    ]


def _stamp_key(user_id: Any, workspace_id: Any) -> str:
    return f"home:summary:{workspace_id}:{user_id}"


def _stamp(actor: Any, workspace: Workspace) -> int:
    return int(cache.get(_stamp_key(actor.pk, workspace.pk), 0))


def forget(user_id: Any, workspace_id: Any) -> None:
    """Retire one viewer's cached summaries, so what changed shows at once."""
    cache.set(_stamp_key(user_id, workspace_id), time.time_ns(), None)


def _forget(actor: Any, workspace: Workspace) -> None:
    forget(actor.pk, workspace.pk)


def summary(actor: Any, workspace: Workspace, today: date, offset_minutes: int = 0) -> Summary:
    """The viewer's Home numbers and lists, cached 30 s per viewer, workspace and day."""
    access.require(actor, "workspace.view", workspace)
    key = (
        f"{_stamp_key(actor.pk, workspace.pk)}:{_stamp(actor, workspace)}:{today}:{offset_minutes}"
    )
    hit = cache.get(key)
    if hit is not None:
        return hit
    result = Summary(computed_at=timezone.now().isoformat())
    _counts_and_lists(actor, workspace, today, result)
    result.recent = _recent(actor, workspace)
    _mentions(actor, workspace, result)
    result.unread_chat = _unread_chat(actor, workspace)
    result.week = _week(actor, workspace, today, offset_minutes)
    result.pinned_dashboards = _pins(actor, workspace)
    cache.set(key, result, CACHE_SECONDS)
    return result


def _as_uuid(raw: str) -> uuid.UUID | None:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        return None


def record_recent(actor: Any, workspace: Workspace, task_id: str) -> None:
    """Remember that the viewer opened a task they can see; keeps the newest ``RECENT_KEEP``."""
    access.require(actor, "workspace.view", workspace)
    task = None
    if (wanted := _as_uuid(task_id)) is not None:
        task = Task.objects.filter(
            pk=wanted,
            workspace=workspace,
            deleted_at__isnull=True,
            project__in=visible_project_ids(actor, workspace),
        ).first()
    if task is None:
        raise ApiError("No such task.", status=404)
    RecentItem.objects.update_or_create(
        user=actor, task=task, defaults={"workspace": workspace, "opened_at": timezone.now()}
    )
    _forget(actor, workspace)
    stale = RecentItem.objects.filter(user=actor, workspace=workspace).order_by("-opened_at")
    old = list(stale.values_list("pk", flat=True)[RECENT_KEEP:])
    if old:
        RecentItem.objects.filter(pk__in=old).delete()


def pin_dashboard(actor: Any, workspace: Workspace, dashboard_id: str, pinned: bool) -> None:
    """Pin or unpin a dashboard the viewer can open (404 otherwise)."""
    access.require(actor, "workspace.view", workspace)
    dashboard = None
    if (wanted := _as_uuid(dashboard_id)) is not None:
        dashboard = dashboards.visible_to(actor, workspace).filter(pk=wanted).first()
    if dashboard is None:
        raise ApiError("No such dashboard.", status=404)
    if pinned:
        DashboardPin.objects.get_or_create(
            user=actor, dashboard=dashboard, defaults={"workspace": workspace}
        )
    else:
        DashboardPin.objects.filter(user=actor, dashboard=dashboard).delete()
    _forget(actor, workspace)
