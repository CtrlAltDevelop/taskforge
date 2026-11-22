"""Time entries, a running timer, estimates, capacity, time off and recurring tasks."""

from datetime import timedelta

from django.utils import timezone

from infrastructure.common.demo.base import Ctx, day
from infrastructure.recurrence import clock
from infrastructure.recurrence import services as recurring
from infrastructure.recurrence.models import Mode
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.timetracking import services as time
from infrastructure.workflows.models import Category, Status
from infrastructure.workload import services as workload

# who logs time on which web tasks (refs from taskdata)
LOGGERS = (
    ("dev", ("chk-audit", "chk-api", "login")),
    ("designer", ("chk-wire", "chk-hifi", "chk-pay")),
    ("member", ("launch", "chk")),
    ("admin", ("chk", "launch")),
    ("owner", ("chk",)),
)
LOG_DAYS = 14
# (hours per day, working weekdays Mon=0). The developer is part-time: busiest, over capacity.
CAPACITY = {
    "owner": (6, [0, 1, 2, 3, 4]),
    "admin": (8, [0, 1, 2, 3, 4]),
    "member": (8, [0, 1, 2, 3, 4]),
    "dev": (3, [1, 2, 3, 4]),
    "designer": (8, [0, 1, 2, 3, 4]),
    "viewer": (4, [0, 1, 2]),
    "guest": (6, [0, 1, 2, 3]),
}
# (user, first day offset, last day offset, kind, note)
TIME_OFF = (
    ("designer", 10, 14, "vacation", "Family trip"),
    ("member", -4, -3, "sick", "Flu"),
    ("admin", 3, 3, "personal", "Appointment"),
    ("dev", 20, 24, "vacation", "Conference and a few days after"),
)


def _log(ctx: Ctx) -> None:
    now = timezone.now()
    for key, refs in LOGGERS:
        actor = ctx.users[key]
        for ago in range(1, LOG_DAYS + 1):
            when = now - timedelta(days=ago)
            if when.weekday() > 4:
                continue
            task = ctx.tasks[refs[ago % len(refs)]]
            hours = 1 + (ago * 3 + len(key)) % 4
            time.create_entry(
                actor, ctx.ws, str(task.project_id), str(task.pk),
                when.replace(hour=9, minute=0, second=0, microsecond=0),
                hours * 3600, f"Working on {task.title.lower()}", billable=key != "owner",
            )  # fmt: skip


def _oddities(ctx: Ctx) -> None:
    """A forgotten 26 h entry and two overlapping ones (flagged for review), a running timer."""
    now = timezone.now().replace(minute=0, second=0, microsecond=0)
    member, dev = ctx.users["member"], ctx.users["dev"]
    launch, login = ctx.tasks["launch"], ctx.tasks["login"]
    pid = str(launch.project_id)
    time.create_entry(
        member, ctx.ws, pid, str(launch.pk), now - timedelta(days=20), 26 * 3600, "Left it running"
    )
    base = now - timedelta(days=16)
    for offset in (0, 1):
        time.create_entry(
            member,
            ctx.ws,
            pid,
            str(launch.pk),
            base + timedelta(minutes=30 * offset),
            3600,
            "Overlap",
        )
    time.start(dev, ctx.ws, str(login.project_id), str(login.pk), "Fixing the redirect")


def _estimates(ctx: Ctx) -> None:
    for ref, hours in (("chk-dark", 5), ("chk-wire", 3)):
        task = ctx.tasks[ref]
        time.set_estimate(ctx.owner, ctx.ws, str(task.project_id), str(task.pk), hours * 3600)


def _workload(ctx: Ctx) -> None:
    for key, (hours, days) in CAPACITY.items():
        workload.set_capacity(ctx.owner, ctx.ws, str(ctx.users[key].pk), hours, days)
    for key, first, last, kind, note in TIME_OFF:
        user = ctx.users[key]
        workload.create_time_off(user, ctx.ws, str(user.pk), day(first), day(last), kind, note)


def _repeating(ctx: Ctx) -> None:
    pid = str(ctx.projects["marketing"].pk)
    done = Status.objects.filter(project_id=pid, category=Category.DONE).first()
    admin = str(ctx.users["admin"].pk)

    def make(title: str, due: int, rule: str, mode: str, who: str = admin) -> Task:
        task = tasks.create(
            ctx.owner, ctx.ws, pid, title, priority="normal", due_date=day(due), assignee_ids=[who]
        )
        recurring.set_rule(ctx.owner, ctx.ws, pid, str(task.pk), rrule=rule, mode=mode)
        return task

    make("Weekly status report", -15, "FREQ=WEEKLY", Mode.SCHEDULE)  # instances are due now
    make("Month-end invoice run", 5, "FREQ=MONTHLY;BYMONTHDAY=1", Mode.SCHEDULE)
    paused = make("Quarterly brand audit", 12, "FREQ=MONTHLY;INTERVAL=3", Mode.SCHEDULE)
    recurring.pause(ctx.owner, ctx.ws, pid, str(paused.pk), True)
    review = make("Review analytics", -3, "FREQ=WEEKLY;INTERVAL=2", Mode.AFTER_COMPLETION)
    if done is not None:  # finishing it makes the next one
        tasks.update(
            ctx.owner,
            ctx.ws,
            pid,
            str(review.pk),
            review.version,
            {"status": str(done.pk)},
        )
    clock.generate_due()


def seed(ctx: Ctx) -> None:
    _log(ctx)
    _oddities(ctx)
    _estimates(ctx)
    _workload(ctx)
    _repeating(ctx)
