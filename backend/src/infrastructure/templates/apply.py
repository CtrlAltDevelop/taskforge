"""Apply a template: one transaction, built from the ordinary services so every event, audit entry
and permission check is the normal one and the history reads as if a person had done it by hand.

Whatever the snapshot names that no longer exists (a field, a status, a feature, a member) is
skipped and reported as a warning; anything the services refuse outright rolls the whole apply
back, so a failure midway leaves nothing behind.
"""

import json
import re
from collections.abc import Callable, Mapping
from dataclasses import dataclass, field
from datetime import date, timedelta
from typing import Any, Final

from django.db import transaction
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.automations import services as automations
from infrastructure.common.errors import ApiError
from infrastructure.customfields import services as custom_services
from infrastructure.customfields import values
from infrastructure.customfields.models import FieldDefinition, FieldType
from infrastructure.projects import services as projects
from infrastructure.projects.features import FEATURE_KEYS
from infrastructure.projects.models import Project
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Priority
from infrastructure.templates import content, services
from infrastructure.templates.models import TemplateKind
from infrastructure.workflows import services as workflows
from infrastructure.workflows.drafts import StatusDraft, TransitionDraft, WorkflowDraft
from infrastructure.workflows.models import Status, Workflow
from infrastructure.workspaces.models import Workspace

UUID_TEXT: Final = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")


@dataclass(frozen=True, slots=True)
class Warn:
    code: str
    message: str


@dataclass(frozen=True, slots=True)
class ProjectParams:
    name: str = ""
    key: str = ""
    description: str = ""
    icon: str = ""
    color: str = ""
    visibility: str = "open"


@dataclass(slots=True)
class Result:
    project_id: str = ""
    task_ids: list[str] = field(default_factory=list)
    warnings: list[Warn] = field(default_factory=list)


@dataclass(slots=True)
class _Run:
    actor: Any
    workspace: Workspace
    project: Project
    result: Result
    statuses: dict[str, str] = field(default_factory=dict)  # lower name -> status id
    fields: dict[str, FieldDefinition] = field(default_factory=dict)  # lower name -> field
    dropped_people: int = 0
    seen: set[str] = field(default_factory=set)

    def warn(self, code: str, message: str, *, once: str = "") -> None:
        if once:
            if once in self.seen:
                return
            self.seen.add(once)
        self.result.warnings.append(Warn(code, message))


def _guarded(run: _Run, code: str, label: str, step: Callable[[], Any]) -> Any:
    """Run ``step`` in a savepoint; a refusal skips just that piece, with a warning."""
    try:
        with transaction.atomic():
            return step()
    except ApiError as error:
        run.warn(code, f"{label} was skipped: {error}")
        return None


def _parse_start(raw: str) -> date:
    if not raw:
        return timezone.localdate()
    try:
        return date.fromisoformat(raw)
    except ValueError:
        raise ApiError("The start date must be YYYY-MM-DD.") from None


def _shift(start: date, offset: Any) -> str:
    return "" if offset is None else (start + timedelta(days=int(offset))).isoformat()


# ------------------------------------------------------------------------------- project parts


def _features(run: _Run, wanted: list[str]) -> None:
    known = [k for k in wanted if k in FEATURE_KEYS]
    for gone in sorted(set(wanted) - set(known)):
        run.warn("FEATURE_GONE", f"The feature {gone} no longer exists and was skipped.")
    current = Project.objects.get(pk=run.project.pk)
    projects.set_features(run.actor, run.workspace, str(current.pk), known, current.version)


def _workflow(run: _Run, spec: Mapping[str, Any]) -> dict[str, str]:
    """Replace the default workflow; returns saved status key -> new status id."""
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(s["key"], s["name"], s["color"], s["category"], s["is_default"])
            for s in spec["statuses"]
        ),
        transitions=tuple(
            TransitionDraft(
                t["from"],
                t["to"],
                require_assignee=t["require_assignee"],
                require_subtasks_done=t["require_subtasks_done"],
            )
            for t in spec["transitions"]
        ),
        restrict=spec["restrict"],
        restrict_creation=spec["restrict_creation"],
    )
    pid = str(run.project.pk)
    workflows.ensure(run.project)
    version = Workflow.objects.get(project=run.project).version
    done = _guarded(
        run,
        "WORKFLOW_INVALID",
        "The workflow",
        lambda: workflows.update(run.actor, run.workspace, pid, version, draft, {}),
    )
    if done is None:
        return {}
    by_name = {s.name.lower(): str(s.pk) for s in done.statuses}
    return {
        s["key"]: by_name[s["name"].lower()]
        for s in spec["statuses"]
        if s["name"].lower() in by_name
    }


def _field(run: _Run, spec: Mapping[str, Any]) -> str | None:
    pid = str(run.project.pk)

    def make(default: str) -> Any:
        return custom_services.create(
            run.actor,
            run.workspace,
            pid,
            name=spec["name"],
            type=spec["type"],
            options=spec["options"],
            required=spec["required"],
            default=default,
            hidden_views=spec["hidden_views"],
        )

    made = _guarded(run, "FIELD_GONE", f"The field {spec['name']}", lambda: make(spec["default"]))
    if made is None and spec["default"]:
        made = _guarded(run, "FIELD_GONE", f"The field {spec['name']}", lambda: make(""))
    return None if made is None else str(made.pk)


def _fields(run: _Run, specs: list[Mapping[str, Any]]) -> dict[str, str]:
    ids: dict[str, str] = {}
    for spec in specs:
        new_id = _field(run, spec)
        if new_id is not None:
            ids[spec["key"]] = new_id
    return ids


def _automations(run: _Run, specs: list[Mapping[str, Any]], ids: Mapping[str, str]) -> None:
    mapping = {old: new for old, new in ids.items() if UUID_TEXT.fullmatch(old)}
    pid = str(run.project.pk)
    for spec in specs:
        item = content.remap_ids(spec, mapping)

        def make(item: Mapping[str, Any] = item) -> Any:
            return automations.create(
                run.actor,
                run.workspace,
                pid,
                item["name"],
                item["trigger"],
                item["actions"],
                condition_json=json.dumps(item["condition"]) if item["condition"] else "",
                enabled=item["enabled"],
            )

        _guarded(run, "AUTOMATION_INVALID", f"The automation {spec['name']}", make)


# ---------------------------------------------------------------------------------- tasks


def _field_value(run: _Run, item: Mapping[str, str]) -> tuple[str, str] | None:
    definition = run.fields.get(item["name"].lower())
    if definition is None or definition.type != item["type"]:
        run.warn(
            "FIELD_GONE",
            f"The field {item['name']} is not in this project; its values were skipped.",
            once="field:" + item["name"].lower(),
        )
        return None
    value = item["value"]
    if definition.type in (FieldType.SELECT, FieldType.MULTISELECT):
        ids = {o["label"].lower(): o["id"] for o in definition.options}
        wanted = (
            [v.strip() for v in value.split(",")] if definition.type == "multiselect" else [value]
        )
        found = [ids[w.lower()] for w in wanted if w.lower() in ids]
        if len(found) != len([w for w in wanted if w]):
            run.warn(
                "OPTION_GONE",
                f"Some options of {definition.name} no longer exist and were skipped.",
                once="option:" + definition.name.lower(),
            )
        value = ",".join(found)
    elif definition.type == FieldType.USER:
        try:
            value = values.user_check(run.project)(value)
        except ApiError:
            run.dropped_people += 1
            return None
    return str(definition.pk), value


def _assignees(run: _Run, raw: list[str]) -> list[str]:
    check = values.user_check(run.project)
    kept: list[str] = []
    for item in raw:
        try:
            kept.append(check(item))
        except ApiError:
            run.dropped_people += 1
    return kept


def _create_task(run: _Run, item: Mapping[str, Any], start: date, parent_id: str) -> str:
    status = run.statuses.get(item["status"].lower(), "") if item["status"] else ""
    if item["status"] and not status:
        run.warn(
            "STATUS_GONE",
            f"The status {item['status']} is not in this project; tasks start in the default.",
            once="status:" + item["status"].lower(),
        )
    due = _shift(start, item["due_offset"])
    chosen = [_field_value(run, f) for f in item["fields"]]
    task = task_services.create(
        run.actor,
        run.workspace,
        str(run.project.pk),
        item["title"],
        description=json.dumps(item["description"]) if item["description"] else "",
        status=status,
        priority=item["priority"] if item["priority"] in Priority.values else "none",
        start_date=_shift(start, item["start_offset"]),
        due_date=due,
        due_time=item["due_time"] if due else "",
        assignee_ids=_assignees(run, item["assignee_ids"]),
        parent_id=parent_id,
        field_values=dict(c for c in chosen if c is not None),
    )
    return str(task.pk)


def _tasks(run: _Run, items: list[Mapping[str, Any]], start: date, root_parent: str) -> None:
    created: dict[str, str] = {}
    for item in items:
        parent = created.get(item["parent"], root_parent) if item["parent"] else root_parent
        created[item["ref"]] = _create_task(run, item, start, parent)
        run.result.task_ids.append(created[item["ref"]])


def _load_target(run: _Run) -> None:
    workflows.ensure(run.project)
    run.statuses = {s.name.lower(): str(s.pk) for s in Status.objects.filter(project=run.project)}
    run.fields = {f.name.lower(): f for f in values.active_fields(run.project)}


def _target_project(
    actor: Any, workspace: Workspace, kind: str, project_id: str, params: ProjectParams
) -> Project:
    if kind == TemplateKind.TASK:
        if not project_id:
            raise ApiError("Choose the project the tasks go into.")
        return projects.load(actor, workspace, project_id)
    return projects.create(
        actor,
        workspace,
        params.name,
        params.key,
        description=params.description,
        icon=params.icon,
        color=params.color,
        visibility=params.visibility or "open",
    ).project


def _check_variables(body: Any, given: Mapping[str, str]) -> dict[str, str]:
    needed = content.variables(body)
    missing = [name for name in needed if not given.get(name, "").strip()]
    if missing:
        raise ApiError(f"Fill in: {', '.join(missing)}.", data={"variables": ",".join(missing)})
    return {name: given[name].strip() for name in needed}


def apply(
    actor: Any,
    workspace: Workspace,
    template_id: str,
    *,
    project_id: str = "",
    parent_task_id: str = "",
    project: ProjectParams = ProjectParams(),  # noqa: B008 - frozen, shared on purpose
    start_date: str = "",
    variables: Mapping[str, str] | None = None,
) -> Result:
    """Create what the template describes. A task template needs ``project_id`` (and may name a
    parent task); a project template creates a new project from ``project``."""
    kind, name, stored = services.load_content(actor, workspace, template_id)
    body = content.clean(kind, stored)
    if len(body["tasks"]) > content.MAX_TASKS:
        raise ApiError(f"A template can hold at most {content.MAX_TASKS} tasks.")
    given = _check_variables(body, variables or {})
    body = content.substitute(body, given)
    params = ProjectParams(**{k: content.substitute(v, given) for k, v in vars_of(project).items()})
    start = _parse_start(start_date)
    with transaction.atomic():
        target = _target_project(actor, workspace, kind, project_id, params)
        run = _Run(actor, workspace, target, Result(project_id=str(target.pk)))
        ids: dict[str, str] = {}
        if kind == TemplateKind.PROJECT:
            if "features" in body:
                _features(run, body["features"])
            if "workflow" in body:
                ids |= _workflow(run, body["workflow"])
            if "fields" in body:
                ids |= _fields(run, body["fields"])
        _load_target(run)
        _tasks(run, body["tasks"], start, parent_task_id)
        if kind == TemplateKind.PROJECT and body.get("automations"):
            _automations(run, body["automations"], ids)
        if run.dropped_people:
            run.warn(
                "PEOPLE_DROPPED",
                f"{run.dropped_people} person reference(s) are no longer members "
                "and were left empty.",
            )
        recorder.record(
            workspace_id=workspace.pk,
            action="template.applied",
            target_type="template",
            target_id=template_id,
            project_id=target.pk,
            changes={"name": name, "tasks": len(run.result.task_ids)},
            actor=actor,
        )
    return run.result


def vars_of(params: ProjectParams) -> dict[str, str]:
    return {
        "name": params.name,
        "key": params.key,
        "description": params.description,
        "icon": params.icon,
        "color": params.color,
        "visibility": params.visibility,
    }
