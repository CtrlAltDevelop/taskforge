"""ChatController over a real gRPC server: the contract. Rules are tested on the services."""

import json
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.chat.grpc import chat_pb2 as pb
from infrastructure.chat.grpc import chat_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _refused
from infrastructure.workspaces.tests.test_grpc import _token

C = stubs.ChatControllerStub
MISSING = "3c4bd4f0-0000-4000-8000-000000000000"


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    """zoe owner, max member, vic guest, eve elsewhere, and ann: a member outside the groups."""
    out = base.team.__wrapped__(transactional_db, add_member)  # type: ignore[attr-defined]
    ann_token = _token("ann")
    ann = get_user_model().objects.get(username="ann")
    from infrastructure.workspaces.models import Workspace

    add_member(Workspace.objects.get(pk=out["ws"]), ann, "Member")
    out["tokens"]["ann"] = ann_token
    out["users"]["ann"] = ann
    return out


def doc(text: str) -> str:
    para = {"type": "paragraph", "content": [{"type": "text", "text": text}]}
    return json.dumps({"type": "doc", "content": [para]})


def call(grpc_call: GrpcCall, team: dict[str, Any], who: str, rpc: str, request: Any) -> Any:
    return grpc_call(C, rpc, request, token=team["tokens"][who])


def test_spaces_round_trip(team: Any, grpc_call: GrpcCall) -> None:
    ws = team["ws"]
    max_id = str(team["users"]["max"].pk)

    made = call(
        grpc_call,
        team,
        "zoe",
        "CreateSpace",
        pb.ChatCreateSpaceRequest(workspace_id=ws, kind="group", name="Plans", member_ids=[max_id]),
    )
    listed = call(grpc_call, team, "max", "ListSpaces", pb.ChatListSpacesRequest(workspace_id=ws))
    dm = call(
        grpc_call,
        team,
        "max",
        "OpenDm",
        pb.ChatOpenDmRequest(workspace_id=ws, user_id=str(team["users"]["zoe"].pk)),
    )

    assert (made.kind, made.name, made.role, made.member_count) == ("group", "Plans", "owner", 2)
    assert [g.id for g in listed.groups] == [made.id]
    assert [c.name for c in listed.channels] == ["general", "Web"]
    assert dm.kind == "dm" and dm.peer_id == str(team["users"]["zoe"].pk)
    assert [
        d.id
        for d in call(
            grpc_call, team, "zoe", "ListSpaces", pb.ChatListSpacesRequest(workspace_id=ws)
        ).dms
    ] == [dm.id]


def test_messages_round_trip_edit_react_read_mute_delete(team: Any, grpc_call: GrpcCall) -> None:
    ws = team["ws"]
    general = call(
        grpc_call, team, "max", "ListSpaces", pb.ChatListSpacesRequest(workspace_id=ws)
    ).channels[0]
    sid = general.id

    sent = call(
        grpc_call,
        team,
        "max",
        "Send",
        pb.ChatSendRequest(workspace_id=ws, space_id=sid, body=doc("hi")),
    )
    reply = call(
        grpc_call,
        team,
        "zoe",
        "Send",
        pb.ChatSendRequest(workspace_id=ws, space_id=sid, body=doc("yo"), parent_id=sent.id),
    )
    edited = call(
        grpc_call,
        team,
        "max",
        "Edit",
        pb.ChatEditRequest(
            workspace_id=ws, space_id=sid, id=sent.id, expected_version=1, body=doc("hello")
        ),
    )
    reacted = call(
        grpc_call,
        team,
        "zoe",
        "React",
        pb.ChatReactRequest(workspace_id=ws, space_id=sid, id=sent.id, emoji="👍", on=True),
    )
    page = call(
        grpc_call,
        team,
        "zoe",
        "ListMessages",
        pb.ChatListMessagesRequest(workspace_id=ws, space_id=sid),
    )
    thread = call(
        grpc_call,
        team,
        "zoe",
        "ListMessages",
        pb.ChatListMessagesRequest(workspace_id=ws, space_id=sid, thread_id=sent.id),
    )
    read = call(
        grpc_call,
        team,
        "zoe",
        "MarkRead",
        pb.ChatMarkReadRequest(workspace_id=ws, space_id=sid, message_id=reply.id),
    )
    muted = call(
        grpc_call,
        team,
        "zoe",
        "Mute",
        pb.ChatMuteRequest(workspace_id=ws, space_id=sid, forever=True, completely=True),
    )
    notified = call(
        grpc_call,
        team,
        "zoe",
        "Notify",
        pb.ChatNotifyRequest(workspace_id=ws, space_id=sid, all_messages=True),
    )
    people = call(
        grpc_call,
        team,
        "zoe",
        "Mentionable",
        pb.ChatMentionableRequest(workspace_id=ws, space_id=sid, query="max"),
    )
    gone = call(
        grpc_call,
        team,
        "max",
        "Delete",
        pb.ChatDeleteRequest(workspace_id=ws, space_id=sid, id=sent.id),
    )

    assert (sent.author_name, sent.version, reply.parent_id) == ("max", 1, sent.id)
    assert (edited.version, json.loads(edited.body)["content"][0]["content"][0]["text"]) == (
        2,
        "hello",
    )
    assert [(r.emoji, list(r.user_ids)) for r in reacted.reactions] == [
        ("👍", [str(team["users"]["zoe"].pk)])
    ]
    assert [m.id for m in page.messages] == [sent.id, reply.id] and page.cursor == ""
    assert [m.id for m in thread.messages] == [sent.id, reply.id]
    assert read.unread_count == 0 and read.last_read_at
    assert muted.muted_completely and muted.muted_until and notified.notify_all
    assert [p.display_name for p in people.people] == ["max"] and people.member_count >= 3
    assert gone.deleted and gone.body == ""


def test_join_leave_add_remove_update(team: Any, grpc_call: GrpcCall) -> None:
    ws = team["ws"]
    made = call(
        grpc_call,
        team,
        "zoe",
        "CreateSpace",
        pb.ChatCreateSpaceRequest(workspace_id=ws, kind="channel", name="random"),
    )
    joined = call(
        grpc_call, team, "max", "Join", pb.ChatJoinRequest(workspace_id=ws, space_id=made.id)
    )
    renamed = call(
        grpc_call,
        team,
        "zoe",
        "UpdateSpace",
        pb.ChatUpdateSpaceRequest(workspace_id=ws, space_id=made.id, name="chatter"),
    )
    call(grpc_call, team, "max", "Leave", pb.ChatLeaveRequest(workspace_id=ws, space_id=made.id))
    group = call(
        grpc_call,
        team,
        "zoe",
        "CreateSpace",
        pb.ChatCreateSpaceRequest(
            workspace_id=ws, kind="group", name="g", member_ids=[str(team["users"]["max"].pk)]
        ),
    )
    added = call(
        grpc_call,
        team,
        "zoe",
        "AddMembers",
        pb.ChatAddMembersRequest(
            workspace_id=ws, space_id=group.id, user_ids=[str(team["users"]["ann"].pk)]
        ),
    )
    done = call(
        grpc_call,
        team,
        "zoe",
        "RemoveMember",
        pb.ChatRemoveMemberRequest(
            workspace_id=ws, space_id=group.id, user_id=str(team["users"]["ann"].pk)
        ),
    )
    archived = call(
        grpc_call,
        team,
        "zoe",
        "UpdateSpace",
        pb.ChatUpdateSpaceRequest(
            workspace_id=ws, space_id=made.id, set_archived=True, archived=True
        ),
    )

    assert joined.joined and renamed.name == "chatter" and renamed.version == 2
    assert added.member_count == 3 and done.ok and archived.archived and archived.read_only


def test_a_stranger_sees_a_private_group_nowhere_over_the_wire(
    team: Any, grpc_call: GrpcCall
) -> None:
    ws = team["ws"]
    group = call(
        grpc_call,
        team,
        "zoe",
        "CreateSpace",
        pb.ChatCreateSpaceRequest(
            workspace_id=ws, kind="group", name="g", member_ids=[str(team["users"]["max"].pk)]
        ),
    )
    sent = call(
        grpc_call,
        team,
        "zoe",
        "Send",
        pb.ChatSendRequest(workspace_id=ws, space_id=group.id, body=doc("secret")),
    )
    s = {"workspace_id": ws, "space_id": group.id}
    requests = {
        "Join": pb.ChatJoinRequest(**s),
        "Leave": pb.ChatLeaveRequest(**s),
        "UpdateSpace": pb.ChatUpdateSpaceRequest(**s, name="x"),
        "AddMembers": pb.ChatAddMembersRequest(**s, user_ids=[str(team["users"]["ann"].pk)]),
        "RemoveMember": pb.ChatRemoveMemberRequest(**s, user_id=str(team["users"]["max"].pk)),
        "ListMessages": pb.ChatListMessagesRequest(**s),
        "Send": pb.ChatSendRequest(**s, body=doc("x")),
        "Edit": pb.ChatEditRequest(**s, id=sent.id, expected_version=1, body=doc("x")),
        "Delete": pb.ChatDeleteRequest(**s, id=sent.id),
        "React": pb.ChatReactRequest(**s, id=sent.id, emoji="👍", on=True),
        "MarkRead": pb.ChatMarkReadRequest(**s),
        "Mute": pb.ChatMuteRequest(**s, forever=True),
        "Notify": pb.ChatNotifyRequest(**s, all_messages=True),
        "Mentionable": pb.ChatMentionableRequest(**s),
    }

    for rpc, request in requests.items():
        refused = _refused(grpc_call, C, rpc, request, token=team["tokens"]["ann"])
        assert refused.code() == grpc.StatusCode.NOT_FOUND, rpc
        guest = _refused(grpc_call, C, rpc, request, token=team["tokens"]["vic"])
        assert guest.code() == grpc.StatusCode.PERMISSION_DENIED, rpc
        elsewhere = _refused(grpc_call, C, rpc, request, token=team["tokens"]["eve"])
        assert elsewhere.code() == grpc.StatusCode.PERMISSION_DENIED, rpc
    seen = call(grpc_call, team, "ann", "ListSpaces", pb.ChatListSpacesRequest(workspace_id=ws))
    assert list(seen.groups) == [] and list(seen.dms) == []
    for who in ("vic", "eve"):
        assert (
            _refused(
                grpc_call,
                C,
                "ListSpaces",
                pb.ChatListSpacesRequest(workspace_id=ws),
                token=team["tokens"][who],
            ).code()
            == grpc.StatusCode.PERMISSION_DENIED
        )
    dm = call(
        grpc_call,
        team,
        "zoe",
        "OpenDm",
        pb.ChatOpenDmRequest(workspace_id=ws, user_id=str(team["users"]["max"].pk)),
    )
    assert (
        _refused(
            grpc_call,
            C,
            "ListMessages",
            pb.ChatListMessagesRequest(workspace_id=ws, space_id=dm.id),
            token=team["tokens"]["ann"],
        ).code()
        == grpc.StatusCode.NOT_FOUND
    )


def test_titles_and_codes_travel(team: Any, grpc_call: GrpcCall) -> None:
    ws = team["ws"]
    general = call(
        grpc_call, team, "max", "ListSpaces", pb.ChatListSpacesRequest(workspace_id=ws)
    ).channels[0]
    send = pb.ChatSendRequest(workspace_id=ws, space_id=general.id, body=doc("x"))

    first = call(grpc_call, team, "max", "Send", send)
    stale = _refused(
        grpc_call,
        C,
        "Edit",
        pb.ChatEditRequest(
            workspace_id=ws, space_id=general.id, id=first.id, expected_version=9, body=doc("y")
        ),
        token=team["tokens"]["max"],
    )
    bad = _refused(
        grpc_call,
        C,
        "Send",
        pb.ChatSendRequest(workspace_id=ws, space_id=general.id, body="not json"),
        token=team["tokens"]["max"],
    )
    again = call(
        grpc_call,
        team,
        "max",
        "Send",
        pb.ChatSendRequest(workspace_id=ws, space_id=general.id, body=doc("x"), client_id=MISSING),
    )
    same = call(
        grpc_call,
        team,
        "max",
        "Send",
        pb.ChatSendRequest(workspace_id=ws, space_id=general.id, body=doc("x"), client_id=MISSING),
    )

    assert stale.code() == grpc.StatusCode.ABORTED
    assert bad.code() == grpc.StatusCode.INVALID_ARGUMENT and "COMMENT_INVALID" in bad.details()
    assert again.id == same.id == MISSING
    unauth = _refused(grpc_call, C, "ListSpaces", pb.ChatListSpacesRequest(workspace_id=ws))
    assert unauth.code() == grpc.StatusCode.UNAUTHENTICATED
