"""The dashboard RPCs end to end: the wire shapes, the stream, and the refusals."""

import csv
import io
import json
import uuid
from typing import Any

import grpc
import pytest

from infrastructure.dashboards.grpc import dashboards_pb2 as pb
from infrastructure.dashboards.grpc import dashboards_pb2_grpc as stubs
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (
    _world,
    people,  # noqa: F401
)

DB = stubs.DashboardControllerStub
WD = stubs.WidgetControllerStub


def _widgets(*specs: tuple[str, dict[str, Any]]) -> list[Any]:
    return [
        pb.WidgetInput(id=str(uuid.uuid4()), type=k, title=k, config_json=json.dumps(c))
        for k, c in specs
    ]


def _saved(world: Any, grpc_call: Any, role: str = "Owner", **kw: Any) -> Any:
    request = pb.DashboardSaveRequest(
        workspace_id=world.ws,
        name=kw.get("name", "Team"),
        visibility=kw.get("visibility", "workspace"),
        widgets=kw.get("widgets", _widgets(("bar", {"group_by": "priority"}))),
        layout_json="[]",
    )
    return grpc_call(DB, "Save", request, token=world.tokens[role]).dashboard


def test_save_data_drill_and_export_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    owner = world.workspace.created_by
    set_actor(owner)
    for title, priority in (("a", "high"), ("b", "high"), ("c", "low")):
        task_services.create(owner, world.workspace, world.project_id, title, priority=priority)
    dashboard = _saved(world, grpc_call)
    assert dashboard.can_edit and len(dashboard.widgets) == 1
    assert json.loads(dashboard.layout_json)[0]["widget_id"] == dashboard.widgets[0].id
    widget_id = dashboard.widgets[0].id

    seen = grpc_call(
        WD,
        "Data",
        pb.WidgetDataRequest(workspace_id=world.ws, widget_id=widget_id),
        token=world.tokens["Viewer"],
    )
    assert seen.total == "3.00"
    assert {b.key: b.value for b in seen.buckets} == {"high": "2.00", "low": "1.00"}
    assert [b.label for b in seen.buckets] == ["High", "Low"]

    drilled = grpc_call(
        WD,
        "Drilldown",
        pb.WidgetDrilldownRequest(workspace_id=world.ws, widget_id=widget_id, bucket="high"),
        token=world.tokens["Viewer"],
    )
    assert sorted(m.task.title for m in drilled) == ["a", "b"]
    assert all(m.task.display_id and m.task.status_name for m in drilled)

    exported = grpc_call(
        WD,
        "Export",
        pb.WidgetExportRequest(workspace_id=world.ws, widget_id=widget_id),
        token=world.tokens["Member"],
    )
    rows = list(csv.reader(io.StringIO(exported.csv)))
    assert rows[0] == ["key", "label", "value"] and ["high", "High", "2.00"] in rows


def test_a_preview_needs_no_save_and_a_bad_config_is_invalid_argument(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    ok = grpc_call(
        WD,
        "Preview",
        pb.WidgetPreviewRequest(workspace_id=world.ws, type="number", config_json="{}"),
        token=world.tokens["Owner"],
    )
    assert ok.total == "0.00" and ok.widget_id == ""
    with pytest.raises(grpc.aio.AioRpcError) as bad:
        grpc_call(
            WD,
            "Preview",
            pb.WidgetPreviewRequest(
                workspace_id=world.ws, type="bar", config_json=json.dumps({"group_by": ""})
            ),
            token=world.tokens["Owner"],
        )
    assert bad.value.code() is grpc.StatusCode.INVALID_ARGUMENT
    assert "DASHBOARD_INVALID" in bad.value.details()


def test_a_stale_save_is_aborted_and_a_member_cannot_share(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    dashboard = _saved(world, grpc_call, visibility="personal")
    request = pb.DashboardSaveRequest(
        workspace_id=world.ws,
        id=dashboard.id,
        name="Renamed",
        visibility="personal",
        widgets=_widgets(("number", {})),
        layout_json="[]",
        expected_version=dashboard.version,
    )
    grpc_call(DB, "Save", request, token=world.tokens["Owner"])
    with pytest.raises(grpc.aio.AioRpcError) as stale:
        grpc_call(DB, "Save", request, token=world.tokens["Owner"])
    assert stale.value.code() is grpc.StatusCode.ABORTED
    with pytest.raises(grpc.aio.AioRpcError) as denied:
        _saved(world, grpc_call, role="Member", visibility="workspace")
    assert denied.value.code() is grpc.StatusCode.PERMISSION_DENIED


def test_another_workspaces_widget_is_not_found(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    a, b = _world(people, 0), _world(people, 1)
    theirs = _saved(b, grpc_call).widgets[0].id
    with pytest.raises(grpc.aio.AioRpcError) as refused:
        grpc_call(
            WD,
            "Data",
            pb.WidgetDataRequest(workspace_id=a.ws, widget_id=theirs),
            token=a.tokens["Owner"],
        )
    assert refused.value.code() is grpc.StatusCode.NOT_FOUND


def test_delete_over_the_wire_answers_the_real_id(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    dashboard = _saved(world, grpc_call, visibility="personal")
    gone = grpc_call(
        DB,
        "Delete",
        pb.DashboardDeleteRequest(workspace_id=world.ws, id=dashboard.id),
        token=world.tokens["Owner"],
    )
    assert gone.id == dashboard.id
