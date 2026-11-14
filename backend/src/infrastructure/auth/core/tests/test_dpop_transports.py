"""DPoP over the three doors (REST, gRPC, WebSocket) with real tokens, in ``required`` mode."""

import asyncio
import threading
import time
from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model
from django.test import Client
from google.protobuf.empty_pb2 import Empty

from apps.notifications.sockets import notifications_socket
from apps.notifications.tests.conftest import SocketClient
from infrastructure.accounts.grpc import accounts_pb2, accounts_pb2_grpc
from infrastructure.auth.core import dpop
from infrastructure.auth.core.challenges import get_challenge_store
from infrastructure.auth.core.dpop import DpopError, Reason
from infrastructure.auth.core.models import AuthEvent
from infrastructure.auth.core.tests.test_dpop import Key
from infrastructure.auth.core.throttling import fingerprint
from infrastructure.auth.password import services as password

pytestmark = pytest.mark.django_db(transaction=True)

SIGNUP = "/api/v1/auth/password/signup"
PROTECTED = "/api/v1/auth/token/sessions"
PASSWORD = "corr3ct-horse-battery"
GRPC_PATH = f"/{accounts_pb2.DESCRIPTOR.services_by_name['AccountController'].full_name}/Me"


@pytest.fixture(autouse=True)
def _required(settings: Any) -> None:
    settings.DPOP_MODE = "required"
    settings.DPOP_NONCE_ENABLED = False
    settings.DPOP_MAX_KEY_FAILURES = 10


def origin() -> str:
    return dpop.public_origin()


def sign_up(key: Key, name: str = "zoe") -> str:
    response = Client().post(
        SIGNUP,
        {"identifier": name, "password": PASSWORD, "email": f"{name}@example.com"},
        content_type="application/json",
        HTTP_DPOP=key.proof(htm="POST", htu=f"{origin()}{SIGNUP}"),
    )
    assert response.status_code == 200, response.content
    token: str = response.json()["data"]["credentials"]["access_token"]
    return token


@pytest.fixture
def key() -> Key:
    return Key()


@pytest.fixture
def token(key: Key) -> str:
    return sign_up(key)


# A proof-building recipe per case: overrides for Key.proof, whether a proof is sent, the scheme,
# and the reason both transports must report.
CASES: dict[str, tuple[dict[str, Any], bool, str, Reason | None]] = {
    "valid": ({}, True, "DPoP", None),
    "wrong_method": ({"htm": "DELETE"}, True, "DPoP", Reason.METHOD_MISMATCH),
    "wrong_url": ({"htu": "https://evil.test/x"}, True, "DPoP", Reason.URL_MISMATCH),
    "stale": ({"iat": 1}, True, "DPoP", Reason.IAT_STALE),
    "no_ath": ({"ath": None}, True, "DPoP", Reason.ATH_MISSING),
    "wrong_ath": ({"ath": dpop.access_token_hash("other")}, True, "DPoP", Reason.ATH_MISMATCH),
    "no_proof": ({}, False, "DPoP", Reason.PROOF_MISSING),
    "bearer": ({}, True, "Bearer", Reason.BEARER_NOT_ALLOWED),
}


def build(case: str, key: Key, token: str, *, htm: str, htu: str) -> tuple[str, str]:
    overrides, send_proof, scheme, _ = CASES[case]
    proof = ""
    if send_proof:
        claims: dict[str, Any] = {
            "htm": htm,
            "htu": htu,
            "ath": dpop.access_token_hash(token),
            **overrides,
        }
        proof = key.proof(**claims)
    return f"{scheme} {token}", proof


def rest_call(authorization: str, proof: str) -> Any:
    extra = {"HTTP_AUTHORIZATION": authorization}
    if proof:
        extra["HTTP_DPOP"] = proof
    return Client().get(PROTECTED, **extra)


def grpc_call_with(authorization: str, proof: str) -> Any:
    from config.grpc import grpc_handlers
    from infrastructure.auth.core.dpop_grpc import method_path_interceptor

    async def run() -> Any:
        server = grpc.aio.server(interceptors=[method_path_interceptor])
        port = server.add_insecure_port("127.0.0.1:0")
        grpc_handlers(server)
        await server.start()
        try:
            async with grpc.aio.insecure_channel(f"127.0.0.1:{port}") as channel:
                metadata = [("authorization", authorization)]
                if proof:
                    metadata.append(("dpop", proof))
                stub = accounts_pb2_grpc.AccountControllerStub(channel)
                return await stub.Me(Empty(), metadata=metadata)
        finally:
            await server.stop(None)

    return asyncio.run(run())


def grpc_outcome(authorization: str, proof: str) -> tuple[bool, str]:
    try:
        grpc_call_with(authorization, proof)
    except grpc.aio.AioRpcError as refusal:
        return False, str(refusal.details())
    return True, ""


@pytest.mark.parametrize("case", sorted(CASES))
def test_rest_and_grpc_agree_over_the_same_proof_table(case: str, key: Key, token: str) -> None:
    reason = CASES[case][3]
    rest_auth, rest_proof = build(case, key, token, htm="GET", htu=f"{origin()}{PROTECTED}")
    grpc_auth, grpc_proof = build(case, key, token, htm="POST", htu=f"{origin()}{GRPC_PATH}")

    rest = rest_call(rest_auth, rest_proof)
    grpc_ok, grpc_detail = grpc_outcome(grpc_auth, grpc_proof)

    if reason is None:
        assert rest.status_code == 200, rest.content
        assert grpc_ok, grpc_detail
        return
    assert rest.status_code == 401, rest.content
    assert not grpc_ok
    assert reason.value in rest.content.decode()
    # gRPC carries the title and message, not the machine reason: the same words as REST's.
    title, _, message = grpc_detail.partition(": ")
    assert title == "TOKEN_INVALID"
    assert message in rest.content.decode()


def test_a_proof_signed_by_another_key_is_refused_on_both_doors(key: Key, token: str) -> None:
    thief = Key()
    auth, proof = build("valid", thief, token, htm="GET", htu=f"{origin()}{PROTECTED}")
    g_auth, g_proof = build("valid", thief, token, htm="POST", htu=f"{origin()}{GRPC_PATH}")

    rest = rest_call(auth, proof)
    grpc_ok, _ = grpc_outcome(g_auth, g_proof)

    assert rest.status_code == 401
    assert Reason.KEY_MISMATCH.value in rest.content.decode()
    assert not grpc_ok


def test_a_replayed_proof_is_refused_on_the_second_use(key: Key, token: str) -> None:
    auth, proof = build("valid", key, token, htm="GET", htu=f"{origin()}{PROTECTED}")

    first, second = rest_call(auth, proof), rest_call(auth, proof)

    assert first.status_code == 200
    assert second.status_code == 401
    assert Reason.REPLAY.value in second.content.decode()


def test_two_workers_sharing_the_cache_cannot_both_spend_one_proof(key: Key) -> None:
    proof = key.proof(htm="GET", htu=f"{origin()}{PROTECTED}")
    outcomes: list[str] = []
    barrier = threading.Barrier(2)

    def worker() -> None:
        barrier.wait()
        try:
            dpop.verify_proof(proof, method="GET", url=f"{origin()}{PROTECTED}")
            outcomes.append("ok")
        except DpopError as error:
            outcomes.append(error.reason.value)

    threads = [threading.Thread(target=worker) for _ in range(2)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()

    assert sorted(outcomes) == sorted(["ok", Reason.REPLAY.value])


def test_wrong_key_attempts_count_toward_the_failed_login_limit(key: Key, token: str) -> None:
    thief = Key()
    store = get_challenge_store()
    scope = f"attempts:{password.ACCOUNT_SCOPE}:{fingerprint('zoe')}"
    failed_before = AuthEvent.objects.filter(event_type="login_failed").count()

    for _ in range(3):
        auth, proof = build("valid", thief, token, htm="GET", htu=f"{origin()}{PROTECTED}")
        assert rest_call(auth, proof).status_code == 401

    assert store.count(scope) == 3
    assert AuthEvent.objects.filter(event_type="login_failed").count() == failed_before + 3


def test_too_many_wrong_key_proofs_end_in_a_429(key: Key, token: str, settings: Any) -> None:
    settings.DPOP_MAX_KEY_FAILURES = 2
    thief = Key()
    statuses = []
    for _ in range(3):
        auth, proof = build("valid", thief, token, htm="GET", htu=f"{origin()}{PROTECTED}")
        statuses.append(rest_call(auth, proof).status_code)

    assert statuses[-1] == 429
    assert 401 in statuses or statuses[0] == 429


def test_proof_free_routes_still_work(key: Key) -> None:
    client = Client()

    assert client.get("/api/health/live").status_code == 200
    assert client.get("/api/version").status_code == 200
    assert client.get("/api/health/ready").status_code == 200
    no_credential = client.get(PROTECTED)
    assert no_credential.status_code == 401
    assert "proof" not in no_credential.content.decode().lower()


def test_signing_in_without_a_proof_is_refused_in_required_mode() -> None:
    response = Client().post(
        SIGNUP,
        {"identifier": "ann", "password": PASSWORD, "email": "ann@example.com"},
        content_type="application/json",
    )

    assert response.status_code == 401
    assert Reason.PROOF_MISSING.value in response.content.decode()
    assert not get_user_model().objects.filter(username="ann").exists()


# --- WebSocket ----------------------------------------------------------------------------


def socket_authenticate(frame: dict[str, Any]) -> dict[str, Any]:
    async def scenario() -> dict[str, Any]:
        client = SocketClient(notifications_socket)
        await client.open()
        await client.next_frame()  # ready
        answer = await client.command({"command": "authenticate", **frame})
        await client.close()
        return answer

    return asyncio.run(scenario())


def socket_proof(key: Key, token: str, **overrides: Any) -> str:
    from django.conf import settings

    claims: dict[str, Any] = {
        "htm": "GET",
        "htu": dpop.socket_url(settings.NOTIFICATIONS_WS_PATH),
        "ath": dpop.access_token_hash(token),
        **overrides,
    }
    return key.proof(**claims)


def test_websocket_accepts_a_token_with_its_proof(key: Key, token: str) -> None:
    answer = socket_authenticate({"token": token, "dpop": socket_proof(key, token)})

    assert answer["type"] == "authenticated"
    assert answer["user"]["username"] == "zoe"


@pytest.mark.parametrize(
    "variant", ["no_proof", "wrong_key", "wrong_url", "wrong_method", "wrong_ath"]
)
def test_websocket_rejects_a_bad_proof(variant: str, key: Key, token: str) -> None:
    proofs = {
        "no_proof": "",
        "wrong_key": socket_proof(Key(), token),
        "wrong_url": socket_proof(key, token, htu="wss://evil.test/ws"),
        "wrong_method": socket_proof(key, token, htm="POST"),
        "wrong_ath": socket_proof(key, token, ath=dpop.access_token_hash("other")),
    }

    answer = socket_authenticate({"token": token, "dpop": proofs[variant]})

    assert answer["type"] == "error"


def test_websocket_refuses_a_replayed_proof(key: Key, token: str) -> None:
    proof = socket_proof(key, token)

    first = socket_authenticate({"token": token, "dpop": proof})
    second = socket_authenticate({"token": token, "dpop": proof})

    assert first["type"] == "authenticated"
    assert second["type"] == "error"


# --- Nonce rotation -----------------------------------------------------------------------


@pytest.fixture
def nonce_window(settings: Any, monkeypatch: pytest.MonkeyPatch) -> Callable[[int], None]:
    settings.DPOP_NONCE_ENABLED = True

    def pin(window: int) -> None:
        monkeypatch.setattr(dpop, "_nonce_window", lambda now=None: window)

    pin(1000)
    return pin


def verify_with(key: Key, nonce: str) -> None:
    proof = key.proof(htm="GET", htu=f"{origin()}{PROTECTED}", nonce=nonce)
    dpop.verify_proof(proof, method="GET", url=f"{origin()}{PROTECTED}")


def test_the_current_and_previous_nonce_are_accepted(nonce_window: Callable[[int], None]) -> None:
    key = Key()

    assert dpop.current_nonce() == dpop._nonce_for(1000)
    verify_with(key, dpop._nonce_for(1000))
    verify_with(key, dpop._nonce_for(999))  # still inside the grace period


@pytest.mark.parametrize("window", [998, 1001])
def test_an_older_or_unissued_nonce_is_refused(
    window: int, nonce_window: Callable[[int], None]
) -> None:
    with pytest.raises(DpopError) as caught:
        verify_with(Key(), dpop._nonce_for(window))

    assert caught.value.reason == Reason.NONCE_STALE
    assert caught.value.nonce == dpop._nonce_for(1000)  # the retry hint is the fresh one


def test_a_nonce_stops_being_valid_two_rotations_later(
    nonce_window: Callable[[int], None],
) -> None:
    key = Key()
    nonce = dpop.current_nonce()
    verify_with(key, nonce)

    nonce_window(1001)
    verify_with(key, nonce)  # previous window: fine
    nonce_window(1002)
    with pytest.raises(DpopError) as caught:
        verify_with(key, nonce)

    assert caught.value.reason == Reason.NONCE_STALE


def test_nonces_differ_per_window_and_per_secret(settings: Any) -> None:
    first = dpop._nonce_for(1)
    settings.DPOP_NONCE_SECRET = "another-secret"

    assert dpop._nonce_for(1) != first
    assert dpop._nonce_for(1) != dpop._nonce_for(2)


def test_rotation_follows_the_configured_period(settings: Any) -> None:
    settings.DPOP_NONCE_ROTATION_SECONDS = 60

    assert dpop._nonce_window(120.0) == 2
    assert dpop._nonce_window(179.9) == 2
    assert dpop._nonce_window(180.0) == 3
    assert time.time() > 0
