"""Saved list layouts over gRPC (``ViewController``): List, Save, Delete.

Permissions: List and a personal Save need workspace membership and a project the caller can open
(a hidden or foreign project, or another person's layout, is NOT_FOUND). A shared Save, or editing
or deleting a shared layout, needs ``project.update`` (PERMISSION_DENIED) on a project that is not
archived (ALREADY_EXISTS PROJECT_ARCHIVED). ``Save`` without ``id`` creates, with ``id`` replaces
that layout and needs its ``expected_version`` (ABORTED VERSION_CONFLICT with
``x-error-version-bin``). INVALID_ARGUMENT VIEW_INVALID for a layout that means nothing,
VIEW_LIMIT at 50 layouts, ALREADY_EXISTS VIEW_NAME_TAKEN. Other refusals as in
``infrastructure.projects.grpc.services``.
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.common.responses import ResponseTitle
from infrastructure.savedviews import services
from infrastructure.savedviews.grpc.serializers import (
    BoardLayout,
    CalendarLayout,
    FilterLayout,
    Layout,
    SavedView,
)
from infrastructure.savedviews.models import SavedView as ViewRow
from infrastructure.workspaces.scoping import require_workspace

IDS = [
    {"name": "workspace_id", "type": "string"},
    {"name": "project_id", "type": "string"},
]
LIST_RESPONSE = [{"name": "views", "cardinality": "repeated", "type": SavedView}]


def _pb() -> Any:
    from infrastructure.savedviews.grpc import savedviews_pb2

    return savedviews_pb2


def _layout(config: dict[str, Any]) -> Any:
    pb = _pb()
    return pb.LayoutResponse(
        columns=config["columns"],
        widths=[pb.LayoutWidthResponse(column=c, width=w) for c, w in config["widths"].items()],
        sort=[pb.LayoutSortResponse(key=s["key"], desc=s["desc"]) for s in config["sort"]],
        group_by=config["group_by"],
    )


def _board(config: dict[str, Any]) -> Any:
    pb = _pb()
    return pb.BoardLayoutResponse(
        group_by=config["group_by"],
        swimlane=config["swimlane"],
        card_fields=config["card_fields"],
        limits=[pb.BoardLimitResponse(column=c, limit=n) for c, n in config["limits"].items()],
    )


def _board_config(board: Any) -> dict[str, Any]:
    return {
        "group_by": board.group_by,
        "swimlane": board.swimlane,
        "card_fields": list(board.card_fields),
        "limits": {limit.column: limit.limit for limit in board.limits},
    }


def _calendar(config: dict[str, Any]) -> Any:
    return _pb().CalendarLayoutResponse(
        mode=config["mode"],
        color_by=config["color_by"],
        week_start=config["week_start"],
        hide_done=config["hide_done"],
    )


def _calendar_config(calendar: Any) -> dict[str, Any]:
    return {
        "mode": calendar.mode,
        "color_by": calendar.color_by,
        "week_start": calendar.week_start,
        "hide_done": calendar.hide_done,
    }


def _filter(config: dict[str, Any]) -> Any:
    return _pb().FilterLayoutResponse(
        ast_json=json.dumps(config["ast"]) if config["ast"] else "",
        saved_id=config["saved_id"],
    )


def _filter_config(active: Any) -> dict[str, Any]:
    try:
        ast = json.loads(active.ast_json) if active.ast_json else None
    except (ValueError, RecursionError):
        raise ApiError("The filter is not JSON.", title=ResponseTitle.VIEW_INVALID) from None
    return {"ast": ast, "saved_id": active.saved_id}


def _config(layout: Any) -> dict[str, Any]:
    return {
        "columns": list(layout.columns),
        "widths": {w.column: w.width for w in layout.widths},
        "sort": [{"key": s.key, "desc": s.desc} for s in layout.sort],
        "group_by": layout.group_by,
    }


def _message(view: ViewRow) -> Any:
    shape = {
        "board": lambda: {"board": _board(view.config)},
        "calendar": lambda: {"calendar": _calendar(view.config)},
        "filter": lambda: {"active_filter": _filter(view.config)},
    }.get(view.kind, lambda: {"layout": _layout(view.config)})()
    return _pb().SavedView(
        **shape,
        id=str(view.pk),
        project_id=str(view.project_id),
        owner_id=str(view.owner_id or ""),
        name=view.name,
        kind=view.kind,
        is_shared=view.is_shared,
        version=view.version,
        updated_at=view.updated_at.isoformat(),
    )


def _requested_config(request: Any) -> dict[str, Any]:
    if request.kind == "board":
        return _board_config(request.board)
    if request.kind == "calendar":
        return _calendar_config(request.calendar)
    if request.kind == "filter":
        return _filter_config(request.active_filter)
    return _config(request.layout)


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class ViewService(generics.GenericService):
    @grpc_action(
        request=[*IDS, {"name": "kind", "type": "string"}],
        request_name="ViewListRequest",
        response=LIST_RESPONSE,
        response_name="ViewList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _pb().ViewList(
                views=[
                    _message(v)
                    for v in services.list_views(user, workspace, request.project_id, request.kind)
                ]
            )
        )()

    @grpc_action(
        request=[
            *IDS,
            {"name": "id", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            {"name": "name", "type": "string"},
            {"name": "kind", "type": "string"},
            {"name": "layout", "type": Layout},
            {"name": "shared", "type": "bool"},
            {"name": "board", "type": BoardLayout},
            {"name": "calendar", "type": CalendarLayout},
            {"name": "active_filter", "type": FilterLayout},
        ],
        request_name="ViewSaveRequest",
        response=SavedView,
        response_name="SavedView",
    )
    @action
    async def Save(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                services.save(
                    user,
                    workspace,
                    request.project_id,
                    name=request.name,
                    config=_requested_config(request),
                    kind=request.kind or "list",
                    view_id=request.id,
                    shared=request.shared,
                    expected_version=request.expected_version,
                )
            )
        )()

    @grpc_action(
        request=[*IDS, {"name": "id", "type": "string"}],
        request_name="ViewDeleteRequest",
        response=SavedView,
        response_name="SavedView",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(services.delete(user, workspace, request.project_id, request.id))
        )()


GRPC_SERVICES = [ViewService]
