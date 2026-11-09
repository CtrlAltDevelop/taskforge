"""``RotationTokenRpcController/Sessions`` through the real gRPC server."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.test import Client
from google.protobuf.empty_pb2 import Empty

from infrastructure.oauth.rotation.grpc import oauth_rotation_pb2_grpc
from infrastructure.oauth.rotation.tests.test_api import _login

Stub = oauth_rotation_pb2_grpc.RotationTokenRpcControllerStub


def test_sessions_lists_the_callers_session(
    transactional_db: None, grpc_call: Callable[..., Any]
) -> None:
    credentials = _login(Client())

    reply = grpc_call(Stub, "Sessions", Empty(), token=credentials["access_token"])

    assert reply.mode == "rotation"
    assert [s.session_id for s in reply.sessions] == [credentials["session_id"]]


def test_sessions_refuses_a_call_without_a_credential(
    transactional_db: None, grpc_call: Callable[..., Any]
) -> None:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        grpc_call(Stub, "Sessions", Empty())

    assert refusal.value.code() is grpc.StatusCode.UNAUTHENTICATED
