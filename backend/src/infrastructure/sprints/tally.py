"""What a sprint holds right now, counted from its tasks."""

from dataclasses import dataclass
from decimal import Decimal
from typing import Any

from django.db.models import Count, DecimalField, Q, Sum, Value
from django.db.models.functions import Coalesce

from infrastructure.sprints.models import Sprint
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Category

ZERO = Decimal("0.00")
OPEN = (Category.NOT_STARTED, Category.ACTIVE)  # cancelled leaves the count but is not "done"


@dataclass(frozen=True, slots=True)
class Tally:
    tasks: int = 0
    points: Decimal = ZERO
    estimate_sec: int = 0
    open_tasks: int = 0
    open_points: Decimal = ZERO
    done_tasks: int = 0
    done_points: Decimal = ZERO


def members(sprint: Sprint) -> Any:
    """The sprint's live tasks (a deleted task is out of every count)."""
    return Task.objects.filter(sprint=sprint, deleted_at__isnull=True)


def _sum(**filters: Any) -> Any:
    return Coalesce(
        Sum("points", filter=Q(**filters) if filters else None),
        Value(ZERO),
        output_field=DecimalField(max_digits=12, decimal_places=2),
    )


def tallies(sprint_ids: list[Any]) -> dict[Any, Tally]:
    rows = (
        Task.objects.filter(sprint_id__in=sprint_ids, deleted_at__isnull=True, is_sample=False)
        .values("sprint_id")
        .annotate(
            n=Count("pk"),
            pts=_sum(),
            est=Coalesce(Sum("estimate_sec"), Value(0)),
            open_n=Count("pk", filter=Q(status__category__in=OPEN)),
            open_pts=_sum(status__category__in=OPEN),
            done_n=Count("pk", filter=Q(status__category=Category.DONE)),
            done_pts=_sum(status__category=Category.DONE),
        )
    )
    found = {
        r["sprint_id"]: Tally(
            r["n"], r["pts"], r["est"], r["open_n"], r["open_pts"], r["done_n"], r["done_pts"]
        )
        for r in rows
    }
    return {pk: found.get(pk, Tally()) for pk in sprint_ids}


def tally(sprint: Sprint) -> Tally:
    return tallies([sprint.pk])[sprint.pk]
