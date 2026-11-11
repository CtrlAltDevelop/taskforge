"""Who is making the change that is being announced.

Set where a request is authenticated (a gRPC call) and read where the change is recorded, so the
change log can say "this client did it" without every service passing the actor along. A context
variable follows the request into the threads the ORM runs in.
"""

import hashlib
import hmac
from contextvars import ContextVar
from typing import Any

from django.conf import settings

_actor: ContextVar[str] = ContextVar("sync_actor", default="")
_origin: ContextVar[str] = ContextVar("sync_origin", default="")


def set_actor(user: Any | None, origin: str | None = None) -> None:
    """``origin`` is the calling client's own id (its ``x-client-id`` header), so a client can tell
    which events are echoes of its own writes; ``None`` leaves it as it was."""
    _actor.set(str(user.pk) if user is not None else "")
    if origin is not None:
        _origin.set(origin[:64])


def current_actor() -> str:
    return _actor.get()


def current_origin() -> str:
    return _origin.get()


def origin_tag(user_id: str, client_id: str) -> str:
    """What an event says about which client made it: a keyed hash of the person and the client's
    own id, so only that client (told its tag when it signs in to the socket) can recognise it.
    Another member who copies the id into their own header gets a different tag, and the id itself
    is never broadcast."""
    if not client_id:
        return ""
    digest = hmac.new(
        settings.SECRET_KEY.encode(), f"sync-origin:{user_id}:{client_id}".encode(), hashlib.sha256
    )
    return digest.hexdigest()[:24]
