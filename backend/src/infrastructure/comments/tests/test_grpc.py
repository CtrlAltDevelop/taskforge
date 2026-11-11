"""CommentController over a real gRPC server: the contract. Rules are tested on the services."""

import json
from typing import Any

import grpc

from infrastructure.comments.grpc import comments_pb2 as pb
from infrastructure.comments.grpc import comments_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused

C = stubs.CommentControllerStub
team = base.team  # the fixture, registered here by name


def _doc(*parts: Any) -> str:
    nodes = [{"type": "text", "text": p} if isinstance(p, str) else p for p in parts]
    return json.dumps({"type": "doc", "content": [{"type": "paragraph", "content": nodes}]})


def _post(
    call: GrpcCall, team: dict[str, Any], task: Any, text: str = "hi", who: str = "max", **kw: Any
) -> Any:
    request = pb.CommentCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], task_id=task.id, body=_doc(text), **kw
    )
    return call(C, "Create", request, token=team["tokens"][who])


def _one(team: dict[str, Any], comment: Any, **kw: Any) -> dict[str, Any]:
    return {"workspace_id": team["ws"], "project_id": team["project"], "id": comment.id, **kw}


def test_a_comment_round_trips_over_the_wire(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, title="T")

    made = _post(grpc_call, team, task, "Looks good")
    page = grpc_call(
        C,
        "List",
        pb.CommentListRequest(workspace_id=team["ws"], project_id=team["project"], task_id=task.id),
        token=team["tokens"]["vic"],
    )

    [got] = page.comments
    assert (got.id, got.author_id, got.version, got.deleted, got.pinned) == (
        made.id,
        str(team["users"]["max"].pk),
        1,
        False,
        False,
    )
    assert json.loads(got.body)["content"][0]["content"][0]["text"] == "Looks good"
    assert page.cursor == "" and got.created_at and got.edited_at == ""


def test_edit_react_pin_history_and_delete(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, title="T")
    made = _post(grpc_call, team, task, "one")
    max_token, zoe_token = team["tokens"]["max"], team["tokens"]["zoe"]

    edited = grpc_call(
        C,
        "Edit",
        pb.CommentEditRequest(**_one(team, made, expected_version=1, body=_doc("two"))),
        token=max_token,
    )
    reacted = grpc_call(
        C, "React", pb.CommentReactRequest(**_one(team, made, emoji="👍", on=True)), token=zoe_token
    )
    pinned = grpc_call(
        C, "Pin", pb.CommentPinRequest(**_one(team, made, pinned=True)), token=zoe_token
    )
    history = grpc_call(
        C, "History", pb.CommentHistoryRequest(**_one(team, made)), token=team["tokens"]["vic"]
    )
    removed = grpc_call(C, "Delete", pb.CommentDeleteRequest(**_one(team, made)), token=max_token)

    assert (edited.version, edited.edit_count) == (2, 1) and edited.edited_at
    assert [(r.emoji, list(r.user_ids)) for r in reacted.reactions] == [
        ("👍", [str(team["users"]["zoe"].pk)])
    ]
    assert pinned.pinned is True
    assert [r.current for r in history.revisions] == [False, True]
    assert removed.deleted is True and removed.body == ""


def test_the_picker_lists_people_who_can_see_the_task(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, title="T")

    got = grpc_call(
        C,
        "Mentionable",
        pb.CommentMentionableRequest(
            workspace_id=team["ws"], project_id=team["project"], task_id=task.id, query="ma"
        ),
        token=team["tokens"]["vic"],
    )

    assert [p.user_id for p in got.people] == [str(team["users"]["max"].pk)]


def test_a_comment_becomes_a_subtask(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, title="T")
    made = _post(grpc_call, team, task, "Do the thing")

    got = grpc_call(
        C, "ToSubtask", pb.CommentToSubtaskRequest(**_one(team, made)), token=team["tokens"]["max"]
    )

    assert got.task_id


def test_refusals_carry_the_right_status_codes(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, title="T")
    made = _post(grpc_call, team, task)
    blank = pb.CommentCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], task_id=task.id, body=_doc("  ")
    )
    stale = pb.CommentEditRequest(**_one(team, made, expected_version=9, body=_doc("x")))

    assert _refused(grpc_call, C, "Create", blank, token=team["tokens"]["max"]).code() is (
        grpc.StatusCode.INVALID_ARGUMENT
    )
    assert (
        _refused(grpc_call, C, "Edit", stale, token=team["tokens"]["max"]).code()
        is grpc.StatusCode.ABORTED
    )
    viewer_post = pb.CommentCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], task_id=task.id, body=_doc("hi")
    )
    assert _refused(grpc_call, C, "Create", viewer_post, token=team["tokens"]["vic"]).code() is (
        grpc.StatusCode.PERMISSION_DENIED
    )
    elsewhere = pb.CommentListRequest(
        workspace_id=team["ws"], project_id=team["project"], task_id=task.id
    )
    assert _refused(grpc_call, C, "List", elsewhere, token=team["tokens"]["eve"]).code() is (
        grpc.StatusCode.PERMISSION_DENIED
    )


def test_a_mention_of_somebody_who_cannot_see_the_task_names_them(
    team: Any, grpc_call: GrpcCall
) -> None:
    task = _create(grpc_call, team, title="T")
    eve = team["users"]["eve"]  # not in this workspace
    body = _doc("hey ", {"type": "mention", "attrs": {"id": str(eve.pk), "label": "Eve"}})

    refusal = _refused(
        grpc_call,
        C,
        "Create",
        pb.CommentCreateRequest(
            workspace_id=team["ws"], project_id=team["project"], task_id=task.id, body=body
        ),
        token=team["tokens"]["max"],
    )

    assert refusal.code() is grpc.StatusCode.INVALID_ARGUMENT
    assert "MENTION_NO_ACCESS" in (refusal.details() or "")
    trailers = {k: v for k, v in refusal.trailing_metadata() or ()}
    assert trailers["x-error-users-bin"] == str(eve.pk).encode()
