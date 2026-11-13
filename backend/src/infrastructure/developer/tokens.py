"""Making, finding and limiting API tokens.

A secret looks like ``tf_<8 hex>_<48 hex>``: the first two parts are the *prefix* (kept in clear,
shown in lists, unique, how the row is found) and the whole string is hashed with SHA-256 (the
secret has 192 bits of randomness, so a fast hash is the right one). Presented tokens are compared
in constant time. The secret is returned once, by ``issue``, and never stored.
"""

import hashlib
import hmac
import secrets
from datetime import timedelta
from typing import TYPE_CHECKING, Any, Final

from django.conf import settings
from django.core.cache import cache
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.developer.scopes import TOKEN_ATTRIBUTE

if TYPE_CHECKING:
    from infrastructure.developer.models import ApiToken

MARKER: Final = "tf_"
LAST_USED_EVERY: Final = timedelta(minutes=1)


def looks_like_token(presented: str) -> bool:
    return presented.startswith(MARKER)


def digest(raw: str) -> str:
    return hashlib.sha256(raw.encode()).hexdigest()


def new_secret() -> tuple[str, str, str]:
    """``(secret, prefix, hash)`` of a fresh token."""
    prefix = f"{MARKER}{secrets.token_hex(4)}"
    raw = f"{prefix}_{secrets.token_hex(24)}"
    return raw, prefix, digest(raw)


def _split(raw: str) -> str | None:
    parts = raw.split("_")
    if len(parts) != 3 or parts[0] != "tf" or not parts[1] or not parts[2]:
        return None
    return f"{parts[0]}_{parts[1]}"


def find(raw: str) -> "ApiToken | None":
    """The live token ``raw`` is the secret of, or ``None`` (the same for every reason)."""
    from infrastructure.developer.models import ApiToken

    prefix = _split(raw)
    if prefix is None:
        return None
    token = ApiToken.objects.select_related("owner").filter(prefix=prefix).first()
    if token is None:
        return None
    if not hmac.compare_digest(token.hash, digest(raw)):
        return None
    if not token.is_active or not token.owner.is_active:
        return None
    return token


def _within_rate(token: "ApiToken") -> bool:
    limit = settings.DEVELOPER_TOKEN_RATE_PER_MINUTE
    if limit <= 0:
        return True
    key = f"developer:token:{token.pk}:{int(timezone.now().timestamp() // 60)}"
    cache.add(key, 0, timeout=120)
    try:
        used = cache.incr(key)
    except ValueError:  # expired between add and incr
        cache.set(key, 1, timeout=120)
        used = 1
    return used <= limit


def _touch(token: "ApiToken") -> None:
    from infrastructure.developer.models import ApiToken

    now = timezone.now()
    if token.last_used_at is None or now - token.last_used_at > LAST_USED_EVERY:
        ApiToken.objects.filter(pk=token.pk).update(last_used_at=now)


def authenticate(raw: str) -> Any | None:
    """The owner of the token ``raw``, carrying the token (``user.api_token``), or ``None``.

    A token over its per-minute allowance is refused with 429 (the rate limit is per token, so one
    runaway script does not slow the owner's other tokens or other people's).
    """
    token = find(raw)
    if token is None:
        return None
    if not _within_rate(token):
        raise ApiError(
            "This token is making too many requests. Wait a minute.",
            status=429,
            title=ResponseTitle.RATE_LIMITED,
        )
    _touch(token)
    user = token.owner
    setattr(user, TOKEN_ATTRIBUTE, token)
    return user
