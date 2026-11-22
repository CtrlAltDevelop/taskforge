"""API tokens and webhooks: the rules. The transports (gRPC, REST) only call these.

Tokens are a person's own: a member makes, lists and revokes theirs, in a workspace they belong to,
and each one carries at most what its owner may do (see ``scopes``). A service account's tokens
are made and revoked by those who hold ``webhook.manage`` (see ``service_accounts``). Webhooks
need ``webhook.manage``. Neither is ever managed *with* a token. Creating and revoking a token each
leave an audit entry naming the token and its prefix, never the secret or its hash.
"""

import secrets
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any, Final

from django.conf import settings
from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.developer import delivery, events, outbound, scopes, tokens
from infrastructure.developer.models import ApiToken, Webhook, WebhookDelivery
from infrastructure.projects import services as projects
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "workspace.view"
MANAGE: Final = "webhook.manage"
MAX_NAME: Final = 80
MAX_EXPIRY_DAYS: Final = 365
PAGE_DEFAULT: Final = 50
PAGE_MAX: Final = 100


def _invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.VALIDATION_ERROR)


def _not_found() -> ApiError:
    return ApiError("Not found.", status=404, title=ResponseTitle.NOT_FOUND)


def _by_person(actor: Any) -> None:
    """Tokens and webhooks are managed by a signed-in person, never by a token."""
    if scopes.token_of(actor) is not None:
        raise ApiError(
            "An API token cannot manage tokens or webhooks.",
            status=403,
            title=ResponseTitle.PERMISSION_DENIED_REASON,
            data={"hint": "sign in as a person"},
        )


def _name(raw: str, *, required: bool = True) -> str:
    name = " ".join(raw.split())
    if required and not name:
        raise _invalid("Give it a name.")
    if len(name) > MAX_NAME:
        raise _invalid(f"A name is at most {MAX_NAME} characters.")
    return name


def _uuid(raw: str) -> uuid.UUID:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise _not_found() from None


# ---- tokens -------------------------------------------------------------------------------


@dataclass(frozen=True, slots=True)
class Issued:
    token: ApiToken
    secret: str  # the only time it exists in clear


def list_tokens(actor: Any, workspace: Workspace) -> list[ApiToken]:
    _by_person(actor)
    access.require(actor, VIEW, workspace)
    return list(ApiToken.objects.filter(workspace=workspace, owner=actor).order_by("-created_at"))


def _expiry(days: int) -> Any:
    if days < 0 or days > MAX_EXPIRY_DAYS:
        raise _invalid(f"A token lasts at most {MAX_EXPIRY_DAYS} days (0 means no expiry).")
    return timezone.now() + timedelta(days=days) if days else None


def create_token(
    actor: Any, workspace: Workspace, name: str, wanted_scopes: Any, expires_in_days: int = 0
) -> Issued:
    _by_person(actor)
    access.require(actor, VIEW, workspace)
    return mint_token(actor, workspace, actor, name, wanted_scopes, expires_in_days)


def mint_token(
    actor: Any,
    workspace: Workspace,
    owner: Any,
    name: str,
    wanted_scopes: Any,
    expires_in_days: int = 0,
    *,
    service_account: str = "",
) -> Issued:
    """Make a token of ``owner`` (the caller, or a service account's user) once ``actor`` has been
    checked by the caller. The audit entry names the token and its prefix, never the secret."""
    cleaned_name = _name(name)
    chosen = scopes.clean(wanted_scopes)
    expires_at = _expiry(expires_in_days)
    with transaction.atomic():
        live = ApiToken.objects.filter(
            workspace=workspace, owner=owner, revoked_at__isnull=True
        ).count()
        if live >= settings.DEVELOPER_MAX_TOKENS:
            raise _invalid("There are too many active tokens here. Revoke one first.")
        secret, prefix, digest = tokens.new_secret()
        token = ApiToken.objects.create(
            workspace=workspace,
            owner=owner,
            name=cleaned_name,
            prefix=prefix,
            hash=digest,
            scopes=chosen,
            expires_at=expires_at,
        )
        recorded = {"name": token.name, "prefix": token.prefix, "scopes": chosen}
        if service_account:
            recorded["service_account"] = service_account
        _audit(workspace, "token.created", "token", token.pk, recorded, actor)
    return Issued(token, secret)


def revoke_token(actor: Any, workspace: Workspace, token_id: str) -> ApiToken:
    """A person revokes their own token; whoever manages webhooks revokes a service account's.
    Any other token is a 404, as if it did not exist."""
    _by_person(actor)
    access.require(actor, VIEW, workspace)
    with transaction.atomic():
        token = (
            ApiToken.objects.select_for_update()
            .select_related("owner")
            .filter(pk=_uuid(token_id), workspace=workspace)
            .first()
        )
        if token is None or not _may_revoke(actor, workspace, token):
            raise _not_found()
        if token.revoked_at is None:
            token.revoked_at = timezone.now()
            token.save(update_fields=["revoked_at"])
            recorded = {"name": token.name, "prefix": token.prefix}
            if token.owner_id != actor.pk:
                recorded["service_account"] = token.owner.service_account.name
            _audit(workspace, "token.revoked", "token", token.pk, recorded, actor)
    return token


def _may_revoke(actor: Any, workspace: Workspace, token: ApiToken) -> bool:
    if token.owner_id == actor.pk:
        return True
    return hasattr(token.owner, "service_account") and access.can(actor, MANAGE, workspace).allowed


def _audit(
    workspace: Workspace,
    action: str,
    target_type: str,
    target_id: Any,
    changes: dict[str, Any],
    actor: Any = None,
) -> None:
    recorder.record(
        actor=actor,
        workspace_id=workspace.pk,
        action=action,
        target_type=target_type,
        target_id=target_id,
        changes=changes,
    )


# ---- webhooks -----------------------------------------------------------------------------


def _check_url(url: str) -> str:
    cleaned = url.strip()
    try:
        outbound.check_url(cleaned)
    except outbound.UnsafeUrl as error:
        raise _invalid(str(error)) from None
    return cleaned


def _check_events(raw: Any) -> list[str]:
    wanted = {str(e) for e in raw or ()}
    unknown = sorted(wanted - set(events.KEYS))
    if unknown:
        raise _invalid(f"Unknown event: {unknown[0]}.")
    if not wanted:
        raise _invalid("Pick at least one event.")
    return [k for k in events.KEYS if k in wanted]


def _load(actor: Any, workspace: Workspace, webhook_id: str, *, lock: bool = False) -> Webhook:
    _by_person(actor)
    access.require(actor, MANAGE, workspace)
    rows = Webhook.objects.filter(pk=_uuid(webhook_id), workspace=workspace)
    hook = (rows.select_for_update() if lock else rows).first()
    if hook is None:
        raise _not_found()
    return hook


def list_webhooks(actor: Any, workspace: Workspace) -> list[Webhook]:
    _by_person(actor)
    access.require(actor, MANAGE, workspace)
    return list(Webhook.objects.filter(workspace=workspace).order_by("created_at"))


def _project_of(actor: Any, workspace: Workspace, project_id: str) -> Any:
    return projects.load(actor, workspace, project_id, as_admin=True) if project_id else None


def create_webhook(
    actor: Any,
    workspace: Workspace,
    url: str,
    wanted_events: Any,
    *,
    name: str = "",
    project_id: str = "",
) -> Webhook:
    _by_person(actor)
    access.require(actor, MANAGE, workspace)
    cleaned_url = _check_url(url)
    chosen = _check_events(wanted_events)
    label = _name(name, required=False)
    with transaction.atomic():
        if Webhook.objects.filter(workspace=workspace).count() >= settings.DEVELOPER_MAX_WEBHOOKS:
            raise _invalid("This workspace has too many webhooks. Delete one first.")
        hook = Webhook.objects.create(
            workspace=workspace,
            project=_project_of(actor, workspace, project_id),
            created_by=actor,
            name=label,
            url=cleaned_url,
            secret="whsec_" + secrets.token_urlsafe(32),
            events=chosen,
        )
        _audit(
            workspace,
            "webhook.created",
            "webhook",
            hook.pk,
            {
                "name": hook.name,
                "url": hook.url,
                "events": chosen,
            },
        )
    return hook


def update_webhook(
    actor: Any, workspace: Workspace, webhook_id: str, expected_version: int, **changes: Any
) -> Webhook:
    """``changes`` holds only what the caller sent: name, url, events, active, project_id."""
    with transaction.atomic():
        hook = _load(actor, workspace, webhook_id, lock=True)
        if hook.version != expected_version:
            raise ApiError(
                "Someone else changed this webhook first.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
                data={"version": hook.version},
            )
        before = {"name": hook.name, "url": hook.url, "events": hook.events, "active": hook.active}
        if "name" in changes:
            hook.name = _name(changes["name"], required=False)
        if "url" in changes:
            hook.url = _check_url(changes["url"])
        if "events" in changes:
            hook.events = _check_events(changes["events"])
        if "project_id" in changes:
            hook.project = _project_of(actor, workspace, changes["project_id"])
        if "active" in changes:
            hook.active = bool(changes["active"])
            hook.disabled_reason = "" if hook.active else "Switched off by hand."
        hook.version += 1
        hook.save()
        after = {"name": hook.name, "url": hook.url, "events": hook.events, "active": hook.active}
        diff = {k: [before[k], after[k]] for k in after if before[k] != after[k]}
        _audit(workspace, "webhook.updated", "webhook", hook.pk, diff)
    return hook


def delete_webhook(actor: Any, workspace: Workspace, webhook_id: str) -> None:
    with transaction.atomic():
        hook = _load(actor, workspace, webhook_id, lock=True)
        _audit(
            workspace, "webhook.deleted", "webhook", hook.pk, {"name": hook.name, "url": hook.url}
        )
        hook.delete()


def list_deliveries(
    actor: Any,
    workspace: Workspace,
    webhook_id: str,
    *,
    before: str = "",
    limit: int = PAGE_DEFAULT,
) -> tuple[list[WebhookDelivery], str]:
    """Newest first; ``before`` is the cursor returned with the previous page ('' at the end)."""
    hook = _load(actor, workspace, webhook_id)
    size = max(1, min(limit or PAGE_DEFAULT, PAGE_MAX))
    rows = WebhookDelivery.objects.filter(webhook=hook).order_by("-created_at", "-id")
    if before:
        stamp, _, ident = before.partition("|")
        try:
            moment = datetime.fromisoformat(stamp)
        except ValueError:
            raise _invalid("Bad cursor.") from None
        rows = rows.filter(Q(created_at__lt=moment) | Q(created_at=moment, id__lt=_uuid(ident)))
    found = list(rows[: size + 1])
    page = found[:size]
    cursor = f"{page[-1].created_at.isoformat()}|{page[-1].pk}" if len(found) > size else ""
    return page, cursor


def _delivery(
    actor: Any, workspace: Workspace, webhook_id: str, delivery_id: str
) -> WebhookDelivery:
    hook = _load(actor, workspace, webhook_id)
    row = WebhookDelivery.objects.filter(pk=_uuid(delivery_id), webhook=hook).first()
    if row is None:
        raise _not_found()
    return row


def get_delivery(
    actor: Any, workspace: Workspace, webhook_id: str, delivery_id: str
) -> WebhookDelivery:
    return _delivery(actor, workspace, webhook_id, delivery_id)


def redeliver(
    actor: Any, workspace: Workspace, webhook_id: str, delivery_id: str
) -> WebhookDelivery:
    return delivery.redeliver(_delivery(actor, workspace, webhook_id, delivery_id))


def send_test(actor: Any, workspace: Workspace, webhook_id: str) -> WebhookDelivery:
    return delivery.ping(_load(actor, workspace, webhook_id))
