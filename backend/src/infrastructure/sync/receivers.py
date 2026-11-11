"""Turns the apps' ``*_changed`` signals into change-log rows and events."""

import functools
import logging
from typing import Any

from infrastructure.customfields.signals import fields_changed
from infrastructure.projects.signals import project_changed
from infrastructure.sync import publish
from infrastructure.tasks.signals import task_changed
from infrastructure.workflows.signals import workflow_changed
from infrastructure.workspaces.signals import access_changed

UID = "infrastructure.sync"
log = logging.getLogger(__name__)


def _guarded(receive: Any) -> Any:
    """A signal is sent from an ``on_commit`` hook: an error here would fail the request that made
    an already committed change and skip every hook after it. Log it; the log row, if it was
    written, still lets a client catch up."""

    @functools.wraps(receive)
    def run(sender: Any, **kw: Any) -> None:
        try:
            receive(sender, **kw)
        except Exception:
            log.exception("Could not record a change")

    return run


@_guarded
def _task(sender: Any, **kw: Any) -> None:
    publish.record(
        entity_type="task",
        entity_id=kw["task_id"],
        workspace_id=kw["workspace_id"],
        project_id=kw["project_id"],
        version=kw["version"],
        action=kw["action"],
    )


@_guarded
def _project(sender: Any, **kw: Any) -> None:
    publish.record(
        entity_type="project",
        entity_id=kw["project_id"],
        workspace_id=kw["workspace_id"],
        project_id=kw["project_id"],
        version=kw["version"],
        action=kw["action"],
    )


def _project_part(entity_type: str) -> Any:
    @_guarded
    def receive(sender: Any, **kw: Any) -> None:
        publish.record(
            entity_type=entity_type,
            entity_id=kw["project_id"],
            workspace_id=kw["workspace_id"],
            project_id=kw["project_id"],
            version=kw["version"],
        )

    return receive


@_guarded
def _access(sender: Any, **kw: Any) -> None:
    publish.record(
        entity_type="access",
        entity_id=kw["user_id"] or kw["workspace_id"],
        workspace_id=kw["workspace_id"],
        action="changed",
        user_id=kw["user_id"],
    )


_workflow = _project_part("workflow")
_fields = _project_part("fields")


def connect() -> None:
    task_changed.connect(_task, dispatch_uid=f"{UID}.task")
    project_changed.connect(_project, dispatch_uid=f"{UID}.project")
    workflow_changed.connect(_workflow, dispatch_uid=f"{UID}.workflow")
    fields_changed.connect(_fields, dispatch_uid=f"{UID}.fields")
    access_changed.connect(_access, dispatch_uid=f"{UID}.access")
