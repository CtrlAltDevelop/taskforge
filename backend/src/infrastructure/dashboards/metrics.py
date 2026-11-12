"""The numbers behind a widget: which tasks the viewer may count, how they are grouped, and the
tasks behind each bucket (so a click on a bar lists exactly what the bar counted).

Every query starts from ``visible_tasks``: the open projects and the private ones the viewer is a
member of, never anything else. A shared dashboard therefore shows each viewer their own numbers.
"""

import json
import uuid
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, datetime, time, timedelta
from datetime import timezone as dt_timezone
from decimal import Decimal
from typing import Any, Final

from django.contrib.auth import get_user_model
from django.db.models import Count, F, OuterRef, Q, Subquery, Sum
from django.db.models.functions import Coalesce, TruncDay, TruncWeek

from infrastructure.audit.models import AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.dashboards import config as cfg
from infrastructure.filters import language
from infrastructure.filters import query as filter_query
from infrastructure.filters import services as filter_services
from infrastructure.filters.language import Catalogue
from infrastructure.projects.models import Project
from infrastructure.sprints import burndown as sprint_burndown
from infrastructure.sprints.models import Sprint
from infrastructure.tasks.models import Priority, Task
from infrastructure.timetracking.models import TimeEntry
from infrastructure.workflows.models import Category, Status
from infrastructure.workspaces.models import Workspace

ZERO: Final = Decimal(0)
CENT: Final = Decimal("0.01")
CYCLE_ROW_CAP: Final = 20_000  # finished tasks read for an average; more is said, not hidden
CHUNK: Final = 900  # ids per IN (...) (SQLite allows 999 variables)
NONE_KEY: Final = "none"
OPEN_CATEGORIES: Final = (Category.NOT_STARTED, Category.ACTIVE)
CATEGORY_LABELS: Final = {
    Category.NOT_STARTED: "Not started",
    Category.ACTIVE: "Active",
    Category.DONE: "Done",
    Category.CANCELLED: "Cancelled",
}


@dataclass(frozen=True, slots=True)
class Bucket:
    key: str
    label: str
    value: Decimal


@dataclass(frozen=True, slots=True)
class Point:
    x: str  # a date
    y: Decimal


@dataclass(frozen=True, slots=True)
class Series:
    name: str
    points: list[Point]


@dataclass(slots=True)
class Result:
    total: Decimal = ZERO
    buckets: list[Bucket] = field(default_factory=list)
    series: list[Series] = field(default_factory=list)
    truncated: bool = False  # more buckets (or finished tasks) existed than were counted


@dataclass(frozen=True, slots=True)
class Scope:
    """Who is asking, about what, and from which day: everything a query depends on."""

    actor: Any
    workspace: Workspace
    project: Project | None
    today: date
    offset_minutes: int = 0  # the viewer's UTC offset: a "day" is theirs

    @property
    def zone(self) -> dt_timezone:
        return dt_timezone(timedelta(minutes=self.offset_minutes))


def visible_projects(scope: Scope) -> Any:
    rows = Project.objects.visible_to(scope.actor, scope.workspace).filter(archived_at__isnull=True)
    return rows.filter(pk=scope.project.pk) if scope.project else rows


def visible_tasks(scope: Scope, where: Q, scope_name: str) -> Any:
    rows = Task.objects.filter(project__in=visible_projects(scope), deleted_at__isnull=True)
    if where:
        rows = rows.filter(where)
    if scope_name == "open":
        rows = rows.filter(status__category__in=OPEN_CATEGORIES)
    elif scope_name == "done":
        rows = rows.filter(status__category=Category.DONE)
    return rows


def where_of(scope: Scope, tfql: str) -> Q:
    """The condition of a widget's TFQL text (empty: every visible task)."""
    text = tfql.strip()
    if not text:
        return Q()
    cat = Catalogue(scope.project) if scope.project else Catalogue(None, scope.workspace)
    checked = filter_services.check(cat, text)
    if checked.errors or checked.ast is None:
        raise cfg.invalid(checked.errors[0].message if checked.errors else "The filter is invalid.")
    ast = json.dumps(language.canonical(checked.ast, cat))
    if scope.project:
        prepared = filter_query.prepare(scope.project, ast, scope.today.isoformat(), scope.actor)
    else:
        prepared = filter_query.prepare_workspace(
            scope.workspace, ast, scope.today.isoformat(), scope.actor
        )
    return prepared.where


# ----------------------------------------------------------------------------- measures


def _rows_with(rows: Any, measure: str) -> tuple[Any, Any]:
    """``rows`` (annotated if the measure needs it) and the aggregate that computes it."""
    if measure == cfg.POINTS:
        return rows, Coalesce(Sum("points"), ZERO)
    if measure == cfg.ESTIMATE_HOURS:
        return rows, Coalesce(Sum("estimate_sec"), 0) / Decimal(3600)
    if measure == cfg.LOGGED_HOURS:
        logged = (
            TimeEntry.objects.filter(task=OuterRef("pk"))
            .values("task")
            .annotate(total=Sum("duration_sec"))
            .values("total")
        )
        rows = rows.annotate(_logged=Coalesce(Subquery(logged), 0))
        return rows, Coalesce(Sum("_logged"), 0) / Decimal(3600)
    return rows, Count("pk", distinct=True)


def _money(value: Any) -> Decimal:
    return Decimal(str(value or 0)).quantize(CENT)


# ----------------------------------------------------------------------------- grouping


def _bucket_expr(group: str, scope: Scope) -> Any:
    return {
        "status": F("status_id"),
        "category": F("status__category"),
        "priority": F("priority"),
        "project": F("project_id"),
        "sprint": F("sprint_id"),
        "assignee": F("assignees__user_id"),
        "created_day": TruncDay("created_at", tzinfo=scope.zone),
        "created_week": TruncWeek("created_at", tzinfo=scope.zone),
        "due_week": TruncWeek("due_date"),
    }[group]


def _key(value: Any) -> str:
    if value is None:
        return NONE_KEY
    if isinstance(value, datetime):
        return value.date().isoformat()
    if isinstance(value, date):
        return value.isoformat()
    return str(value)


def _days(key: str) -> date:
    return date.fromisoformat(key)


def _checked(group: str, key: str) -> None:
    """A bucket key as the client sent it must be one this grouping could have made."""
    none = key == NONE_KEY
    try:
        if group in ("status", "project"):
            uuid.UUID(key)
        elif group in ("sprint", "assignee"):
            if not none:
                uuid.UUID(key)
        elif group == "category":
            if key not in Category.values:
                raise ValueError(key)
        elif group == "priority":
            if key not in Priority.values:
                raise ValueError(key)
        elif group in ("created_day", "created_week") or (group == "due_week" and not none):
            date.fromisoformat(key)
    except ValueError:
        raise cfg.invalid("That bucket does not belong to this widget.") from None


def bucket_q(group: str, key: str, scope: Scope) -> Q:
    """The condition that picks exactly the tasks a bucket counted."""
    _checked(group, key)
    none = key == NONE_KEY
    match group:
        case "status":
            return Q(status_id=key)
        case "category":
            return Q(status__category=key)
        case "priority":
            return Q(priority=key)
        case "project":
            return Q(project_id=key)
        case "sprint":
            return Q(sprint__isnull=True) if none else Q(sprint_id=key)
        case "assignee":
            return Q(assignees__isnull=True) if none else Q(assignees__user_id=key)
        case "created_day" | "created_week":
            span = timedelta(days=1 if group == "created_day" else 7)
            start = datetime.combine(_days(key), time.min, tzinfo=scope.zone)
            return Q(created_at__gte=start, created_at__lt=start + span)
        case "due_week":
            if none:
                return Q(due_date__isnull=True)
            return Q(due_date__gte=_days(key), due_date__lt=_days(key) + timedelta(days=7))
    raise cfg.invalid("Unknown grouping.")


def _labels(group: str, keys: list[str]) -> dict[str, str]:
    ids = [k for k in keys if k != NONE_KEY]
    names: dict[str, str] = {}
    match group:
        case "status":
            names = {
                str(p): n for p, n in Status.objects.filter(pk__in=ids).values_list("pk", "name")
            }
        case "project":
            names = {
                str(p): n for p, n in Project.objects.filter(pk__in=ids).values_list("pk", "name")
            }
        case "sprint":
            names = {
                str(p): n for p, n in Sprint.objects.filter(pk__in=ids).values_list("pk", "name")
            }
        case "assignee":
            for user in get_user_model().objects.filter(pk__in=ids):
                names[str(user.pk)] = user.get_full_name() or user.get_username()
        case "category":
            names = {k: CATEGORY_LABELS.get(k, k) for k in ids}
        case "priority":
            names = {k: k.capitalize() for k in ids}
    empty = {
        "assignee": "Unassigned",
        "sprint": "No sprint",
        "due_week": "No due date",
    }.get(group, "None")
    return {k: (empty if k == NONE_KEY else names.get(k, k)) for k in keys}


def _grouped(rows: Any, scope: Scope, config: dict[str, Any]) -> list[tuple[str, Decimal]]:
    group = config["group_by"]
    rows, aggregate = _rows_with(rows.annotate(_b=_bucket_expr(group, scope)), config["measure"])
    found = rows.order_by().values("_b").annotate(_v=aggregate).values_list("_b", "_v")
    return [(_key(b), _money(v)) for b, v in found]


# ----------------------------------------------------------------------------- cycle time


def _cycle(
    rows: Any, scope: Scope, config: dict[str, Any]
) -> tuple[Decimal, dict[str, Decimal], bool]:
    """Average days from creation to the last move into a done status, overall and per bucket,
    read from the audit history (phase 27). A task finished without any recorded move has no
    cycle time and is left out."""
    group = config["group_by"]
    if group:
        rows = rows.annotate(_b=_bucket_expr(group, scope))
        found = list(rows.values_list("pk", "created_at", "_b")[: cfg_cap() + 1])
    else:
        found = [(p, c, None) for p, c in rows.values_list("pk", "created_at")[: cfg_cap() + 1]]
    truncated = len(found) > cfg_cap()
    found = found[: cfg_cap()]
    done_ids = [
        str(pk)
        for pk in Status.objects.filter(
            category=Category.DONE, project__in=visible_projects(scope)
        ).values_list("pk", flat=True)
    ]
    finished: dict[str, datetime] = {}
    ids = [str(pk) for pk, _, _ in found]
    for start in range(0, len(ids), CHUNK):
        entries = AuditEntry.objects.filter(
            workspace=scope.workspace.pk,
            target_type="task",  # the (target_type, target_id) index
            target_id__in=ids[start : start + CHUNK],
            # Any entry that moved the task into a done status, whether or not other fields
            # changed in the same edit (those are recorded as "task.updated").
            changes__status_id__1__in=done_ids,
        ).values_list("target_id", "at")
        for target, at in entries:
            if target not in finished or at > finished[target]:
                finished[target] = at
    sums: dict[str, list[float]] = defaultdict(list)
    for pk, created, bucket in found:
        done_at = finished.get(str(pk))
        if done_at is not None:
            sums[_key(bucket) if group else ""].append(max((done_at - created).total_seconds(), 0))
    every = [v for values in sums.values() for v in values]
    avg = lambda values: _money(sum(values) / len(values) / 86400) if values else ZERO  # noqa: E731
    per = {k: avg(v) for k, v in sums.items() if k != "" or group}
    return avg(every), per, truncated


def cfg_cap() -> int:
    return CYCLE_ROW_CAP


# ----------------------------------------------------------------------------- compute


def _too_heavy() -> ApiError:
    return ApiError(
        "This widget takes too long to compute. Narrow its filter.",
        status=400,
        title=ResponseTitle.DASHBOARD_TOO_HEAVY,
    )


def compute(scope: Scope, kind: str, config: dict[str, Any], tfql: str, now: datetime) -> Result:
    """The widget's numbers, every query under the time limit (not only a filtered one)."""
    where = where_of(scope, tfql) if kind != cfg.BURNDOWN else Q()
    try:
        if kind == cfg.BURNDOWN:
            return filter_query.timed(lambda: _burndown(scope, config, now))
        return filter_query.timed(lambda: _compute(scope, kind, config, where))
    except filter_query.StatementTimeout:
        raise _too_heavy() from None


def _compute(scope: Scope, kind: str, config: dict[str, Any], where: Q) -> Result:
    rows = visible_tasks(scope, where, config["scope"])
    measure, group = config["measure"], config["group_by"]
    result = Result()
    if measure == cfg.CYCLE_DAYS:
        result.total, per, result.truncated = _cycle(rows, scope, config)
        pairs = list(per.items())
    else:
        counted, aggregate = _rows_with(rows, measure)
        result.total = _money(counted.order_by().aggregate(v=aggregate)["v"])
        pairs = _grouped(rows, scope, config) if group else []
    if not group:
        return result
    time_based = group in cfg.TIME_GROUPS
    pairs.sort(key=(lambda p: p[0]) if time_based else (lambda p: (-p[1], p[0])))
    if time_based:
        pairs = _within_range(pairs, scope, config)
    limit = config["limit"]
    result.truncated = result.truncated or len(pairs) > limit
    # A time axis keeps its newest buckets (the oldest are the ones that fall off the left).
    pairs = pairs[-limit:] if time_based else pairs[:limit]
    labels = _labels(group, [k for k, _ in pairs])
    result.buckets = [Bucket(k, k if time_based else labels[k], v) for k, v in pairs]
    if kind == cfg.LINE:
        result.series = [Series(measure, [Point(b.key, b.value) for b in result.buckets])]
    return result


def _within_range(pairs: list[tuple[str, Decimal]], scope: Scope, config: dict[str, Any]) -> Any:
    """Time buckets of the last ``range_days`` days, oldest first (a no-date bucket stays out)."""
    start = scope.today - timedelta(days=config["range_days"])
    return [(k, v) for k, v in pairs if k != NONE_KEY and _days(k) >= start]


def _burndown(scope: Scope, config: dict[str, Any], now: datetime) -> Result:
    project_id = config["project_id"] or (str(scope.project.pk) if scope.project else "")
    if not project_id:
        raise cfg.invalid("A burndown widget needs a project.")
    chart = sprint_burndown.burndown(
        scope.actor, scope.workspace, project_id, config["sprint_id"], now
    )
    remaining = [
        Point(d.date.isoformat(), _money(d.remaining_points))
        for d in chart.days
        if d.has_actual or d.live
    ]
    ideal = [Point(d.date.isoformat(), _money(d.ideal_points)) for d in chart.days]
    result = Result(series=[Series("Remaining", remaining), Series("Ideal", ideal)])
    result.total = remaining[-1].y if remaining else _money(chart.baseline_points)
    return result


def drilldown(scope: Scope, kind: str, config: dict[str, Any], tfql: str, bucket: str) -> Any:
    """The tasks a widget's number (or one bucket of it) counts: the same query, one more filter."""
    if kind == cfg.BURNDOWN:
        # The open tasks of the sprint, in the project the chart is about (the number is what
        # remains of their points), whatever project the dashboard itself is filed under.
        project_id = config["project_id"] or (str(scope.project.pk) if scope.project else "")
        if not project_id:
            raise cfg.invalid("A burndown widget needs a project.")
        wide = Scope(scope.actor, scope.workspace, None, scope.today, scope.offset_minutes)
        return visible_tasks(wide, Q(sprint_id=config["sprint_id"], project_id=project_id), "open")
    rows = visible_tasks(scope, where_of(scope, tfql), config["scope"])
    group = config["group_by"]
    if bucket:
        if not group:
            raise cfg.invalid("This widget has no buckets.")
        rows = rows.filter(bucket_q(group, bucket, scope))
    return rows.distinct()
