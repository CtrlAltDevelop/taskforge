"""The query language and saved filters over gRPC: ``QueryController`` and ``FilterController``.

``Validate`` reads TFQL (or a filter AST) for a project and answers in-band: ``ok`` with the AST
and the normal text, or ``errors`` with the position and length of what is wrong. ``Suggest``
offers what could come next at a cursor. Both need workspace membership and, with a project, a
project the caller can open (a hidden or foreign project is NOT_FOUND); with no project only the
built-in fields that need none are known. The filters controller lists, saves and deletes: private
filters are the owner's, project-shared ones need ``project.update`` and an active project,
workspace-shared ones ``workspace.update``; INVALID_ARGUMENT FILTER_INVALID (with ``position`` and
``length`` trailers) for a query that does not hold up, ALREADY_EXISTS FILTER_NAME_TAKEN,
FILTER_LIMIT at 100 per place, ABORTED VERSION_CONFLICT for a stale save. Task calls take a
filter as ``filter_ast`` (see ``infrastructure.tasks.grpc``).
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.filters import services
from infrastructure.filters.grpc.serializers import Filter, QueryProblem, QuerySuggestion
from infrastructure.filters.models import SavedFilter
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
PROJECT = {"name": "project_id", "type": "string"}


def _pb() -> Any:
    from infrastructure.filters.grpc import filters_pb2

    return filters_pb2


def _filter(row: SavedFilter, tfql: str) -> Any:
    return _pb().Filter(
        id=str(row.pk),
        project_id=str(row.project_id or ""),
        owner_id=str(row.owner_id),
        name=row.name,
        visibility=row.visibility,
        ast_json=json.dumps(row.ast),
        tfql=tfql,
        version=row.version,
        updated_at=row.updated_at.isoformat(),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class QueryService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            PROJECT,
            {"name": "tfql", "type": "string"},
            {"name": "ast_json", "type": "string"},
        ],
        request_name="QueryValidateRequest",
        response=[
            {"name": "ok", "type": "bool"},
            {"name": "ast_json", "type": "string"},
            {"name": "tfql", "type": "string"},
            {"name": "errors", "cardinality": "repeated", "type": QueryProblem},
        ],
        response_name="QueryChecked",
    )
    @action
    async def Validate(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            found = services.validate(
                user, workspace, request.project_id, request.tfql, request.ast_json
            )
            return _pb().QueryChecked(
                ok=not found.errors,
                ast_json=json.dumps(found.ast) if found.ast is not None else "",
                tfql=found.tfql,
                errors=[
                    _pb().QueryProblem(position=e.position, length=e.length, message=e.message)
                    for e in found.errors
                ],
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=[
            WS,
            PROJECT,
            {"name": "partial", "type": "string"},
            {"name": "cursor", "type": "int32"},
        ],
        request_name="QuerySuggestRequest",
        response=[{"name": "items", "cardinality": "repeated", "type": QuerySuggestion}],
        response_name="QuerySuggestions",
    )
    @action
    async def Suggest(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            found = services.suggest(
                user, workspace, request.project_id, request.partial, request.cursor
            )
            return _pb().QuerySuggestions(
                items=[
                    _pb().QuerySuggestion(text=s.text, kind=s.kind, start=s.start, label=s.label)
                    for s in found
                ]
            )

        return await sync_to_async(read)()


class FilterService(generics.GenericService):
    @grpc_action(
        request=[WS, PROJECT],
        request_name="FilterListRequest",
        response=[{"name": "filters", "cardinality": "repeated", "type": Filter}],
        response_name="FilterList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().FilterList(
                filters=[
                    _filter(row, text)
                    for row, text in services.list_filters(user, workspace, request.project_id)
                ]
            )
        )()

    @grpc_action(
        request=[
            WS,
            PROJECT,
            {"name": "id", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            {"name": "name", "type": "string"},
            {"name": "tfql", "type": "string"},
            {"name": "ast_json", "type": "string"},
            {"name": "visibility", "type": "string"},
        ],
        request_name="FilterSaveRequest",
        response=Filter,
        response_name="Filter",
    )
    @action
    async def Save(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def write() -> Any:
            row, text = services.save(
                user,
                workspace,
                request.project_id,
                name=request.name,
                text=request.tfql,
                ast_json=request.ast_json,
                visibility=request.visibility or "private",
                filter_id=request.id,
                expected_version=request.expected_version,
            )
            return _filter(row, text)

        return await sync_to_async(write)()

    @grpc_action(
        request=[WS, PROJECT, {"name": "id", "type": "string"}],
        request_name="FilterDeleteRequest",
        response=Filter,
        response_name="Filter",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _filter(services.delete(user, workspace, request.project_id, request.id), "")
        )()


GRPC_SERVICES = [QueryService, FilterService]
