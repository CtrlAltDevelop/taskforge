"""Linked key results: count their tasks, and recount (debounced) when tasks change.

A task event marks the affected linked key results dirty with a due time a few seconds ahead; one
drain (Celery task or ``make tick``) recounts those that are due. Events that arrive while a row
is waiting do not move it, so a burst of edits costs one recount.
"""

import json
import logging
from datetime import timedelta
from decimal import Decimal
from typing import Any, Final

from django.conf import settings
from django.db import transaction
from django.db.models import Count, Q
from django.utils import timezone

from infrastructure.filters import query as filter_query
from infrastructure.goals import progress as math
from infrastructure.goals.events import tracking
from infrastructure.goals.models import CheckIn, KeyResult, KeyResultTask, KrType, ProgressDirty
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Category

logger = logging.getLogger(__name__)

BATCH: Final = 200
COUNTED_ACTIONS: Final = frozenset({"created", "updated", "deleted", "restored", "reparented"})


def task_condition(kr: KeyResult, actor: Any) -> Q:
    """Which tasks the key result counts: the hand-picked ones plus those the filter matches
    among the projects ``actor`` may see. Matches nothing when it has neither."""
    cond = Q(pk__in=[])
    if KeyResultTask.objects.filter(kr=kr).exists():
        cond |= Q(pk__in=KeyResultTask.objects.filter(kr=kr).values("task_id"))
    if kr.filter_ast and actor is not None:
        workspace = kr.goal.workspace
        where = filter_query.prepare_workspace(
            workspace, json.dumps(kr.filter_ast), timezone.localdate().isoformat(), actor
        ).where
        visible = Project.objects.visible_to(actor, workspace)
        cond |= Q(project__in=visible) & where
    return cond


def count_linked(kr: KeyResult) -> tuple[int, int]:
    """``(done, total)``. Deleted tasks and cancelled ones are not in the total."""
    goal = kr.goal
    actor = goal.owner or goal.created_by
    rows = (
        Task.objects.filter(workspace_id=goal.workspace_id, deleted_at__isnull=True)
        .filter(task_condition(kr, actor))
        .exclude(status__category=Category.CANCELLED)
    )
    found = rows.aggregate(
        total=Count("pk", distinct=True),
        done=Count("pk", filter=Q(status__category=Category.DONE), distinct=True),
    )
    return found["done"], found["total"]


def recompute_kr(kr_id: Any) -> bool:
    """Recount one linked key result; True when its numbers changed."""
    with transaction.atomic():
        kr = KeyResult.objects.select_related("goal", "goal__workspace").filter(pk=kr_id).first()
        if kr is None or kr.type != KrType.LINKED:
            return False
        done, total = count_linked(kr)
        if (done, total) == (kr.linked_done, kr.linked_total):
            return False
        with tracking(kr.goal.workspace_id):
            previous = kr.linked_done
            kr.linked_done, kr.linked_total = done, total
            kr.updated_at = timezone.now()
            kr.save(update_fields=["linked_done", "linked_total", "updated_at"])
            CheckIn.objects.create(
                kr=kr,
                user=None,
                value=done,
                previous_value=previous,
                progress=math.kr_progress(
                    kr.type, kr.start_value, kr.target_value, Decimal(0), done, total
                ),
            )
    return True


def debounce_seconds() -> int:
    return int(getattr(settings, "GOALS_RECOMPUTE_DEBOUNCE_SECONDS", 15))


def mark_dirty(kr_ids: Any) -> int:
    """Queue the key results for a recount (an already queued one keeps its earlier time)."""
    due = timezone.now() + timedelta(seconds=debounce_seconds())
    queued = 0
    for pk in kr_ids:
        _, created = ProgressDirty.objects.get_or_create(kr_id=pk, defaults={"due_at": due})
        queued += int(created)
    return queued


def affected_by_task(task_id: Any, workspace_id: Any) -> list[Any]:
    """Linked key results a change to this task may move: ones that picked it, and every one with
    a filter in the workspace."""
    by_filter = KeyResult.objects.filter(
        goal__workspace_id=workspace_id, type=KrType.LINKED, filter_ast__isnull=False
    )
    picked = KeyResultTask.objects.filter(task_id=task_id).values("kr_id")
    rows = KeyResult.objects.filter(
        Q(pk__in=by_filter.values("pk")) | Q(pk__in=picked), type=KrType.LINKED
    )
    return list(rows.values_list("pk", flat=True))


def process_due() -> int:
    """Recount every key result whose time has come; returns how many changed."""
    now = timezone.now()
    ids = list(
        ProgressDirty.objects.filter(due_at__lte=now)
        .order_by("due_at")
        .values_list("kr_id", flat=True)[:BATCH]
    )
    changed = 0
    for kr_id in ids:
        claimed, _ = ProgressDirty.objects.filter(kr_id=kr_id, due_at__lte=now).delete()
        if not claimed:
            continue  # another worker took it
        try:
            changed += int(recompute_kr(kr_id))
        except Exception:  # noqa: BLE001 -- one bad filter must not stop the rest
            logger.exception("could not recount key result %s", kr_id)
    return changed
