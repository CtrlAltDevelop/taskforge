"""Every workflow rule. gRPC renders the answer; nothing here knows a transport.

A project's workflow is created on first use with three default statuses (``ensure``), so a
project made before this phase, or one nobody has opened yet, still has one. Reading needs
``workspace.view``; saving or validating needs ``project.update`` (so a project's creator may edit
it). ``update`` saves the whole workflow in one transaction: it is checked first (``validate`` plus
the database rules below) and an invalid draft changes nothing and answers the full list of
problems.
Deleting a status moves its tasks (trashed ones too) to the status the editor chose, in the same
transaction, so no task is ever left without a status.
"""

import json
from collections.abc import Callable, Mapping
from dataclasses import dataclass
from typing import Any

from django.core.exceptions import ValidationError
from django.db import transaction
from django.db.models import Count, Q
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.workflows.defaults import create_default_statuses
from infrastructure.workflows.drafts import Problem, StatusDraft, WorkflowDraft
from infrastructure.workflows.models import Status, Transition, Workflow
from infrastructure.workflows.signals import announce
from infrastructure.workflows.validate import validate
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Role, Workspace

VIEW = "workspace.view"
EDIT = "project.update"
MIGRATE_BATCH = 500


@dataclass(frozen=True, slots=True)
class WorkflowView:
    workflow: Workflow
    statuses: list[Status]
    transitions: list[Transition]


def ensure(project: Project) -> Workflow:
    """The project's workflow, created with the default statuses if it has none yet."""
    with transaction.atomic():
        workflow, created = Workflow.objects.get_or_create(project=project)
        if created:
            create_default_statuses(Status, project.pk)
    return workflow


def _view(project: Project) -> WorkflowView:
    workflow = ensure(project)
    return WorkflowView(
        workflow=workflow,
        # order_by is explicit: an aggregate annotation makes Django ignore Meta.ordering.
        statuses=list(
            Status.objects.filter(project=project)
            .annotate(task_count=Count("tasks"))
            .order_by("position", "name")
        ),
        transitions=list(Transition.objects.filter(project=project)),
    )


def get(actor: Any, workspace: Workspace, project_id: str) -> WorkflowView:
    access.require(actor, VIEW, workspace)
    return _view(projects.load(actor, workspace, project_id))


def default_status(project: Project) -> Status:
    """The status new tasks start in."""
    ensure(project)
    return Status.objects.get(project=project, is_default=True)


def status_of(project: Project, status_id: str) -> Status:
    """``status_id`` as a status of ``project``, else a 400 (a foreign id is just unknown)."""
    try:
        return Status.objects.get(project=project, pk=status_id)
    except (Status.DoesNotExist, ValidationError, ValueError, TypeError):
        raise ApiError("That status does not exist in this project.") from None


# ---------------------------------------------------------------------------------- save


def _invalid(problems: list[Problem]) -> ApiError:
    listing = [{"code": p.code, "message": p.message, "status_key": p.status_key} for p in problems]
    return ApiError(
        f"The workflow has {len(problems)} problem(s): " + "; ".join(p.message for p in problems),
        title=ResponseTitle.WORKFLOW_INVALID,
        data={"errors": json.dumps(listing)},
    )


def _migration_problems(
    draft: WorkflowDraft, migrate: Mapping[str, str], existing: Mapping[str, Status]
) -> list[Problem]:
    kept = {s.key for s in draft.statuses}
    problems: list[Problem] = []
    for key, status in existing.items():
        if key in kept or not status.tasks.exists():
            continue
        target = migrate.get(key, "")
        if not target or target == key or target not in kept:
            problems.append(
                Problem(
                    "STATUS_NEEDS_MIGRATION",
                    f"{status.name} has tasks: choose a status to move them to.",
                    key,
                )
            )
    return problems


def _role_problems(draft: WorkflowDraft, workspace: Workspace) -> list[Problem]:
    wanted = {t.required_role_id for t in draft.transitions if t.required_role_id}
    if not wanted:
        return []
    known = {
        str(pk)
        for pk in Role.objects.filter(Q(workspace=None) | Q(workspace=workspace)).values_list(
            "pk", flat=True
        )
    }
    return [
        Problem("TRANSITION_ROLE_UNKNOWN", "A transition names a role that does not exist.")
        for _ in sorted(wanted - known)
    ]


def _problems(
    workspace: Workspace,
    draft: WorkflowDraft,
    migrate: Mapping[str, str],
    existing: Mapping[str, Status],
) -> list[Problem]:
    return (
        validate(draft)
        + _migration_problems(draft, migrate, existing)
        + _role_problems(draft, workspace)
    )


def validate_draft(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    draft: WorkflowDraft,
    migrate: Mapping[str, str],
) -> list[Problem]:
    """A dry run of ``update``: every problem, nothing saved."""
    project = projects.authorize(actor, workspace, project_id, EDIT)
    ensure(project)
    existing = {str(s.pk): s for s in Status.objects.filter(project=project)}
    return _problems(workspace, draft, migrate, existing)


def _temporary(status: Status) -> str:
    return f"~{status.pk}"


def _move_tasks(source: Status, target: Status) -> None:
    """Move every task of ``source`` (trashed ones too) to ``target``; each counts as a status
    edit, so anyone holding the old version of one is told it changed. Read in batches, so a
    status with a great many tasks is not held in memory all at once."""
    from infrastructure.tasks.models import Task

    now = timezone.now()
    ids = list(Task.objects.filter(status=source).values_list("pk", flat=True))
    for start in range(0, len(ids), MIGRATE_BATCH):
        batch = list(
            Task.objects.select_for_update().filter(pk__in=ids[start : start + MIGRATE_BATCH])
        )
        for task in batch:
            task.status = target
            task.version += 1
            task.field_versions = {**task.field_versions, "status": task.version}
            task.updated_at = now
        Task.objects.bulk_update(
            batch, ["status", "version", "field_versions", "updated_at"], batch_size=MIGRATE_BATCH
        )


def _apply(
    project: Project,
    workflow: Workflow,
    draft: WorkflowDraft,
    migrate: Mapping[str, str],
    existing: dict[str, Status],
) -> None:
    kept_keys = {s.key for s in draft.statuses}
    removed = [s for key, s in existing.items() if key not in kept_keys]
    # Free every name and the default flag first: a save may swap two names, or reuse the name
    # of a status it deletes, and both are unique per project.
    for status in existing.values():
        Status.objects.filter(pk=status.pk).update(name=_temporary(status), is_default=False)
    by_key: dict[str, Status] = {}
    for position, item in enumerate(draft.statuses):
        by_key[item.key] = _write_status(project, existing.get(item.key), item, position)
    for gone in removed:
        if gone.tasks.exists():
            _move_tasks(gone, by_key[migrate[str(gone.pk)]])
        gone.delete()
    Transition.objects.filter(project=project).delete()
    Transition.objects.bulk_create(
        Transition(
            project=project,
            from_status=by_key[t.from_key],
            to_status=by_key[t.to_key],
            required_role_id=int(t.required_role_id) if t.required_role_id else None,
            require_assignee=t.require_assignee,
            require_subtasks_done=t.require_subtasks_done,
        )
        for t in draft.transitions
    )
    workflow.restrict_transitions = draft.restrict
    workflow.restrict_creation = draft.restrict_creation
    workflow.version += 1
    workflow.save(update_fields=["restrict_transitions", "restrict_creation", "version"])


def _recount_progress(project: Project) -> None:
    """A status changing category, or tasks moving to another status, changes how many subtasks
    are done: recount every parent of the project."""
    from infrastructure.tasks import tree

    tree.refresh_project(project.pk)


def _write_status(
    project: Project, current: Status | None, item: StatusDraft, position: int
) -> Status:
    values = {
        "name": item.name.strip(),
        "color": item.color.upper(),
        "category": item.category,
        "position": position,
        "is_default": item.is_default,
    }
    if current is None:
        return Status.objects.create(project=project, **values)
    Status.objects.filter(pk=current.pk).update(**values)
    current.refresh_from_db()
    return current


def update(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    expected_version: int,
    draft: WorkflowDraft,
    migrate: Mapping[str, str],
) -> WorkflowView:
    """Save the whole workflow or nothing. ``migrate`` maps each deleted status that still has
    tasks to the key of the status that takes them."""
    with transaction.atomic():
        project = projects.authorize(actor, workspace, project_id, EDIT, lock=True)
        projects.writable(project)
        ensure(project)
        workflow = Workflow.objects.select_for_update().get(project=project)
        if workflow.version != expected_version:
            raise ApiError(
                "The workflow changed since you opened it; reload and retry.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
            )
        existing = {
            str(s.pk): s for s in Status.objects.filter(project=project).select_for_update()
        }
        problems = _problems(workspace, draft, migrate, existing)
        if problems:
            raise _invalid(problems)
        _apply(project, workflow, draft, migrate, existing)
        _recount_progress(project)
        announce(project, workflow.version)
    return _view(project)


# ------------------------------------------------------------------------------- moves


def check_create(project: Project, target: Status) -> None:
    """Raise ``TRANSITION_NOT_ALLOWED`` if the project makes new tasks start in the default
    status and ``target`` is another one. Off by default: creating in any status is free."""
    if not ensure(project).restrict_creation or target.is_default:
        return
    start = Status.objects.get(project=project, is_default=True)
    reason = f"New tasks must start in {start.name}."
    raise ApiError(
        reason,
        status=409,
        title=ResponseTitle.TRANSITION_NOT_ALLOWED,
        data={"from": "", "to": str(target.pk), "reason": reason},
    )


def _not_allowed(source: Status, target: Status, reason: str) -> ApiError:
    return ApiError(
        reason,
        status=409,
        title=ResponseTitle.TRANSITION_NOT_ALLOWED,
        data={"from": str(source.pk), "to": str(target.pk), "reason": reason},
    )


def check_move(
    actor: Any,
    workspace: Workspace,
    project: Project,
    source: Status,
    target: Status,
    *,
    assignee_count: int,
    open_subtasks: Callable[[], int] = lambda: 0,
) -> None:
    """Raise ``TRANSITION_NOT_ALLOWED`` unless ``actor`` may move a task from ``source`` to
    ``target``. Staying put is never a move; without restriction every move is allowed."""
    if source.pk == target.pk:
        return
    if not ensure(project).restrict_transitions:
        return
    arrow = f"{source.name} → {target.name}"
    rule = Transition.objects.filter(from_status=source, to_status=target).first()
    if rule is None:
        raise _not_allowed(source, target, f"{arrow} is not allowed.")
    if rule.require_subtasks_done:
        open_now = open_subtasks()
        if open_now:
            raise _not_allowed(
                source,
                target,
                f"{arrow} needs all subtasks done first ({open_now} still open).",
            )
    if rule.require_assignee and assignee_count == 0:
        raise _not_allowed(source, target, f"{arrow} needs an assignee first.")
    if rule.required_role_id is not None:
        grant = access.grant_of(actor, workspace)
        if grant is None or grant.role.pk != rule.required_role_id:
            role = Role.objects.get(pk=rule.required_role_id)
            raise _not_allowed(source, target, f"{arrow} is only for the {role.name} role.")
