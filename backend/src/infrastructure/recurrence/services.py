"""Repeat rules on tasks. gRPC renders the answer; nothing here knows a transport.

Setting, changing, pausing or clearing a rule needs ``task.update`` on the task's project, reading
it needs only to see the task. Every lookup goes through the task's project, so a rule is never
reachable from a workspace or project the caller cannot open."""

import json
from dataclasses import dataclass
from datetime import date, timedelta
from typing import Any, Final

from django.db import transaction
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.projects import services as projects
from infrastructure.recurrence import rules, schedule, template
from infrastructure.recurrence.models import Mode, Occurrence, RecurrenceSeries
from infrastructure.tasks import fields, tree
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

EDIT = "task.update"
PREVIEW_MAX: Final = 20
GHOST_RANGE_DAYS: Final = 366
GHOSTS_PER_SERIES: Final = 100
GHOSTS_MAX: Final = 500
NEXT_SHOWN: Final = 5


@dataclass(frozen=True, slots=True)
class View:
    series: RecurrenceSeries
    summary: str
    index: int  # the number of the task asked about (0: the first)
    instance_count: int
    next_dates: list[date]
    is_template: bool


@dataclass(frozen=True, slots=True)
class Preview:
    summary: str
    dates: list[date]


@dataclass(frozen=True, slots=True)
class Ghost:
    series_id: str
    project_id: str
    title: str
    due_date: date


def _mode(value: str) -> str:
    if value not in (Mode.SCHEDULE, Mode.AFTER_COMPLETION):
        raise ApiError("The mode is schedule or after_completion.")
    return value


def _lead(value: int, mode: str) -> int:
    if not 0 <= value <= schedule.MAX_LEAD_DAYS:
        raise ApiError(f"Lead days are 0 to {schedule.MAX_LEAD_DAYS}.")
    return value if mode == Mode.SCHEDULE else 0


def _series_of(task: Task, *, lock: bool = False) -> tuple[RecurrenceSeries, Occurrence] | None:
    row = Occurrence.objects.filter(task=task).first()
    if row is None:
        return None
    rows = RecurrenceSeries.objects.select_related("workspace", "created_by", "project")
    return (rows.select_for_update() if lock else rows).get(pk=row.series_id), row


def _view(series: RecurrenceSeries, row: Occurrence) -> View:
    rule = schedule.parse_rule(series.rrule)
    return View(
        series=series,
        summary=rules.describe(rule, series.mode),
        index=row.index,
        instance_count=Occurrence.objects.filter(series=series).count(),
        next_dates=schedule.ahead(series, rule, NEXT_SHOWN),
        is_template=series.template_task_id == row.task_id,
    )


def _latest_day(series: RecurrenceSeries) -> date:
    row = Occurrence.objects.filter(series=series).order_by("-index").first()
    return row.occurs_on if row else series.starts_on


def set_rule(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    *,
    rrule: str,
    mode: str,
    timezone_name: str = "UTC",
    at_time: str = "09:00",
    lead_days: int = 0,
    ends_on: str = "",
    skip_weekends: bool = False,
) -> View:
    """Make ``task`` repeat. On a task that already belongs to a series this replaces the
    series' rule (and takes the task as the new template), and the caller becomes its owner."""
    rule = schedule.parse_rule(rrule)
    mode = _mode(mode)
    schedule.zone(timezone_name)
    at = schedule.clock_time(at_time)
    lead = _lead(lead_days, mode)
    end = fields.clean_date(ends_on)
    with transaction.atomic():
        project = tasks.lock_for_write(actor, workspace, project_id, EDIT)
        task = tasks.load_task(project, task_id, lock=True)
        if task.parent_id and _series_of(task, lock=True) is None:
            # Instances are made at the top level, so a subtask would leave its parent.
            raise ApiError("A subtask cannot repeat by itself: repeat its parent task.")
        found = _series_of(task, lock=True)
        now = timezone.now()
        values: dict[str, Any] = {
            "rrule": rules.render(rule),
            "mode": mode,
            "timezone": timezone_name or "UTC",
            "at_time": at,
            "lead_days": lead,
            "ends_on": end,
            "skip_weekends": skip_weekends,
            "template": template.snapshot(task),
            "template_task": task,
            "paused": False,
            "pause_reason": "",
            "created_by": actor,
        }
        if found is None:
            series = RecurrenceSeries(
                workspace=workspace,
                project=project,
                starts_on=task.due_date or timezone.localdate(now),
                **values,
            )
            if task.due_date is None:
                series.starts_on = schedule.today(series, now)
            series.save()
            row = Occurrence.objects.create(
                task=task, series=series, index=0, occurs_on=series.starts_on
            )
        else:
            series, row = found
            for name, value in values.items():
                setattr(series, name, value)
            series.version += 1
            series.save()
        schedule.plan(series, rule, _latest_day(series) if found else series.starts_on)
        series.save(update_fields=["next_due_on", "next_run_at"])
    return _view(series, row)


def clear(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> None:
    """Stop repeating: the series goes, every instance stays as an ordinary task."""
    with transaction.atomic():
        project = tasks.lock_for_write(actor, workspace, project_id, EDIT)
        task = tasks.load_task(project, task_id, lock=True)
        found = _series_of(task, lock=True)
        if found is None:
            raise ApiError("This task does not repeat.", status=404)
        found[0].delete()


def pause(actor: Any, workspace: Workspace, project_id: str, task_id: str, paused: bool) -> View:
    """Stop making instances for a while (or start again: dates missed meanwhile are skipped)."""
    with transaction.atomic():
        project = tasks.lock_for_write(actor, workspace, project_id, EDIT)
        task = tasks.load_task(project, task_id, lock=True)
        found = _series_of(task, lock=True)
        if found is None:
            raise ApiError("This task does not repeat.", status=404)
        series, row = found
        series.paused, series.pause_reason = paused, ""
        if not paused:
            series.created_by = actor  # whoever resumes it owns what it makes
            yesterday = schedule.today(series, timezone.now()) - timedelta(days=1)
            rule = schedule.parse_rule(series.rrule)
            schedule.plan(series, rule, max(_latest_day(series), yesterday))
        series.version += 1
        series.save()
    return _view(series, row)


def get(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> View | None:
    """The repeat rule of a task the caller can see, or None when it does not repeat."""
    project = tasks.project_for_view(actor, workspace, project_id)
    found = _series_of(tasks.load_task(project, task_id))
    return _view(*found) if found else None


_FUTURE_FIELDS: Final = ("title", "description", "priority", "assignee_ids")


def update_future(
    actor: Any, workspace: Workspace, project_id: str, task_id: str
) -> tuple[View, int]:
    """Take ``task`` as the new template and carry its title, description, priority and people to
    the open instances after it. "Edit this task only" is an ordinary task edit. Returns the
    series and how many later instances were changed."""
    with transaction.atomic():
        project = tasks.lock_for_write(actor, workspace, project_id, EDIT)
        task = tasks.load_task(project, task_id, lock=True)
        found = _series_of(task, lock=True)
        if found is None:
            raise ApiError("This task does not repeat.", status=404)
        series, row = found
        node = template.snapshot(task)
        series.template, series.template_task = node, task
        series.version += 1
        series.save(update_fields=["template", "template_task", "version"])
        later = (
            Task.objects.filter(
                occurrence__series=series,
                occurrence__index__gt=row.index,
                deleted_at__isnull=True,
            )
            .exclude(status__category__in=tree.FINAL)
            .order_by("occurrence__index")
        )
        changed = 0
        for other in later:
            if _carry(actor, workspace, other, node):
                changed += 1
        recorder.record(
            workspace_id=series.workspace_id,
            action="recurrence.future_updated",
            target_type="recurrence",
            target_id=series.pk,
            project_id=series.project_id,
            changes={"task_id": str(task.pk), "instances_changed": changed},
        )
    return _view(series, row), changed


def _carry(actor: Any, workspace: Workspace, other: Task, node: dict[str, Any]) -> bool:
    wanted = {
        "title": node["title"],
        "description": json.dumps(node["description"]) if node["description"] else "",
        "priority": node["priority"],
        "assignee_ids": node["assignee_ids"],
    }
    have = {
        "title": other.title,
        "description": json.dumps(other.description) if other.description else "",
        "priority": other.priority,
        "assignee_ids": [str(i) for i in other.assignee_ids()],
    }
    changes = {k: v for k, v in wanted.items() if v != have[k]}
    if "assignee_ids" in changes and sorted(changes["assignee_ids"]) == sorted(
        have["assignee_ids"]
    ):
        del changes["assignee_ids"]
    if not changes:
        return False
    try:
        tasks.update(actor, workspace, str(other.project_id), str(other.pk), other.version, changes)
    except ApiError:
        if "assignee_ids" not in changes:
            raise
        del changes["assignee_ids"]  # someone no longer on the project: keep the rest
        if not changes:
            return False
        tasks.update(actor, workspace, str(other.project_id), str(other.pk), other.version, changes)
    return True


def preview(
    actor: Any,
    workspace: Workspace,
    *,
    rrule: str,
    mode: str,
    starts_on: str = "",
    after: str = "",
    count: int = NEXT_SHOWN,
    skip_weekends: bool = False,
    ends_on: str = "",
    timezone_name: str = "UTC",
) -> Preview:
    """The sentence and the next ``count`` dates a rule would make for a task due ``starts_on``
    (today when empty): the same arithmetic the clock uses, nothing is saved. For a series that
    already runs, ``starts_on`` is its start and ``after`` the day of its latest instance."""
    access.require(actor, tasks.VIEW, workspace)
    rule = schedule.parse_rule(rrule)
    mode = _mode(mode)
    zone = schedule.zone(timezone_name)
    start = fields.clean_date(starts_on) or timezone.now().astimezone(zone).date()
    until = fields.clean_date(ends_on)
    limit = max(1, min(count, PREVIEW_MAX))
    latest = fields.clean_date(after)
    if mode == Mode.AFTER_COMPLETION:
        found = schedule.chain(
            rule, latest or start, limit, skip_weekends=skip_weekends, until=until
        )
    else:
        # ``COUNT`` is a number of instances from the start, which ``dates`` counts itself.
        left = limit if rule.count is None or latest else min(limit, rule.count - 1)
        found = (
            rules.dates(
                rule,
                start,
                after=latest or start,
                skip_weekends=skip_weekends,
                limit=left,
                until=until,
            )
            if left > 0
            else []
        )
    return Preview(summary=rules.describe(rule, mode), dates=found)


def upcoming(
    actor: Any, workspace: Workspace, start: str, end: str, project_id: str = ""
) -> list[Ghost]:
    """The dates the clock will still make inside ``[start, end]`` for the series of projects the
    caller can open: the calendar's ghost items. Paused and after-completion series have none."""
    first, last = fields.clean_date(start), fields.clean_date(end)
    if first is None or last is None or last < first:
        raise ApiError("Send a start and an end date (YYYY-MM-DD), the end not before the start.")
    if (last - first).days > GHOST_RANGE_DAYS:
        raise ApiError(f"Ask for at most {GHOST_RANGE_DAYS} days at a time.")
    visible = [v.project.pk for v in projects.list_projects(actor, workspace)]
    if project_id:
        visible = [p for p in visible if str(p) == str(project_id)]
    rows = RecurrenceSeries.objects.filter(
        workspace=workspace,
        project_id__in=visible,
        paused=False,
        mode=Mode.SCHEDULE,
        next_due_on__isnull=False,
    ).order_by("next_due_on", "pk")
    out: list[Ghost] = []
    for series in rows:
        rule = schedule.parse_rule(series.rrule)
        floor = max(series.next_due_on, first) if series.next_due_on else first
        left = GHOSTS_PER_SERIES
        if rule.count is not None:
            left = min(left, rule.count - 1 - series.last_index)
        until = min(last, series.ends_on) if series.ends_on else last
        found = (
            rules.dates(
                rule,
                series.starts_on,
                after=floor - timedelta(days=1),
                skip_weekends=series.skip_weekends,
                limit=left,
                until=until,
            )
            if left > 0
            else []
        )
        for day in found:
            out.append(Ghost(str(series.pk), str(series.project_id), series.template["title"], day))
    return sorted(out, key=lambda g: (g.due_date, g.title))[:GHOSTS_MAX]
