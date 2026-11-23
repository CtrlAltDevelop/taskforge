"""A dashboard of the common widgets over 100 000 tasks opens in under two seconds."""

import time
import uuid
from datetime import timedelta
from typing import Any

from django.utils import timezone

from infrastructure.common.tests.perf import budget
from infrastructure.dashboards import services
from infrastructure.dashboards.services import WidgetInput
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Status

ROWS = 100_000
BUDGET_SECONDS = 2.0


def test_the_common_widgets_over_100k_tasks_load_in_two_seconds(world: Any) -> None:
    world.task(world.web, "seed")  # creates the workflow's statuses
    statuses = list(Status.objects.filter(project=world.web))
    now = timezone.now()
    prototype = Task.objects.get(project=world.web)
    Task.objects.bulk_create(
        (
            Task(
                workspace=world.ws,
                project=world.web,
                number=1000 + i,
                title=f"t{i}",
                status=statuses[i % len(statuses)],
                priority=("none", "low", "normal", "high", "urgent")[i % 5],
                created_at=now - timedelta(days=i % 120),
                position=prototype.position,
                path=f"p{i}",
                tree_key=f"k{i}",
                points=i % 8,
                created_by=world.owner,
            )
            for i in range(ROWS)
        ),
        batch_size=5000,
    )
    kinds = [
        ("number", {}),
        ("number", {"measure": "points"}),
        ("bar", {"group_by": "status"}),
        ("pie", {"group_by": "priority"}),
        ("line", {"group_by": "created_week"}),
        ("workload", {}),
        ("number", {"measure": "cycle_days"}),
    ]
    widgets = [WidgetInput(str(uuid.uuid4()), k, k, c) for k, c in kinds]
    view = services.save(
        world.owner, world.ws, "", name="Big", visibility="personal", project_id="",
        widgets=widgets, layout=[],
    )  # fmt: skip
    began = time.perf_counter()
    totals = [
        services.widget_data(world.owner, world.ws, str(w.pk)).result.total for w in view.widgets
    ]
    elapsed = time.perf_counter() - began
    assert totals[0] == ROWS + 1
    cycle = services.widget_data(world.owner, world.ws, str(view.widgets[-1].pk))
    assert cycle.result.truncated  # past the row cap the average says it is a sample
    assert elapsed < budget(BUDGET_SECONDS), f"{elapsed:.2f}s for seven widgets over {ROWS} tasks"
