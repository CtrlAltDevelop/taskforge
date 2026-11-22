"""Tokens, service accounts and webhooks over REST: ``/api/v1/tokens``,
``/api/v1/service-accounts`` and ``/api/v1/webhooks``.

All name the workspace with the ``X-Workspace`` header, need a signed-in person (an API token is
refused) and call the same services as the gRPC controllers the app uses.
"""

import json
from typing import Any

from django.http import HttpRequest
from ninja import Router, Schema

from infrastructure.auth.core.sessions import api_auth
from infrastructure.developer import service_accounts, services
from infrastructure.developer.models import ApiToken, Webhook, WebhookDelivery
from infrastructure.workspaces.scoping import workspace_from_request

tokens_router = Router()
accounts_router = Router()
webhooks_router = Router()


class TokenIn(Schema):
    name: str
    scopes: list[str]
    expires_in_days: int = 0


class TokenOut(Schema):
    id: str
    name: str
    prefix: str
    scopes: list[str]
    expires_at: str | None
    last_used_at: str | None
    revoked_at: str | None
    created_at: str


class TokenCreated(TokenOut):
    secret: str  # shown once


class AccountIn(Schema):
    name: str
    role_id: str


class AccountRolePatch(Schema):
    role_id: str


class AccountOut(Schema):
    id: str
    name: str
    user_id: str
    role_id: str
    role_name: str
    active: bool
    token_count: int
    created_at: str


class WebhookIn(Schema):
    url: str
    events: list[str]
    name: str = ""
    project_id: str = ""


class WebhookPatch(Schema):
    expected_version: int
    url: str | None = None
    events: list[str] | None = None
    name: str | None = None
    active: bool | None = None
    project_id: str | None = None


class WebhookOut(Schema):
    id: str
    name: str
    url: str
    secret: str
    events: list[str]
    project_id: str | None
    active: bool
    disabled_reason: str
    version: int


class DeliveryOut(Schema):
    id: str
    event: str
    event_id: str
    status: str
    status_code: int | None
    attempt: int
    error: str
    response_snippet: str
    payload: dict[str, Any]
    next_retry_at: str | None
    created_at: str
    at: str | None


class DeliveryPage(Schema):
    deliveries: list[DeliveryOut]
    cursor: str


def _iso(value: Any) -> str | None:
    return value.isoformat() if value else None


def _token(row: ApiToken) -> dict[str, Any]:
    return {
        "id": str(row.pk),
        "name": row.name,
        "prefix": row.prefix,
        "scopes": row.scopes,
        "expires_at": _iso(row.expires_at),
        "last_used_at": _iso(row.last_used_at),
        "revoked_at": _iso(row.revoked_at),
        "created_at": row.created_at.isoformat(),
    }


def _account(view: service_accounts.AccountView) -> dict[str, Any]:
    account = view.account
    return {
        "id": str(account.pk),
        "name": account.name,
        "user_id": str(account.user_id),
        "role_id": str(view.role.pk),
        "role_name": view.role.name,
        "active": view.active,
        "token_count": view.token_count,
        "created_at": account.created_at.isoformat(),
    }


def _hook(row: Webhook) -> WebhookOut:
    return WebhookOut(
        id=str(row.pk),
        name=row.name,
        url=row.url,
        secret=row.secret,
        events=row.events,
        project_id=str(row.project_id) if row.project_id else None,
        active=row.active,
        disabled_reason=row.disabled_reason,
        version=row.version,
    )


def _delivery(row: WebhookDelivery) -> DeliveryOut:
    return DeliveryOut(
        id=str(row.pk),
        event=row.event,
        event_id=row.event_id,
        status=row.status,
        status_code=row.status_code,
        attempt=row.attempt,
        error=row.error,
        response_snippet=row.response_snippet,
        payload=json.loads(json.dumps(row.payload)),
        next_retry_at=_iso(row.next_retry_at),
        created_at=row.created_at.isoformat(),
        at=_iso(row.at),
    )


@tokens_router.get("", response=list[TokenOut], auth=api_auth, summary="Your API tokens")
def list_tokens(request: HttpRequest) -> list[dict[str, Any]]:
    workspace = workspace_from_request(request)
    return [_token(t) for t in services.list_tokens(request.user, workspace)]


@tokens_router.post(
    "",
    response={201: TokenCreated},
    auth=api_auth,
    summary="Create an API token (the secret is in this answer only)",
)
def create_token(request: HttpRequest, payload: TokenIn) -> tuple[int, dict[str, Any]]:
    workspace = workspace_from_request(request)
    issued = services.create_token(
        request.user, workspace, payload.name, payload.scopes, payload.expires_in_days
    )
    return 201, {**_token(issued.token), "secret": issued.secret}


@tokens_router.delete("/{token_id}", response=TokenOut, auth=api_auth, summary="Revoke a token")
def revoke_token(request: HttpRequest, token_id: str) -> dict[str, Any]:
    workspace = workspace_from_request(request)
    return _token(services.revoke_token(request.user, workspace, token_id))


@accounts_router.get(
    "", response=list[AccountOut], auth=api_auth, summary="List the service accounts"
)
def list_accounts(request: HttpRequest) -> list[dict[str, Any]]:
    workspace = workspace_from_request(request)
    return [_account(v) for v in service_accounts.list_accounts(request.user, workspace)]


@accounts_router.post(
    "",
    response={201: AccountOut},
    auth=api_auth,
    summary="Create a service account (not an owner; a role you hold in full)",
)
def create_account(request: HttpRequest, payload: AccountIn) -> tuple[int, dict[str, Any]]:
    workspace = workspace_from_request(request)
    view = service_accounts.create_account(request.user, workspace, payload.name, payload.role_id)
    return 201, _account(view)


@accounts_router.patch(
    "/{account_id}", response=AccountOut, auth=api_auth, summary="Change its role"
)
def set_account_role(
    request: HttpRequest, account_id: str, payload: AccountRolePatch
) -> dict[str, Any]:
    workspace = workspace_from_request(request)
    view = service_accounts.set_role(request.user, workspace, account_id, payload.role_id)
    return _account(view)


@accounts_router.delete(
    "/{account_id}", response={204: None}, auth=api_auth, summary="Delete it and end its tokens"
)
def delete_account(request: HttpRequest, account_id: str) -> tuple[int, None]:
    workspace = workspace_from_request(request)
    service_accounts.delete_account(request.user, workspace, account_id)
    return 204, None


@accounts_router.get(
    "/{account_id}/tokens", response=list[TokenOut], auth=api_auth, summary="Its tokens"
)
def list_account_tokens(request: HttpRequest, account_id: str) -> list[dict[str, Any]]:
    workspace = workspace_from_request(request)
    return [_token(t) for t in service_accounts.list_tokens(request.user, workspace, account_id)]


@accounts_router.post(
    "/{account_id}/tokens",
    response={201: TokenCreated},
    auth=api_auth,
    summary="Create a token for it (the secret is in this answer only; revoke with DELETE /tokens)",
)
def create_account_token(
    request: HttpRequest, account_id: str, payload: TokenIn
) -> tuple[int, dict[str, Any]]:
    workspace = workspace_from_request(request)
    issued = service_accounts.create_token(
        request.user, workspace, account_id, payload.name, payload.scopes, payload.expires_in_days
    )
    return 201, {**_token(issued.token), "secret": issued.secret}


@webhooks_router.get("", response=list[WebhookOut], auth=api_auth, summary="List webhooks")
def list_webhooks(request: HttpRequest) -> list[WebhookOut]:
    workspace = workspace_from_request(request)
    return [_hook(h) for h in services.list_webhooks(request.user, workspace)]


@webhooks_router.post("", response={201: WebhookOut}, auth=api_auth, summary="Create a webhook")
def create_webhook(request: HttpRequest, payload: WebhookIn) -> tuple[int, WebhookOut]:
    workspace = workspace_from_request(request)
    hook = services.create_webhook(
        request.user,
        workspace,
        payload.url,
        payload.events,
        name=payload.name,
        project_id=payload.project_id,
    )
    return 201, _hook(hook)


@webhooks_router.patch(
    "/{webhook_id}", response=WebhookOut, auth=api_auth, summary="Change a webhook"
)
def update_webhook(request: HttpRequest, webhook_id: str, payload: WebhookPatch) -> WebhookOut:
    workspace = workspace_from_request(request)
    changes = payload.model_dump(exclude_unset=True, exclude={"expected_version"})
    hook = services.update_webhook(
        request.user, workspace, webhook_id, payload.expected_version, **changes
    )
    return _hook(hook)


@webhooks_router.delete("/{webhook_id}", response={204: None}, auth=api_auth, summary="Delete")
def delete_webhook(request: HttpRequest, webhook_id: str) -> tuple[int, None]:
    workspace = workspace_from_request(request)
    services.delete_webhook(request.user, workspace, webhook_id)
    return 204, None


@webhooks_router.get(
    "/{webhook_id}/deliveries", response=DeliveryPage, auth=api_auth, summary="Delivery log"
)
def list_deliveries(
    request: HttpRequest, webhook_id: str, before: str = "", limit: int = 50
) -> DeliveryPage:
    workspace = workspace_from_request(request)
    rows, cursor = services.list_deliveries(
        request.user, workspace, webhook_id, before=before, limit=limit
    )
    return DeliveryPage(deliveries=[_delivery(r) for r in rows], cursor=cursor)


@webhooks_router.post(
    "/{webhook_id}/deliveries/{delivery_id}/redeliver",
    response=DeliveryOut,
    auth=api_auth,
    summary="Send a delivery again",
)
def redeliver(request: HttpRequest, webhook_id: str, delivery_id: str) -> DeliveryOut:
    workspace = workspace_from_request(request)
    return _delivery(services.redeliver(request.user, workspace, webhook_id, delivery_id))


@webhooks_router.post(
    "/{webhook_id}/test", response=DeliveryOut, auth=api_auth, summary="Send a test ping now"
)
def send_test(request: HttpRequest, webhook_id: str) -> DeliveryOut:
    workspace = workspace_from_request(request)
    return _delivery(services.send_test(request.user, workspace, webhook_id))
