"""Tasks over gRPC (``TaskController``). Adapters resolve the caller and workspace and render
what ``infrastructure.tasks`` decides.

Permissions: Get/List need only workspace membership; Create ``task.create``; Update and Move
``task.update`` (a status change must also be allowed by the project's workflow:
FAILED_PRECONDITION TRANSITION_NOT_ALLOWED with ``x-error-{from,to,reason}-bin``), and so does
SetParent (a task under itself or its own subtask is INVALID_ARGUMENT); Delete/Restore/ListTrash
``task.delete`` (a task with subtasks needs ``mode`` ``subtree`` or ``promote``, else
INVALID_ARGUMENT HAS_SUBTASKS with ``x-error-count-bin``). A task or project the caller may not see
is NOT_FOUND. ``List`` returns only top-level tasks unless ``include_subtasks``, then every task in
tree order (a parent right before its own subtasks); ``ListChildren`` the direct subtasks.
``List`` is server-streamed in pages of up to 100 so a 10,000-task project starts rendering after
the first page and never sits whole in memory. A status change into Done is refused while the
task has open blockers (FAILED_PRECONDITION TASK_BLOCKED, ``x-error-blockers-bin``) unless
``override_blocked`` is set by someone who manages the project; ``Task.is_blocked`` says whether
it has any. ``field_values`` (field id, wire value; empty clears) on Create/Update set custom
field values (``FIELD_REQUIRED`` / ``FIELD_INVALID``; an edit conflicts per field,
``x-error-field-bin`` ``field:<id>``). Links are the ``LinkController`` beside this service.
``Update`` sends only the fields to change (``HasField``) plus ``expected_version``; a clash on
the same field is ABORTED VERSION_CONFLICT
with ``x-error-{field,current,version}-bin`` trailers. Other refusals as in
``infrastructure.projects.grpc.services``.
"""

import json
from collections.abc import AsyncIterator
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller, stream_action
from infrastructure.common.identity import grpc_caller
from infrastructure.tasks import bulk, services
from infrastructure.tasks.grpc.link_services import LinkService
from infrastructure.tasks.grpc.serializers import (
    BulkResult,
    GroupCount,
    SortKey,
    Task,
    TaskFieldValue,
)
from infrastructure.tasks.models import Task as TaskRow
from infrastructure.workspaces.scoping import require_workspace

IDS: list[dict[str, str]] = [
    {"name": "workspace_id", "type": "string"},
    {"name": "project_id", "type": "string"},
]
ID = {"name": "id", "type": "string"}
# A filter (the AST of a TFQL query as JSON) and the viewer's today for its relative dates.
FILTER: list[dict[str, str]] = [
    {"name": "filter_ast", "type": "string"},
    {"name": "today", "type": "string"},
]
VERSION = {"name": "expected_version", "type": "int32"}
TEXT_FIELDS = (
    "title",
    "description",
    "status",
    "priority",
    "start_date",
    "due_date",
    "due_time",
)
CREATE_FIELDS = [
    *({"name": n, "type": "string"} for n in TEXT_FIELDS),
    {"name": "assignee_ids", "cardinality": "repeated", "type": "string"},
    {"name": "parent_id", "type": "string"},
    {"name": "field_values", "cardinality": "repeated", "type": TaskFieldValue},
]


def _pb() -> Any:
    from infrastructure.tasks.grpc import tasks_pb2

    return tasks_pb2


def _field_value(kind: str, field_id: str, value: str) -> Any:
    """A custom value as the message ``kind`` nests it (the generator names that message
    ``TaskFieldValue`` or ``TaskFieldValueResponse`` depending on how the serializers are used)."""
    nested = getattr(_pb(), kind).DESCRIPTOR.fields_by_name["fields"].message_type.name
    return getattr(_pb(), nested)(field_id=field_id, value=value)


def _message(task: TaskRow, kind: str = "Task") -> Any:
    """The task as ``Task`` (or as ``TaskResponse``, the same fields as nested in a result)."""
    return getattr(_pb(), kind)(
        id=str(task.pk),
        workspace_id=str(task.workspace_id),
        project_id=str(task.project_id),
        number=task.number,
        display_id=task.display_id,
        title=task.title,
        description=json.dumps(task.description) if task.description else "",
        status=str(task.status_id),
        status_name=task.status.name,
        status_category=task.status.category,
        priority=task.priority,
        start_date=task.start_date.isoformat() if task.start_date else "",
        due_date=task.due_date.isoformat() if task.due_date else "",
        due_time=task.due_time.strftime("%H:%M") if task.due_time else "",
        assignee_ids=sorted(str(i) for i in task.assignee_ids()),
        parent_id=str(task.parent_id or ""),
        depth=task.depth,
        progress_done=task.progress_done,
        progress_total=task.progress_total,
        created_by=str(task.created_by_id),
        version=task.version,
        position=task.position,
        created_at=task.created_at.isoformat(),
        updated_at=task.updated_at.isoformat(),
        deleted_at=task.deleted_at.isoformat() if task.deleted_at else "",
        is_blocked=task.is_blocked,
        blocked_by=list(task.blockers),
        blockers_due=task.blockers_due,
        blocks_due=task.blocks_due,
        group_key=task.group_key,
        fields=[
            _field_value(kind, field_id, value)
            for field_id, value in sorted(task.custom_values.items())
        ],
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    workspace = await sync_to_async(require_workspace)(user, request.workspace_id)
    return user, workspace


async def _one(request: Any, context: Any, call: Any) -> Any:
    user, workspace = await _scope(request, context)
    return await sync_to_async(lambda: _message(call(user, workspace)))()


def _page(user: Any, workspace: Any, request: Any, cursor: str) -> tuple[list[Any], str]:
    tasks, following = services.list_page(
        user,
        workspace,
        request.project_id,
        status=request.status,
        assignee_id=request.assignee_id,
        cursor=cursor,
        limit=request.page_size or services.PAGE_DEFAULT,
        include_subtasks=request.include_subtasks,
        sort=[(k.key, k.desc) for k in request.sort],
        group_by=request.group_by,
        filter_ast=request.filter_ast,
        today=request.today,
    )
    return [_message(t) for t in tasks], following


class TaskService(generics.GenericService):
    @grpc_action(
        request=[*IDS, ID], request_name="TaskGetRequest", response=Task, response_name="Task"
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        return await _one(
            request, context, lambda u, w: services.get(u, w, request.project_id, request.id)
        )

    @grpc_action(
        request=[*IDS, *CREATE_FIELDS],
        request_name="TaskCreateRequest",
        response=Task,
        response_name="Task",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.create(
                u,
                w,
                request.project_id,
                request.title,
                description=request.description,
                status=request.status,
                priority=request.priority or "none",
                start_date=request.start_date,
                due_date=request.due_date,
                due_time=request.due_time,
                assignee_ids=list(request.assignee_ids),
                parent_id=request.parent_id,
                field_values={v.field_id: v.value for v in request.field_values},
            ),
        )

    @grpc_action(
        request=[
            *IDS,
            ID,
            VERSION,
            *({"name": n, "type": "string", "cardinality": "optional"} for n in TEXT_FIELDS),
            {"name": "set_assignees", "type": "bool"},
            {"name": "assignee_ids", "cardinality": "repeated", "type": "string"},
            {"name": "override_blocked", "type": "bool"},
            {"name": "field_values", "cardinality": "repeated", "type": TaskFieldValue},
        ],
        request_name="TaskUpdateRequest",
        response=Task,
        response_name="Task",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        sent: dict[str, Any] = {n: getattr(request, n) for n in TEXT_FIELDS if request.HasField(n)}
        if request.set_assignees:
            sent["assignee_ids"] = list(request.assignee_ids)
        if request.field_values:
            sent["field_values"] = {v.field_id: v.value for v in request.field_values}
        return await _one(
            request,
            context,
            lambda u, w: services.update(
                u,
                w,
                request.project_id,
                request.id,
                request.expected_version,
                sent,
                override_blocked=request.override_blocked,
            ),
        )

    @grpc_action(
        request=[
            *IDS,
            ID,
            VERSION,
            {"name": "status", "type": "string"},
            {"name": "include_subtasks", "type": "bool"},
            {"name": "override_blocked", "type": "bool"},
        ],
        request_name="TaskMoveRequest",
        response=Task,
        response_name="Task",
    )
    @action
    async def Move(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.move(
                u,
                w,
                request.project_id,
                request.id,
                request.expected_version,
                request.status,
                with_subtasks=request.include_subtasks,
                override_blocked=request.override_blocked,
            ),
        )

    @grpc_action(
        request=[*IDS, ID, {"name": "mode", "type": "string"}],
        request_name="TaskDeleteRequest",
        response=Task,
        response_name="Task",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.delete(u, w, request.project_id, request.id, request.mode),
        )

    @grpc_action(
        request=[*IDS, ID, VERSION, {"name": "parent_id", "type": "string"}],
        request_name="TaskSetParentRequest",
        response=Task,
        response_name="Task",
    )
    @action
    async def SetParent(self, request: Any, context: Any) -> Any:
        return await _one(
            request,
            context,
            lambda u, w: services.set_parent(
                u, w, request.project_id, request.id, request.expected_version, request.parent_id
            ),
        )

    @grpc_action(
        request=[*IDS, ID],
        request_name="TaskListChildrenRequest",
        response=[{"name": "tasks", "cardinality": "repeated", "type": Task}],
        response_name="TaskChildren",
    )
    @action
    async def ListChildren(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        rows = await sync_to_async(
            lambda: [
                _message(t)
                for t in services.list_children(user, workspace, request.project_id, request.id)
            ]
        )()
        return _pb().TaskChildren(tasks=rows)

    @grpc_action(
        request=[*IDS, ID], request_name="TaskRestoreRequest", response=Task, response_name="Task"
    )
    @action
    async def Restore(self, request: Any, context: Any) -> Any:
        return await _one(
            request, context, lambda u, w: services.restore(u, w, request.project_id, request.id)
        )

    @grpc_action(
        request=IDS,
        request_name="TaskListTrashRequest",
        response=[{"name": "tasks", "cardinality": "repeated", "type": Task}],
        response_name="TaskTrash",
    )
    @action
    async def ListTrash(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        rows = await sync_to_async(
            lambda: [_message(t) for t in services.list_trash(user, workspace, request.project_id)]
        )()
        return _pb().TaskTrash(tasks=rows)

    @grpc_action(
        request=[
            *IDS,
            {"name": "status", "type": "string"},
            {"name": "assignee_id", "type": "string"},
            {"name": "cursor", "type": "string"},
            {"name": "page_size", "type": "int32"},
            {"name": "include_subtasks", "type": "bool"},
            {"name": "sort", "cardinality": "repeated", "type": SortKey},
            {"name": "group_by", "type": "string"},
            *FILTER,
        ],
        request_name="TaskListRequest",
        response=Task,
        response_name="Task",
        response_stream=True,
    )
    @stream_action
    async def List(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)
        cursor = request.cursor
        while True:
            page, cursor = await sync_to_async(_page)(user, workspace, request, cursor)
            for message in page:
                yield message
            if not cursor:
                return

    @grpc_action(
        request=[
            *IDS,
            {"name": "group_by", "type": "string"},
            {"name": "status", "type": "string"},
            {"name": "assignee_id", "type": "string"},
            {"name": "include_subtasks", "type": "bool"},
            *FILTER,
        ],
        request_name="TaskGroupCountsRequest",
        response=[{"name": "groups", "cardinality": "repeated", "type": GroupCount}],
        response_name="TaskGroupCounts",
    )
    @action
    async def GroupCounts(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        counts = await sync_to_async(
            lambda: services.group_counts(
                user,
                workspace,
                request.project_id,
                request.group_by,
                status=request.status,
                assignee_id=request.assignee_id,
                include_subtasks=request.include_subtasks,
                filter_ast=request.filter_ast,
                today=request.today,
            )
        )()
        return _pb().TaskGroupCounts(
            groups=[_pb().GroupCount(key=key, count=n) for key, n in counts]
        )

    @grpc_action(
        request=[
            *IDS,
            {"name": "ids", "cardinality": "repeated", "type": "string"},
            *(
                {"name": n, "type": "string", "cardinality": "optional"}
                for n in ("status", "priority")
            ),
            {"name": "set_assignees", "type": "bool"},
            {"name": "assignee_ids", "cardinality": "repeated", "type": "string"},
            {"name": "delete", "type": "bool"},
            {"name": "delete_mode", "type": "string"},
        ],
        request_name="TaskBulkUpdateRequest",
        response=BulkResult,
        response_name="BulkResult",
        response_stream=True,
    )
    @stream_action
    async def BulkUpdate(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)
        changes: dict[str, Any] = {
            n: getattr(request, n) for n in ("status", "priority") if request.HasField(n)
        }
        if request.set_assignees:
            changes["assignee_ids"] = list(request.assignee_ids)
        results = bulk.update_many(
            user,
            workspace,
            request.project_id,
            list(request.ids),
            changes=changes or None,
            delete=(request.delete_mode if request.delete else None),
        )
        while (message := await sync_to_async(_next_result)(results)) is not None:
            yield message


def _next_result(results: Any) -> Any:
    """The next bulk result as a message (None at the end), built where the ORM may be used."""
    result = next(results, None)
    if result is None:
        return None
    if result.error is not None:
        error = result.error
        return _pb().BulkResult(
            id=result.task_id,
            code=str(error.title),
            message=str(error),
            detail=json.dumps(error.data, default=str) if error.data else "",
        )
    return _pb().BulkResult(id=result.task_id, ok=True, task=_message(result.task, "TaskResponse"))


# Imported last: the board adapter reuses the helpers above.
from infrastructure.tasks.grpc.board_services import BoardService  # noqa: E402
from infrastructure.tasks.grpc.calendar_services import CalendarService  # noqa: E402
from infrastructure.tasks.grpc.timeline_services import TimelineService  # noqa: E402

GRPC_SERVICES = [TaskService, LinkService, BoardService, CalendarService, TimelineService]
