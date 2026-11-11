"""Comments over gRPC (``CommentController``): List, Create, Edit, Delete, React, Pin, History,
ToSubtask (answers with the new task's id), Mentionable.

Reading needs a task the caller can open (a hidden or foreign project or task is NOT_FOUND);
writing needs ``comment.create`` (PERMISSION_DENIED) and a project that is not archived. ``List``
returns the newest ``page_size`` comments oldest first and a ``cursor`` for ``before`` to load
the ones earlier (empty at the start). ``Edit`` is the author's, within the edit window, on the
comment's ``expected_version`` (ABORTED VERSION_CONFLICT; FAILED... COMMENT_LOCKED once past the
window). A comment may mention only people who can see the task: otherwise INVALID_ARGUMENT
MENTION_NO_ACCESS with the people in ``x-error-users-bin``, unless ``grant_access`` is set by
someone who may manage the project's members. Rules and queries are in
``infrastructure.comments.services``.
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.comments import mentions, services
from infrastructure.comments.grpc.serializers import Comment, CommentRevision, Mentionable
from infrastructure.comments.models import Comment as CommentRow
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
    from infrastructure.comments.grpc import comments_pb2

    return comments_pb2


def _message(comment: CommentRow) -> Any:
    return _pb().Comment(
        id=str(comment.pk),
        task_id=str(comment.task_id),
        author_id=str(comment.author_id),
        parent_id=str(comment.parent_id or ""),
        body=json.dumps(comment.body) if comment.body else "",
        created_at=comment.created_at.isoformat(),
        edited_at=comment.edited_at.isoformat() if comment.edited_at else "",
        deleted=comment.is_deleted,
        pinned=comment.pinned,
        version=comment.version,
        mention_ids=getattr(comment, "mention_ids", []),
        reactions=[
            _pb().ReactionResponse(emoji=e, user_ids=u)
            for e, u in getattr(comment, "reaction_map", {}).items()
        ],
        edit_count=getattr(comment, "edit_count", 0),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class CommentService(generics.GenericService):
    @grpc_action(
        request=[
            *TASK,
            {"name": "before", "type": "string"},
            {"name": "page_size", "type": "int32"},
        ],
        request_name="CommentListRequest",
        response=[
            {"name": "comments", "cardinality": "repeated", "type": Comment},
            {"name": "cursor", "type": "string"},
        ],
        response_name="CommentPage",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            page = services.list_page(
                user,
                workspace,
                request.project_id,
                request.task_id,
                before=request.before,
                limit=request.page_size,
            )
            return _pb().CommentPage(
                comments=[_message(c) for c in page.comments], cursor=page.cursor
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=[
            *TASK,
            {"name": "body", "type": "string"},
            {"name": "parent_id", "type": "string"},
            {"name": "grant_access", "type": "bool"},
        ],
        request_name="CommentCreateRequest",
        response=Comment,
        response_name="Comment",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.create(
                    user,
                    workspace,
                    request.project_id,
                    request.task_id,
                    request.body,
                    parent_id=request.parent_id,
                    grant_access=request.grant_access,
                )
            )
        )()

    @grpc_action(
        request=[
            *ONE,
            {"name": "expected_version", "type": "int32"},
            {"name": "body", "type": "string"},
            {"name": "grant_access", "type": "bool"},
        ],
        request_name="CommentEditRequest",
        response=Comment,
        response_name="Comment",
    )
    @action
    async def Edit(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.edit(
                    user,
                    workspace,
                    request.project_id,
                    request.id,
                    request.expected_version,
                    request.body,
                    grant_access=request.grant_access,
                )
            )
        )()

    @grpc_action(
        request=ONE, request_name="CommentDeleteRequest", response=Comment, response_name="Comment"
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(services.delete(user, workspace, request.project_id, request.id))
        )()

    @grpc_action(
        request=[*ONE, {"name": "emoji", "type": "string"}, {"name": "on", "type": "bool"}],
        request_name="CommentReactRequest",
        response=Comment,
        response_name="Comment",
    )
    @action
    async def React(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.react(
                    user, workspace, request.project_id, request.id, request.emoji, request.on
                )
            )
        )()

    @grpc_action(
        request=[*ONE, {"name": "pinned", "type": "bool"}],
        request_name="CommentPinRequest",
        response=Comment,
        response_name="Comment",
    )
    @action
    async def Pin(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.pin(user, workspace, request.project_id, request.id, request.pinned)
            )
        )()

    @grpc_action(
        request=ONE,
        request_name="CommentHistoryRequest",
        response=[{"name": "revisions", "cardinality": "repeated", "type": CommentRevision}],
        response_name="CommentHistory",
    )
    @action
    async def History(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            found = services.history(user, workspace, request.project_id, request.id)
            return _pb().CommentHistory(
                revisions=[
                    _pb().CommentRevision(
                        body=json.dumps(r.body), at=r.at.isoformat(), current=r.current
                    )
                    for r in found
                ]
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=ONE,
        request_name="CommentToSubtaskRequest",
        response=[{"name": "task_id", "type": "string"}],
        response_name="CommentSubtask",
    )
    @action
    async def ToSubtask(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        made = await sync_to_async(services.to_subtask)(
            user, workspace, request.project_id, request.id
        )
        return _pb().CommentSubtask(task_id=str(made.pk))

    @grpc_action(
        request=[*TASK, {"name": "query", "type": "string"}],
        request_name="CommentMentionableRequest",
        response=[{"name": "people", "cardinality": "repeated", "type": Mentionable}],
        response_name="CommentMentionable",
    )
    @action
    async def Mentionable(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            project, _ = services._task(user, workspace, request.project_id, request.task_id)
            found = mentions.candidates(workspace, project, request.query)
            return _pb().CommentMentionable(
                people=[_pb().Mentionable(user_id=str(u.pk), display_name=_name(u)) for u in found]
            )

        return await sync_to_async(read)()


_name = mentions.display_name


GRPC_SERVICES = [CommentService]
