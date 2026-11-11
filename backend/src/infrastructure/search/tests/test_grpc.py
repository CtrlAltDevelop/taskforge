"""The search controller over a real gRPC server: the contract."""

from typing import Any

import grpc

from infrastructure.search.grpc import search_pb2 as pb
from infrastructure.search.grpc import search_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused

team = base.team  # the fixture, registered here by name
S = stubs.SearchControllerStub


def _query(call: GrpcCall, team: dict[str, Any], text: str, who: str = "max", **kw: Any) -> Any:
    request = pb.SearchQueryRequest(workspace_id=team["ws"], text=text, **kw)
    return call(S, "Query", request, token=team["tokens"][who])


def test_a_task_comes_back_grouped_with_marks_and_a_jump(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team, who="zoe", title="Fix the login")

    found = _query(grpc_call, team, "login")
    [hit] = found.tasks

    assert (hit.id, hit.key, hit.kind) == (created.id, "WEB-1", "task")
    assert [(m.start, m.end) for m in hit.title_marks] == [(8, 13)]
    assert not found.comments and found.jump.id == ""
    assert _query(grpc_call, team, "web-1").jump.id == created.id


def test_recent_searches_round_trip(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]
    grpc_call(
        S, "Remember", pb.SearchRememberRequest(workspace_id=team["ws"], text="login"), token=token
    )

    found = grpc_call(S, "Recent", pb.SearchRecentRequest(workspace_id=team["ws"]), token=token)

    assert list(found.queries) == ["login"]


def test_bad_input_and_strangers_are_refused(team: Any, grpc_call: GrpcCall) -> None:
    assert (
        _refused(
            grpc_call,
            S,
            "Query",
            pb.SearchQueryRequest(workspace_id=team["ws"], text="x", types=["wiki"]),
            token=team["tokens"]["max"],
        ).code()
        == grpc.StatusCode.INVALID_ARGUMENT
    )
    assert (
        _refused(
            grpc_call,
            S,
            "Query",
            pb.SearchQueryRequest(workspace_id=team["ws"], text="x"),
            token=team["tokens"]["eve"],
        ).code()
        == grpc.StatusCode.PERMISSION_DENIED
    )
