"""Demo developer settings and security: API tokens, service accounts, webhooks, sessions, 2FA.

Webhooks are created last of all (see ``extras.seed``): from then on every task change would queue
a real delivery, and the demo must never call out. Their delivery history is written directly.
"""

import json
from datetime import timedelta
from typing import Any

import pyotp
from django.test import RequestFactory
from django.test.utils import override_settings
from django.utils import timezone

from infrastructure.auth.core.sessions import issue_credentials
from infrastructure.common.demo.base import Ctx
from infrastructure.developer import delivery, events, signing
from infrastructure.developer import service_accounts as accounts
from infrastructure.developer import services as developer
from infrastructure.developer.models import DeliveryStatus, WebhookDelivery
from infrastructure.security import devices, policy, twofactor
from infrastructure.workspaces import access

# model; os; osVersion, user agent
SESSIONS = (
    ("owner", "MacBook Pro", "macos", "14.5", "198.51.100.7", "Mozilla/5.0 (Macintosh) Chrome/126"),
    ("owner", "iPhone 15", "ios", "17.5", "198.51.100.8", "TaskForge/1.0 (iPhone)"),
    ("owner", "Pixel 8", "android", "14", "203.0.113.40", "TaskForge/1.0 (Android)"),
    ("member", "ThinkPad X1", "windows", "11", "192.0.2.21", "Mozilla/5.0 (Windows) Firefox/127"),
)


def _request(ip: str = "198.51.100.7", agent: str = "demo", device: str = "") -> Any:
    extra = {"HTTP_X_DEVICE_INFO": device} if device else {}
    return RequestFactory().post("/", REMOTE_ADDR=ip, HTTP_USER_AGENT=agent, **extra)


def create_tokens(ctx: Ctx) -> None:
    """Personal tokens (live, expiring, revoked) and a service account with its own token."""
    owner, ws = ctx.owner, ctx.ws
    developer.create_token(owner, ws, "CI status board", ["workspaces:read", "tasks:read"], 90)
    developer.create_token(
        owner, ws, "Zapier sync", ["tasks:read", "tasks:write", "comments:write"]
    )
    old = developer.create_token(owner, ws, "Old laptop script", ["tasks:read"], 30)
    developer.revoke_token(owner, ws, str(old.token.pk))
    developer.create_token(ctx.users["dev"], ws, "Local scripts", ["projects:read", "tasks:read"])
    role = str(access.builtin_role("Member").pk)
    bot = accounts.create_account(owner, ws, "Release bot", role)
    accounts.create_token(
        owner, ws, str(bot.account.pk), "release-pipeline", ["tasks:read", "tasks:write"], 180
    )


def create_security(ctx: Ctx) -> None:
    """Sessions on several devices, trusted devices, one person with two-factor, a 2FA policy."""
    _sessions(ctx)
    viewer = ctx.users["viewer"]
    secret, _ = twofactor.begin(viewer)
    codes = twofactor.confirm(_request(), viewer, pyotp.TOTP(secret).now())
    ctx.extra["totp"] = {"user": "viewer", "secret": secret, "recovery_codes": codes}
    devices.trust(_request(), viewer, "Chloe's laptop")
    for label in ("Office iMac", "Home desktop"):
        devices.trust(_request(), ctx.owner, label)
    devices.revoke(ctx.owner, str(devices.active(ctx.owner)[-1].pk))
    side = ctx.workspaces["side"]
    policy.set_policy(side, ctx.owner, require_2fa=True, grace_days=14, expected_version=0)


def _sessions(ctx: Ctx) -> None:
    with override_settings(
        COLLECT_DEVICE_INFO=True, DEVICE_FINGERPRINT_PEPPER="demo-pepper", DPOP_MODE="off"
    ):
        for who, model, os_name, version, ip, agent in SESSIONS:
            header = f"model={model};os={os_name};osVersion={version}"
            issue_credentials(_request(ip, agent, header), ctx.users[who], method="password")


def create_webhooks(ctx: Ctx) -> None:
    """Three webhooks with a delivery history: delivered, retrying, gave up."""
    owner, ws = ctx.owner, ctx.ws
    slack = developer.create_webhook(
        owner,
        ws,
        "https://hooks.example.com/slack/relay",
        ["task.created", "task.status_changed", "comment.created"],
        name="Slack relay",
    )
    billing = developer.create_webhook(
        owner,
        ws,
        "https://billing.example.com/taskforge",
        ["task.updated", "goal.progress_changed"],
        name="Billing sync",
        project_id=str(ctx.projects["web"].pk),
    )
    zapier = developer.create_webhook(
        owner, ws, "https://hooks.zapier.example.com/old", ["task.deleted"], name="Old Zapier zap"
    )
    developer.update_webhook(owner, ws, str(zapier.pk), zapier.version, active=False)
    task = ctx.tasks["login"]
    for hook, event, status, code, minutes in (
        (slack, "task.created", DeliveryStatus.DELIVERED, 200, 50),
        (slack, "task.status_changed", DeliveryStatus.DELIVERED, 204, 30),
        (slack, "comment.created", DeliveryStatus.FAILED, 503, 5),
        (billing, "task.updated", DeliveryStatus.DELIVERED, 200, 120),
        (billing, "task.updated", DeliveryStatus.GAVE_UP, None, 1500),
        (zapier, "task.deleted", DeliveryStatus.GAVE_UP, 410, 2900),
    ):
        _history(hook, event, status, code, minutes, task)


def _history(hook: Any, event: str, status: str, code: int | None, minutes: int, task: Any) -> None:
    now = timezone.now()
    event_id = events.event_id(f"demo:{hook.pk}:{event}:{minutes}")
    body = delivery.envelope(hook, event, event_id, {"task": events.task_data(task)})
    raw = json.dumps(body, separators=(",", ":"), sort_keys=True).encode()
    stamp = int(now.timestamp())
    failing = status != DeliveryStatus.DELIVERED
    WebhookDelivery.objects.create(
        webhook=hook,
        workspace_id=hook.workspace_id,
        event=event,
        event_id=event_id,
        payload=body,
        status=status,
        status_code=code,
        response_snippet=""
        if code is None
        else ('{"ok":true}' if not failing else "Service Unavailable"),
        error="Timed out after 10 seconds." if code is None else "",
        request_headers={
            "Content-Type": "application/json",
            "X-TaskForge-Event": event,
            signing.TIMESTAMP_HEADER: str(stamp),
            signing.SIGNATURE_HEADER: signing.sign(hook.secret, stamp, raw),
        },
        attempt=1 if status == DeliveryStatus.DELIVERED else 4,
        next_retry_at=now + timedelta(minutes=8) if status == DeliveryStatus.FAILED else None,
        created_at=now - timedelta(minutes=minutes),
        at=now - timedelta(minutes=minutes),
        duration_ms=10_000 if code is None else 180,
    )
