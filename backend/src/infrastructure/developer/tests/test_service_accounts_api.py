"""Service accounts over REST and gRPC: the same rules as the service functions, end to end."""

import json
from typing import Any

from django.contrib.auth import get_user_model
from django.test import Client

from infrastructure.developer.grpc import developer_pb2 as pb
from infrastructure.developer.grpc import developer_pb2_grpc as stubs
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.access import builtin_role
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (
    _world,
    people,  # noqa: F401
)

PASSWORD = "corr3ct-horse-battery"


def _owner(db: None) -> tuple[Client, str, Any]:
    client = Client()
    reply = client.post(
        "/api/v1/auth/password/signup",
        {"identifier": "zoe", "password": PASSWORD, "email": "zoe@example.com"},
        content_type="application/json",
    )
    token = reply.json()["data"]["credentials"]["access_token"]
    user = get_user_model().objects.get(username="zoe")
    return client, token, workspace_services.create(user, "Acme", "acme")


def _call(client: Client, token: str, ws: Any, method: str, path: str, body: Any = None) -> Any:
    return getattr(client, method)(
        f"/api/v1{path}",
        data=json.dumps(body) if body is not None else None,
        content_type="application/json",
        HTTP_AUTHORIZATION=f"Bearer {token}",
        HTTP_X_WORKSPACE=str(ws.pk),
    )


def test_rest_make_an_account_and_a_token_then_revoke_it(db: None) -> None:
    client, token, ws = _owner(db)
    role = str(builtin_role("Member").pk)

    made = _call(client, token, ws, "post", "/service-accounts", {"name": "CI", "role_id": role})
    assert made.status_code == 201, made.content
    account = made.json()["data"]
    assert account["role_name"] == "Member" and account["active"]

    issued = _call(
        client,
        token,
        ws,
        "post",
        f"/service-accounts/{account['id']}/tokens",
        {"name": "deploy", "scopes": ["workspaces:read"]},
    )
    assert issued.status_code == 201
    secret = issued.json()["data"]["secret"]
    listed = _call(client, token, ws, "get", f"/service-accounts/{account['id']}/tokens")
    assert "secret" not in json.dumps(listed.json()["data"])

    as_bot = Client().get("/api/v1/workspaces", HTTP_AUTHORIZATION=f"Bearer {secret}")
    assert as_bot.status_code == 200
    assert [w["id"] for w in as_bot.json()["data"]] == [str(ws.pk)]

    token_id = issued.json()["data"]["id"]
    assert _call(client, token, ws, "delete", f"/tokens/{token_id}").status_code == 200
    assert (
        Client().get("/api/v1/workspaces", HTTP_AUTHORIZATION=f"Bearer {secret}").status_code == 401
    )

    assert (
        _call(client, token, ws, "delete", f"/service-accounts/{account['id']}").status_code == 204
    )
    assert _call(client, token, ws, "get", "/service-accounts").json()["data"] == []


def test_rest_a_service_token_cannot_manage_service_accounts(db: None) -> None:
    client, token, ws = _owner(db)
    role = str(builtin_role("Member").pk)
    account = _call(client, token, ws, "post", "/service-accounts", {"name": "CI", "role_id": role})
    secret = _call(
        client,
        token,
        ws,
        "post",
        f"/service-accounts/{account.json()['data']['id']}/tokens",
        {"name": "t", "scopes": ["workspaces:read"]},
    ).json()["data"]["secret"]

    refused = _call(Client(), secret, ws, "get", "/service-accounts")

    assert refused.status_code in (401, 403)


def test_grpc_token_rpcs_carry_the_service_account(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    token = world.tokens["Owner"]
    role_id = str(builtin_role("Member").pk)

    account = grpc_call(
        stubs.ServiceAccountControllerStub,
        "Create",
        pb.ServiceAccountCreateRequest(workspace_id=world.ws, name="bot", role_id=role_id),
        token=token,
    ).account
    created = grpc_call(
        stubs.ApiTokenControllerStub,
        "Create",
        pb.ApiTokenCreateRequest(
            workspace_id=world.ws,
            name="t",
            scopes=["tasks:read"],
            service_account_id=account.id,
        ),
        token=token,
    )
    mine = grpc_call(
        stubs.ApiTokenControllerStub,
        "List",
        pb.ApiTokenListRequest(workspace_id=world.ws),
        token=token,
    )
    theirs = grpc_call(
        stubs.ApiTokenControllerStub,
        "List",
        pb.ApiTokenListRequest(workspace_id=world.ws, service_account_id=account.id),
        token=token,
    )

    assert created.token.service_account_id == account.id and created.secret.startswith("tf_")
    assert list(mine.tokens) == []
    assert [t.id for t in theirs.tokens] == [created.token.id]
