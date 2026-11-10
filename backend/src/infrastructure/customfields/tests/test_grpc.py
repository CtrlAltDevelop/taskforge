"""FieldController (and the field values on TaskController) over a real gRPC server: the
contract, status codes, titles and trailers. Rules are tested on the services."""

import json
from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.customfields.grpc import customfields_pb2 as pb
from infrastructure.customfields.grpc import customfields_pb2_grpc as stubs
from infrastructure.projects import services as projects
from infrastructure.tasks.grpc import tasks_pb2 as tpb
from infrastructure.tasks.grpc import tasks_pb2_grpc as tstubs
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

F = stubs.FieldControllerStub
T = tstubs.TaskControllerStub
GrpcCall = Callable[..., Any]
NAMES = ("zoe", "max", "vic", "eve")  # owner, member, viewer, outsider


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    tokens = {n: _token(n) for n in NAMES}
    users = {n: get_user_model().objects.get(username=n) for n in NAMES}
    workspace = workspace_services.create(users["zoe"], "Acme", "acme")
    workspace_services.create(users["eve"], "Other", "other")
    add_member(workspace, users["max"], "Member")
    add_member(workspace, users["vic"], "Viewer")
    project = projects.create(users["zoe"], workspace, "Web", "WEB").project
    return {"ws": str(workspace.id), "project": str(project.pk), "tokens": tokens}


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def _create(call: GrpcCall, team: dict[str, Any], who: str = "zoe", **fields: Any) -> Any:
    request = pb.FieldCreateRequest(workspace_id=team["ws"], project_id=team["project"], **fields)
    return call(F, "Create", request, token=team["tokens"][who])


def _list(call: GrpcCall, team: dict[str, Any], who: str = "vic", **kw: Any) -> Any:
    request = pb.FieldListRequest(workspace_id=team["ws"], project_id=team["project"], **kw)
    return call(F, "List", request, token=team["tokens"][who])


def test_create_list_and_read_back_every_attribute(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(
        grpc_call,
        team,
        name="Kind",
        type="select",
        options=[pb.FieldOption(label="Bug", color="#ff0000"), pb.FieldOption(label="Feature")],
        required=True,
        hidden_views=["board"],
    )

    listed = _list(grpc_call, team).fields

    assert [f.id for f in listed] == [created.id]
    got = listed[0]
    assert (got.name, got.type, got.required, got.version) == ("Kind", "select", True, 1)
    assert [(o.label, o.color) for o in got.options] == [("Bug", "#FF0000"), ("Feature", "")]
    assert all(o.id for o in got.options) and list(got.hidden_views) == ["board"]
    assert got.archived_at == "" and got.project_id == team["project"]


def test_viewer_may_read_but_not_write_and_a_stranger_sees_nothing(
    team: Any, grpc_call: GrpcCall
) -> None:
    denied = _refused(
        grpc_call,
        F,
        "Create",
        pb.FieldCreateRequest(
            workspace_id=team["ws"], project_id=team["project"], name="X", type="text"
        ),
        token=team["tokens"]["vic"],
    )
    stranger = _refused(
        grpc_call,
        F,
        "List",
        pb.FieldListRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["eve"],
    )

    assert denied.code() == grpc.StatusCode.PERMISSION_DENIED
    assert stranger.code() in (grpc.StatusCode.NOT_FOUND, grpc.StatusCode.PERMISSION_DENIED)


def test_invalid_definition_is_invalid_argument_with_its_title(
    team: Any, grpc_call: GrpcCall
) -> None:
    refusal = _refused(
        grpc_call,
        F,
        "Create",
        pb.FieldCreateRequest(
            workspace_id=team["ws"], project_id=team["project"], name="X", type="formula"
        ),
        token=team["tokens"]["zoe"],
    )

    assert refusal.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert refusal.details().startswith("FIELD_INVALID")


def test_duplicate_name_is_already_exists(team: Any, grpc_call: GrpcCall) -> None:
    _create(grpc_call, team, name="Env", type="text")

    refusal = _refused(
        grpc_call,
        F,
        "Create",
        pb.FieldCreateRequest(
            workspace_id=team["ws"], project_id=team["project"], name="env", type="text"
        ),
        token=team["tokens"]["zoe"],
    )

    assert refusal.code() == grpc.StatusCode.ALREADY_EXISTS
    assert refusal.details().startswith("FIELD_NAME_TAKEN")


def _update(team: Any, field: Any, **kw: Any) -> Any:
    return pb.FieldUpdateRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        id=field.id,
        expected_version=field.version,
        **kw,
    )


def test_update_sends_only_what_changes_and_a_stale_version_is_aborted(
    team: Any, grpc_call: GrpcCall
) -> None:
    field = _create(grpc_call, team, name="Env", type="text", default="prod")

    saved = grpc_call(
        F, "Update", _update(team, field, name="Environment"), token=team["tokens"]["zoe"]
    )
    stale = _refused(
        grpc_call, F, "Update", _update(team, field, required=True), token=team["tokens"]["zoe"]
    )

    assert (saved.name, saved.default, saved.required, saved.version) == (
        "Environment",
        "prod",
        False,
        2,
    )
    assert stale.code() == grpc.StatusCode.ABORTED
    assert stale.details().startswith("VERSION_CONFLICT")


def test_removing_a_used_option_is_a_failed_precondition_listing_the_counts(
    team: Any, grpc_call: GrpcCall
) -> None:
    field = _create(
        grpc_call,
        team,
        name="Kind",
        type="select",
        options=[pb.FieldOption(label="Bug"), pb.FieldOption(label="Feature")],
    )
    bug, feature = field.options
    kept = [pb.FieldOption(id=feature.id, label=feature.label, color=feature.color)]
    grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            title="A",
            field_values=[tpb.TaskFieldValue(field_id=field.id, value=bug.id)],
        ),
        token=team["tokens"]["max"],
    )
    keep = _update(team, field, set_options=True, options=kept)

    refusal = _refused(grpc_call, F, "Update", keep, token=team["tokens"]["zoe"])
    saved = grpc_call(
        F,
        "Update",
        _update(
            team,
            field,
            set_options=True,
            options=kept,
            remaps=[pb.OptionRemap(from_option=bug.id, to_option=feature.id)],
        ),
        token=team["tokens"]["zoe"],
    )

    assert refusal.code() == grpc.StatusCode.FAILED_PRECONDITION
    assert json.loads(dict(refusal.trailing_metadata())["x-error-options-bin"]) == {bug.id: 1}
    assert [o.label for o in saved.options] == ["Feature"]


def test_reorder_archive_and_restore(team: Any, grpc_call: GrpcCall) -> None:
    a = _create(grpc_call, team, name="A", type="text")
    b = _create(grpc_call, team, name="B", type="text")

    ordered = grpc_call(
        F,
        "Reorder",
        pb.FieldReorderRequest(
            workspace_id=team["ws"], project_id=team["project"], ids=[b.id, a.id]
        ),
        token=team["tokens"]["zoe"],
    )
    archived = grpc_call(
        F,
        "Archive",
        pb.FieldArchiveRequest(
            workspace_id=team["ws"], project_id=team["project"], id=a.id, expected_version=1
        ),
        token=team["tokens"]["zoe"],
    )
    active = _list(grpc_call, team).fields
    everything = _list(grpc_call, team, who="zoe", include_archived=True).fields
    restored = grpc_call(
        F,
        "Restore",
        pb.FieldRestoreRequest(
            workspace_id=team["ws"], project_id=team["project"], id=a.id, expected_version=2
        ),
        token=team["tokens"]["zoe"],
    )

    assert [f.name for f in ordered.fields] == ["B", "A"]
    assert archived.archived_at != "" and [f.name for f in active] == ["B"]
    assert [f.name for f in everything] == ["B", "A"]
    assert restored.archived_at == ""


def test_task_values_round_trip_over_the_proto_and_required_blocks_create(
    team: Any, grpc_call: GrpcCall
) -> None:
    money = _create(grpc_call, team, name="Budget", type="money", required=True)
    labels = _create(
        grpc_call,
        team,
        name="Labels",
        type="multiselect",
        options=[pb.FieldOption(label="A"), pb.FieldOption(label="B")],
    )
    base = {"workspace_id": team["ws"], "project_id": team["project"], "title": "Task"}

    missing = _refused(
        grpc_call, T, "Create", tpb.TaskCreateRequest(**base), token=team["tokens"]["max"]
    )
    task = grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(
            **base,
            field_values=[
                tpb.TaskFieldValue(field_id=money.id, value="12.5 usd"),
                tpb.TaskFieldValue(
                    field_id=labels.id, value=",".join(o.id for o in reversed(labels.options))
                ),
            ],
        ),
        token=team["tokens"]["max"],
    )
    edited = grpc_call(
        T,
        "Update",
        tpb.TaskUpdateRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            id=task.id,
            expected_version=task.version,
            field_values=[tpb.TaskFieldValue(field_id=money.id, value="20 EUR")],
        ),
        token=team["tokens"]["max"],
    )
    fetched = grpc_call(
        T,
        "Get",
        tpb.TaskGetRequest(workspace_id=team["ws"], project_id=team["project"], id=task.id),
        token=team["tokens"]["vic"],
    )

    assert missing.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert missing.details().startswith("FIELD_REQUIRED")
    assert json.loads(dict(missing.trailing_metadata())["x-error-fields-bin"]) == [money.id]
    assert {v.field_id: v.value for v in task.fields} == {
        money.id: "12.50 USD",
        labels.id: ",".join(o.id for o in labels.options),
    }
    assert {v.field_id: v.value for v in edited.fields}[money.id] == "20.00 EUR"
    assert {v.field_id: v.value for v in fetched.fields} == {
        v.field_id: v.value for v in edited.fields
    }
    assert edited.version == task.version + 1


def test_streamed_list_carries_the_values(team: Any, grpc_call: GrpcCall) -> None:
    field = _create(grpc_call, team, name="Env", type="text")
    grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            title="A",
            field_values=[tpb.TaskFieldValue(field_id=field.id, value="prod")],
        ),
        token=team["tokens"]["max"],
    )

    listed = grpc_call(
        T,
        "List",
        tpb.TaskListRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["vic"],
    )

    first = next(iter(listed))
    assert [(v.field_id, v.value) for v in first.fields] == [(field.id, "prod")]
