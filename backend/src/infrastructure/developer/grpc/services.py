"""API tokens and webhooks over gRPC: ``ApiTokenController`` and ``WebhookController``. The rules
are in ``infrastructure.developer.services``.

A token's secret is returned once, by ``ApiToken.Create`` (``secret``); lists carry the prefix
only. ``Webhook.Update`` names what it changes in ``fields`` (name, url, events, active, project)
and carries ``expected_version`` (a stale one is ABORTED). ``Webhook.Deliveries`` pages newest
first (``before`` is the returned ``cursor``); ``Redeliver`` sends a delivery again; ``Test``
sends a ping now. PERMISSION_DENIED without ``webhook.manage``, and for any caller that is an API
token: tokens and webhooks are managed by people.
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.developer import events, scopes, services
from infrastructure.developer.grpc.serializers import ApiToken, CatalogItem, Delivery, Webhook
from infrastructure.developer.models import WebhookDelivery
from infrastructure.workspaces.scoping import require_workspace

WS = [{"name": "workspace_id", "type": "string"}]
HOOK = [*WS, {"name": "webhook_id", "type": "string"}]
HOOK_ANSWER = [{"name": "webhook", "type": Webhook}]
DELIVERY_ANSWER = [{"name": "delivery", "type": Delivery}]
EDITABLE = {"name", "url", "events", "active", "project"}


def _pb() -> Any:
    from infrastructure.developer.grpc import developer_pb2

    return developer_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def token_message(token: Any) -> Any:
    status = "revoked" if token.revoked_at else ("active" if token.is_active else "expired")
    return _pb().ApiToken(
        id=str(token.pk),
        name=token.name,
        prefix=token.prefix,
        scopes=token.scopes,
        status=status,
        expires_at=_iso(token.expires_at),
        last_used_at=_iso(token.last_used_at),
        revoked_at=_iso(token.revoked_at),
        created_at=_iso(token.created_at),
    )


def webhook_message(hook: Any) -> Any:
    last = (
        WebhookDelivery.objects.filter(webhook=hook)
        .order_by("-created_at")
        .only("status", "at")
        .first()
    )
    return _pb().Webhook(
        id=str(hook.pk),
        workspace_id=str(hook.workspace_id),
        project_id=str(hook.project_id or ""),
        name=hook.name,
        url=hook.url,
        secret=hook.secret,
        events=hook.events,
        active=hook.active,
        disabled_reason=hook.disabled_reason,
        version=hook.version,
        created_at=_iso(hook.created_at),
        last_status=last.status if last else "",
        last_at=_iso(last.at) if last else "",
    )


def delivery_message(row: Any) -> Any:
    return _pb().Delivery(
        id=str(row.pk),
        webhook_id=str(row.webhook_id),
        event=row.event,
        event_id=row.event_id,
        status=row.status,
        status_code=row.status_code or 0,
        attempt=row.attempt,
        error=row.error,
        response_snippet=row.response_snippet,
        payload_json=json.dumps(row.payload, indent=2, sort_keys=True),
        request_headers_json=json.dumps(row.request_headers, indent=2, sort_keys=True),
        next_retry_at=_iso(row.next_retry_at),
        created_at=_iso(row.created_at),
        at=_iso(row.at),
        duration_ms=row.duration_ms,
        resend_of=str(row.resend_of_id or ""),
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


def _hook_answer(hook: Any) -> Any:
    return _pb().WebhookAnswer(webhook=webhook_message(hook))


class ApiTokenService(generics.GenericService):
    @grpc_action(
        request=WS,
        request_name="ApiTokenListRequest",
        response=[{"name": "tokens", "cardinality": "repeated", "type": ApiToken}],
        response_name="ApiTokenList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_tokens(user, workspace)
            return _pb().ApiTokenList(tokens=[token_message(t) for t in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *WS,
            {"name": "name", "type": "string"},
            {"name": "scopes", "cardinality": "repeated", "type": "string"},
            {"name": "expires_in_days", "type": "int32"},
        ],
        request_name="ApiTokenCreateRequest",
        response=[
            {"name": "token", "type": ApiToken},
            {"name": "secret", "type": "string"},
        ],
        response_name="ApiTokenCreated",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            issued = services.create_token(
                user, workspace, request.name, list(request.scopes), request.expires_in_days
            )
            return _pb().ApiTokenCreated(token=token_message(issued.token), secret=issued.secret)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*WS, {"name": "token_id", "type": "string"}],
        request_name="ApiTokenRevokeRequest",
        response=[{"name": "token", "type": ApiToken}],
        response_name="ApiTokenAnswer",
    )
    @action
    async def Revoke(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            token = services.revoke_token(user, workspace, request.token_id)
            return _pb().ApiTokenAnswer(token=token_message(token))

        return await sync_to_async(run)()

    @grpc_action(
        request=WS,
        request_name="CatalogRequest",
        response=[
            {"name": "scopes", "cardinality": "repeated", "type": CatalogItem},
            {"name": "events", "cardinality": "repeated", "type": CatalogItem},
        ],
        response_name="CatalogAnswer",
    )
    @action
    async def Catalog(self, request: Any, context: Any) -> Any:
        await _scope(request, context)
        pb = _pb()
        return pb.CatalogAnswer(
            scopes=[pb.CatalogItem(key=s, label=scopes.SCOPE_LABELS[s]) for s in scopes.SCOPES],
            events=[pb.CatalogItem(key=e.key, label=e.label) for e in events.CATALOG],
        )


class WebhookService(generics.GenericService):
    @grpc_action(
        request=WS,
        request_name="WebhookListRequest",
        response=[{"name": "webhooks", "cardinality": "repeated", "type": Webhook}],
        response_name="WebhookList",
    )
    @action
    async def List(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows = services.list_webhooks(user, workspace)
            return _pb().WebhookList(webhooks=[webhook_message(h) for h in rows])

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *WS,
            {"name": "name", "type": "string"},
            {"name": "url", "type": "string"},
            {"name": "events", "cardinality": "repeated", "type": "string"},
            {"name": "project_id", "type": "string"},
        ],
        request_name="WebhookCreateRequest",
        response=HOOK_ANSWER,
        response_name="WebhookAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            hook = services.create_webhook(
                user,
                workspace,
                request.url,
                list(request.events),
                name=request.name,
                project_id=request.project_id,
            )
            return _hook_answer(hook)

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *HOOK,
            {"name": "fields", "cardinality": "repeated", "type": "string"},
            {"name": "expected_version", "type": "int32"},
            {"name": "name", "type": "string"},
            {"name": "url", "type": "string"},
            {"name": "events", "cardinality": "repeated", "type": "string"},
            {"name": "active", "type": "bool"},
            {"name": "project_id", "type": "string"},
        ],
        request_name="WebhookUpdateRequest",
        response=HOOK_ANSWER,
        response_name="WebhookAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        """``fields`` names what to change (any of name, url, events, active, project)."""
        user, workspace = await _scope(request, context)

        def run() -> Any:
            changes: dict[str, Any] = {}
            for name in request.fields:
                if name not in EDITABLE:
                    raise ApiError(f"Cannot change {name}.", status=400)
                match name:
                    case "events":
                        changes[name] = list(request.events)
                    case "project":
                        changes["project_id"] = request.project_id
                    case "active":
                        changes[name] = request.active
                    case _:
                        changes[name] = getattr(request, name)
            hook = services.update_webhook(
                user, workspace, request.webhook_id, request.expected_version, **changes
            )
            return _hook_answer(hook)

        return await sync_to_async(run)()

    @grpc_action(
        request=HOOK,
        request_name="WebhookDeleteRequest",
        response=[{"name": "id", "type": "string"}],
        response_name="WebhookDeleted",
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            services.delete_webhook(user, workspace, request.webhook_id)
            return _pb().WebhookDeleted(id=request.webhook_id)

        return await sync_to_async(run)()

    @grpc_action(
        request=HOOK,
        request_name="WebhookTestRequest",
        response=DELIVERY_ANSWER,
        response_name="DeliveryAnswer",
    )
    @action
    async def Test(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            row = services.send_test(user, workspace, request.webhook_id)
            return _pb().DeliveryAnswer(delivery=delivery_message(row))

        return await sync_to_async(run)()

    @grpc_action(
        request=[
            *HOOK,
            {"name": "before", "type": "string"},
            {"name": "limit", "type": "int32"},
        ],
        request_name="DeliveriesRequest",
        response=[
            {"name": "deliveries", "cardinality": "repeated", "type": Delivery},
            {"name": "cursor", "type": "string"},
        ],
        response_name="DeliveryList",
    )
    @action
    async def Deliveries(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            rows, cursor = services.list_deliveries(
                user, workspace, request.webhook_id, before=request.before, limit=request.limit
            )
            return _pb().DeliveryList(deliveries=[delivery_message(r) for r in rows], cursor=cursor)

        return await sync_to_async(run)()

    @grpc_action(
        request=[*HOOK, {"name": "delivery_id", "type": "string"}],
        request_name="RedeliverRequest",
        response=DELIVERY_ANSWER,
        response_name="DeliveryAnswer",
    )
    @action
    async def Redeliver(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def run() -> Any:
            row = services.redeliver(user, workspace, request.webhook_id, request.delivery_id)
            return _pb().DeliveryAnswer(delivery=delivery_message(row))

        return await sync_to_async(run)()


GRPC_SERVICES = [ApiTokenService, WebhookService]
