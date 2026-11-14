from types import SimpleNamespace
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.forms import ratelimit


def test_parse_rate() -> None:
    assert ratelimit.parse_rate("") is None
    assert ratelimit.parse_rate("10/hour") == (10, 3600)
    assert ratelimit.parse_rate("5/minutes") == (5, 60)
    with pytest.raises(KeyError):
        ratelimit.parse_rate("5/fortnight")


def test_per_ip_limit_is_per_form_and_address(settings: Any) -> None:
    settings.FORMS_RATE_PER_FORM = ""
    settings.FORMS_RATE_PER_IP = "2/hour"
    ratelimit.check("f1", "ip-a")
    ratelimit.check("f1", "ip-a")
    with pytest.raises(ApiError) as caught:
        ratelimit.check("f1", "ip-a")
    assert caught.value.status == 429
    ratelimit.check("f1", "ip-b")  # another address
    ratelimit.check("f2", "ip-a")  # another form


def test_per_form_limit(settings: Any) -> None:
    settings.FORMS_RATE_PER_FORM = "1/hour"
    settings.FORMS_RATE_PER_IP = ""
    ratelimit.check("f9", "x")
    with pytest.raises(ApiError):
        ratelimit.check("f9", "y")


def test_client_ip_trusts_only_configured_hops(settings: Any) -> None:
    meta = {"REMOTE_ADDR": "9.9.9.9", "HTTP_X_FORWARDED_FOR": "1.1.1.1, 2.2.2.2"}
    request = SimpleNamespace(META=meta)
    settings.AUDIT_TRUSTED_PROXY_HOPS = 0
    assert ratelimit.client_ip(request) == "9.9.9.9"
    settings.AUDIT_TRUSTED_PROXY_HOPS = 1
    assert ratelimit.client_ip(request) == "2.2.2.2"
    settings.AUDIT_TRUSTED_PROXY_HOPS = 5  # more hops than the header has: ignore the header
    assert ratelimit.client_ip(request) == "9.9.9.9"
