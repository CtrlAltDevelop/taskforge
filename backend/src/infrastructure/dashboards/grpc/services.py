"""Dashboards over gRPC: ``DashboardController`` and ``WidgetController``. Rules are in
``infrastructure.dashboards``.

``Dashboard.List`` (optionally of one project), ``Get``, ``Save`` (create with an empty ``id``, or
replace a dashboard and all its widgets; ``expected_version`` guards a stale save: ABORTED
VERSION_CONFLICT), ``Delete`` and ``FromTemplate`` (``project_overview`` or ``my_work``).
``Widget.Data`` answers the numbers of a saved widget for the caller (cached a minute per person;
``refresh`` skips the cache), ``Preview`` those of an unsaved config, ``Drilldown`` streams the
tasks behind the widget's number or one bucket of it, ``Export`` gives its numbers as CSV.
``today`` (``YYYY-MM-DD``) and ``utc_offset_minutes`` are the caller's day: buckets of days and
weeks, and relative dates in the filter, count from it. INVALID_ARGUMENT DASHBOARD_INVALID /
DASHBOARD_LIMIT / DASHBOARD_TOO_HEAVY / FILTER_INVALID for a bad request, NOT_FOUND for a
dashboard, widget or project the caller may not open, PERMISSION_DENIED for sharing or changing a
shared dashboard without ``dashboard.manage``.
"""

import json
from collections.abc import AsyncIterator
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller, stream_action
from infrastructure.common.identity import grpc_caller
from infrastructure.dashboards import services
from infrastructure.dashboards.grpc.serializers import (
    Bucket,
    Dashboard,
    DrillTask,
    Series,
    WidgetInput,
)
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
DAY = [
    {"name": "today", "type": "string"},
    {"name": "utc_offset_minutes", "type": "int32"},
]
ANSWER = [{"name": "dashboard", "type": Dashboard}]
DATA = [
    {"name": "widget_id", "type": "string"},
    {"name": "total", "type": "string"},
    {"name": "buckets", "cardinality": "repeated", "type": Bucket},
    {"name": "series", "cardinality": "repeated", "type": Series},
    {"name": "truncated", "type": "bool"},
    {"name": "computed_at", "type": "string"},
    {"name": "cached", "type": "bool"},
]


def _pb() -> Any:
    from infrastructure.dashboards.grpc import dashboards_pb2

    return dashboards_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def _dashboard(view: services.View) -> Any:
    d, pb = view.dashboard, _pb()
    return pb.Dashboard(
        id=str(d.pk),
        workspace_id=str(d.workspace_id),
        project_id=str(d.project_id or ""),
        owner_id=str(d.owner_id),
        name=d.name,
        visibility=d.visibility,
        layout_json=json.dumps(d.layout),
        version=d.version,
        can_edit=view.can_edit,
        widgets=[
            pb.Widget(
                id=str(w.pk),
                type=w.type,
                title=w.title,
                config_json=json.dumps(w.config),
                version=w.version,
            )
            for w in view.widgets
        ],
        updated_at=_iso(d.updated_at),
    )


def _data(widget_id: str, computed: services.Computed) -> Any:
    pb, r = _pb(), computed.result
    return pb.WidgetData(
        widget_id=widget_id,
        total=str(r.total),
        buckets=[pb.Bucket(key=b.key, label=b.label, value=str(b.value)) for b in r.buckets],
        series=[
            pb.Series(name=s.name, points=[pb.Point(x=p.x, y=str(p.y)) for p in s.points])
            for s in r.series
        ],
        truncated=r.truncated,
        computed_at=_iso(computed.computed_at),
        cached=computed.cached,
    )


def _json(raw: str, what: str) -> Any:
    from infrastructure.dashboards import config

    if not raw:
        return {}
    try:
        return json.loads(raw)
    except (ValueError, RecursionError):
        raise config.invalid(f"{what} is not JSON.") from None


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class DashboardService(generics.GenericService):
    @grpc_action(
        request=[WS, {"name": "project_id", "type": "string"}],
        request_name="DashboardListRequest",
        response=[{"name": "dashboards", "cardinality": "repeated", "type": Dashboard}],
        response_name="DashboardList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_dashboards(user, workspace, request.project_id)
            return _pb().DashboardList(dashboards=[_dashboard(v) for v in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}],
        request_name="DashboardGetRequest",
        response=ANSWER,
        response_name="DashboardAnswer",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.get(user, workspace, request.id)
            return _pb().DashboardAnswer(dashboard=_dashboard(view))

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "id", "type": "string"},
            {"name": "name", "type": "string"},
            {"name": "visibility", "type": "string"},
            {"name": "project_id", "type": "string"},
            {"name": "widgets", "cardinality": "repeated", "type": WidgetInput},
            {"name": "layout_json", "type": "string"},
            {"name": "expected_version", "type": "int32"},
        ],
        request_name="DashboardSaveRequest",
        response=ANSWER,
        response_name="DashboardAnswer",
    )
    @action
    async def Save(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            widgets = [
                services.WidgetInput(
                    w.id, w.type, w.title, _json(w.config_json, "A widget's config")
                )
                for w in request.widgets
            ]
            view = services.save(
                user,
                workspace,
                request.id,
                name=request.name,
                visibility=request.visibility,
                project_id=request.project_id,
                widgets=widgets,
                layout=_json(request.layout_json, "The layout") or [],
                expected_version=request.expected_version,
            )
            return _pb().DashboardAnswer(dashboard=_dashboard(view))

        return await sync_to_async(run)()

    @grpc_action(
        request=[WS, {"name": "id", "type": "string"}],
        request_name="DashboardDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="DashboardDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            gone = services.delete(user, workspace, request.id)
            return _pb().DashboardDeleted(id=str(gone))

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "template", "type": "string"},
            {"name": "project_id", "type": "string"},
        ],
        request_name="DashboardFromTemplateRequest",
        response=ANSWER,
        response_name="DashboardAnswer",
    )
    @action
    async def FromTemplate(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            view = services.from_template(user, workspace, request.template, request.project_id)
            return _pb().DashboardAnswer(dashboard=_dashboard(view))

        return await sync_to_async(run)()


class WidgetService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            {"name": "widget_id", "type": "string"},
            *DAY,
            {"name": "refresh", "type": "bool"},
        ],
        request_name="WidgetDataRequest",
        response=DATA,
        response_name="WidgetData",
    )
    @action
    async def Data(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            computed = services.widget_data(
                user,
                workspace,
                request.widget_id,
                today=request.today,
                offset_minutes=request.utc_offset_minutes,
                refresh=request.refresh,
            )
            return _data(request.widget_id, computed)

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "project_id", "type": "string"},
            {"name": "type", "type": "string"},
            {"name": "config_json", "type": "string"},
            *DAY,
        ],
        request_name="WidgetPreviewRequest",
        response=DATA,
        response_name="WidgetData",
    )
    @action
    async def Preview(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            computed = services.preview(
                user,
                workspace,
                request.project_id,
                request.type,
                _json(request.config_json, "The config"),
                today=request.today,
                offset_minutes=request.utc_offset_minutes,
            )
            return _data("", computed)

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            WS,
            {"name": "widget_id", "type": "string"},
            {"name": "bucket", "type": "string"},
            *DAY,
        ],
        request_name="WidgetDrilldownRequest",
        response=[
            {"name": "task", "type": DrillTask},
            {"name": "truncated", "type": "bool"},
        ],
        response_name="DrilledTask",
        response_stream=True,
    )
    @stream_action
    async def Drilldown(self, request: Any, context: Any) -> AsyncIterator[Any]:
        user, workspace = await _scope(request, context)

        def run() -> list[Any]:
            pb = _pb()
            drilled = services.drilldown(
                user,
                workspace,
                request.widget_id,
                request.bucket,
                today=request.today,
                offset_minutes=request.utc_offset_minutes,
            )
            return [
                pb.DrilledTask(
                    truncated=drilled.truncated,
                    task=pb.DrillTask(
                        id=str(t.pk),
                        project_id=str(t.project_id),
                        display_id=t.display_id,
                        title=t.title,
                        status_name=t.status.name,
                        status_category=t.status.category,
                        priority=t.priority,
                        due_date=_iso(t.due_date),
                        points="" if t.points is None else str(t.points),
                        assignee_ids=[str(a.user_id) for a in t.assignees.all()],
                    ),
                )
                for t in drilled.tasks
            ]

        for message in await sync_to_async(run)():
            yield message

    @grpc_action(
        request=[WS, {"name": "widget_id", "type": "string"}, *DAY],
        request_name="WidgetExportRequest",
        response=[{"name": "csv", "type": "string"}],
        response_name="WidgetExport",
    )
    @action
    async def Export(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            text = services.export_csv(
                user,
                workspace,
                request.widget_id,
                today=request.today,
                offset_minutes=request.utc_offset_minutes,
            )
            return _pb().WidgetExport(csv=text)

        return await sync_to_async(run)()


GRPC_SERVICES = [DashboardService, WidgetService]
