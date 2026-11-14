"""Turn the domain events other apps already send (tasks, comments) into webhook events.

Each handler runs after the change committed and never raises into the code that sent it.
"""

import functools
import logging
from collections.abc import Callable
from typing import Any

from infrastructure.comments.models import Comment
from infrastructure.comments.signals import comment_changed
from infrastructure.developer import delivery, events
from infrastructure.developer.models import Webhook
from infrastructure.goals.signals import goal_progress_changed
from infrastructure.tasks.models import Task
from infrastructure.tasks.signals import task_activity, task_changed

logger = logging.getLogger(__name__)

_TASK_ACTIONS = {"created": "task.created", "updated": "task.updated", "deleted": "task.deleted"}
_COMMENT_ACTIONS = {
    "created": "comment.created",
    "updated": "comment.updated",
    "deleted": "comment.deleted",
}


def _guarded(handler: Callable[..., None]) -> Callable[..., None]:
    @functools.wraps(handler)
    def run(sender: Any, **kw: Any) -> None:
        try:
            handler(sender, **kw)
        except Exception:  # noqa: BLE001 -- the change is committed; webhooks are best effort here
            logger.exception("webhooks could not handle %s", handler.__name__)

    return run


def _wanted(workspace_id: Any, event: str) -> bool:
    return any(
        event in hook_events
        for hook_events in Webhook.objects.filter(
            workspace_id=workspace_id, active=True
        ).values_list("events", flat=True)
    )


def _send_task(kw: dict[str, Any], event: str, identity: str, extra: dict[str, Any]) -> None:
    if not _wanted(kw["workspace_id"], event):
        return
    task = Task.objects.select_related("status").filter(pk=kw["task_id"]).first()
    if task is None:
        return
    data = {"task": events.task_data(task), **extra}
    delivery.dispatch(kw["workspace_id"], kw["project_id"], event, identity, data)


@_guarded
def _task_changed(sender: Any, **kw: Any) -> None:
    event = _TASK_ACTIONS.get(kw["action"])
    if event:
        _send_task(kw, event, f"{event}:{kw['task_id']}:{kw['version']}", {})


@_guarded
def _task_activity(sender: Any, **kw: Any) -> None:
    kind, data = kw["kind"], kw["data"]
    if kind == "status_changed":
        extra = {"from": data.get("from_name"), "to": data.get("to_name")}
        _send_task(kw, "task.status_changed", f"status:{kw['task_id']}:{kw['version']}", extra)
    elif kind == "assigned":
        extra = {"assignee_ids": [str(u) for u in data.get("user_ids", [])]}
        _send_task(kw, "task.assigned", f"assigned:{kw['task_id']}:{kw['version']}", extra)


@_guarded
def _comment_changed(sender: Any, **kw: Any) -> None:
    event = _COMMENT_ACTIONS.get(kw["action"])
    if not event or not _wanted(kw["workspace_id"], event):
        return
    from infrastructure.comments.body import plain_text

    comment = Comment.objects.filter(pk=kw["comment_id"]).first()
    if comment is None:
        return
    text = "" if comment.deleted_at else plain_text(comment.body)
    delivery.dispatch(
        kw["workspace_id"],
        kw["project_id"],
        event,
        f"{event}:{kw['comment_id']}:{kw['version']}",
        {"comment": events.comment_data(comment, text)},
    )


@_guarded
def _goal_progress(sender: Any, **kw: Any) -> None:
    event = "goal.progress_changed"
    if not _wanted(kw["workspace_id"], event):
        return
    data = {
        "goal_id": kw["goal_id"],
        "previous": kw["previous"],
        "progress": kw["progress"],
        "status": kw["status"],
        "actor_id": kw["actor_id"] or None,
    }
    identity = f"{event}:{kw['goal_id']}:{kw['progress']}:{kw['previous']}"
    delivery.dispatch(kw["workspace_id"], None, event, identity, {"goal": data})


def connect() -> None:
    task_changed.connect(_task_changed, dispatch_uid="developer.task_changed")
    task_activity.connect(_task_activity, dispatch_uid="developer.task_activity")
    comment_changed.connect(_comment_changed, dispatch_uid="developer.comment_changed")
    goal_progress_changed.connect(_goal_progress, dispatch_uid="developer.goal_progress")
