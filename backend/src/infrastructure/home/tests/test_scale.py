"""Home.Summary over a 50 000-task workspace stays inside its budget."""

import time
from datetime import date, timedelta

from django.core.cache import cache
from django.utils import timezone

from infrastructure.home import summary
from infrastructure.home.tests.conftest import World
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.workflows.models import Status

ROWS = 50_000
MINE_EVERY = 5  # one task in five is the viewer's
BUDGET_SECONDS = 0.15


def test_summary_over_50k_tasks_is_under_150ms(world: World) -> None:
    world.task(world.web, "seed")  # creates the workflow's statuses
    statuses = list(Status.objects.filter(project=world.web))
    prototype = Task.objects.get(project=world.web)
    today = date(2026, 11, 18)
    Task.objects.bulk_create(
        (
            Task(
                workspace=world.ws,
                project=world.web,
                number=1000 + i,
                title=f"t{i}",
                status=statuses[i % len(statuses)],
                due_date=today + timedelta(days=i % 30 - 10),
                position=prototype.position,
                path=f"p{i}",
                tree_key=f"k{i}",
                created_by=world.owner,
                created_at=timezone.now(),
            )
            for i in range(ROWS)
        ),
        batch_size=5000,
    )
    mine = Task.objects.filter(project=world.web, number__gte=1000).order_by("number")
    TaskAssignee.objects.bulk_create(
        (
            TaskAssignee(task_id=pk, user=world.member)
            for pk in mine.values_list("pk", flat=True)[::MINE_EVERY]
        ),
        batch_size=5000,
    )

    timings = []
    for _ in range(20):
        cache.clear()
        started = time.perf_counter()
        got = summary.summary(world.member, world.ws, today)
        timings.append(time.perf_counter() - started)

    assert got.overdue_count > 0 and got.today_count > 0
    assert sorted(timings)[int(len(timings) * 0.95) - 1] < BUDGET_SECONDS, timings  # p95
