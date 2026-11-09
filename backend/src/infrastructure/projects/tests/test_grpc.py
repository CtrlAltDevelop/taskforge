"""ProjectController over a real gRPC server. Rules are tested on the services; this checks the
contract: field names, status codes, titles, the payload."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects.grpc import projects_pb2 as pb
from infrastructure.projects.grpc import projects_pb2_grpc as stubs
from infrastructure.projects.models import Project
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

P = stubs.ProjectControllerStub
GrpcCall = Callable[..., Any]
NAMES = ("zoe", "ann", "max", "vic", "eve")  # owner, admin, member, viewer, outsider


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    tokens = {n: _token(n) for n in NAMES}
    users = {n: get_user_model().objects.get(username=n) for n in NAMES}
    workspace = workspace_services.create(users["zoe"], "Acme", "acme")
    other = workspace_services.create(users["eve"], "Other", "other")
    for name, role in (("ann", "Admin"), ("max", "Member"), ("vic", "Viewer")):
        add_member(workspace, users[name], role)
    return {"ws": str(workspace.id), "other": str(other.id), "tokens": tokens, "users": users}


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def _create(call: GrpcCall, team: dict[str, Any], who: str = "zoe", **fields: Any) -> Any:
    fields = {"name": "Web", "key": "WEB", **fields}
    request = pb.ProjectCreateRequest(workspace_id=team["ws"], **fields)
    return call(P, "Create", request, token=team["tokens"][who])


def test_create_get_list_round_trip_with_the_full_payload(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(
        grpc_call, team, key="web", description="d", icon="🚀", color="#abcdef", visibility="open"
    )

    got = grpc_call(
        P,
        "Get",
        pb.ProjectGetRequest(workspace_id=team["ws"], id=created.id),
        token=team["tokens"]["vic"],
    )
    listed = grpc_call(
        P, "List", pb.ProjectListRequest(workspace_id=team["ws"]), token=team["tokens"]["vic"]
    )

    assert got == listed.projects[0]
    assert (got.key, got.name, got.description, got.icon, got.color) == (
        "WEB",
        "Web",
        "d",
        "🚀",
        "#ABCDEF",
    )
    assert (got.workspace_id, got.visibility, got.version, got.task_counter) == (
        team["ws"],
        "open",
        1,
        0,
    )
    assert (got.archived_at, got.is_favorite, got.member_count, got.is_member, got.can_open) == (
        "",
        False,
        0,
        False,
        True,
    )
    assert got.created_by == str(team["users"]["zoe"].pk)
    assert [(f.key, f.enabled) for f in got.features] == [
        ("subtasks", False),
        ("dependencies", False),
        ("custom_fields", False),
        ("time_tracking", False),
        ("sprints", False),
    ]
    assert [f.key for f in listed.feature_info] == [f.key for f in got.features]
    assert all(f.label and f.description for f in listed.feature_info)


def test_features_persist_and_appear_in_the_payload(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team)
    owner = team["tokens"]["zoe"]

    updated = grpc_call(
        P,
        "SetFeatures",
        pb.ProjectSetFeaturesRequest(
            workspace_id=team["ws"],
            project_id=created.id,
            enabled_keys=["sprints", "time_tracking"],
            expected_version=1,
        ),
        token=owner,
    )
    reread = grpc_call(
        P, "Get", pb.ProjectGetRequest(workspace_id=team["ws"], id=created.id), token=owner
    )

    assert updated.version == 2
    assert {f.key for f in reread.features if f.enabled} == {"sprints", "time_tracking"}
    unknown = _refused(
        grpc_call,
        P,
        "SetFeatures",
        pb.ProjectSetFeaturesRequest(
            workspace_id=team["ws"], project_id=created.id, enabled_keys=["x"], expected_version=2
        ),
        token=owner,
    )
    assert unknown.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_update_changes_only_what_was_sent(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team, description="keep")

    updated = grpc_call(
        P,
        "Update",
        pb.ProjectUpdateRequest(
            workspace_id=team["ws"], id=created.id, expected_version=1, name="Site"
        ),
        token=team["tokens"]["ann"],
    )

    assert (updated.name, updated.description, updated.key, updated.version) == (
        "Site",
        "keep",
        "WEB",
        2,
    )


def test_update_can_clear_an_optional_field(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team, description="gone")

    updated = grpc_call(
        P,
        "Update",
        pb.ProjectUpdateRequest(
            workspace_id=team["ws"], id=created.id, expected_version=1, description=""
        ),
        token=team["tokens"]["zoe"],
    )

    assert updated.description == ""


def test_error_codes_and_titles(team: Any, grpc_call: GrpcCall) -> None:
    owner = team["tokens"]["zoe"]
    created = _create(grpc_call, team)
    ws = team["ws"]

    taken = _refused(
        grpc_call,
        P,
        "Create",
        pb.ProjectCreateRequest(workspace_id=ws, name="X", key="web"),
        token=owner,
    )
    bad = _refused(
        grpc_call,
        P,
        "Create",
        pb.ProjectCreateRequest(workspace_id=ws, name="X", key="1"),
        token=owner,
    )
    stale = _refused(
        grpc_call,
        P,
        "Archive",
        pb.ProjectArchiveRequest(workspace_id=ws, id=created.id, expected_version=7),
        token=owner,
    )
    Project.objects.filter(pk=created.id).update(task_counter=1)
    locked = _refused(
        grpc_call,
        P,
        "Update",
        pb.ProjectUpdateRequest(workspace_id=ws, id=created.id, expected_version=1, key="NEW"),
        token=owner,
    )
    grpc_call(
        P,
        "Archive",
        pb.ProjectArchiveRequest(workspace_id=ws, id=created.id, expected_version=1),
        token=owner,
    )
    archived = _refused(
        grpc_call,
        P,
        "Update",
        pb.ProjectUpdateRequest(workspace_id=ws, id=created.id, expected_version=2, name="N"),
        token=owner,
    )

    assert (taken.code(), taken.details().split(":")[0]) == (
        grpc.StatusCode.ALREADY_EXISTS,
        "KEY_TAKEN",
    )
    assert bad.code() is grpc.StatusCode.INVALID_ARGUMENT
    assert (stale.code(), stale.details().split(":")[0]) == (
        grpc.StatusCode.ABORTED,
        "VERSION_CONFLICT",
    )
    assert locked.details().split(":")[0] == "KEY_LOCKED"
    assert archived.details().split(":")[0] == "PROJECT_ARCHIVED"


def test_private_projects_are_not_found_for_non_members_and_the_admin_list_works(
    team: Any, grpc_call: GrpcCall
) -> None:
    tokens, ws = team["tokens"], team["ws"]
    secret = _create(grpc_call, team, who="max", name="Secret", key="SEC", visibility="private")

    hidden = _refused(
        grpc_call,
        P,
        "Get",
        pb.ProjectGetRequest(workspace_id=ws, id=secret.id),
        token=tokens["zoe"],
    )
    admin_list = grpc_call(
        P, "ListPrivate", pb.ProjectListPrivateRequest(workspace_id=ws), token=tokens["zoe"]
    )
    normal = grpc_call(P, "List", pb.ProjectListRequest(workspace_id=ws), token=tokens["zoe"])
    denied = _refused(
        grpc_call,
        P,
        "ListPrivate",
        pb.ProjectListPrivateRequest(workspace_id=ws),
        token=tokens["max"],
    )

    assert hidden.code() is grpc.StatusCode.NOT_FOUND
    assert list(normal.projects) == []
    assert [
        (p.key, p.member_count, p.can_open, p.description, len(p.features))
        for p in admin_list.projects
    ] == [("SEC", 1, False, "", 0)]
    assert denied.code() is grpc.StatusCode.PERMISSION_DENIED
    assert denied.details().startswith("PERMISSION_DENIED_REASON: missing: project.view_private")

    added = grpc_call(
        P,
        "AddMember",
        pb.ProjectAddMemberRequest(
            workspace_id=ws, project_id=secret.id, user_id=str(team["users"]["zoe"].pk)
        ),
        token=tokens["zoe"],
    )
    opened = grpc_call(
        P, "Get", pb.ProjectGetRequest(workspace_id=ws, id=secret.id), token=tokens["zoe"]
    )
    members = grpc_call(
        P,
        "ListMembers",
        pb.ProjectListMembersRequest(workspace_id=ws, project_id=secret.id),
        token=tokens["zoe"],
    )
    assert added.user_id == str(team["users"]["zoe"].pk)
    assert (opened.is_member, opened.can_open, opened.member_count) == (True, True, 2)
    assert {m.user_id for m in members.members} == {
        str(team["users"][n].pk) for n in ("zoe", "max")
    }


def test_last_member_is_refused_and_remove_member_works(team: Any, grpc_call: GrpcCall) -> None:
    tokens, ws = team["tokens"], team["ws"]
    secret = _create(grpc_call, team, who="ann", key="SEC", visibility="private")
    ann = str(team["users"]["ann"].pk)

    refusal = _refused(
        grpc_call,
        P,
        "RemoveMember",
        pb.ProjectRemoveMemberRequest(workspace_id=ws, project_id=secret.id, user_id=ann),
        token=tokens["ann"],
    )

    assert refusal.details().split(":")[0] == "LAST_MEMBER"


def test_favorite_and_ordering(team: Any, grpc_call: GrpcCall) -> None:
    token, ws = team["tokens"]["vic"], team["ws"]
    _create(grpc_call, team, name="Alpha", key="AAA")
    beta = _create(grpc_call, team, name="Beta", key="BBB")

    starred = grpc_call(
        P,
        "Favorite",
        pb.ProjectFavoriteRequest(workspace_id=ws, project_id=beta.id, favorite=True),
        token=token,
    )
    listed = grpc_call(P, "List", pb.ProjectListRequest(workspace_id=ws), token=token)

    assert starred.is_favorite is True
    assert [(p.key, p.is_favorite) for p in listed.projects] == [("BBB", True), ("AAA", False)]


def test_restore_and_include_archived(team: Any, grpc_call: GrpcCall) -> None:
    token, ws = team["tokens"]["zoe"], team["ws"]
    created = _create(grpc_call, team)
    archived = grpc_call(
        P,
        "Archive",
        pb.ProjectArchiveRequest(workspace_id=ws, id=created.id, expected_version=1),
        token=token,
    )
    hidden = grpc_call(P, "List", pb.ProjectListRequest(workspace_id=ws), token=token)
    shown = grpc_call(
        P, "List", pb.ProjectListRequest(workspace_id=ws, include_archived=True), token=token
    )
    restored = grpc_call(
        P,
        "Restore",
        pb.ProjectRestoreRequest(workspace_id=ws, id=created.id, expected_version=2),
        token=token,
    )

    assert archived.archived_at != "" and list(hidden.projects) == [] and len(shown.projects) == 1
    assert (restored.archived_at, restored.version) == ("", 3)


def test_other_tenants_are_refused_uniformly(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team)
    eve = team["tokens"]["eve"]

    for method, request in (
        ("List", pb.ProjectListRequest(workspace_id=team["ws"])),
        ("Get", pb.ProjectGetRequest(workspace_id=team["ws"], id=created.id)),
        ("Create", pb.ProjectCreateRequest(workspace_id=team["ws"], name="X", key="XX")),
    ):
        refusal = _refused(grpc_call, P, method, request, token=eve)
        assert refusal.code() is grpc.StatusCode.PERMISSION_DENIED
        assert refusal.details().startswith("FORBIDDEN:")
    # her own workspace, someone else's project id
    cross = _refused(
        grpc_call,
        P,
        "Get",
        pb.ProjectGetRequest(workspace_id=team["other"], id=created.id),
        token=eve,
    )
    assert cross.code() is grpc.StatusCode.NOT_FOUND
