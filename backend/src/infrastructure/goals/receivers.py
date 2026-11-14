"""A task changed: queue the linked key results it may move for a (debounced) recount."""

import logging
from typing import Any

from infrastructure.goals import recompute
from infrastructure.tasks.signals import task_changed

logger = logging.getLogger(__name__)


def _task_changed(sender: Any, **kw: Any) -> None:
    if kw["action"] not in recompute.COUNTED_ACTIONS:
        return
    try:
        ids = recompute.affected_by_task(kw["task_id"], kw["workspace_id"])
        if not ids:
            return
        recompute.mark_dirty(ids)
        from infrastructure.goals.tasks import recompute_due

        recompute_due.apply_async(countdown=recompute.debounce_seconds())
    except Exception:  # noqa: BLE001 -- the task change is committed; the drain is the safety net
        logger.exception("could not queue goal progress for task %s", kw.get("task_id"))


def connect() -> None:
    task_changed.connect(_task_changed, dispatch_uid="goals.task_changed")
