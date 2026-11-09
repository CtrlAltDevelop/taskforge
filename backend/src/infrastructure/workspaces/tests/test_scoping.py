"""The scoping helper every later phase uses to find the caller's workspace."""

from typing import Any

import pytest
from django.test import RequestFactory

from infrastructure.common.errors import ApiError
from infrastructure.workspaces import services
from infrastructure.workspaces.scoping import require_workspace, workspace_from_request


def test_member_resolves_the_workspace(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")

    assert require_workspace(alice, str(workspace.id)) == workspace


@pytest.mark.parametrize("raw", [None, "", "garbage", "00000000-0000-0000-0000-000000000000"])
def test_missing_or_bogus_ids_are_forbidden(alice: Any, raw: str | None) -> None:
    with pytest.raises(ApiError) as refusal:
        require_workspace(alice, raw)

    assert refusal.value.status == 403


def test_cross_tenant_guess_is_forbidden_exactly_like_a_missing_id(alice: Any, bob: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    with pytest.raises(ApiError) as guessed:
        require_workspace(bob, str(workspace.id))
    with pytest.raises(ApiError) as missing:
        require_workspace(bob, "00000000-0000-0000-0000-000000000000")

    assert (guessed.value.status, str(guessed.value), guessed.value.title) == (
        missing.value.status,
        str(missing.value),
        missing.value.title,
    )


def test_deleted_workspace_is_forbidden_even_to_its_member(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    services.delete(alice, str(workspace.id), "Acme")

    with pytest.raises(ApiError) as refusal:
        require_workspace(alice, str(workspace.id))

    assert refusal.value.status == 403


def test_rest_header_is_read(alice: Any) -> None:
    workspace = services.create(alice, "Acme", "acme")
    request = RequestFactory().get("/", HTTP_X_WORKSPACE=str(workspace.id))
    request.user = alice

    assert workspace_from_request(request) == workspace


def test_rest_without_header_is_forbidden(alice: Any) -> None:
    request = RequestFactory().get("/")
    request.user = alice

    with pytest.raises(ApiError) as refusal:
        workspace_from_request(request)

    assert refusal.value.status == 403


def test_grpc_metadata_is_read(alice: Any) -> None:
    from types import SimpleNamespace

    from infrastructure.workspaces.scoping import _grpc_workspace

    workspace = services.create(alice, "Acme", "acme")
    context = SimpleNamespace(http_request=SimpleNamespace(META={"x-workspace": str(workspace.id)}))

    assert _grpc_workspace(context, alice) == workspace
    with pytest.raises(ApiError):
        _grpc_workspace(SimpleNamespace(http_request=SimpleNamespace(META={})), alice)


def test_anonymous_user_is_forbidden(alice: Any) -> None:
    from django.contrib.auth.models import AnonymousUser

    workspace = services.create(alice, "Acme", "acme")
    for user in (AnonymousUser(), None):
        with pytest.raises(ApiError) as refusal:
            require_workspace(user, str(workspace.id))
        assert refusal.value.status == 403
