"""Keeping ``SearchEntry`` true: one row per live task and per live comment."""

from collections.abc import Iterable
from typing import Any

from infrastructure.comments import body
from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.search.fold import fold
from infrastructure.search.models import Kind, SearchEntry
from infrastructure.tasks.models import Task

BATCH = 500


def plain(document: Any) -> str:
    """The text of a stored rich-text document; empty for none."""
    if not document:
        return ""
    try:
        return body.plain_text(document)
    except ApiError:  # a document with no text in it
        return ""


def _task_values(task: Task) -> dict[str, Any]:
    return {
        "workspace_id": task.workspace_id,
        "task_id": task.pk,
        "title": fold(task.title),
        "body": fold(plain(task.description)),
        "updated_at": task.updated_at,
    }


def _comment_values(comment: Comment) -> dict[str, Any]:
    return {
        "workspace_id": comment.workspace_id,
        "task_id": comment.task_id,
        "title": "",
        "body": fold(plain(comment.body)),
        "updated_at": comment.edited_at or comment.created_at,
    }


def put_task(task_id: Any) -> None:
    """Write the task's row, or remove it when the task is gone or deleted."""
    task = Task.objects.filter(pk=task_id, deleted_at__isnull=True).first()
    if task is None:
        drop(Kind.TASK, task_id)
        return
    SearchEntry.objects.update_or_create(
        kind=Kind.TASK, ref_id=task.pk, defaults=_task_values(task)
    )


def put_comment(comment_id: Any) -> None:
    comment = Comment.objects.filter(pk=comment_id, deleted_at__isnull=True).first()
    if comment is None:
        drop(Kind.COMMENT, comment_id)
        return
    SearchEntry.objects.update_or_create(
        kind=Kind.COMMENT, ref_id=comment.pk, defaults=_comment_values(comment)
    )


def drop(kind: str, ref_id: Any) -> None:
    SearchEntry.objects.filter(kind=kind, ref_id=ref_id).delete()


def _chunks(rows: Iterable[Any]) -> Iterable[list[Any]]:
    chunk: list[Any] = []
    for row in rows:
        chunk.append(row)
        if len(chunk) >= BATCH:
            yield chunk
            chunk = []
    if chunk:
        yield chunk


def reindex(workspace_id: Any = None) -> int:
    """Rebuild every row (of one workspace, or all): what ``manage.py reindex`` runs after an
    import or a restore. Returns how many rows it wrote."""
    tasks = Task.objects.filter(deleted_at__isnull=True)
    comments = Comment.objects.filter(deleted_at__isnull=True, task__deleted_at__isnull=True)
    stale = SearchEntry.objects.all()
    if workspace_id:
        tasks = tasks.filter(workspace_id=workspace_id)
        comments = comments.filter(workspace_id=workspace_id)
        stale = stale.filter(workspace_id=workspace_id)
    stale.delete()
    written = 0
    for kind, rows, values in (
        (Kind.TASK, tasks, _task_values),
        (Kind.COMMENT, comments, _comment_values),
    ):
        for chunk in _chunks(rows.iterator(chunk_size=BATCH)):
            SearchEntry.objects.bulk_create(
                [SearchEntry(kind=kind, ref_id=row.pk, **values(row)) for row in chunk]
            )
            written += len(chunk)
    return written
