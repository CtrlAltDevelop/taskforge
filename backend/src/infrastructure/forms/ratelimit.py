"""Per-form and per-IP limits for the public submit, counted in Django's cache (a fixed window)."""

import hashlib
import hmac
import time
from typing import Final

from django.conf import settings
from django.core.cache import cache
from django.http import HttpRequest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle

PERIODS: Final = {"second": 1, "minute": 60, "hour": 3600, "day": 86400}


def parse_rate(rate: str) -> tuple[int, int] | None:
    """``"10/hour"`` -> (10, 3600); empty turns the limit off."""
    if not rate:
        return None
    count, _, period = rate.partition("/")
    return int(count), PERIODS[period.strip().rstrip("s") or "hour"]


def _hit(key: str, limit: int, window: int) -> bool:
    bucket = f"forms:rl:{key}:{int(time.time()) // window}"
    cache.add(bucket, 0, timeout=window)
    try:
        return int(cache.incr(bucket)) <= limit
    except ValueError:  # expired between add and incr
        cache.set(bucket, 1, timeout=window)
        return True


def too_many() -> ApiError:
    return ApiError("Too many submissions. Try again later.", 429, title=ResponseTitle.RATE_LIMITED)


def check(form_id: object, ip_hash: str) -> None:
    """Count one submission against the form and the address; raise 429 over either limit."""
    for scope, who, rate in (
        ("form", str(form_id), settings.FORMS_RATE_PER_FORM),
        ("ip", f"{form_id}:{ip_hash}", settings.FORMS_RATE_PER_IP),
    ):
        parsed = parse_rate(rate)
        if parsed and not _hit(f"{scope}:{who}", *parsed):
            raise too_many()


def client_ip(request: HttpRequest) -> str:
    """The caller's address: ``REMOTE_ADDR`` unless ``AUDIT_TRUSTED_PROXY_HOPS`` proxies of ours
    sit in front (then the Nth hop from the right of ``X-Forwarded-For``, as the audit log does)."""
    meta = request.META
    ip = str(meta.get("REMOTE_ADDR") or "")
    hops = int(getattr(settings, "AUDIT_TRUSTED_PROXY_HOPS", 0))
    parts = [p.strip() for p in str(meta.get("HTTP_X_FORWARDED_FOR") or "").split(",") if p.strip()]
    if hops and len(parts) >= hops:
        ip = parts[-hops]
    return ip


def hash_ip(ip: str) -> str:
    """A keyed hash (HMAC-SHA256): stable enough to rate-limit, useless to read an address from."""
    key = settings.FORMS_IP_HASH_KEY.encode()
    return hmac.new(key, ip.encode(), hashlib.sha256).hexdigest()
