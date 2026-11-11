"""Time tracking: the server-side timer, manual entries, estimates.

Elapsed time is always ``server now - started_at``; the client's clock never enters. A person has at
most one running entry (a partial unique index), across every workspace: starting a second timer
stops the first and says which. Seeing and logging time needs ``workspace.view`` and the task's
project to be visible and to have *Time tracking* switched on (off keeps the data but hides it);
logging needs ``time.log``; touching somebody else's entry needs ``time.edit_others``.
"""

import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any, Final

from django.db import IntegrityError, OperationalError, transaction
from django.db.models import Q, Sum
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.timetracking.models import Source, TimeEntry
from infrastructure.timetracking.signals import announce
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW = "workspace.view"
LOG = "time.log"
OTHERS = "time.edit_others"
FEATURE = "time_tracking"
MAX_ENTRY_SEC: Final = 7 * 24 * 3600
LONG_ENTRY_SEC: Final = 24 * 3600  # longer is flagged for review
FUTURE_SLACK: Final = timedelta(minutes=5)
START_RETRIES: Final = 3
ENTRIES_LIMIT: Final = 500  # the newest this many on a task


@dataclass(frozen=True, slots=True)
class Row:
    """An entry as the screens need it: the task it is on, and what is odd about it."""

    entry: TimeEntry
    task: Task
    seconds: int  # a running entry counts up to now
    flags: tuple[str, ...]  # "long", "overlap", "running"


def _bad(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.VALIDATION_ERROR)


def _not_found() -> ApiError:
    return ApiError("No such time entry.", status=404)


def feature_on(project: Project) -> bool:
    return FEATURE in projects.enabled_features(project)


def _need_feature(project: Project) -> None:
    if not feature_on(project):
        raise _bad("Time tracking is switched off for this project.")


def _task(actor: Any, workspace: Workspace, project_id: str, task_id: str, key: str) -> Task:
    """The live task if the caller may see it (and ``key``), in a project with time tracking on."""
    access.require(actor, VIEW, workspace)
    if key != VIEW:
        access.require(actor, key, workspace)
    project = projects.load(actor, workspace, project_id)
    try:
        pk = uuid.UUID(str(task_id))
    except ValueError:
        raise tasks.not_found() from None
    task = (
        Task.objects.select_related("project", "status")
        .filter(pk=pk, project=project, deleted_at__isnull=True)
        .first()
    )
    if task is None:
        raise tasks.not_found()
    _need_feature(project)
    if key != VIEW:
        projects.writable(project)
    return task


def seconds_of(entry: TimeEntry, now: datetime) -> int:
    if entry.ended_at is None:
        return max(0, int((now - entry.started_at).total_seconds()))
    return entry.duration_sec


def _stop_row(entry: TimeEntry, now: datetime) -> None:
    entry.ended_at = max(now, entry.started_at)
    entry.duration_sec = max(0, int((entry.ended_at - entry.started_at).total_seconds()))
    entry.updated_at = now
    entry.save(update_fields=["ended_at", "duration_sec", "updated_at"])


@dataclass(frozen=True, slots=True)
class Started:
    entry: TimeEntry
    stopped: TimeEntry | None  # the timer this replaced, if there was one


def start(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, note: str = ""
) -> Started:
    """Run a timer on the task, stopping any other of the caller's first."""
    task = _task(actor, workspace, project_id, task_id, LOG)
    note = _clean_note(note)
    for attempt in range(START_RETRIES):
        try:
            with transaction.atomic():
                now = timezone.now().replace(microsecond=0)
                running = (
                    TimeEntry.objects.select_for_update()
                    .filter(user=actor, ended_at__isnull=True)
                    .select_related("workspace")
                    .first()
                )
                if running is not None:
                    _stop_row(running, now)
                entry = TimeEntry.objects.create(
                    workspace=workspace,
                    task=task,
                    user=actor,
                    started_at=now,
                    note=note,
                    source=Source.TIMER,
                    created_at=now,
                    updated_at=now,
                )
        except (IntegrityError, OperationalError):  # SQLite reports a lost race as "locked"
            if attempt == START_RETRIES - 1:  # another device keeps winning the race
                raise ApiError("Could not start the timer. Try again.", status=409) from None
            continue
        announce(actor, workspace)
        if running is not None and running.workspace_id != workspace.pk:
            announce(actor, running.workspace)  # the other workspace's devices stop showing it
        return Started(entry, running)
    raise AssertionError("unreachable")  # pragma: no cover


def stop(actor: Any, workspace: Workspace) -> TimeEntry:
    """Stop the caller's running timer in this workspace."""
    access.require(actor, VIEW, workspace)
    with transaction.atomic():
        running = (
            TimeEntry.objects.select_for_update()
            .filter(user=actor, ended_at__isnull=True, workspace=workspace)
            .first()
        )
        if running is None:
            raise _bad("No timer is running.")
        _stop_row(running, timezone.now().replace(microsecond=0))
    announce(actor, workspace)
    return running


def current(actor: Any, workspace: Workspace) -> TimeEntry | None:
    """The caller's running timer in this workspace, if the task is still theirs to see."""
    access.require(actor, VIEW, workspace)
    entry = (
        TimeEntry.objects.filter(user=actor, ended_at__isnull=True, workspace=workspace)
        .select_related("task__project", "task__status", "user__profile")
        .first()
    )
    if entry is None or entry.task.deleted_at is not None:
        return None
    visible = Project.objects.visible_to(actor, workspace).filter(pk=entry.task.project_id)
    return entry if visible.exists() else None


def _clean_note(note: str) -> str:
    note = note.strip()
    if len(note) > 500:
        raise _bad("A note can be at most 500 characters.")
    return note


def _clean_duration(seconds: int) -> int:
    if not 0 < seconds <= MAX_ENTRY_SEC:
        raise _bad("The duration must be between a second and 7 days.")
    return seconds


def _check_past(started_at: datetime, seconds: int, now: datetime) -> None:
    if started_at + timedelta(seconds=seconds) > now + FUTURE_SLACK:
        raise _bad("Time cannot be logged in the future.")


def create_entry(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    started_at: datetime,
    duration_sec: int,
    note: str = "",
    billable: bool = False,
    for_user: Any = None,
) -> TimeEntry:
    """Log time that already happened. ``for_user`` (another member) needs ``time.edit_others``."""
    task = _task(actor, workspace, project_id, task_id, LOG)
    owner = _owner(actor, workspace, for_user)
    seconds = _clean_duration(duration_sec)
    now = timezone.now()
    _check_past(started_at, seconds, now)
    entry = TimeEntry.objects.create(
        workspace=workspace,
        task=task,
        user=owner,
        started_at=started_at,
        ended_at=started_at + timedelta(seconds=seconds),
        duration_sec=seconds,
        note=_clean_note(note),
        billable=billable,
        source=Source.MANUAL,
        created_at=now,
        updated_at=now,
    )
    announce(owner, workspace)
    return entry


def _owner(actor: Any, workspace: Workspace, for_user: Any) -> Any:
    if for_user is None or for_user.pk == actor.pk:
        return actor
    access.require(actor, OTHERS, workspace)
    from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

    if not WorkspaceMember.objects.filter(
        workspace=workspace, user=for_user, status=MemberStatus.ACTIVE
    ).exists():
        raise _bad("That person is not a member of this workspace.")
    return for_user


def _entry(actor: Any, workspace: Workspace, entry_id: str, *, write: bool) -> TimeEntry:
    """The entry if the caller may see its task; for ``write`` also if it is theirs or they hold
    ``time.edit_others``."""
    access.require(actor, VIEW, workspace)
    try:
        pk = uuid.UUID(str(entry_id))
    except ValueError:
        raise _not_found() from None
    entry = (
        TimeEntry.objects.select_for_update(of=("self",))
        .filter(pk=pk, workspace=workspace, task__deleted_at__isnull=True)
        .select_related("task__project")
        .first()
    )
    if entry is None:
        raise _not_found()
    visible = Project.objects.visible_to(actor, workspace).filter(pk=entry.task.project_id)
    if not visible.exists() or not feature_on(entry.task.project):
        raise _not_found()
    if write:
        if entry.user_id != actor.pk:
            access.require(actor, OTHERS, workspace)
        else:
            access.require(actor, LOG, workspace)
    return entry


def update_entry(
    actor: Any,
    workspace: Workspace,
    entry_id: str,
    changes: dict[str, Any],
) -> TimeEntry:
    """Change ``started_at``, ``duration_sec``, ``note`` and/or ``billable``. A running entry takes
    only the note and billable flag (stop it first to change its time)."""
    unknown = set(changes) - {"started_at", "duration_sec", "note", "billable"}
    if unknown:
        raise _bad(f"Cannot change {sorted(unknown)[0]}.")
    with transaction.atomic():
        entry = _entry(actor, workspace, entry_id, write=True)
        if entry.is_running and ({"started_at", "duration_sec"} & set(changes)):
            raise _bad("Stop the timer before changing its time.")
        if "note" in changes:
            entry.note = _clean_note(changes["note"])
        if "billable" in changes:
            entry.billable = bool(changes["billable"])
        if not entry.is_running and ({"started_at", "duration_sec"} & set(changes)):
            started = changes.get("started_at", entry.started_at)
            seconds = (
                _clean_duration(changes["duration_sec"])
                if "duration_sec" in changes
                else entry.duration_sec
            )
            _check_past(started, seconds, timezone.now())
            entry.started_at = started
            entry.duration_sec = seconds
            entry.ended_at = started + timedelta(seconds=seconds)
        entry.updated_at = timezone.now()
        entry.save()
    announce(entry.user, workspace)
    return entry


def delete_entry(actor: Any, workspace: Workspace, entry_id: str) -> None:
    with transaction.atomic():
        entry = _entry(actor, workspace, entry_id, write=True)
        owner = entry.user
        entry.delete()
    announce(owner, workspace)


def set_estimate(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    estimate_sec: int,
    expected_version: int = 0,
) -> Task:
    """Set (or with 0 clear) the task's estimate. Needs ``task.update``. With ``expected_version``
    the change is refused (409) if the task changed since; 0 means "whatever is there now"."""
    task = _task(actor, workspace, project_id, task_id, "task.update")
    changed = tasks.update(
        actor,
        workspace,
        project_id,
        task_id,
        expected_version or task.version,
        {"estimate_sec": str(estimate_sec) if estimate_sec else ""},
    )
    return changed


# -- reading ---------------------------------------------------------------------------------


def _visible_enabled(actor: Any, workspace: Workspace) -> list[Any]:
    rows = Project.objects.visible_to(actor, workspace).filter(archived_at__isnull=True)
    return [p.pk for p in rows if feature_on(p)]


def flag(rows: list[TimeEntry], now: datetime) -> dict[Any, tuple[str, ...]]:
    """What is odd about each entry: ``running``, ``long`` (over 24 h) or ``overlap`` (another
    entry of the same person covers part of the same time)."""
    if not rows:
        return {}
    users = {r.user_id for r in rows}
    low = min(r.started_at for r in rows)
    high = max(r.ended_at or now for r in rows)
    workspaces = {r.workspace_id for r in rows}
    others = list(
        TimeEntry.objects.filter(
            user_id__in=users,
            workspace_id__in=workspaces,
            task__deleted_at__isnull=True,
            started_at__lt=high,
        ).filter(Q(ended_at__isnull=True) | Q(ended_at__gt=low))
    )
    out: dict[Any, tuple[str, ...]] = {}
    for r in rows:
        mine = (r.started_at, r.ended_at or now)
        found: list[str] = []
        if r.ended_at is None:
            found.append("running")
        if seconds_of(r, now) > LONG_ENTRY_SEC:
            found.append("long")
        if any(
            o.pk != r.pk
            and o.user_id == r.user_id
            and o.started_at < mine[1]
            and (o.ended_at or now) > mine[0]
            for o in others
        ):
            found.append("overlap")
        out[r.pk] = tuple(found)
    return out


def rows_of(entries: list[TimeEntry], now: datetime) -> list[Row]:
    flags = flag(entries, now)
    return [Row(e, e.task, seconds_of(e, now), flags[e.pk]) for e in entries]


def entries_for_task(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> list[Row]:
    """Everyone's entries on the task, newest first (time on a task is a team matter)."""
    task = _task(actor, workspace, project_id, task_id, VIEW)
    found = list(
        TimeEntry.objects.filter(task=task)
        .select_related("task__project", "user__profile")
        .order_by("-started_at", "id")[:ENTRIES_LIMIT]
    )
    return rows_of(found, timezone.now())


@dataclass(frozen=True, slots=True)
class Summary:
    estimate_sec: int  # 0 = none
    logged_sec: int
    billable_sec: int
    running: bool  # somebody has a timer on it


def summary(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> Summary:
    task = _task(actor, workspace, project_id, task_id, VIEW)
    now = timezone.now()
    closed = TimeEntry.objects.filter(task=task, ended_at__isnull=False)
    totals = closed.aggregate(
        all=Sum("duration_sec"), pay=Sum("duration_sec", filter=Q(billable=True))
    )
    live = list(TimeEntry.objects.filter(task=task, ended_at__isnull=True))
    live_sec = sum(seconds_of(e, now) for e in live)
    live_pay = sum(seconds_of(e, now) for e in live if e.billable)
    return Summary(
        task.estimate_sec or 0,
        (totals["all"] or 0) + live_sec,
        (totals["pay"] or 0) + live_pay,
        bool(live),
    )
