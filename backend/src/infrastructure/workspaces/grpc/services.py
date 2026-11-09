"""Workspaces over gRPC: list mine, list deleted, create, update, delete, restore.

Logo upload is REST (``POST /api/v1/workspaces/{id}/logo``); bytes do not belong
in these messages. ``expected_version`` on Update is the optimistic lock: a stale
one is ``ABORTED`` and the caller should re-List and retry.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workspaces import services
from infrastructure.workspaces.grpc.serializers import Workspace
from infrastructure.workspaces.models import Workspace as WorkspaceRow


def workspace_message(workspace: WorkspaceRow, actor: Any) -> Any:
    from infrastructure.workspaces.grpc import workspaces_pb2

    return workspaces_pb2.Workspace(
        id=str(workspace.id),
        name=workspace.name,
        slug=workspace.slug,
        logo=workspace.logo.url if workspace.logo else "",
        created_by=str(workspace.created_by_id),
        created_at=workspace.created_at.isoformat(),
        deleted_at=workspace.deleted_at.isoformat() if workspace.deleted_at else "",
        version=workspace.version,
        is_owner=workspace.created_by_id == actor.pk,
    )


class WorkspaceService(generics.GenericService):
    @grpc_action(
        request=[],
        response=[{"name": "workspaces", "cardinality": "repeated", "type": Workspace}],
        response_name="WorkspaceList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2

        user = require_caller(await grpc_caller(context))
        rows = await sync_to_async(services.list_mine)(user)
        return workspaces_pb2.WorkspaceList(
            workspaces=[workspace_message(row, user) for row in rows]
        )

    @grpc_action(
        request=[],
        response=[{"name": "workspaces", "cardinality": "repeated", "type": Workspace}],
        response_name="WorkspaceList",
    )
    @action
    async def ListDeleted(self, request: Any, context: Any) -> Any:
        from infrastructure.workspaces.grpc import workspaces_pb2

        user = require_caller(await grpc_caller(context))
        rows = await sync_to_async(services.list_deleted)(user)
        return workspaces_pb2.WorkspaceList(
            workspaces=[workspace_message(row, user) for row in rows]
        )

    @grpc_action(
        request=[{"name": "name", "type": "string"}, {"name": "slug", "type": "string"}],
        request_name="WorkspaceCreateRequest",
        response=Workspace,
        response_name="Workspace",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        row = await sync_to_async(services.create)(user, request.name, request.slug)
        return workspace_message(row, user)

    @grpc_action(
        request=[
            {"name": "id", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            {"name": "name", "type": "string", "cardinality": "optional"},
            {"name": "slug", "type": "string", "cardinality": "optional"},
        ],
        request_name="WorkspaceUpdateRequest",
        response=Workspace,
        response_name="Workspace",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        row = await sync_to_async(services.update)(
            user,
            request.id,
            request.expected_version,
            name=request.name if request.HasField("name") else None,
            slug=request.slug if request.HasField("slug") else None,
        )
        return workspace_message(row, user)

    @grpc_action(
        request=[
            {"name": "id", "type": "string"},
            {"name": "confirmation", "type": "string"},
        ],
        request_name="WorkspaceDeleteRequest",
        response=Workspace,
        response_name="Workspace",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        row = await sync_to_async(services.delete)(user, request.id, request.confirmation)
        return workspace_message(row, user)

    @grpc_action(
        request=[{"name": "id", "type": "string"}],
        request_name="WorkspaceRestoreRequest",
        response=Workspace,
        response_name="Workspace",
    )
    @action
    async def Restore(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        row = await sync_to_async(services.restore)(user, request.id)
        return workspace_message(row, user)


def _all_services() -> list[type]:
    # Imported late: members.py imports workspace_message from this module.
    from infrastructure.workspaces.grpc.members import InvitationService, MemberService

    return [WorkspaceService, MemberService, InvitationService]


GRPC_SERVICES = _all_services()
