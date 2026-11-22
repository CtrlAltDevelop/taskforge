"""The planning seed builds every area it promises on top of the core."""

from typing import Any

import pytest

from infrastructure.common.demo import core, planning
from infrastructure.common.demo.base import Ctx
from infrastructure.dashboards.models import Dashboard, Widget
from infrastructure.goals.models import CheckIn, Goal, KeyResult
from infrastructure.recurrence.models import RecurrenceSeries
from infrastructure.sprints.models import Snapshot, Sprint, State
from infrastructure.timetracking.models import TimeEntry
from infrastructure.workload.models import MemberCapacity, TimeOff

pytestmark = pytest.mark.django_db(transaction=True)


@pytest.fixture(autouse=True)
def _debug(settings: Any) -> None:
    settings.DEBUG = True


def test_planning_builds_every_area() -> None:
    ctx = Ctx()
    core.seed(ctx)
    planning.seed(ctx)

    states = set(Sprint.objects.values_list("state", flat=True))
    assert states == {State.COMPLETED, State.ACTIVE, State.PLANNED}
    assert Snapshot.objects.filter(sprint=ctx.extra["sprints"]["active"]).count() >= 5
    assert TimeEntry.objects.filter(ended_at__isnull=True).count() == 1
    assert TimeEntry.objects.count() > 30
    assert MemberCapacity.objects.count() == 7
    assert TimeOff.objects.count() == 4
    assert Goal.objects.count() == 4 and KeyResult.objects.count() == 7
    assert CheckIn.objects.count() >= 5
    assert Widget.objects.filter(type="burndown").exists()
    assert {w.type for w in Widget.objects.all()} >= {
        "number", "bar", "line", "pie", "table", "burndown", "workload", "goals",
    }  # fmt: skip
    assert Dashboard.objects.count() >= 4
    assert RecurrenceSeries.objects.filter(paused=True).count() == 1
    assert RecurrenceSeries.objects.count() == 4
