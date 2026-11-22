"""Hooks from the other apps into the inbox: a task assigned or moved, someone mentioned, a comment.

Each handler runs after the change committed (the signals are sent through ``on_commit``) and must
never raise into the code that sent it, so a failure is logged and the work that caused it stays.
"""

import functools
import logging
from collections.abc import Callable
from typing import Any

from infrastructure.chat.signals import chat_notice
from infrastructure.comments import body as comment_body
from infrastructure.comments.models import Comment, CommentMention
from infrastructure.comments.signals import comment_changed, user_mentioned
from infrastructure.goals.signals import goal_progress_changed
from infrastructure.inbox import kinds, notify, render, watchers
from infrastructure.tasks.models import Task
from infrastructure.tasks.signals import task_activity

logger = logging.getLogger(__name__)
UID = "inbox"


def _guarded(handler: Callable[..., None]) -> Callable[..., None]:
    @functools.wraps(handler)
    def run(sender: Any, **kw: Any) -> None:
        try:
            handler(sender, **kw)
        except Exception:  # noqa: BLE001 -- the change is committed; telling people is best effort
            logger.exception("inbox could not handle %s", handler.__name__)

    return run


def _task(task_id: Any) -> Task | None:
    return (
        Task.objects.filter(pk=task_id, deleted_at__isnull=True)
        .select_related("project", "workspace")
        .first()
    )


def _about(task: Task) -> dict[str, Any]:
    return {"title": task.title, "key": task.display_id}


@_guarded
def _activity(sender: Any, **kw: Any) -> None:
    task = _task(kw["task_id"])
    if task is None:
        return
    kind, data, actor = kw["kind"], kw["data"], kw["actor_id"]
    if kind == "created":
        watchers.ensure(task.pk, [task.created_by_id])
    elif kind == "assigned":
        watchers.ensure(task.pk, data["user_ids"])
        notify.notify(
            kind=kinds.ASSIGNED,
            recipients=data["user_ids"],
            workspace=task.workspace,
            project=task.project,
            task=task,
            actor_id=actor,
            payload=_about(task),
            dedupe=f"assigned:{task.pk}:{kw['version']}",
            fold=False,
        )
    elif kind == "status_changed":
        notify.notify(
            kind=kinds.STATUS_CHANGED,
            recipients=watchers.watcher_ids(task.pk),
            workspace=task.workspace,
            project=task.project,
            task=task,
            actor_id=actor,
            payload={**_about(task), "from": data["from_name"], "to": data["to_name"]},
            dedupe=f"status:{task.pk}:{kw['version']}",
        )


def _excerpt(comment: Comment) -> str:
    return render.excerpt(comment_body.plain_text(comment.body)) if comment.body else ""


@_guarded
def _mentioned(sender: Any, **kw: Any) -> None:
    task, comment = _task(kw["task_id"]), Comment.objects.filter(pk=kw["comment_id"]).first()
    if task is None or comment is None:
        return
    watchers.ensure(task.pk, [kw["user_id"]])
    notify.notify(
        kind=kinds.MENTIONED,
        recipients=[kw["user_id"]],
        workspace=task.workspace,
        project=task.project,
        task=task,
        actor_id=kw["author_id"],
        payload={**_about(task), "comment_id": str(comment.pk), "excerpt": _excerpt(comment)},
        dedupe=f"mention:{comment.pk}:{kw['version']}",
        fold=False,
    )


@_guarded
def _comment(sender: Any, **kw: Any) -> None:
    if kw["action"] != "created":
        return
    task, comment = _task(kw["task_id"]), Comment.objects.filter(pk=kw["comment_id"]).first()
    if task is None or comment is None or comment.is_deleted or comment.is_system:
        return
    watchers.ensure(task.pk, [comment.author_id])
    told_as_mentioned = set(
        CommentMention.objects.filter(comment=comment).values_list("user_id", flat=True)
    )
    notify.notify(
        kind=kinds.COMMENTED,
        recipients=[u for u in watchers.watcher_ids(task.pk) if u not in told_as_mentioned],
        workspace=task.workspace,
        project=task.project,
        task=task,
        actor_id=comment.author_id,
        payload={**_about(task), "comment_id": str(comment.pk), "excerpt": _excerpt(comment)},
        dedupe=f"comment:{comment.pk}",
    )


# status moves and assignment already have their own notification kinds
_OWN_KIND = frozenset({"status_id", "assignees"})


@_guarded
def _system_message(sender: Any, **kw: Any) -> None:
    """A change message in a task's chat tells the assignees and watchers, once (a coalesced
    message is an update, not a new notification)."""
    if kw["action"] != "created":
        return
    comment = Comment.objects.filter(pk=kw["comment_id"], kind="system").first()
    task = _task(kw["task_id"])
    if comment is None or task is None or (comment.event or {}).get("field") in _OWN_KIND:
        return
    event = comment.event or {}
    recipients = {*watchers.watcher_ids(task.pk), *task.assignee_ids()}
    notify.notify(
        kind=kinds.TASK_CHANGED,
        recipients=list(recipients),
        workspace=task.workspace,
        project=task.project,
        task=task,
        actor_id=comment.author_id,
        payload={**_about(task), "field": event.get("field", "")},
        dedupe=f"taskchanged:{comment.pk}",
    )


@_guarded
def _chat(sender: Any, **kw: Any) -> None:
    from infrastructure.inbox import chat_notices

    chat_notices.handle(**kw)


@_guarded
def _goal(sender: Any, **kw: Any) -> None:
    from infrastructure.inbox import goal_notices

    goal_notices.handle(**kw)


def connect() -> None:
    goal_progress_changed.connect(_goal, dispatch_uid=f"{UID}.goal")
    chat_notice.connect(_chat, dispatch_uid=f"{UID}.chat")
    task_activity.connect(_activity, dispatch_uid=f"{UID}.activity")
    user_mentioned.connect(_mentioned, dispatch_uid=f"{UID}.mentioned")
    comment_changed.connect(_comment, dispatch_uid=f"{UID}.comment")
    comment_changed.connect(_system_message, dispatch_uid=f"{UID}.system")
