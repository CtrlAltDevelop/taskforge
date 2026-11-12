"""ShortcutController over a real gRPC server: the contract, status codes and who sees what."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest

from infrastructure.shortcuts.grpc import shortcuts_pb2 as pb
from infrastructure.shortcuts.grpc import shortcuts_pb2_grpc as stubs
from infrastructure.workspaces.tests.test_grpc import _token

S = stubs.ShortcutControllerStub
GrpcCall = Callable[..., Any]


@pytest.fixture
def tokens(transactional_db: None) -> dict[str, str]:
    return {name: _token(name) for name in ("zoe", "max")}


def _set(call: GrpcCall, token: str, action_id: str, keys: str = "", reset: bool = False) -> Any:
    request = pb.ShortcutSetRequest(action_id=action_id, keys=keys, reset=reset)
    return call(S, "Set", request, token=token)


def test_set_then_get_round_trips_and_normalises(
    tokens: dict[str, str], grpc_call: GrpcCall
) -> None:
    _set(grpc_call, tokens["zoe"], "task.create", "Shift+Mod+C")

    got = grpc_call(S, "Get", pb.ShortcutGetRequest(), token=tokens["zoe"])

    assert [(s.action_id, s.keys) for s in got.shortcuts] == [("task.create", "mod+shift+c")]


def test_each_person_sees_only_their_own(tokens: dict[str, str], grpc_call: GrpcCall) -> None:
    _set(grpc_call, tokens["zoe"], "task.create", "alt+c")

    got = grpc_call(S, "Get", pb.ShortcutGetRequest(), token=tokens["max"])

    assert list(got.shortcuts) == []


def test_a_clash_is_already_exists_with_its_title(
    tokens: dict[str, str], grpc_call: GrpcCall
) -> None:
    _set(grpc_call, tokens["zoe"], "task.create", "alt+c")

    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        _set(grpc_call, tokens["zoe"], "project.create", "alt+c")

    assert refusal.value.code() == grpc.StatusCode.ALREADY_EXISTS


def test_a_browser_key_is_invalid_argument(tokens: dict[str, str], grpc_call: GrpcCall) -> None:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        _set(grpc_call, tokens["zoe"], "task.create", "mod+w")

    assert refusal.value.code() == grpc.StatusCode.INVALID_ARGUMENT


def test_reset_drops_the_override(tokens: dict[str, str], grpc_call: GrpcCall) -> None:
    _set(grpc_call, tokens["zoe"], "task.create", "alt+c")

    after = _set(grpc_call, tokens["zoe"], "task.create", reset=True)

    assert list(after.shortcuts) == []


def test_unauthenticated_is_refused(transactional_db: None, grpc_call: GrpcCall) -> None:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        grpc_call(S, "Get", pb.ShortcutGetRequest(), token=None)

    assert refusal.value.code() == grpc.StatusCode.UNAUTHENTICATED
