"""Automations: save, switch, test and read rules. Rules live in ``engine``.

Seeing rules and runs needs ``workspace.view`` and a project the caller can open; every change,
the dry run included, needs ``automation.manage``. A rule runs with its *owner's* permissions, so
whoever edits a rule or switches it back on becomes its owner (nobody can use a rule to do more
than they could do themselves). Every query is scoped to the workspace and the project.
"""

import json
import uuid
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Final

from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.automations import engine, integrity, signals, spec
from infrastructure.automations.models import Automation, AutomationRun, RunStatus
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.filters import language
from infrastructure.filters import services as filter_services
from infrastructure.filters.language import Catalogue
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "workspace.view"
MANAGE: Final = engine.MANAGE
MAX_PER_PROJECT: Final = 50
RUNS_DEFAULT: Final = 50
RUNS_MAX: Final = 200
EDITABLE: Final = ("name", "trigger", "condition", "actions")


def not_found() -> ApiError:
    return ApiError("No such automation.", status=404)


def _project(
    actor: Any, workspace: Workspace, project_id: str, key: str, *, lock: bool = False
) -> Project:
    access.require(actor, VIEW, workspace)
    if key != VIEW:
        access.require(actor, key, workspace)
    project = projects.load(actor, workspace, project_id, lock=lock)
    if key != VIEW:
        projects.writable(project)
    return project


def _load(project: Project, automation_id: str, *, lock: bool = False) -> Automation:
    try:
        pk = uuid.UUID(str(automation_id))
    except ValueError:
        raise not_found() from None
    rows = Automation.objects.filter(pk=pk, project=project, workspace_id=project.workspace_id)
    row = (
        (rows.select_for_update(of=("self",)) if lock else rows)
        .select_related("project", "workspace", "owner")
        .first()
    )
    if row is None:
        raise not_found()
    return row


@dataclass(frozen=True, slots=True)
class View:
    automation: Automation
    condition_tfql: str
    last_run_at: datetime | None
    last_run_status: str


def condition_text(automation: Automation) -> str:
    ast = automation.condition_ast
    if not ast or ast.get("where") is None:
        return ""
    try:
        return language.render(ast, Catalogue(automation.project))
    except language.QueryError:
        return ""


def _view(automation: Automation, last: AutomationRun | None = None) -> View:
    return View(
        automation,
        condition_text(automation),
        last.started_at if last else None,
        last.status if last else "",
    )


def list_automations(actor: Any, workspace: Workspace, project_id: str) -> list[View]:
    project = _project(actor, workspace, project_id, VIEW)
    rows = list(
        Automation.objects.filter(project=project, workspace=workspace)
        .select_related("project", "workspace", "owner")
        .order_by("created_at")
    )
    latest = {r.pk: r.runs.order_by("-started_at").first() for r in rows}  # at most 50 rules
    return [_view(r, latest.get(r.pk)) for r in rows]


def get_view(actor: Any, workspace: Workspace, project_id: str, automation_id: str) -> View:
    project = _project(actor, workspace, project_id, VIEW)
    automation = _load(project, automation_id)
    last = automation.runs.order_by("-started_at").first()
    return _view(automation, last)


def _condition(project: Project, text: str, ast_json: str) -> dict[str, Any]:
    if not text.strip() and not ast_json:
        return {}
    try:
        ast = json.loads(ast_json) if ast_json else None
    except (ValueError, RecursionError):
        raise spec.bad("The condition is not JSON.") from None
    checked = filter_services.check(Catalogue(project), text, ast)
    if checked.errors:
        raise spec.bad(f"The condition: {checked.errors[0].message}")
    found = checked.ast or {}
    return {"where": found["where"], "order": []} if found.get("where") is not None else {}


def _size_check(trigger: Any, condition: Any, actions: Any) -> None:
    if len(json.dumps([trigger, condition, actions])) > spec.MAX_JSON_BYTES:
        raise spec.bad("This rule is too large.")


def create(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    name: str,
    trigger: Any,
    actions: Any,
    *,
    condition_tfql: str = "",
    condition_json: str = "",
    enabled: bool = True,
) -> View:
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        if Automation.objects.filter(project=project).count() >= MAX_PER_PROJECT:
            raise spec.bad(f"A project has at most {MAX_PER_PROJECT} automations.")
        clean_trigger = spec.clean_trigger(project, trigger)
        clean_condition = _condition(project, condition_tfql, condition_json)
        clean_actions = spec.clean_actions(project, actions)
        _size_check(clean_trigger, clean_condition, clean_actions)
        automation = Automation.objects.create(
            workspace=workspace,
            project=project,
            name=spec.clean_name(name),
            enabled=enabled,
            trigger=clean_trigger,
            condition_ast=clean_condition,
            actions=clean_actions,
            owner=actor,
        )
        signals.announce(automation, "created")
    return _view(_load(project, str(automation.pk)))


def _conflict(automation: Automation) -> ApiError:
    return ApiError(
        "Someone else changed this rule first; reload and retry.",
        status=409,
        title=ResponseTitle.VERSION_CONFLICT,
        data={"version": automation.version},
    )


def update(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    automation_id: str,
    changes: dict[str, Any],
    expected_version: int,
) -> View:
    """``changes`` holds any of name, trigger, condition (TFQL text), actions. The rule is then
    the actor's: it runs with their permissions from now on."""
    if not changes:
        raise spec.bad("Send at least one field to change.")
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        automation = _load(project, automation_id, lock=True)
        if automation.version != expected_version:
            raise _conflict(automation)
        if "name" in changes:
            automation.name = spec.clean_name(str(changes["name"]))
        if "trigger" in changes:
            automation.trigger = spec.clean_trigger(project, changes["trigger"])
        if "condition" in changes:
            automation.condition_ast = _condition(project, str(changes["condition"]), "")
        if "actions" in changes:
            automation.actions = spec.clean_actions(project, changes["actions"])
        _size_check(automation.trigger, automation.condition_ast, automation.actions)
        automation.owner = actor
        _bump(automation)
    return _view(_load(project, automation_id))


def _bump(automation: Automation) -> None:
    automation.version += 1
    automation.updated_at = timezone.now()
    automation.save()
    signals.announce(automation, "updated")


def toggle(
    actor: Any, workspace: Workspace, project_id: str, automation_id: str, enabled: bool
) -> View:
    """Switch on (refused while the rule still names something that is gone; the actor becomes
    its owner) or off."""
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        automation = _load(project, automation_id, lock=True)
        if enabled:
            problems = integrity.problems_of(automation)
            if problems:
                raise spec.bad("Fix the rule first: " + " ".join(problems))
            automation.owner = actor
            automation.disabled_reason = ""
        automation.enabled = enabled
        _bump(automation)
    return _view(_load(project, automation_id))


def delete(actor: Any, workspace: Workspace, project_id: str, automation_id: str) -> None:
    with transaction.atomic():
        project = _project(actor, workspace, project_id, MANAGE, lock=True)
        automation = _load(project, automation_id, lock=True)
        signals.announce(automation, "deleted")
        automation.delete()


@dataclass(frozen=True, slots=True)
class DryRun:
    """What the rule would do to the task now: ``would_run``, the ``status`` it would end with,
    the plain ``explanation`` when it would not do anything and the exact ``steps``."""

    would_run: bool
    status: str
    explanation: str
    error: str
    steps: list[dict[str, Any]]


def dry_run(
    actor: Any, workspace: Workspace, project_id: str, automation_id: str, task_id: str
) -> DryRun:
    project = _project(actor, workspace, project_id, MANAGE)
    automation = _load(project, automation_id)
    task = tasks.load_task(project, task_id)
    event = {"type": automation.trigger["type"], "id": "dry-run", "depth": 0, "data": {}}
    result = engine.evaluate(automation, task, event, apply=False)
    explanation = result.explanation
    if not automation.enabled:
        explanation = ("The rule is switched off. " + explanation).strip()
    return DryRun(
        automation.enabled and result.status == RunStatus.SUCCEEDED,
        result.status,
        explanation,
        result.error,
        result.steps,
    )


# --------------------------------------------------------------------------------- run history


def _cursor(raw: str) -> tuple[datetime, uuid.UUID | None] | None:
    """``before``: a time, or ``<time>#<run id>`` (the last run of the page) so that runs sharing
    a start time are neither skipped nor repeated."""
    if not raw:
        return None
    moment, _, run_id = raw.partition("#")
    try:
        return datetime.fromisoformat(moment), (uuid.UUID(run_id) if run_id else None)
    except ValueError:
        raise spec.bad("before is a time like 2026-11-05T10:00:00+00:00 (then #run id).") from None


def list_runs(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    automation_id: str = "",
    *,
    task_id: str = "",
    status: str = "",
    before: str = "",
    limit: int = 0,
) -> list[AutomationRun]:
    """Newest first; ``before`` (a run's ``started_at``) pages on."""
    project = _project(actor, workspace, project_id, VIEW)
    rows = AutomationRun.objects.filter(automation__project=project, workspace=workspace)
    if automation_id:
        rows = rows.filter(automation=_load(project, automation_id))
    if task_id:
        rows = rows.filter(task_id__in=tasks.valid_uuids([task_id]))
    if status:
        if status not in RunStatus.values:
            raise spec.bad(f"Unknown run status: {status}.")
        rows = rows.filter(status=status)
    cursor = _cursor(before)
    if cursor is not None:
        moment, run_pk = cursor
        older = Q(started_at__lt=moment)
        if run_pk is not None:
            older |= Q(started_at=moment, pk__lt=run_pk)
        rows = rows.filter(older)
    size = min(limit or RUNS_DEFAULT, RUNS_MAX)
    return list(
        rows.select_related("automation", "task__project").order_by("-started_at", "-pk")[:size]
    )


def get_run(actor: Any, workspace: Workspace, project_id: str, run_id: str) -> AutomationRun:
    project = _project(actor, workspace, project_id, VIEW)
    try:
        pk = uuid.UUID(str(run_id))
    except ValueError:
        raise not_found() from None
    row = (
        AutomationRun.objects.filter(pk=pk, automation__project=project, workspace=workspace)
        .select_related("automation", "task__project")
        .first()
    )
    if row is None:
        raise ApiError("No such run.", status=404)
    return row
