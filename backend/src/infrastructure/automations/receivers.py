"""Hooks from the other apps: the events that fire rules and the changes that break them.

Each handler runs after the change committed and never raises into the code that sent it. A rule
fires through ``queue.run_later``; the event id (``kind:task:version`` or the comment's id) is what
makes a retry harmless.
"""

import functools
import logging
from collections.abc import Callable
from typing import Any

from infrastructure.automations import engine, integrity, queue, spec
from infrastructure.automations.models import Automation
from infrastructure.comments.models import Comment
from infrastructure.comments.signals import comment_changed
from infrastructure.customfields.signals import fields_changed
from infrastructure.tasks.models import Task
from infrastructure.tasks.signals import task_activity, task_changed
from infrastructure.workflows.signals import workflow_changed
from infrastructure.workspaces.signals import access_changed

logger = logging.getLogger(__name__)


def _guarded(handler: Callable[..., None]) -> Callable[..., None]:
    @functools.wraps(handler)
    def run(sender: Any, **kw: Any) -> None:
        try:
            handler(sender, **kw)
        except Exception:  # noqa: BLE001 -- the change is committed; rules are best effort here
            logger.exception("automations could not handle %s", handler.__name__)

    return run


def dispatch(
    workspace_id: Any, project_id: Any, kind: str, task_id: Any, event_id: str, data: dict[str, Any]
) -> int:
    """Queue every enabled rule of the project whose trigger this event fires; returns how many."""
    rules = Automation.objects.filter(
        workspace_id=workspace_id, project_id=project_id, enabled=True, trigger__type=kind
    )
    depth = engine.current_depth()
    queued = 0
    for rule in rules:
        if not spec.matches(rule.trigger, kind, data):
            continue
        event = {
            "type": kind,
            "id": event_id,
            "task_id": str(task_id),
            "depth": depth,
            "data": data,
        }
        queue.run_later(engine.execute, str(rule.pk), event, lane=queue.lane_for(rule.actions))
        queued += 1
    return queued


@_guarded
def _activity(sender: Any, **kw: Any) -> None:
    kind, task_id = kw["kind"], kw["task_id"]
    event_id = f"{kind}:{task_id}:{kw['version']}"
    data: dict[str, Any] = {}
    if kind == "created":
        trigger = spec.TASK_CREATED
    elif kind == "assigned":
        trigger, data = spec.ASSIGNED, {"user_ids": [str(u) for u in kw["data"]["user_ids"]]}
    elif kind == "status_changed":
        status_id = Task.objects.filter(pk=task_id).values_list("status_id", flat=True).first()
        trigger, data = spec.STATUS_CHANGED, {"to_status": str(status_id)}
    else:
        return
    dispatch(kw["workspace_id"], kw["project_id"], trigger, task_id, event_id, data)


@_guarded
def _changed(sender: Any, **kw: Any) -> None:
    if kw["action"] != "updated":
        return
    versions = (
        Task.objects.filter(pk=kw["task_id"]).values_list("field_versions", flat=True).first()
    )
    changed = [name for name, v in (versions or {}).items() if v == kw["version"]]
    if not changed:
        return
    dispatch(
        kw["workspace_id"],
        kw["project_id"],
        spec.FIELD_CHANGED,
        kw["task_id"],
        f"updated:{kw['task_id']}:{kw['version']}",
        {"fields": changed},
    )


@_guarded
def _comment(sender: Any, **kw: Any) -> None:
    if kw["action"] != "created":
        return
    if Comment.objects.filter(pk=kw["comment_id"], kind="system").exists():
        return  # a change message is not a comment someone wrote
    dispatch(
        kw["workspace_id"],
        kw["project_id"],
        spec.COMMENT_ADDED,
        kw["task_id"],
        f"comment:{kw['comment_id']}",
        {"comment_id": kw["comment_id"]},
    )


@_guarded
def _project_broke(sender: Any, **kw: Any) -> None:
    integrity.check_project(kw["project_id"])


@_guarded
def _access_changed(sender: Any, **kw: Any) -> None:
    integrity.check_workspace(kw["workspace_id"])


def connect() -> None:
    task_activity.connect(_activity, dispatch_uid="automations.activity")
    task_changed.connect(_changed, dispatch_uid="automations.changed")
    comment_changed.connect(_comment, dispatch_uid="automations.comment")
    workflow_changed.connect(_project_broke, dispatch_uid="automations.workflow")
    fields_changed.connect(_project_broke, dispatch_uid="automations.fields")
    access_changed.connect(_access_changed, dispatch_uid="automations.access")
