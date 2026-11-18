"""The first-run checklist, the starters and the sample tasks.

A checklist belongs to one person in one workspace (a new workspace starts a new one). It ticks
itself from what the server sees (a task created, an invitation sent: see ``receivers``) and from
``complete_step`` for what only the client sees (the board opened, the palette used). Once every
step is ticked, or the person dismisses it, it never shows again.
"""

import re
import string
from collections.abc import Iterator
from contextlib import contextmanager
from contextvars import ContextVar
from dataclasses import dataclass
from typing import Any, Final

from django.db import transaction
from django.db.models import F, Q
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.home.models import UserOnboarding
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.templates import apply as template_apply
from infrastructure.templates import builtin, content
from infrastructure.workflows import services as workflows
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

STEPS: Final = ("create_task", "invite_member", "try_board", "open_palette")
BLANK: Final = "blank"
DEFAULT_NAME: Final = "My project"
SAMPLE_VARIABLES: Final = {"sprint_name": "Sprint 1", "campaign_name": "Spring launch"}
KEY_MAX: Final = 6
NAME_MAX: Final = 80

# Set while a starter builds its sample tasks: they are not "a task the person created".
_building_samples: ContextVar[bool] = ContextVar("home_building_samples", default=False)


@dataclass(frozen=True, slots=True)
class Starter:
    key: str
    name: str
    description: str


@dataclass(frozen=True, slots=True)
class State:
    steps: list[tuple[str, bool]]
    dismissed: bool
    complete: bool
    visible: bool
    sample_project_id: str
    sample_count: int


@dataclass(frozen=True, slots=True)
class Applied:
    project_id: str
    task_count: int


def starters() -> list[Starter]:
    """The starters in picker order: the built-in project templates, then an empty project."""
    found = [Starter(b.key, b.name, b.description) for b in builtin.BUILTINS]
    return [*found, Starter(BLANK, "Blank", "An empty project: add your own tasks.")]


def _row(actor: Any, workspace: Workspace) -> UserOnboarding:
    access.require(actor, "workspace.view", workspace)
    row, _ = UserOnboarding.objects.get_or_create(user=actor, workspace=workspace)
    return row


def _state(row: UserOnboarding) -> State:
    done = {step: step in row.checklist for step in STEPS}
    complete = all(done.values())
    samples = 0
    if row.sample_project_id:
        samples = Task.objects.filter(
            project_id=row.sample_project_id, is_sample=True, deleted_at__isnull=True
        ).count()
    return State(
        steps=list(done.items()),
        dismissed=row.dismissed_at is not None,
        complete=complete,
        visible=not complete and row.dismissed_at is None,
        sample_project_id=str(row.sample_project_id or ""),
        sample_count=samples,
    )


def get(actor: Any, workspace: Workspace) -> State:
    return _state(_row(actor, workspace))


def _tick(row: UserOnboarding, step: str) -> None:
    if step not in row.checklist:
        row.checklist = {**row.checklist, step: timezone.now().isoformat()}
        row.save(update_fields=["checklist"])


def complete_step(actor: Any, workspace: Workspace, step: str) -> State:
    """Tick a step (safe to repeat)."""
    if step not in STEPS:
        raise ApiError(f"The step is one of {', '.join(STEPS)}.")
    _row(actor, workspace)
    with transaction.atomic():
        row = UserOnboarding.objects.select_for_update().get(user=actor, workspace=workspace)
        _tick(row, step)
    return _state(row)


def tick_for(user_id: Any, workspace_id: Any, step: str) -> None:
    """Tick ``step`` for someone because of something they did (called from the receivers)."""
    settled = UserOnboarding.objects.filter(user_id=user_id, workspace_id=workspace_id)
    if settled.filter(Q(dismissed_at__isnull=False) | Q(checklist__has_key=step)).exists():
        return  # the usual case once set up: no lock, no write
    with transaction.atomic():
        row, _ = UserOnboarding.objects.select_for_update().get_or_create(
            user_id=user_id, workspace_id=workspace_id
        )
        _tick(row, step)


def dismiss(actor: Any, workspace: Workspace) -> State:
    row = _row(actor, workspace)
    if row.dismissed_at is None:
        row.dismissed_at = timezone.now()
        row.save(update_fields=["dismissed_at"])
    return _state(row)


def is_building_samples() -> bool:
    return _building_samples.get()


@contextmanager
def _samples_being_built() -> Iterator[None]:
    token = _building_samples.set(True)
    try:
        yield
    finally:
        _building_samples.reset(token)


def _key_from(workspace: Workspace, name: str) -> str:
    letters = "".join(c for c in name.upper() if c in string.ascii_uppercase) or "PRJ"
    base = letters[:KEY_MAX].ljust(2, "X")
    taken = {
        k.upper() for k in Project.objects.filter(workspace=workspace).values_list("key", flat=True)
    }
    for candidate in (base, *(base[: KEY_MAX - 1] + c for c in string.ascii_uppercase)):
        if candidate not in taken:
            return candidate
    raise ApiError("Pick a project key: none could be made from the name.")


def _sample_variables(template_id: str) -> dict[str, str]:
    """Values for the ``{{variables}}`` a built-in starter asks for, so the picker needs none."""
    names = content.variables(builtin.BY_ID[template_id].content)
    return {n: SAMPLE_VARIABLES.get(n, n.replace("_", " ").title()) for n in names}


def apply_starter(
    actor: Any, workspace: Workspace, starter: str, name: str = "", key: str = ""
) -> Applied:
    """Create a project from a starter and mark its tasks as samples, in one transaction.
    ``Blank`` is an empty project. Needs ``project.create``."""
    access.require(actor, "project.create", workspace)
    chosen = next((s for s in starters() if s.key == starter), None)
    if chosen is None:
        raise ApiError("That starter does not exist.")
    title = re.sub(r"\s+", " ", name).strip()[:NAME_MAX] or (
        DEFAULT_NAME if chosen.key == BLANK else chosen.name
    )
    project_key = key.strip() or _key_from(workspace, title)
    with transaction.atomic(), _samples_being_built():
        if chosen.key == BLANK:
            project = projects.create(actor, workspace, title, project_key).project
            workflows.ensure(project)
            task_ids: list[str] = []
        else:
            template_id = builtin.PREFIX + chosen.key
            made = template_apply.apply(
                actor,
                workspace,
                template_id,
                project=template_apply.ProjectParams(name=title, key=project_key),
                variables=_sample_variables(template_id),
            )
            project = Project.objects.get(pk=made.project_id)
            task_ids = made.task_ids
        Task.objects.filter(pk__in=task_ids, workspace=workspace).update(is_sample=True)
        row = _row(actor, workspace)
        if task_ids:
            row.sample_project = project
            row.save(update_fields=["sample_project"])
        recorder.record(
            workspace_id=workspace.pk,
            action="onboarding.starter_applied",
            target_type="project",
            target_id=project.pk,
            project_id=project.pk,
            changes={"starter": chosen.key, "samples": len(task_ids)},
            actor=actor,
        )
    return Applied(str(project.pk), len(task_ids))


def _drop_sample(actor: Any, workspace: Workspace, task: Task) -> None:
    """Delete one sample the normal way; if the project no longer allows it (archived, or the
    person lost the right), trash it directly: it is their own example and "delete the samples"
    must always work. ponytail: the direct path sends no live event and does not promote a real
    subtask; both are rare enough to leave."""
    try:
        with transaction.atomic():
            task_services.delete(
                actor, workspace, str(task.project_id), str(task.pk), mode="promote"
            )
    except ApiError:
        now = timezone.now()
        Task.objects.filter(pk=task.pk, deleted_at__isnull=True).update(
            deleted_at=now, updated_at=now, version=F("version") + 1
        )


def delete_samples(actor: Any, workspace: Workspace) -> int:
    """Delete every sample task the person's starters made (in any project), leaving the projects
    (and any task they made themselves, even under a sample: it moves up). Returns how many went.
    The tasks go to the trash like any deleted task."""
    access.require(actor, "workspace.view", workspace)
    samples = list(
        Task.objects.filter(
            workspace=workspace, created_by=actor, is_sample=True, deleted_at__isnull=True
        ).order_by("-depth", "number")
    )
    with transaction.atomic():
        for task in samples:
            _drop_sample(actor, workspace, task)
        if samples:
            recorder.record(
                workspace_id=workspace.pk,
                action="onboarding.samples_deleted",
                target_type="workspace",
                target_id=workspace.pk,
                changes={"samples": len(samples)},
                actor=actor,
            )
    return len(samples)
