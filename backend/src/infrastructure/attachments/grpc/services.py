"""Attachments over gRPC (``AttachmentController``): List, Delete, Usage. Uploading and
downloading are REST (``/api/uploads``, ``/api/files``), as files suit HTTP better than gRPC.

Reading needs a task the caller can open (a hidden or foreign one is NOT_FOUND). ``Delete`` is the
uploader's, or anyone holding ``task.attachment_manage``, in a project that is not archived.
``Usage`` is open to every member. Rules and queries are in ``infrastructure.attachments.services``.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.attachments import services
from infrastructure.attachments.grpc.serializers import Attachment, StorageUsage
from infrastructure.attachments.models import Attachment as AttachmentRow
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workspaces.scoping import require_workspace

TASK = [
    {"name": "workspace_id", "type": "string"},
    {"name": "project_id", "type": "string"},
    {"name": "task_id", "type": "string"},
]
ONE = [
    {"name": "workspace_id", "type": "string"},
    {"name": "project_id", "type": "string"},
    {"name": "id", "type": "string"},
]


def _pb() -> Any:
    from infrastructure.attachments.grpc import attachments_pb2

    return attachments_pb2


def message(row: AttachmentRow) -> Any:
    return _pb().Attachment(
        id=str(row.pk),
        task_id=str(row.task_id),
        comment_id=str(row.comment_id or ""),
        uploader_id=str(row.uploader_id),
        filename=row.filename,
        mime=row.mime,
        size=row.size,
        has_thumb=bool(row.thumb_key),
        created_at=row.created_at.isoformat(),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class AttachmentService(generics.GenericService):
    @grpc_action(
        request=TASK,
        request_name="AttachmentListRequest",
        response=[{"name": "attachments", "cardinality": "repeated", "type": Attachment}],
        response_name="AttachmentList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().AttachmentList(
                attachments=[
                    message(a)
                    for a in services.list_for_task(
                        user, workspace, request.project_id, request.task_id
                    )
                ]
            )
        )()

    @grpc_action(
        request=ONE,
        request_name="AttachmentDeleteRequest",
        response=Attachment,
        response_name="Attachment",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: message(services.delete(user, workspace, request.project_id, request.id))
        )()

    @grpc_action(
        request=[{"name": "workspace_id", "type": "string"}],
        request_name="UsageRequest",
        response=StorageUsage,
        response_name="StorageUsage",
    )
    @action
    async def Usage(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(lambda: _pb().StorageUsage(**services.usage(user, workspace)))()


GRPC_SERVICES = [AttachmentService]
