"""Sprints of the Web project: one finished, one running (with burndown) and one planned."""

from datetime import timedelta
from decimal import Decimal

from django.utils import timezone

from infrastructure.common.demo.base import Ctx, day
from infrastructure.sprints import services as sprints
from infrastructure.sprints import snapshots, tally
from infrastructure.sprints.models import Snapshot, Sprint
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Category

PAST_DONE, PAST_OPEN, ACTIVE_TASKS, LATER_TASKS = 6, 2, 6, 4
LATE_ADD_DAYS_AGO = 3


def _shape(sprint: Sprint, final_points: Decimal, final_tasks: int) -> None:
    """Snapshots are written from today's state (flat); bend them into a descending burndown."""
    rows = list(Snapshot.objects.filter(sprint=sprint).order_by("date"))
    for index, row in enumerate(rows):
        progress = Decimal((index + 1) / len(rows)) ** Decimal("0.8")
        row.remaining_points = max(
            Decimal(0), row.scope_points - (row.scope_points - final_points) * progress
        ).quantize(Decimal("0.01"))
        row.remaining_tasks = max(
            final_tasks, round(row.scope_tasks - (row.scope_tasks - final_tasks) * float(progress))
        )
        row.backfilled = False
    Snapshot.objects.bulk_update(rows, ["remaining_points", "remaining_tasks", "backfilled"])


def _add(ctx: Ctx, sprint: Sprint, picked: list[Task], when: object = None) -> None:
    ids = [str(t.pk) for t in picked]
    sprints.add_tasks(ctx.owner, ctx.ws, str(sprint.project_id), str(sprint.pk), ids, now=when)  # type: ignore[arg-type]


def seed(ctx: Ctx) -> None:
    pid, now = str(ctx.projects["web"].pk), timezone.now()
    top = list(
        Task.objects.filter(project_id=pid, deleted_at__isnull=True, parent__isnull=True)
        .select_related("status")
        .order_by("number")
    )
    done = [t for t in top if t.status.category == Category.DONE]
    free = [t for t in top if t.status.category in tally.OPEN and t.sprint_id is None]

    def make(name: str, goal: str, start: int, end: int, points: str, hours: int) -> Sprint:
        return sprints.create(
            ctx.owner, ctx.ws, pid, name, goal, day(start), day(end), points, hours * 3600
        ).sprint

    past = make("Sprint 12", "Ship the onboarding revamp", -21, -8, "30", 160)
    current = make("Sprint 13", "Checkout redesign, first half", -7, 6, "40", 160)
    later = make("Sprint 14", "Payments and polish", 7, 20, "40", 160)

    _add(ctx, past, done[:PAST_DONE] + free[:PAST_OPEN], now - timedelta(days=22))
    sprints.start(ctx.owner, ctx.ws, pid, str(past.pk), now=now - timedelta(days=21))
    sprints.complete(
        ctx.owner, ctx.ws, pid, str(past.pk), "next", str(current.pk), now=now - timedelta(days=8)
    )
    past.refresh_from_db()
    _shape(
        past, max(Decimal(0), past.baseline_points - past.completed_points), past.unfinished_tasks
    )

    rest = free[PAST_OPEN:]
    _add(ctx, current, rest[:ACTIVE_TASKS], now - timedelta(days=8))
    sprints.start(ctx.owner, ctx.ws, pid, str(current.pk), now=now - timedelta(days=7))
    if len(rest) > ACTIVE_TASKS:  # scope added mid-sprint shows as a step in the burndown
        _add(
            ctx,
            current,
            rest[ACTIVE_TASKS : ACTIVE_TASKS + 1],
            now - timedelta(days=LATE_ADD_DAYS_AGO),
        )
    _add(ctx, later, rest[ACTIVE_TASKS + 1 : ACTIVE_TASKS + 1 + LATER_TASKS])
    current.refresh_from_db()
    snapshots.catch_up(current, now)
    counts = tally.tally(current)
    _shape(current, counts.open_points, counts.open_tasks)
    ctx.extra["sprints"] = {"past": past, "active": current, "future": later}
