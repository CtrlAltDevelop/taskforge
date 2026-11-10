"""Task links over gRPC (``LinkController``): Add, Remove, ListForTask, SearchTasks.

Add and Remove need ``task.update``, ListForTask and SearchTasks only workspace membership
(SearchTasks lists live tasks of the projects the caller can open, by title or ``KEY-N``). Both
tasks of a link must be ones the caller can open (else NOT_FOUND); a far end the caller cannot
open reads back as ``restricted`` with no title or id. Refusals: ALREADY_EXISTS LINK_EXISTS and
LINK_CYCLE (with ``x-error-path-bin``, the loop as ``WEB-3 → WEB-1 → WEB-3``), INVALID_ARGUMENT
for a task linked to itself or an unknown kind, ALREADY_EXISTS PROJECT_ARCHIVED. The shared
plumbing is in ``infrastructure.tasks.grpc.services``.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.tasks import links
from infrastructure.tasks.grpc.serializers import Link, LinkCandidate
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
TASK = {"name": "task_id", "type": "string"}
LIST_RESPONSE = [{"name": "links", "cardinality": "repeated", "type": Link}]


def _message(view: links.LinkView) -> Any:
    from infrastructure.tasks.grpc import tasks_pb2

    other = view.other
    shown = other is not None
    return tasks_pb2.Link(
        id=str(view.link.pk),
        kind=view.kind,
        restricted=not shown,
        other_id=str(other.pk) if other else "",
        other_project_id=str(other.project_id) if other else "",
        other_display_id=other.display_id if other else "",
        other_title=other.title if other else "",
        other_status_name=other.status.name if other else "",
        other_status_category=other.status.category if other else "",
    )


def _list(user: Any, workspace: Any, task_id: str) -> Any:
    from infrastructure.tasks.grpc import tasks_pb2

    views = links.list_for_task(user, workspace, task_id)
    return tasks_pb2.LinkList(links=[_message(v) for v in views])


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class LinkService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            TASK,
            {"name": "other_task_id", "type": "string"},
            {"name": "kind", "type": "string"},
            {"name": "close_duplicate", "type": "bool"},
        ],
        request_name="LinkAddRequest",
        response=LIST_RESPONSE,
        response_name="LinkList",
    )
    @action
    async def Add(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            links.add(
                user,
                workspace,
                request.task_id,
                request.other_task_id,
                request.kind,
                close_duplicate=request.close_duplicate,
            )
            return _list(user, workspace, request.task_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, TASK, {"name": "id", "type": "string"}],
        request_name="LinkRemoveRequest",
        response=LIST_RESPONSE,
        response_name="LinkList",
    )
    @action
    async def Remove(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            links.remove(user, workspace, request.id)
            return _list(user, workspace, request.task_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, TASK],
        request_name="LinkListForTaskRequest",
        response=LIST_RESPONSE,
        response_name="LinkList",
    )
    @action
    async def ListForTask(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(lambda: _list(user, workspace, request.task_id))()

    @grpc_action(
        request=[WS, {"name": "query", "type": "string"}],
        request_name="LinkSearchTasksRequest",
        response=[{"name": "tasks", "cardinality": "repeated", "type": LinkCandidate}],
        response_name="LinkCandidates",
    )
    @action
    async def SearchTasks(self, request: Any, context: Any) -> Any:
        from infrastructure.tasks.grpc import tasks_pb2

        user, workspace = await _scope(request, context)

        def run() -> Any:
            found = links.search_tasks(user, workspace, request.query)
            return tasks_pb2.LinkCandidates(
                tasks=[
                    tasks_pb2.LinkCandidate(
                        id=str(t.pk),
                        project_id=str(t.project_id),
                        display_id=t.display_id,
                        title=t.title,
                        status_name=t.status.name,
                        status_category=t.status.category,
                    )
                    for t in found
                ]
            )

        return await sync_to_async(run)()
