"""Role, Permission and Member.SetRole over a real gRPC server."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.workspaces import services
from infrastructure.workspaces.grpc import workspaces_pb2 as pb
from infrastructure.workspaces.grpc import workspaces_pb2_grpc as stubs
from infrastructure.workspaces.registry import ALL_KEYS, BUILTIN_GRANTS

from .test_grpc import _token

Roles, Perms, Members = (
    stubs.RoleControllerStub,
    stubs.PermissionControllerStub,
    stubs.MemberControllerStub,
)
Workspaces = stubs.WorkspaceControllerStub
GrpcCall = Callable[..., Any]


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    tokens = {n: _token(n) for n in ("zoe", "ann", "max", "vic")}  # owner, admin, member, viewer
    users = {n: get_user_model().objects.get(username=n) for n in tokens}
    workspace = services.create(users["zoe"], "Acme", "acme")
    for name, role in (("ann", "Admin"), ("max", "Member"), ("vic", "Viewer")):
        add_member(workspace, users[name], role)
    return {"ws": str(workspace.id), "tokens": tokens, "users": users, "workspace": workspace}


def _role_ids(call: GrpcCall, team: dict[str, Any]) -> dict[str, str]:
    listed = call(
        Roles, "List", pb.RoleListRequest(workspace_id=team["ws"]), token=team["tokens"]["zoe"]
    )
    return {r.name: r.id for r in listed.roles}


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def test_list_returns_roles_counts_and_the_grouped_registry(team: Any, grpc_call: GrpcCall) -> None:
    listed = grpc_call(
        Roles, "List", pb.RoleListRequest(workspace_id=team["ws"]), token=team["tokens"]["vic"]
    )

    assert [(r.name, r.is_builtin, r.member_count) for r in listed.roles] == [
        ("Owner", True, 1),
        ("Admin", True, 1),
        ("Member", True, 1),
        ("Viewer", True, 1),
    ]
    assert set(listed.roles[3].permissions) == BUILTIN_GRANTS["Viewer"]
    assert [a.area for a in listed.registry] == [
        "workspace",
        "member",
        "role",
        "project",
        "task",
        "comment",
        "time",
        "sprint",
        "doc",
        "automation",
    ]
    assert {p.key for a in listed.registry for p in a.permissions} == ALL_KEYS
    assert all(p.label for a in listed.registry for p in a.permissions)


def test_custom_role_lifecycle_over_grpc(team: Any, grpc_call: GrpcCall) -> None:
    zoe, vic = team["tokens"]["zoe"], team["tokens"]["vic"]
    ws = team["ws"]
    made = grpc_call(
        Roles,
        "Create",
        pb.RoleCreateRequest(
            workspace_id=ws, name="Helper", permissions=["workspace.view", "member.invite"]
        ),
        token=zoe,
    )
    assert (made.name, made.is_builtin, made.member_count) == ("Helper", False, 0)
    vic_id = str(team["users"]["vic"].pk)
    moved = grpc_call(
        Members,
        "SetRole",
        pb.MemberSetRoleRequest(workspace_id=ws, user_id=vic_id, role_id=made.id),
        token=zoe,
    )
    assert (moved.role_id, moved.role_name, moved.is_owner) == (made.id, "Helper", False)
    grpc_call(
        stubs.InvitationControllerStub,
        "CreateLink",
        pb.InvitationCreateLinkRequest(workspace_id=ws),
        token=vic,
    )

    updated = grpc_call(
        Roles,
        "Update",
        pb.RoleUpdateRequest(
            workspace_id=ws,
            id=made.id,
            name="Helper 2",
            permissions=["workspace.view"],
            expected_version=made.version,
        ),
        token=zoe,
    )
    assert (updated.name, list(updated.permissions), updated.member_count) == (
        "Helper 2",
        ["workspace.view"],
        1,
    )
    assert (made.version, updated.version) == (1, 2)
    assert (
        _refused(
            grpc_call,
            stubs.InvitationControllerStub,
            "CreateLink",
            pb.InvitationCreateLinkRequest(workspace_id=ws),
            token=vic,
        ).code()
        is grpc.StatusCode.PERMISSION_DENIED
    )

    ids = _role_ids(grpc_call, team)
    grpc_call(
        Roles,
        "Delete",
        pb.RoleDeleteRequest(workspace_id=ws, id=made.id, reassign_to=ids["Viewer"]),
        token=zoe,
    )
    after = grpc_call(Members, "List", pb.MemberListRequest(workspace_id=ws), token=zoe)
    assert {m.email: m.role_name for m in after.members}["vic@example.com"] == "Viewer"


def test_role_refusals_have_distinct_statuses_and_titles(team: Any, grpc_call: GrpcCall) -> None:
    zoe, ws = team["tokens"]["zoe"], team["ws"]
    ids = _role_ids(grpc_call, team)
    grpc_call(Roles, "Create", pb.RoleCreateRequest(workspace_id=ws, name="Dup"), token=zoe)

    dup = _refused(
        grpc_call, Roles, "Create", pb.RoleCreateRequest(workspace_id=ws, name="dup"), token=zoe
    )
    unknown = _refused(
        grpc_call,
        Roles,
        "Create",
        pb.RoleCreateRequest(workspace_id=ws, name="Z", permissions=["task.edit"]),
        token=zoe,
    )
    builtin = _refused(
        grpc_call,
        Roles,
        "Update",
        pb.RoleUpdateRequest(workspace_id=ws, id=ids["Admin"], name="X", expected_version=1),
        token=zoe,
    )
    missing = _refused(
        grpc_call,
        Roles,
        "Update",
        pb.RoleUpdateRequest(workspace_id=ws, id="999999", name="X", expected_version=1),
        token=zoe,
    )

    assert dup.code() is grpc.StatusCode.ALREADY_EXISTS and dup.details().startswith(
        "ROLE_NAME_TAKEN:"
    )
    assert unknown.code() is grpc.StatusCode.INVALID_ARGUMENT
    assert builtin.code() is grpc.StatusCode.PERMISSION_DENIED and builtin.details().startswith(
        "ROLE_BUILTIN:"
    )
    assert missing.code() is grpc.StatusCode.NOT_FOUND


def test_escalation_and_last_owner_over_grpc(team: Any, grpc_call: GrpcCall) -> None:
    ws, ann, max_, zoe = (
        team["ws"],
        team["tokens"]["ann"],
        team["tokens"]["max"],
        team["tokens"]["zoe"],
    )
    ids, users = _role_ids(grpc_call, team), team["users"]

    admin_to_owner = _refused(
        grpc_call,
        Members,
        "SetRole",
        pb.MemberSetRoleRequest(
            workspace_id=ws, user_id=str(users["ann"].pk), role_id=ids["Owner"]
        ),
        token=ann,
    )
    member_promotes_self = _refused(
        grpc_call,
        Members,
        "SetRole",
        pb.MemberSetRoleRequest(
            workspace_id=ws, user_id=str(users["max"].pk), role_id=ids["Admin"]
        ),
        token=max_,
    )
    demote_last_owner = _refused(
        grpc_call,
        Members,
        "SetRole",
        pb.MemberSetRoleRequest(
            workspace_id=ws, user_id=str(users["zoe"].pk), role_id=ids["Admin"]
        ),
        token=zoe,
    )
    leave = _refused(grpc_call, Members, "Leave", pb.MemberLeaveRequest(workspace_id=ws), token=zoe)

    assert (
        admin_to_owner.details()
        == "PERMISSION_DENIED_REASON: missing: workspace.delete; your role: Admin"
    )
    assert (
        member_promotes_self.details()
        == "PERMISSION_DENIED_REASON: missing: member.set_role; your role: Member"
    )
    assert demote_last_owner.details().startswith("OWNER_PROTECTED:")
    assert leave.code() is grpc.StatusCode.PERMISSION_DENIED and leave.details().startswith(
        "OWNER_PROTECTED:"
    )


def test_ownership_transfer_and_derived_is_owner(team: Any, grpc_call: GrpcCall) -> None:
    ws, zoe, ann = team["ws"], team["tokens"]["zoe"], team["tokens"]["ann"]
    ids = _role_ids(grpc_call, team)

    grpc_call(
        Members,
        "SetRole",
        pb.MemberSetRoleRequest(
            workspace_id=ws, user_id=str(team["users"]["ann"].pk), role_id=ids["Owner"]
        ),
        token=zoe,
    )
    grpc_call(Members, "Leave", pb.MemberLeaveRequest(workspace_id=ws), token=zoe)

    listed = grpc_call(Members, "List", pb.MemberListRequest(workspace_id=ws), token=ann)
    mine = grpc_call(
        Workspaces,
        "List",
        __import__("google.protobuf.empty_pb2", fromlist=["Empty"]).Empty(),
        token=ann,
    )
    assert [(m.role_name, m.is_owner) for m in listed.members if m.email == "ann@example.com"] == [
        ("Owner", True)
    ]
    assert mine.workspaces[0].is_owner is True


def test_cross_tenant_role_ids_are_not_found_over_grpc(team: Any, grpc_call: GrpcCall) -> None:
    other = _token("rival")
    rival_ws = grpc_call(
        Workspaces, "Create", pb.WorkspaceCreateRequest(name="B", slug="rival-b"), token=other
    )
    secret = grpc_call(
        Roles, "Create", pb.RoleCreateRequest(workspace_id=rival_ws.id, name="Secret"), token=other
    )

    stolen = _refused(
        grpc_call,
        Members,
        "SetRole",
        pb.MemberSetRoleRequest(
            workspace_id=team["ws"], user_id=str(team["users"]["vic"].pk), role_id=secret.id
        ),
        token=team["tokens"]["zoe"],
    )
    peeking = _refused(
        grpc_call,
        Roles,
        "List",
        pb.RoleListRequest(workspace_id=rival_ws.id),
        token=team["tokens"]["ann"],
    )

    assert stolen.code() is grpc.StatusCode.NOT_FOUND
    assert peeking.code() is grpc.StatusCode.PERMISSION_DENIED and peeking.details().startswith(
        "FORBIDDEN:"
    )


def test_permission_check_answers_for_the_caller(team: Any, grpc_call: GrpcCall) -> None:
    ws = team["ws"]

    viewer = grpc_call(
        Perms,
        "Check",
        pb.PermissionCheckRequest(workspace_id=ws, keys=["workspace.view", "role.manage", "bogus"]),
        token=team["tokens"]["vic"],
    )
    owner = grpc_call(
        Perms,
        "Check",
        pb.PermissionCheckRequest(workspace_id=ws, keys=sorted(ALL_KEYS)),
        token=team["tokens"]["zoe"],
    )
    outsider = _refused(
        grpc_call,
        Perms,
        "Check",
        pb.PermissionCheckRequest(workspace_id=ws, keys=["workspace.view"]),
        token=_token("eve"),
    )

    assert {a.key: a.allowed for a in viewer.answers} == {
        "workspace.view": True,
        "role.manage": False,
        "bogus": False,
    }
    assert viewer.role_name == "Viewer" and viewer.role_id
    assert all(a.allowed for a in owner.answers) and owner.role_name == "Owner"
    assert outsider.code() is grpc.StatusCode.PERMISSION_DENIED and outsider.details().startswith(
        "FORBIDDEN:"
    )


def test_stale_role_update_is_aborted_with_version_conflict(team: Any, grpc_call: GrpcCall) -> None:
    zoe, ws = team["tokens"]["zoe"], team["ws"]
    made = grpc_call(Roles, "Create", pb.RoleCreateRequest(workspace_id=ws, name="Doc"), token=zoe)
    update = pb.RoleUpdateRequest(workspace_id=ws, id=made.id, name="Doc 2", expected_version=1)
    grpc_call(Roles, "Update", update, token=zoe)

    stale = _refused(grpc_call, Roles, "Update", update, token=zoe)

    assert stale.code() is grpc.StatusCode.ABORTED
    assert stale.details().startswith("VERSION_CONFLICT:")
