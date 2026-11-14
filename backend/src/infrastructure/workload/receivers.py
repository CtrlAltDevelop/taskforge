"""A task changed: the cached workload grids of its workspace are stale."""

from typing import Any

from infrastructure.tasks.signals import task_changed
from infrastructure.workload import services


def _task_changed(sender: Any, **kw: Any) -> None:
    services.invalidate(kw["workspace_id"])


def connect() -> None:
    task_changed.connect(_task_changed, dispatch_uid="workload.task_changed")
