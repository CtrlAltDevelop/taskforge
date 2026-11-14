from datetime import timedelta
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.developer import delivery, outbound, scopes, signing, tokens
from infrastructure.developer.models import ApiToken


@pytest.fixture
def owner(db: None) -> Any:
    return get_user_model().objects.create_user(
        username="dev", email="dev@example.com", password="corr3ct-horse-battery"
    )


@pytest.fixture
def workspace(owner: Any) -> Any:
    from infrastructure.workspaces.models import Workspace

    return Workspace.objects.create(name="W", slug="w-dev", created_by=owner)


def _issue(owner: Any, workspace: Any, **extra: Any) -> tuple[str, ApiToken]:
    raw, prefix, digest = tokens.new_secret()
    token = ApiToken.objects.create(
        workspace=workspace,
        owner=owner,
        name="t",
        prefix=prefix,
        hash=digest,
        scopes=["tasks:read"],
        **extra,
    )
    return raw, token


def test_secret_shape_and_hash() -> None:
    raw, prefix, digest = tokens.new_secret()
    assert raw.startswith(prefix + "_") and tokens.looks_like_token(raw)
    assert digest == tokens.digest(raw) and len(digest) == 64 and raw not in digest


def test_find_accepts_the_secret_only(owner: Any, workspace: Any) -> None:
    raw, token = _issue(owner, workspace)
    assert tokens.find(raw) == token
    assert tokens.find(raw[:-1] + ("0" if raw[-1] != "0" else "1")) is None
    for bad in ("", "tf_", "tf_a_b_c", "nope", f"tf_{'x'}_"):
        assert tokens.find(bad) is None


def test_revoked_expired_and_inactive_owner_are_refused(owner: Any, workspace: Any) -> None:
    raw, token = _issue(owner, workspace, revoked_at=timezone.now())
    assert tokens.find(raw) is None
    raw, _ = _issue(owner, workspace, expires_at=timezone.now() - timedelta(seconds=1))
    assert tokens.find(raw) is None
    raw, _ = _issue(owner, workspace)
    owner.is_active = False
    owner.save()
    assert tokens.find(raw) is None


def test_authenticate_attaches_token_and_touches_last_used(owner: Any, workspace: Any) -> None:
    raw, token = _issue(owner, workspace)
    user = tokens.authenticate(raw)
    assert scopes.token_of(user) == token
    token.refresh_from_db()
    assert token.last_used_at is not None
    assert tokens.authenticate("tf_zz_zz") is None


def test_rate_limit_is_per_token(owner: Any, workspace: Any, settings: Any) -> None:
    settings.DEVELOPER_TOKEN_RATE_PER_MINUTE = 2
    raw, _ = _issue(owner, workspace)
    other, _ = _issue(owner, workspace)
    assert tokens.authenticate(raw) and tokens.authenticate(raw)
    with pytest.raises(ApiError) as caught:
        tokens.authenticate(raw)
    assert caught.value.status == 429
    assert tokens.authenticate(other)  # another token has its own allowance
    settings.DEVELOPER_TOKEN_RATE_PER_MINUTE = 0
    assert tokens.authenticate(raw)  # 0 disables the limit


def test_scope_clean_and_keys() -> None:
    assert scopes.clean(["tasks:write", "tasks:read", "tasks:read"]) == [
        "tasks:read",
        "tasks:write",
    ]
    with pytest.raises(ApiError):
        scopes.clean(["bogus"])
    with pytest.raises(ApiError):
        scopes.clean([])
    assert scopes.allowed_keys([]) == frozenset()
    assert "task.create" in scopes.allowed_keys(["tasks:write"])
    assert "task.create" not in scopes.allowed_keys(["tasks:read"])


def test_require_and_grpc_scope(owner: Any) -> None:
    scopes.require(owner, "tasks:write")  # a person is not limited
    owner.api_token = ApiToken(scopes=["tasks:read"])
    with pytest.raises(ApiError) as caught:
        scopes.require(owner, "tasks:write")
    assert caught.value.status == 403
    assert scopes.grpc_scope("TaskService", "List") == "tasks:read"
    assert scopes.grpc_scope("TaskService", "Create") == "tasks:write"
    assert scopes.grpc_scope("RoleService", "List") is None
    scopes.check_grpc(owner, "TaskService", "List")
    with pytest.raises(ApiError):
        scopes.check_grpc(owner, "RoleService", "List")
    with pytest.raises(ApiError):
        scopes.check_grpc(owner, "TaskService", "Create")


def test_signature_roundtrip_and_tamper() -> None:
    header = signing.sign("s3cret", 1000, b"{}")
    assert signing.verify("s3cret", header, b"{}", now=1000)
    assert not signing.verify("other", header, b"{}", now=1000)
    assert not signing.verify("s3cret", header, b"{ }", now=1000)
    assert not signing.verify("s3cret", header, b"{}", now=1000 + signing.TOLERANCE_SECONDS + 1)
    for junk in ("", "t=x,v1=y", "v1=abc", "garbage"):
        assert not signing.verify("s3cret", junk, b"{}", now=1000)


def test_backoff_doubles_and_caps() -> None:
    assert [delivery.backoff(n).total_seconds() for n in (1, 2, 3)] == [60, 120, 240]
    assert delivery.backoff(0).total_seconds() == 60
    assert delivery.backoff(40).total_seconds() == delivery.MAX_DELAY_SECONDS


@pytest.mark.parametrize(
    "url",
    [
        "http://127.0.0.1/hook",
        "http://localhost/hook",
        "http://foo.localhost/hook",
        "http://10.0.0.5/x",
        "http://169.254.169.254/latest",
        "http://[::1]/x",
        "http://[::ffff:127.0.0.1]/x",
        "http://user:pw@example.com/x",
        "ftp://example.com/x",
    ],
)
def test_private_or_odd_urls_are_refused(url: str) -> None:
    with pytest.raises(outbound.UnsafeUrl):
        outbound.check_url(url)


def test_public_ip_ok_and_allowlist(settings: Any) -> None:
    outbound.check_url("https://93.184.216.34/hook")
    settings.DEVELOPER_WEBHOOK_ALLOWLIST = ["10.0.0.0/8", "localhost"]
    outbound.check_url("http://10.1.2.3/x")
    outbound.check_url("http://localhost/x")
