"""Members and Invitations over a real gRPC server."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest

from infrastructure.auth.core import delivery
from infrastructure.workspaces.grpc import workspaces_pb2 as pb
from infrastructure.workspaces.grpc import workspaces_pb2_grpc as stubs

from .test_grpc import Stub as WorkspaceStub
from .test_grpc import _create, _token

Members = stubs.MemberControllerStub
Invites = stubs.InvitationControllerStub


@pytest.fixture
def zoe(transactional_db: None) -> str:
    return _token("zoe")


@pytest.fixture
def max_(transactional_db: None) -> str:
    return _token("max")


def _code(call: Callable[..., Any], *args: Any, **kwargs: Any) -> Any:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value.code()


def _emailed_tokens() -> list[str]:
    return [m.body.split("/invite/")[1].split()[0] for m in delivery.outbox]


def test_email_invite_accept_then_members_list(
    zoe: str, max_: str, grpc_call: Callable[..., Any]
) -> None:
    delivery.outbox.clear()
    ws = _create(grpc_call, zoe)
    made = grpc_call(
        Invites,
        "Create",
        pb.InvitationCreateRequest(workspace_id=ws.id, emails=["max@example.com"]),
        token=zoe,
    )

    joined = grpc_call(
        Invites, "Accept", pb.InvitationAcceptRequest(token=_emailed_tokens()[0]), token=max_
    )
    listed = grpc_call(Members, "List", pb.MemberListRequest(workspace_id=ws.id), token=zoe)

    assert made.invitations[0].token == "" and joined.id == ws.id
    assert [m.display_name for m in listed.members] == ["zoe", "max"]


def test_link_invite_flow_then_leave(zoe: str, max_: str, grpc_call: Callable[..., Any]) -> None:
    ws = _create(grpc_call, zoe)
    link = grpc_call(
        Invites, "CreateLink", pb.InvitationCreateLinkRequest(workspace_id=ws.id), token=zoe
    )
    pending = grpc_call(Invites, "List", pb.InvitationListRequest(workspace_id=ws.id), token=zoe)

    joined = grpc_call(Invites, "Accept", pb.InvitationAcceptRequest(token=link.token), token=max_)
    listed = grpc_call(Members, "List", pb.MemberListRequest(workspace_id=ws.id), token=max_)

    assert link.token and pending.invitations[0].token == "" and pending.invitations[0].is_link
    assert joined.id == ws.id and joined.is_owner is False
    assert [(m.display_name, m.is_owner) for m in listed.members] == [("zoe", True), ("max", False)]
    grpc_call(Members, "Leave", pb.MemberLeaveRequest(workspace_id=ws.id), token=max_)
    assert _code(
        grpc_call, Members, "List", pb.MemberListRequest(workspace_id=ws.id), token=max_
    ) is (grpc.StatusCode.PERMISSION_DENIED)


def test_email_invite_resend_revoke_and_errors(
    zoe: str, max_: str, grpc_call: Callable[..., Any]
) -> None:
    ws = _create(grpc_call, zoe)
    made = grpc_call(
        Invites,
        "Create",
        pb.InvitationCreateRequest(
            workspace_id=ws.id, emails=["other@example.com", "max@example.com"]
        ),
        token=zoe,
    )
    inv, matching = made.invitations
    again = grpc_call(
        Invites, "Resend", pb.InvitationResendRequest(workspace_id=ws.id, id=inv.id), token=zoe
    )
    accept = pb.InvitationAcceptRequest(token=_emailed_tokens()[-1])

    assert inv.token == "" and again.token == ""  # email tokens only travel by email
    assert _code(grpc_call, Invites, "Accept", accept, token=max_) is (
        grpc.StatusCode.PERMISSION_DENIED  # different address
    )
    grpc_call(
        Invites, "Revoke", pb.InvitationRevokeRequest(workspace_id=ws.id, id=inv.id), token=zoe
    )
    assert _code(grpc_call, Invites, "Accept", accept, token=max_) is grpc.StatusCode.NOT_FOUND
    grpc_call(Invites, "Decline", accept, token=max_)
    joined = grpc_call(
        Invites, "Accept", pb.InvitationAcceptRequest(token=_emailed_tokens()[1]), token=max_
    )
    assert matching.token == ""
    assert joined.id == ws.id  # unverified but matching address is accepted


def test_cross_tenant_and_owner_rules(zoe: str, max_: str, grpc_call: Callable[..., Any]) -> None:
    ws = _create(grpc_call, zoe)
    other = grpc_call(
        WorkspaceStub, "Create", pb.WorkspaceCreateRequest(name="B", slug="beta"), token=max_
    )
    link = grpc_call(
        Invites, "CreateLink", pb.InvitationCreateLinkRequest(workspace_id=other.id), token=max_
    )

    denied = grpc.StatusCode.PERMISSION_DENIED
    assert (
        _code(grpc_call, Members, "List", pb.MemberListRequest(workspace_id=other.id), token=zoe)
        is denied
    )
    assert (
        _code(
            grpc_call, Invites, "List", pb.InvitationListRequest(workspace_id=other.id), token=zoe
        )
        is denied
    )
    assert (
        _code(
            grpc_call,
            Invites,
            "Revoke",
            pb.InvitationRevokeRequest(workspace_id=ws.id, id=link.id),
            token=zoe,
        )
        is grpc.StatusCode.NOT_FOUND
    )
    assert (
        _code(grpc_call, Members, "Leave", pb.MemberLeaveRequest(workspace_id=ws.id), token=zoe)
        is denied
    )
    owner_id = (
        grpc_call(Members, "List", pb.MemberListRequest(workspace_id=ws.id), token=zoe)
        .members[0]
        .user_id
    )
    assert (
        _code(
            grpc_call,
            Members,
            "Remove",
            pb.MemberRemoveRequest(workspace_id=ws.id, user_id=owner_id),
            token=zoe,
        )
        is denied
    )
    assert _code(grpc_call, Members, "List", pb.MemberListRequest(workspace_id=ws.id)) is (
        grpc.StatusCode.UNAUTHENTICATED
    )


def test_owner_removes_member_and_quota_is_resource_exhausted(
    zoe: str, max_: str, grpc_call: Callable[..., Any], settings: Any
) -> None:
    ws = _create(grpc_call, zoe)
    link = grpc_call(
        Invites, "CreateLink", pb.InvitationCreateLinkRequest(workspace_id=ws.id), token=zoe
    )
    grpc_call(Invites, "Accept", pb.InvitationAcceptRequest(token=link.token), token=max_)
    member_id = [
        m
        for m in grpc_call(
            Members, "List", pb.MemberListRequest(workspace_id=ws.id), token=zoe
        ).members
        if not m.is_owner
    ][0].user_id

    grpc_call(
        Members, "Remove", pb.MemberRemoveRequest(workspace_id=ws.id, user_id=member_id), token=zoe
    )

    assert _code(
        grpc_call, Members, "List", pb.MemberListRequest(workspace_id=ws.id), token=max_
    ) is (grpc.StatusCode.PERMISSION_DENIED)
    settings.WORKSPACE_INVITES_PER_HOUR = 1
    assert _code(
        grpc_call,
        Invites,
        "CreateLink",
        pb.InvitationCreateLinkRequest(workspace_id=ws.id),
        token=zoe,
    ) is (grpc.StatusCode.RESOURCE_EXHAUSTED)
