"""What the recorder needs to know that the changed row does not say: how the caller reached us,
whether an automation is acting, and which bulk operation a change belongs to."""

import uuid
from collections.abc import Iterator
from contextlib import contextmanager
from contextvars import ContextVar
from typing import Any

_batch: ContextVar[uuid.UUID | None] = ContextVar("audit_batch", default=None)
_actor_type: ContextVar[str] = ContextVar("audit_actor_type", default="")
_actor_id: ContextVar[str] = ContextVar("audit_actor_id", default="")
_suppressed: ContextVar[bool] = ContextVar("audit_suppressed", default=False)
_ip: ContextVar[str] = ContextVar("audit_ip", default="")
_user_agent: ContextVar[str] = ContextVar("audit_user_agent", default="")


def is_suppressed() -> bool:
    return _suppressed.get()


@contextmanager
def suppressed() -> Iterator[None]:
    """The signal receivers record nothing inside: for a write the caller records itself (a
    workflow save that renames through a temporary name) or a purge that is recorded as one."""
    token = _suppressed.set(True)
    try:
        yield
    finally:
        _suppressed.reset(token)


def current_batch() -> uuid.UUID | None:
    return _batch.get()


def current_actor_type() -> str:
    return _actor_type.get()


def current_actor_id() -> str:
    """Who an automation says is acting (its own id), when one is."""
    return _actor_id.get()


def current_client() -> tuple[str, str]:
    return _ip.get(), _user_agent.get()


def set_client(meta: Any) -> None:
    """Remember the caller's address and agent (from a request's ``META``) for this call. The
    address is ``REMOTE_ADDR`` unless ``AUDIT_TRUSTED_PROXY_HOPS`` says N proxies we run sit in
    front: then it is the Nth hop from the right of ``X-Forwarded-For`` (the part a client can
    write is the left; each of our proxies appends the peer it saw on the right)."""
    from django.conf import settings

    ip = str(meta.get("REMOTE_ADDR") or "")
    hops = int(getattr(settings, "AUDIT_TRUSTED_PROXY_HOPS", 0))
    forwarded = str(meta.get("HTTP_X_FORWARDED_FOR") or meta.get("x-forwarded-for") or "")
    parts = [p.strip() for p in forwarded.split(",") if p.strip()]
    if hops and len(parts) >= hops:
        ip = parts[-hops]
    agent = str(meta.get("HTTP_USER_AGENT") or meta.get("user-agent") or "")
    _ip.set(ip)
    _user_agent.set(agent[:200])


@contextmanager
def batch(batch_id: uuid.UUID | None = None) -> Iterator[uuid.UUID]:
    """Everything recorded inside shares one ``batch_id`` (a bulk edit: one entry per task).
    Pass the id again to rejoin a batch from a later call (a generator that yields between its
    tasks must not hold the context open across a yield)."""
    chosen = batch_id or _batch.get() or uuid.uuid4()  # a nested batch joins the outer one
    token = _batch.set(chosen)
    try:
        yield chosen
    finally:
        _batch.reset(token)


@contextmanager
def as_automation(automation_id: object = "") -> Iterator[None]:
    """Changes made inside are an automation's (``automation_id`` is the "actor"), not the
    person's whose permissions it borrows."""
    kind = _actor_type.set("automation")
    who = _actor_id.set(str(automation_id))
    try:
        yield
    finally:
        _actor_id.reset(who)
        _actor_type.reset(kind)


@contextmanager
def as_system() -> Iterator[None]:
    """Changes made inside are the system's (a clock making a recurring task), not a person's,
    although the rows still belong to the person whose permissions it borrows."""
    kind = _actor_type.set("system")
    try:
        yield
    finally:
        _actor_type.reset(kind)
