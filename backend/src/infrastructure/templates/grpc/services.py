"""Templates over gRPC: ``TemplateController``. The rules are in ``infrastructure.templates``.

``Update`` names what it changes in ``changed`` (name, description, visibility, content_json) and
carries ``expected_version`` (a stale one is ABORTED). ``Apply`` of a task template needs
``project_id`` (and may name ``parent_task_id``); of a project template it creates a project from
the ``project_*`` fields. Everything is created in one transaction; ``warnings`` lists what the
template named that no longer exists and was skipped.
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.templates import apply, services
from infrastructure.templates.grpc.serializers import Template, Variable, Warning
from infrastructure.workspaces.scoping import require_workspace

WS = [{"name": "workspace_id", "type": "string"}]
ONE = [*WS, {"name": "template_id", "type": "string"}]
META = [
    {"name": "name", "type": "string"},
    {"name": "description", "type": "string"},
    {"name": "visibility", "type": "string"},
]
ANSWER = [{"name": "template", "type": Template}]


def _pb() -> Any:
    from infrastructure.templates.grpc import templates_pb2

    return templates_pb2


def message(view: services.TemplateView, *, full: bool) -> Any:
    return _pb().Template(
        id=view.id,
        kind=view.kind,
        name=view.name,
        description=view.description,
        visibility=view.visibility,
        builtin=view.is_builtin,
        created_by=view.created_by,
        created_at=view.created_at,
        updated_at=view.updated_at,
        version=view.version,
        task_count=view.task_count,
        variables=view.variables,
        includes=view.includes,
        status_names=view.status_names,
        can_edit=view.can_edit,
        content_json=json.dumps(view.content) if full else "",
    )


def _answer(view: services.TemplateView) -> Any:
    return _pb().TemplateAnswer(template=message(view, full=True))


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class TemplateService(generics.GenericService):
    @grpc_action(
        request=[
            *WS,
            {"name": "query", "type": "string"},
            {"name": "kind", "type": "string"},
        ],
        request_name="TemplateListRequest",
        response=[{"name": "templates", "cardinality": "repeated", "type": Template}],
        response_name="TemplateList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        """The gallery: built-ins, shared and the caller's private ones; ``query`` searches name
        and description. Content is left out (use Get)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_templates(user, workspace, request.query, request.kind)
            return _pb().TemplateList(templates=[message(r, full=False) for r in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=ONE,
        request_name="TemplateGetRequest",
        response=ANSWER,
        response_name="TemplateAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _answer(services.get(user, workspace, request.template_id))
        )()

    @grpc_action(
        request=[
            *WS,
            {"name": "kind", "type": "string"},
            *META,
            {"name": "content_json", "type": "string"},
        ],
        request_name="TemplateCreateRequest",
        response=ANSWER,
        response_name="TemplateAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(
                services.create(
                    user,
                    workspace,
                    request.kind,
                    request.name,
                    request.description,
                    request.visibility or "workspace",
                    request.content_json,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *ONE,
            {"name": "changed", "cardinality": "repeated", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            *META,
            {"name": "content_json", "type": "string"},
        ],
        request_name="TemplateUpdateRequest",
        response=ANSWER,
        response_name="TemplateAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            changes: dict[str, str] = {}
            for name in request.changed:
                if name not in services.EDITABLE:
                    raise ApiError(f"Cannot change {name}.")
                changes[name] = getattr(request, name)
            return _answer(
                services.update(
                    user, workspace, request.template_id, request.expected_version, **changes
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=ONE,
        request_name="TemplateDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="TemplateDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete(user, workspace, request.template_id)
            return _pb().TemplateDeleted(id=request.template_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *WS,
            {"name": "project_id", "type": "string"},
            {"name": "task_id", "type": "string"},
            *META,
            {"name": "include_assignees", "type": "bool"},
        ],
        request_name="TemplateSaveFromTaskRequest",
        response=ANSWER,
        response_name="TemplateAnswer",
    )
    @action
    async def SaveFromTask(self, request: Any, context: Any) -> Any:
        """Save the task and all its subtasks as a task template."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(
                services.save_from_task(
                    user,
                    workspace,
                    request.project_id,
                    request.task_id,
                    request.name,
                    request.description,
                    request.visibility or "workspace",
                    request.include_assignees,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *WS,
            {"name": "project_id", "type": "string"},
            *META,
            {"name": "include", "cardinality": "repeated", "type": "string"},
            {"name": "include_assignees", "type": "bool"},
        ],
        request_name="TemplateSaveFromProjectRequest",
        response=ANSWER,
        response_name="TemplateAnswer",
    )
    @action
    async def SaveFromProject(self, request: Any, context: Any) -> Any:
        """``include`` is any of workflow, fields, automations, features, tasks."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            return _answer(
                services.save_from_project(
                    user,
                    workspace,
                    request.project_id,
                    request.name,
                    request.description,
                    request.visibility or "workspace",
                    list(request.include),
                    request.include_assignees,
                )
            )

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *ONE,
            {"name": "project_id", "type": "string"},
            {"name": "parent_task_id", "type": "string"},
            {"name": "project_name", "type": "string"},
            {"name": "project_key", "type": "string"},
            {"name": "project_description", "type": "string"},
            {"name": "project_icon", "type": "string"},
            {"name": "project_color", "type": "string"},
            {"name": "project_visibility", "type": "string"},
            {"name": "start_date", "type": "string"},
            {"name": "variables", "cardinality": "repeated", "type": Variable},
        ],
        request_name="TemplateApplyRequest",
        response=[
            {"name": "project_id", "type": "string"},
            {"name": "task_ids", "cardinality": "repeated", "type": "string"},
            {"name": "warnings", "cardinality": "repeated", "type": Warning},
        ],
        response_name="TemplateApplied",
    )
    @action
    async def Apply(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            result = apply.apply(
                user,
                workspace,
                request.template_id,
                project_id=request.project_id,
                parent_task_id=request.parent_task_id,
                project=apply.ProjectParams(
                    name=request.project_name,
                    key=request.project_key,
                    description=request.project_description,
                    icon=request.project_icon,
                    color=request.project_color,
                    visibility=request.project_visibility or "open",
                ),
                start_date=request.start_date,
                variables={v.name: v.value for v in request.variables},
            )
            pb = _pb()
            return pb.TemplateApplied(
                project_id=result.project_id,
                task_ids=result.task_ids,
                warnings=[pb.Warning(code=w.code, message=w.message) for w in result.warnings],
            )

        return await sync_to_async(run)()


GRPC_SERVICES = [TemplateService]
