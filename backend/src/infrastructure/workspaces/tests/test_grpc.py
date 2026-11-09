"""The Workspaces service over a real gRPC server."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.test import Client
from google.protobuf.empty_pb2 import Empty

from infrastructure.workspaces.grpc import workspaces_pb2 as pb
from infrastructure.workspaces.grpc import workspaces_pb2_grpc

Stub = workspaces_pb2_grpc.WorkspaceControllerStub
PASSWORD = "corr3ct-horse-battery"


def _token(username: str) -> str:
    response = Client().post(
        "/api/v1/auth/password/signup",
        {"identifier": username, "password": PASSWORD, "email": f"{username}@example.com"},
        content_type="application/json",
    )
    assert response.status_code == 200, response.content
    token: str = response.json()["data"]["credentials"]["access_token"]
    return token


@pytest.fixture
def zoe(transactional_db: None) -> str:
    return _token("zoe")


@pytest.fixture
def max_(transactional_db: None) -> str:
    return _token("max")


def _create(call: Callable[..., Any], token: str, name: str = "Acme", slug: str = "acme") -> Any:
    return call(Stub, "Create", pb.WorkspaceCreateRequest(name=name, slug=slug), token=token)


def test_create_then_list(zoe: str, grpc_call: Callable[..., Any]) -> None:
    created = _create(grpc_call, zoe)
    listed = grpc_call(Stub, "List", Empty(), token=zoe)

    assert (created.name, created.slug, created.version) == ("Acme", "acme", 1)
    assert [w.id for w in listed.workspaces] == [created.id]
    assert listed.workspaces[0].is_owner is True


def test_unauthenticated_is_refused(transactional_db: None, grpc_call: Callable[..., Any]) -> None:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        grpc_call(Stub, "List", Empty())

    assert refusal.value.code() is grpc.StatusCode.UNAUTHENTICATED


def test_duplicate_slug_is_already_exists(
    zoe: str, max_: str, grpc_call: Callable[..., Any]
) -> None:
    _create(grpc_call, zoe)

    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        _create(grpc_call, max_, "Other", "acme")

    assert refusal.value.code() is grpc.StatusCode.ALREADY_EXISTS


def test_update_changes_only_what_was_sent(zoe: str, grpc_call: Callable[..., Any]) -> None:
    created = _create(grpc_call, zoe)

    updated = grpc_call(
        Stub,
        "Update",
        pb.WorkspaceUpdateRequest(id=created.id, expected_version=1, name="Acme Inc"),
        token=zoe,
    )

    assert (updated.name, updated.slug, updated.version) == ("Acme Inc", "acme", 2)


def test_stale_update_is_aborted(zoe: str, grpc_call: Callable[..., Any]) -> None:
    created = _create(grpc_call, zoe)
    request = pb.WorkspaceUpdateRequest(id=created.id, expected_version=1, name="One")
    grpc_call(Stub, "Update", request, token=zoe)

    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        grpc_call(Stub, "Update", request, token=zoe)

    assert refusal.value.code() is grpc.StatusCode.ABORTED


def test_cross_tenant_update_delete_restore_are_permission_denied(
    zoe: str, max_: str, grpc_call: Callable[..., Any]
) -> None:
    created = _create(grpc_call, zoe)
    attempts = [
        ("Update", pb.WorkspaceUpdateRequest(id=created.id, expected_version=1, name="Hax")),
        ("Delete", pb.WorkspaceDeleteRequest(id=created.id, confirmation="Acme")),
        ("Restore", pb.WorkspaceRestoreRequest(id=created.id)),
    ]
    for method, request in attempts:
        with pytest.raises(grpc.aio.AioRpcError) as refusal:
            grpc_call(Stub, method, request, token=max_)
        assert refusal.value.code() is grpc.StatusCode.PERMISSION_DENIED, method
    assert list(grpc_call(Stub, "List", Empty(), token=max_).workspaces) == []


def test_delete_then_restore(zoe: str, grpc_call: Callable[..., Any]) -> None:
    created = _create(grpc_call, zoe)

    deleted = grpc_call(
        Stub, "Delete", pb.WorkspaceDeleteRequest(id=created.id, confirmation="Acme"), token=zoe
    )
    assert deleted.deleted_at != ""
    assert list(grpc_call(Stub, "List", Empty(), token=zoe).workspaces) == []

    restored = grpc_call(Stub, "Restore", pb.WorkspaceRestoreRequest(id=created.id), token=zoe)
    assert restored.deleted_at == ""
    assert len(grpc_call(Stub, "List", Empty(), token=zoe).workspaces) == 1


def test_delete_with_wrong_confirmation_is_invalid(zoe: str, grpc_call: Callable[..., Any]) -> None:
    created = _create(grpc_call, zoe)

    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        grpc_call(
            Stub, "Delete", pb.WorkspaceDeleteRequest(id=created.id, confirmation="nope"), token=zoe
        )

    assert refusal.value.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_list_deleted_then_restore(zoe: str, max_: str, grpc_call: Callable[..., Any]) -> None:
    created = _create(grpc_call, zoe)
    grpc_call(
        Stub, "Delete", pb.WorkspaceDeleteRequest(id=created.id, confirmation="Acme"), token=zoe
    )

    mine = grpc_call(Stub, "ListDeleted", Empty(), token=zoe)
    others = grpc_call(Stub, "ListDeleted", Empty(), token=max_)
    grpc_call(Stub, "Restore", pb.WorkspaceRestoreRequest(id=created.id), token=zoe)
    after = grpc_call(Stub, "ListDeleted", Empty(), token=zoe)

    assert [w.id for w in mine.workspaces] == [created.id]
    assert list(others.workspaces) == [] and list(after.workspaces) == []
