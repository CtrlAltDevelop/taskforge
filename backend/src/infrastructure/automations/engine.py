"""Running a rule: the checks, then the actions, one run record.

Order of a run: rate guard, loop guard (``MAX_DEPTH``), the owner's standing (still an active
member holding ``automation.manage``, project still open), the condition (TFQL, evaluated on the
task), then each action in turn through the ordinary task, comment and inbox services *as the
owner*, so a rule can never do what its owner could not. Actions are not one transaction: the
steps that ran stay done, the failed one is recorded and the rest are marked not run.

``evaluate(..., apply=False)`` is the dry run: the same checks and the exact would-be changes,
nothing written and nothing sent. ``_depth`` carries how many automations led here; the signal
receivers read it so what a rule causes is one hop deeper.
"""

import json
import logging
from contextvars import ContextVar
from dataclasses import dataclass, field
from datetime import timedelta
from typing import Any, Final

from django.db import IntegrityError, transaction
from django.utils import timezone

from infrastructure.automations import safe_http, spec
from infrastructure.automations.models import Automation, AutomationRun, RunStatus
from infrastructure.comments import services as comments
from infrastructure.common.errors import ApiError
from infrastructure.customfields import values as custom
from infrastructure.filters import compile as compiler
from infrastructure.filters import language
from infrastructure.filters.language import Catalogue, QueryError
from infrastructure.inbox import kinds, notify
from infrastructure.projects import services as projects
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Status
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

logger = logging.getLogger(__name__)
MANAGE: Final = "automation.manage"
MAX_DEPTH: Final = 5
RATE_PER_MINUTE: Final = 30
_depth: ContextVar[int] = ContextVar("automation_depth", default=0)


def current_depth() -> int:
    """How many automations in a row led to what is being done now (0 for a person's own action)."""
    return _depth.get()


@dataclass(slots=True)
class Result:
    status: str
    steps: list[dict[str, Any]] = field(default_factory=list)
    error: str = ""
    explanation: str = ""


@dataclass(frozen=True, slots=True)
class Ctx:
    automation: Automation
    owner: Any
    run_id: str
    today: str


def owner_problem(automation: Automation) -> str:
    """Why the rule may not run as its owner now, or ``""``."""
    owner = automation.owner
    if owner is None:
        return "The rule's owner no longer exists."
    active = WorkspaceMember.objects.filter(
        workspace_id=automation.workspace_id, user=owner, status=MemberStatus.ACTIVE
    ).exists()
    if not active:
        return "The rule's owner is no longer a member of this workspace."
    if not access.can(owner, MANAGE, automation.workspace).allowed:
        return f"The rule's owner no longer holds the {MANAGE} permission."
    try:
        projects.writable(projects.load(owner, automation.workspace, str(automation.project_id)))
    except ApiError:
        return "The rule's owner can no longer open this project, or it is archived."
    return ""


class ConditionBroken(Exception):  # noqa: N818 -- a reason, not an error to log
    pass


def failed_conditions(automation: Automation, task: Task) -> list[str]:
    """The parts of the condition the task does not meet (empty: it meets all of it)."""
    ast = automation.condition_ast
    if not ast or ast.get("where") is None:
        return []
    cat = Catalogue(automation.project)
    try:
        where = language.canonical(ast, cat)["where"]
        parts = where["args"] if where["op"] == "and" else [where]
        today = timezone.now().date()
        failed = []
        for part in parts:
            node = {"where": part, "order": []}
            q = compiler.where(node, cat, today, automation.owner)
            if not Task.objects.filter(pk=task.pk).filter(q).exists():
                failed.append(language.render(node, cat))
        return failed
    except QueryError as error:
        raise ConditionBroken(f"The condition no longer holds up: {error.message}") from None


def _fresh(task: Task) -> Task | None:
    return (
        Task.objects.filter(pk=task.pk, deleted_at__isnull=True)
        .select_related("project", "status")
        .first()
    )


def _assignee_change(action: dict[str, Any], task: Task) -> tuple[dict[str, Any], str, str]:
    have = sorted(str(u) for u in task.assignee_ids())
    if action["mode"] == "clear":
        new: list[str] = []
    elif action["mode"] == "add":
        new = sorted({*have, *action["user_ids"]})
    else:
        new = sorted(action["user_ids"])
    return {"assignee_ids": new}, ",".join(have), ",".join(new)


def _task_change(
    action: dict[str, Any], task: Task, ctx: Ctx
) -> tuple[dict[str, Any], dict[str, Any]]:
    """The ``tasks.update`` changes of a set_field / set_status / set_assignee action, and the
    ``{field, from, to}`` line that says what they do."""
    kind = action["type"]
    if kind == spec.SET_STATUS:
        name = Status.objects.filter(pk=action["status"]).values_list("name", flat=True).first()
        line = {"field": "status", "from": task.status.name, "to": name or action["status"]}
        return {"status": action["status"]}, line
    if kind == spec.SET_ASSIGNEE:
        changes, before, after = _assignee_change(action, task)
        return changes, {"field": "assignee_ids", "from": before, "to": after}
    name = action["field"]
    value = ctx.today if action["value"] == spec.TODAY else action["value"]
    line = {"field": name, "from": spec.task_value(task, name), "to": value}
    if name.startswith(spec.CUSTOM_PREFIX):
        return {"field_values": {name[len(spec.CUSTOM_PREFIX) :]: value}}, line
    return {name: value}, line


def _text(action_text: str, task: Task, ctx: Ctx) -> str:
    return spec.render_text(
        action_text,
        title=task.title,
        key=task.display_id,
        status=task.status.name,
        today=ctx.today,
        rule=ctx.automation.name,
    )


def _recipients(action: dict[str, Any], task: Task, ctx: Ctx) -> list[str]:
    found: list[str] = []
    for item in action["to"]:
        if item == "assignees":
            found += [str(u) for u in task.assignee_ids()]
        elif item == "owner":
            found.append(str(ctx.owner.pk))
        elif item == "creator":
            found += [str(task.created_by_id)] if task.created_by_id else []
        else:
            found.append(item)
    return list(dict.fromkeys(found))


def _comment_body(text: str, label: str) -> str:
    line = {"type": "text", "text": f"[{label}] {text}"}
    return json.dumps({"type": "doc", "content": [{"type": "paragraph", "content": [line]}]})


def _webhook_payload(task: Task, ctx: Ctx, event: dict[str, Any]) -> dict[str, Any]:
    return {
        "automation": ctx.automation.name,
        "event": event.get("type", ""),
        "task": {
            "id": str(task.pk),
            "key": task.display_id,
            "title": task.title,
            "status": task.status.name,
            "priority": task.priority,
        },
    }


def _describe(
    action: dict[str, Any], task: Task, ctx: Ctx, event: dict[str, Any], *, lookup: bool = True
) -> dict[str, Any]:
    """The would-be effect of an action, validated, without doing it. ``lookup`` resolves a
    webhook host; a real run skips it because the call resolves (and pins) the host itself."""
    kind = action["type"]
    step: dict[str, Any] = {"type": kind, "status": "planned", "changes": [], "detail": ""}
    if kind in (spec.SET_FIELD, spec.SET_STATUS, spec.SET_ASSIGNEE):
        changes, line = _task_change(action, task, ctx)
        scalar = {k: v for k, v in changes.items() if k != "field_values"}
        if scalar:
            tasks.check_changes(task.project, scalar)
        custom.prepare(task.project, changes.get("field_values", {}))
        step["changes"] = [line]
    elif kind == spec.ADD_COMMENT:
        step["detail"] = _text(action["text"], task, ctx)
    elif kind == spec.CREATE_SUBTASK:
        step["detail"] = _text(action["title"], task, ctx)
    elif kind == spec.NOTIFY:
        step["detail"] = _text(action["message"], task, ctx)
        step["changes"] = [
            {"field": "notify", "from": "", "to": ",".join(_recipients(action, task, ctx))}
        ]
    else:
        if lookup:
            safe_http.resolve(action["url"])
        scheme, host, path = safe_http.describe(action["url"])
        step["detail"] = f"{action['method']} {scheme}://{host}{path}"
    return step


def _apply(action: dict[str, Any], task: Task, ctx: Ctx, event: dict[str, Any], index: int) -> str:
    """Do one action; returns a short note for the step."""
    kind, owner, project = action["type"], ctx.owner, task.project
    ws = ctx.automation.workspace
    if kind in (spec.SET_FIELD, spec.SET_STATUS, spec.SET_ASSIGNEE):
        changes, _ = _task_change(action, task, ctx)
        tasks.update(owner, ws, str(project.pk), str(task.pk), task.version, changes)
        return ""
    if kind == spec.ADD_COMMENT:
        body = _comment_body(_text(action["text"], task, ctx), ctx.automation.actor_label)
        comments.create(owner, ws, str(project.pk), str(task.pk), body)
        return ""
    if kind == spec.CREATE_SUBTASK:
        made = tasks.create(
            owner, ws, str(project.pk), _text(action["title"], task, ctx), parent_id=str(task.pk)
        )
        return f"Created {made.display_id}."
    if kind == spec.NOTIFY:
        made_rows = notify.notify(
            kind=kinds.AUTOMATION,
            recipients=_recipients(action, task, ctx),
            workspace=ws,
            project=project,
            task=task,
            actor_id=None,
            payload={
                "title": task.title,
                "key": task.display_id,
                "automation": ctx.automation.name,
                "message": _text(action["message"], task, ctx),
            },
            dedupe=f"automation:{ctx.run_id}:{index}",
            fold=False,
        )
        return f"Notified {len(made_rows)}."
    try:
        answer = safe_http.call(action["url"], action["method"], _webhook_payload(task, ctx, event))
    except safe_http.UnsafeUrl as error:
        raise ApiError(str(error)) from None
    except OSError:
        raise ApiError("The webhook could not be reached (or timed out).") from None
    if answer.status >= 300:
        raise ApiError(f"The webhook answered {answer.status}.")
    return f"Answered {answer.status}."


def _run_actions(
    automation: Automation, task: Task, ctx: Ctx, event: dict[str, Any], *, apply: bool
) -> Result:
    steps: list[dict[str, Any]] = []
    current: Task | None = task
    for index, action in enumerate(automation.actions):
        step: dict[str, Any] = {
            "type": action["type"],
            "status": "not_run",
            "changes": [],
            "detail": "",
        }
        if current is None:
            step["error"] = "The task was deleted."
            steps.append(step)
            return Result(RunStatus.FAILED, steps, "The task was deleted before the rule finished.")
        try:
            step = _describe(action, current, ctx, event, lookup=not apply)
            if apply:
                step["detail"] = _apply(action, current, ctx, event, index) or step["detail"]
                step["status"] = "ok"
        except (ApiError, safe_http.UnsafeUrl) as error:
            step.update(status="failed" if apply else "would_fail", error=str(error))
            steps.append(step)
            steps += [
                {"type": a["type"], "status": "not_run", "changes": [], "detail": ""}
                for a in automation.actions[index + 1 :]
            ]
            return Result(RunStatus.FAILED, steps, f"Step {index + 1} ({action['type']}): {error}")
        steps.append(step)
        if apply:
            current = _fresh(current)
    return Result(RunStatus.SUCCEEDED, steps)


def evaluate(
    automation: Automation, task: Task, event: dict[str, Any], *, apply: bool, run_id: str = ""
) -> Result:
    """Everything after the loop and rate guards: owner, condition, actions."""
    problem = owner_problem(automation)
    if problem:
        return Result(RunStatus.FAILED, [], problem, problem)
    try:
        failed = failed_conditions(automation, task)
    except ConditionBroken as error:
        return Result(RunStatus.FAILED, [], str(error), str(error))
    if failed:
        why = "The task does not meet: " + "; ".join(failed) + "."
        return Result(RunStatus.SKIPPED_CONDITION, [], "", why)
    ctx = Ctx(automation, automation.owner, run_id, timezone.now().date().isoformat())
    token = _depth.set(int(event.get("depth", 0)) + 1)
    try:
        return _run_actions(automation, task, ctx, event, apply=apply)
    finally:
        _depth.reset(token)


def _snapshot(task: Task, event: dict[str, Any]) -> dict[str, Any]:
    return {
        "event": event,
        "task": {
            "id": str(task.pk),
            "key": task.display_id,
            "title": task.title,
            "status": task.status.name,
            "version": task.version,
        },
    }


def _begin(automation: Automation, task: Task, event: dict[str, Any]) -> AutomationRun | None:
    """The run row, or ``None`` when this event already ran this rule on this task."""
    try:
        with transaction.atomic():
            return AutomationRun.objects.create(
                automation=automation,
                workspace_id=automation.workspace_id,
                task=task,
                event_key=str(event["id"])[:200],
                depth=int(event.get("depth", 0)),
                status=RunStatus.FAILED,
                error="The run did not finish.",
                input=_snapshot(task, event),
            )
    except IntegrityError:
        return None


def _finish(run: AutomationRun, result: Result) -> AutomationRun:
    run.status, run.steps = result.status, result.steps
    run.error, run.explanation = result.error[:1000], result.explanation[:1000]
    run.finished_at = timezone.now()
    run.save(update_fields=["status", "steps", "error", "explanation", "finished_at"])
    return run


def _too_fast(automation: Automation) -> bool:
    since = timezone.now() - timedelta(minutes=1)
    return (
        AutomationRun.objects.filter(automation=automation, started_at__gte=since).count()
        >= RATE_PER_MINUTE
    )


def execute(automation_id: Any, event: dict[str, Any]) -> AutomationRun | None:
    """Run one rule for one event (``{type, id, task_id, depth, data}``). Scoped to the rule's own
    project: a task of any other project is never touched."""
    automation = (
        Automation.objects.select_related("project", "workspace", "owner")
        .filter(pk=automation_id, enabled=True)
        .first()
    )
    if automation is None:
        return None
    task = (
        Task.objects.filter(
            pk=event["task_id"],
            project_id=automation.project_id,
            workspace_id=automation.workspace_id,
            deleted_at__isnull=True,
        )
        .select_related("project", "status")
        .first()
    )
    if task is None:
        return None
    run = _begin(automation, task, event)
    if run is None:
        return None
    if int(event.get("depth", 0)) >= MAX_DEPTH:
        why = f"Stopped: {MAX_DEPTH} automations in a row led here (a possible loop)."
        return _finish(run, Result(RunStatus.SKIPPED_LOOP, explanation=why))
    if _too_fast(automation):
        why = f"Stopped: this rule already ran {RATE_PER_MINUTE} times in the last minute."
        return _finish(run, Result(RunStatus.SKIPPED_RATE, explanation=why))
    try:
        result = evaluate(automation, task, event, apply=True, run_id=str(run.pk))
    except Exception:  # noqa: BLE001 -- the run record must say it failed
        logger.exception("automation %s crashed", automation.pk)
        result = Result(RunStatus.FAILED, [], "An unexpected error stopped the run.")
    return _finish(run, result)
