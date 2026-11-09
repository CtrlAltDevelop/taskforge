"""Workflows over gRPC (``WorkflowController``). Adapters resolve the caller and workspace and
render what ``infrastructure.workflows`` decides.

Permissions: Get needs workspace membership (and a visible project); Update and Validate need
``project.update`` (a project's creator has it for their own project). ``Update`` saves the whole
workflow or nothing: an invalid draft is INVALID_ARGUMENT ``WORKFLOW_INVALID`` and the trailer
``x-error-errors-bin`` holds the JSON list of ``{code, message, status_key}``; a stale
``expected_version`` is ABORTED ``VERSION_CONFLICT``; an archived project is ALREADY_EXISTS
``PROJECT_ARCHIVED``. ``Validate`` is the same check without saving and always answers the list
(empty means it would save).
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workflows import services
from infrastructure.workflows.drafts import StatusDraft, TransitionDraft, WorkflowDraft
from infrastructure.workflows.grpc.serializers import (
    MigrationInput,
    StatusInput,
    TransitionInput,
    Workflow,
    WorkflowProblem,
)
from infrastructure.workspaces.scoping import require_workspace

IDS = [
    {"name": "workspace_id", "type": "string"},
    {"name": "project_id", "type": "string"},
]
DRAFT = [
    {"name": "restrict_transitions", "type": "bool"},
    {"name": "restrict_creation", "type": "bool"},
    {"name": "statuses", "cardinality": "repeated", "type": StatusInput},
    {"name": "transitions", "cardinality": "repeated", "type": TransitionInput},
    {"name": "migrations", "cardinality": "repeated", "type": MigrationInput},
]


def _pb() -> Any:
    from infrastructure.workflows.grpc import workflows_pb2

    return workflows_pb2


def _message(view: services.WorkflowView) -> Any:
    pb = _pb()
    return pb.Workflow(
        project_id=str(view.workflow.project_id),
        restrict_transitions=view.workflow.restrict_transitions,
        restrict_creation=view.workflow.restrict_creation,
        version=view.workflow.version,
        statuses=[
            pb.StatusResponse(
                id=str(s.pk),
                name=s.name,
                color=s.color,
                category=s.category,
                position=s.position,
                is_default=s.is_default,
                task_count=getattr(s, "task_count", 0),
            )
            for s in view.statuses
        ],
        transitions=[
            pb.TransitionResponse(
                from_status=str(t.from_status_id),
                to_status=str(t.to_status_id),
                required_role_id=str(t.required_role_id or ""),
                require_assignee=t.require_assignee,
            )
            for t in view.transitions
        ],
    )


def _draft(request: Any) -> tuple[WorkflowDraft, dict[str, str]]:
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(s.key, s.name, s.color, s.category, s.is_default) for s in request.statuses
        ),
        transitions=tuple(
            TransitionDraft(t.from_key, t.to_key, t.required_role_id, t.require_assignee)
            for t in request.transitions
        ),
        restrict=request.restrict_transitions,
        restrict_creation=request.restrict_creation,
    )
    return draft, {m.from_key: m.to_key for m in request.migrations}


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    workspace = await sync_to_async(require_workspace)(user, request.workspace_id)
    return user, workspace


class WorkflowService(generics.GenericService):
    @grpc_action(
        request=IDS,
        request_name="WorkflowGetRequest",
        response=Workflow,
        response_name="Workflow",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(services.get(user, workspace, request.project_id))
        )()

    @grpc_action(
        request=[*IDS, {"name": "expected_version", "type": "int32"}, *DRAFT],
        request_name="WorkflowUpdateRequest",
        response=Workflow,
        response_name="Workflow",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        draft, migrate = _draft(request)
        return await sync_to_async(
            lambda: _message(
                services.update(
                    user, workspace, request.project_id, request.expected_version, draft, migrate
                )
            )
        )()

    @grpc_action(
        request=[*IDS, *DRAFT],
        request_name="WorkflowValidateRequest",
        response=[{"name": "problems", "cardinality": "repeated", "type": WorkflowProblem}],
        response_name="WorkflowProblems",
    )
    @action
    async def Validate(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        draft, migrate = _draft(request)
        pb = _pb()
        found = await sync_to_async(services.validate_draft)(
            user, workspace, request.project_id, draft, migrate
        )
        return pb.WorkflowProblems(
            problems=[
                pb.WorkflowProblem(code=p.code, message=p.message, status_key=p.status_key)
                for p in found
            ]
        )


GRPC_SERVICES = [WorkflowService]
