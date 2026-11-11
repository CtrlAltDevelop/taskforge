"""Search over gRPC: ``SearchController`` Query, Remember and Recent. Rules are in
``infrastructure.search.services``.

``Query`` takes ``text`` (with operators such as ``in:WEB assignee:me status:open``), the
``types`` wanted (task, comment, project, member; none means all), a ``cursor`` (the previous
answer's ``next_cursor``: the same offset in every group) and ``page_size``. The answer groups
hits by type, and ``jump`` is the task when the text is an id like ``WEB-12`` (empty ``id`` when
not). INVALID_ARGUMENT for an unknown type, a bad cursor or text over 200 characters;
RESOURCE_EXHAUSTED (RATE_LIMITED) past the per-minute limit. ``Remember`` keeps the text as a
recent search (call it when a result is opened); ``Recent`` lists them, newest first.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.search import services
from infrastructure.search.grpc.serializers import Hit
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}


def _pb() -> Any:
    from infrastructure.search.grpc import search_pb2

    return search_pb2


def _hit(hit: services.Hit) -> Any:
    pb = _pb()
    return pb.Hit(
        kind=hit.kind,
        id=hit.id,
        task_id=hit.task_id,
        project_id=hit.project_id,
        key=hit.key,
        title=hit.title,
        title_marks=[pb.Span(start=s, end=e) for s, e in hit.title_marks],
        snippet=hit.snippet,
        snippet_marks=[pb.Span(start=s, end=e) for s, e in hit.snippet_marks],
        project_name=hit.project_name,
        status=hit.status,
        author=hit.author,
        updated_at=hit.updated_at,
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class SearchService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            {"name": "text", "type": "string"},
            {"name": "types", "cardinality": "repeated", "type": "string"},
            {"name": "cursor", "type": "string"},
            {"name": "page_size", "type": "int32"},
        ],
        request_name="SearchQueryRequest",
        response=[
            {"name": "tasks", "cardinality": "repeated", "type": Hit},
            {"name": "comments", "cardinality": "repeated", "type": Hit},
            {"name": "projects", "cardinality": "repeated", "type": Hit},
            {"name": "members", "cardinality": "repeated", "type": Hit},
            {"name": "jump", "type": Hit},
            {"name": "next_cursor", "type": "string"},
        ],
        response_name="SearchResults",
    )
    @action
    async def Query(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            page = services.query(
                user,
                workspace,
                request.text,
                list(request.types),
                request.cursor,
                request.page_size,
            )
            groups = {k: [_hit(h) for h in v] for k, v in page.hits.items()}
            return _pb().SearchResults(
                tasks=groups.get("task", []),
                comments=groups.get("comment", []),
                projects=groups.get("project", []),
                members=groups.get("member", []),
                jump=_hit(page.jump) if page.jump else None,
                next_cursor=page.next_cursor,
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=[WS, {"name": "text", "type": "string"}],
        request_name="SearchRememberRequest",
        response=[{"name": "ok", "type": "bool"}],
        response_name="SearchRemembered",
    )
    @action
    async def Remember(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        await sync_to_async(services.remember)(user, workspace, request.text)
        return _pb().SearchRemembered(ok=True)

    @grpc_action(
        request=[WS],
        request_name="SearchRecentRequest",
        response=[{"name": "queries", "cardinality": "repeated", "type": "string"}],
        response_name="SearchRecent",
    )
    @action
    async def Recent(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        found = await sync_to_async(services.recent)(user, workspace)
        return _pb().SearchRecent(queries=found)


GRPC_SERVICES = [SearchService]
