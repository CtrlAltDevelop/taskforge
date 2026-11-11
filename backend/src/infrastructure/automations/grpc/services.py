"""Automations over gRPC: ``AutomationController`` and ``AutomationRunController``. Rules are in
``infrastructure.automations``.

``List`` / ``Create`` / ``Update`` / ``Toggle`` answer with ``Automation`` messages. A rule is
``trigger_json`` (``{"type": "status_changed", "to_status": id}`` ...), an optional TFQL
``condition_tfql`` and ``actions_json`` (a list). ``Update`` names what it changes in ``fields``
(name, trigger, condition, actions) and carries the ``expected_version``; a stale one is ABORTED
(VERSION_CONFLICT). Whoever updates or switches a rule on becomes its owner (it runs with their
permissions). ``DryRun`` shows the exact would-be steps for a task without changing anything.
``AutomationRun.List`` (filter by rule, task or status, newest first, ``before`` pages on) and
``Get`` read the history. INVALID_ARGUMENT for a bad rule, NOT_FOUND for a rule, run or project
the caller may not open, PERMISSION_DENIED without ``automation.manage`` for changes.
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.automations import services
from infrastructure.automations.grpc.serializers import Automation, AutomationRun
from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
PROJECT = [WS, {"name": "project_id", "type": "string"}]
RULE = [*PROJECT, {"name": "automation_id", "type": "string"}]
ANSWER = [{"name": "automation", "type": Automation}]
FIELDS = [
    {"name": "name", "type": "string"},
    {"name": "trigger_json", "type": "string"},
    {"name": "condition_tfql", "type": "string"},
    {"name": "actions_json", "type": "string"},
]


def _pb() -> Any:
    from infrastructure.automations.grpc import automations_pb2

    return automations_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def _json(raw: str, what: str) -> Any:
    try:
        return json.loads(raw)
    except (ValueError, RecursionError):
        raise services.spec.bad(f"{what} is not JSON.") from None


def automation_message(view: services.View) -> Any:
    a = view.automation
    return _pb().Automation(
        id=str(a.pk),
        workspace_id=str(a.workspace_id),
        project_id=str(a.project_id),
        name=a.name,
        enabled=a.enabled,
        trigger_json=json.dumps(a.trigger),
        condition_tfql=view.condition_tfql,
        condition_json=json.dumps(a.condition_ast) if a.condition_ast else "",
        actions_json=json.dumps(a.actions),
        owner_id=str(a.owner_id or ""),
        disabled_reason=a.disabled_reason,
        version=a.version,
        created_at=_iso(a.created_at),
        updated_at=_iso(a.updated_at),
        last_run_at=_iso(view.last_run_at),
        last_run_status=view.last_run_status,
    )


def run_message(run: Any) -> Any:
    task = run.task
    return _pb().AutomationRun(
        id=str(run.pk),
        automation_id=str(run.automation_id),
        automation_name=run.automation.name,
        task_id=str(run.task_id or ""),
        task_key=task.display_id if task else "",
        status=run.status,
        depth=run.depth,
        event_key=run.event_key,
        input_json=json.dumps(run.input),
        steps_json=json.dumps(run.steps),
        error=run.error,
        explanation=run.explanation,
        started_at=_iso(run.started_at),
        finished_at=_iso(run.finished_at),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


def _answer(view: services.View) -> Any:
    return _pb().AutomationAnswer(automation=automation_message(view))


class AutomationService(generics.GenericService):
    @grpc_action(
        request=PROJECT,
        request_name="AutomationListRequest",
        response=[{"name": "automations", "cardinality": "repeated", "type": Automation}],
        response_name="AutomationList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_automations(user, workspace, request.project_id)
            return _pb().AutomationList(automations=[automation_message(v) for v in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[*PROJECT, *FIELDS, {"name": "enabled", "type": "bool"}],
        request_name="AutomationCreateRequest",
        response=ANSWER,
        response_name="AutomationAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(
                services.create(
                    user,
                    workspace,
                    request.project_id,
                    request.name,
                    _json(request.trigger_json, "The trigger"),
                    _json(request.actions_json, "The actions"),
                    condition_tfql=request.condition_tfql,
                    enabled=request.enabled,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *RULE,
            {"name": "fields", "cardinality": "repeated", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            *FIELDS,
        ],
        request_name="AutomationUpdateRequest",
        response=ANSWER,
        response_name="AutomationAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        """``fields`` names what to change (any of name, trigger, condition, actions)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            changes: dict[str, Any] = {}
            for name in request.fields:
                if name not in services.EDITABLE:
                    raise ApiError(f"Cannot change {name}.", status=400)
                match name:
                    case "trigger":
                        changes[name] = _json(request.trigger_json, "The trigger")
                    case "actions":
                        changes[name] = _json(request.actions_json, "The actions")
                    case "condition":
                        changes[name] = request.condition_tfql
                    case _:
                        changes[name] = request.name
            return _answer(
                services.update(
                    user,
                    workspace,
                    request.project_id,
                    request.automation_id,
                    changes,
                    request.expected_version,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=RULE,
        request_name="AutomationDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="AutomationDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete(user, workspace, request.project_id, request.automation_id)
            return _pb().AutomationDeleted(id=request.automation_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*RULE, {"name": "enabled", "type": "bool"}],
        request_name="AutomationToggleRequest",
        response=ANSWER,
        response_name="AutomationAnswer",
    )
    @action
    async def Toggle(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(
                services.toggle(
                    user, workspace, request.project_id, request.automation_id, request.enabled
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[*RULE, {"name": "task_id", "type": "string"}],
        request_name="AutomationDryRunRequest",
        response=[
            {"name": "would_run", "type": "bool"},
            {"name": "status", "type": "string"},
            {"name": "explanation", "type": "string"},
            {"name": "error", "type": "string"},
            {"name": "steps_json", "type": "string"},
        ],
        response_name="AutomationDryRunAnswer",
    )
    @action
    async def DryRun(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            out = services.dry_run(
                user, workspace, request.project_id, request.automation_id, request.task_id
            )
            return _pb().AutomationDryRunAnswer(
                would_run=out.would_run,
                status=out.status,
                explanation=out.explanation,
                error=out.error,
                steps_json=json.dumps(out.steps),
            )

        return await sync_to_async(run)()


class AutomationRunService(generics.GenericService):
    @grpc_action(
        request=[
            *PROJECT,
            {"name": "automation_id", "type": "string"},
            {"name": "task_id", "type": "string"},
            {"name": "status", "type": "string"},
            {"name": "before", "type": "string"},
            {"name": "limit", "type": "int32"},
        ],
        request_name="AutomationRunListRequest",
        response=[{"name": "runs", "cardinality": "repeated", "type": AutomationRun}],
        response_name="AutomationRunList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_runs(
                user,
                workspace,
                request.project_id,
                request.automation_id,
                task_id=request.task_id,
                status=request.status,
                before=request.before,
                limit=request.limit,
            )
            return _pb().AutomationRunList(runs=[run_message(r) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[*PROJECT, {"name": "run_id", "type": "string"}],
        request_name="AutomationRunGetRequest",
        response=[{"name": "run", "type": AutomationRun}],
        response_name="AutomationRunAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            row = services.get_run(user, workspace, request.project_id, request.run_id)
            return _pb().AutomationRunAnswer(run=run_message(row))

        return await sync_to_async(run)()


GRPC_SERVICES = [AutomationService, AutomationRunService]
