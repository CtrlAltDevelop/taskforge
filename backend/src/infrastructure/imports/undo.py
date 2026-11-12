"""Taking an import back: exactly what it made, and nothing a person made since.

A task the import made that now has subtasks someone added by hand is kept (with the chain above
it), so no work of a person is deleted; the count of kept tasks is part of the answer.
"""

from typing import Any

from django.db import transaction
from django.db.models import ProtectedError

from infrastructure.audit import context as audit_context
from infrastructure.audit import recorder
from infrastructure.comments.models import Comment
from infrastructure.customfields.models import FieldDefinition
from infrastructure.imports import engine
from infrastructure.imports.models import ImportJob, PlaceholderUser
from infrastructure.projects.models import Project
from infrastructure.search.models import Kind, SearchEntry
from infrastructure.sprints.models import Sprint
from infrastructure.tasks import tree
from infrastructure.tasks.models import Task, TaskLink
from infrastructure.workflows.models import Status

BATCH = 500


def _ids(job: ImportJob, kind: str) -> list[Any]:
    return list(job.refs.filter(entity_type=kind).values_list("entity_id", flat=True))


def _worked_on(task_ids: set[Any], imported_comments: set[Any]) -> set[Any]:
    """The imported tasks a person has added to since: a sub-task, a comment of their own, a file
    or logged time."""
    from infrastructure.attachments.models import Attachment
    from infrastructure.timetracking.models import TimeEntry

    worked: set[Any] = set()
    ids = sorted(task_ids, key=str)
    for start in range(0, len(ids), BATCH):
        part = ids[start : start + BATCH]
        worked.update(
            Task.objects.filter(parent_id__in=part)
            .exclude(pk__in=task_ids)
            .values_list("parent_id", flat=True)
        )
        theirs = Comment.objects.filter(task_id__in=part, deleted_at__isnull=True)
        worked.update(
            t for t, c in theirs.values_list("task_id", "pk") if c not in imported_comments
        )
        worked.update(
            Attachment.objects.filter(task_id__in=part, deleted_at__isnull=True).values_list(
                "task_id", flat=True
            )
        )
        worked.update(TimeEntry.objects.filter(task_id__in=part).values_list("task_id", flat=True))
    return worked


def _kept(task_ids: set[Any], imported_comments: set[Any]) -> set[Any]:
    """Imported tasks to keep: those a person has worked on, and the chain above them."""
    worked = _worked_on(task_ids, imported_comments)
    kept: set[Any] = set()
    for path in Task.objects.filter(pk__in=worked).values_list("path", flat=True):
        kept.update(p for p in path.split(tree.PATH_SEP) if p)
    return {pk for pk in task_ids if str(pk) in kept}


def undo(job: ImportJob) -> dict[str, int]:
    """Remove what ``job`` made; returns counts of what went and what was kept."""
    gone: dict[str, int] = {}
    with transaction.atomic(), audit_context.suppressed():
        task_ids = set(_ids(job, "task"))
        comment_ids = set(_ids(job, "comment"))
        keep = _kept(task_ids, comment_ids)
        SearchEntry.objects.filter(kind=Kind.COMMENT, ref_id__in=comment_ids).delete()
        gone["comments"] = Comment.objects.filter(pk__in=comment_ids).delete()[0]
        gone["links"] = TaskLink.objects.filter(pk__in=_ids(job, "link")).delete()[0]
        removing = list(task_ids - keep)
        projects = set(Task.objects.filter(pk__in=removing).values_list("project_id", flat=True))
        for start in range(0, len(removing), BATCH):
            Task.objects.filter(pk__in=removing[start : start + BATCH]).delete()
        gone["tasks"] = len(removing)
        gone["kept"] = len(keep)
        _structure(job, gone, kept=bool(keep))
        for project_id in projects:
            if Project.objects.filter(pk=project_id).exists():
                tree.refresh_project(project_id)
        job.refs.exclude(entity_id__in=list(keep)).delete()
        for project_id in projects:
            if Project.objects.filter(pk=project_id).exists():
                engine.tell_clients(project_id)
        recorder.record(
            workspace_id=job.workspace_id,
            action="import.undone",
            target_type="import",
            target_id=job.pk,
            actor=job.created_by,
            actor_type="system",
            changes={"removed": gone},
        )
    return gone


def _structure(job: ImportJob, gone: dict[str, int], *, kept: bool) -> None:
    """The statuses, fields, sprints, placeholders and project the import made, where nothing
    that matters still uses them."""
    held = PlaceholderUser.objects.filter(pk__in=_ids(job, "placeholder"), assignments__isnull=True)
    gone["placeholders"] = held.delete()[0]
    # A sprint or field somebody has since used for their own work stays.
    unused_sprints = Sprint.objects.filter(pk__in=_ids(job, "sprint"), tasks__isnull=True)
    gone["sprints"] = unused_sprints.delete()[0]
    unused_fields = FieldDefinition.objects.filter(pk__in=_ids(job, "field"), values__isnull=True)
    gone["fields"] = unused_fields.delete()[0]
    removed = 0
    for status in Status.objects.filter(pk__in=_ids(job, "status")):
        try:
            with transaction.atomic():
                status.delete()
            removed += 1
        except ProtectedError:
            continue  # a task the person made uses it
    gone["statuses"] = removed
    for project in Project.objects.filter(pk__in=_ids(job, "project")):
        if not Task.objects.filter(project=project).exists() and not kept:
            try:
                with transaction.atomic():
                    project.delete()
                gone["projects"] = 1
            except ProtectedError:
                continue
