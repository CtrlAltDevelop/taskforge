"""Hook: a task reaching a done status makes the next instance of its after-completion series.
Runs after the change committed and never raises into the code that sent it."""

import logging
from typing import Any

from infrastructure.recurrence import clock
from infrastructure.tasks.signals import task_activity

logger = logging.getLogger(__name__)


def _activity(sender: Any, **kw: Any) -> None:
    if kw["kind"] != "status_changed":
        return
    try:
        clock.on_completed(kw["task_id"])
    except Exception:  # noqa: BLE001 -- the change is committed; the tick makes up for it
        logger.exception("recurrence could not handle a completion")


def connect() -> None:
    task_activity.connect(_activity, dispatch_uid="recurrence.activity")
