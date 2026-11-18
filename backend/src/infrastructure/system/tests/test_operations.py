"""The operational routes: health, version, metrics, and the extra security headers."""

from typing import Any

import pytest
from django.test import Client

from infrastructure.system import version
from infrastructure.system.middleware import HEADERS


@pytest.fixture
def client() -> Client:
    return Client()


def test_live_answers_without_a_credential(client: Client) -> None:
    response = client.get("/api/health/live")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    assert "no-cache" in response["Cache-Control"] or "max-age=0" in response["Cache-Control"]


@pytest.mark.django_db
@pytest.mark.parametrize("path", ["/api/health", "/api/health/ready"])
def test_ready_reports_the_database(client: Client, path: str) -> None:
    response = client.get(path)

    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert response.json()["checks"]["database"] == "ok"


def test_ready_is_503_when_the_database_is_down(client: Client, monkeypatch: Any) -> None:
    from infrastructure.common.services import health_service

    monkeypatch.setattr(health_service, "database_is_ready", lambda: False)

    response = client.get("/api/health/ready")

    assert response.status_code == 503
    assert response.json()["checks"]["database"] == "unavailable"


def test_live_stays_200_when_the_database_is_down(client: Client, monkeypatch: Any) -> None:
    from infrastructure.common.services import health_service

    monkeypatch.setattr(health_service, "database_is_ready", lambda: False)

    assert client.get("/api/health/live").status_code == 200


@pytest.mark.parametrize("path", ["/api/health/live", "/api/health/ready", "/api/version"])
def test_operational_routes_only_answer_get(client: Client, path: str) -> None:
    assert client.post(path).status_code == 405


def test_version_reports_the_build_and_the_minimum_client(client: Client, settings: Any) -> None:
    settings.APP_VERSION = "1.4.2"
    settings.MIN_CLIENT_VERSION = "1.2.0"
    settings.BUILD_COMMIT = "abc1234"

    body = client.get("/api/version").json()

    assert body == {
        "version": "1.4.2",
        "min_client_version": "1.2.0",
        "api": "v1",
        "commit": "abc1234",
    }


def test_minimum_client_version_defaults_to_everything_allowed(settings: Any) -> None:
    settings.MIN_CLIENT_VERSION = "0.0.0"

    assert version.min_client_version() == "0.0.0"
    assert not version.is_older("0.0.1", version.min_client_version())


@pytest.mark.parametrize(
    ("have", "minimum", "older"),
    [
        ("1.1.9", "1.2.0", True),
        ("1.2.0", "1.2.0", False),
        ("1.10.0", "1.9.0", False),
        ("1.2.0-rc.1", "1.2.0", True),
        ("v2.0.0", "1.9.9", False),
        ("garbage", "1.2.0", False),
        ("1.2.0", "garbage", False),
    ],
)
def test_is_older_compares_semver(have: str, minimum: str, older: bool) -> None:
    assert version.is_older(have, minimum) is older


def test_metrics_is_404_without_a_configured_token(client: Client, settings: Any) -> None:
    settings.METRICS_TOKEN = ""

    assert client.get("/metrics").status_code == 404
    assert client.get("/metrics", HTTP_AUTHORIZATION="Bearer anything").status_code == 404


@pytest.mark.django_db
def test_metrics_requires_the_token_when_one_is_configured(client: Client, settings: Any) -> None:
    settings.METRICS_TOKEN = "scrape-secret"

    missing = client.get("/metrics")
    wrong = client.get("/metrics", HTTP_AUTHORIZATION="Bearer nope")
    right = client.get("/metrics", HTTP_AUTHORIZATION="Bearer scrape-secret")

    assert missing.status_code == 401
    assert missing["WWW-Authenticate"].startswith("Bearer")
    assert wrong.status_code == 401
    assert right.status_code == 200
    assert "taskforge_info" in right.content.decode()
    assert right["Content-Type"].startswith("text/plain")


def test_security_headers_are_added_to_every_response(client: Client) -> None:
    response = client.get("/api/health/live")

    for name, value in HEADERS.items():
        assert response[name] == value


def test_security_headers_do_not_override_a_view_that_set_its_own() -> None:
    from django.http import HttpRequest, HttpResponse

    from infrastructure.system.middleware import SecurityHeadersMiddleware

    def view(request: HttpRequest) -> HttpResponse:
        response = HttpResponse()
        response["Permissions-Policy"] = "camera=(self)"
        return response

    response = SecurityHeadersMiddleware(view)(HttpRequest())

    assert response["Permissions-Policy"] == "camera=(self)"
    assert response["Cross-Origin-Opener-Policy"] == "same-origin"


def test_maintenance_mode_answers_503_json_but_keeps_operations_up(
    client: Client, settings: Any
) -> None:
    settings.MAINTENANCE_MODE = True

    refused = client.get("/api/v1/workspaces")

    assert refused.status_code == 503
    assert refused.json()["maintenance"] is True and refused["Retry-After"] == "60"
    assert client.get("/api/health/live").status_code == 200
    assert client.get("/api/version").status_code == 200
    assert client.get("/metrics").status_code != 503


def test_maintenance_mode_is_off_by_default(client: Client) -> None:
    assert client.get("/api/health/live").status_code == 200
    assert client.get("/api/v1/workspaces").status_code != 503


def _call_through_the_interceptor(stub_class: Any, method: str, request: Any) -> Any:
    """One RPC on a server carrying the project's handlers *and* the maintenance interceptor
    (the shared ``grpc_call`` fixture builds its server without the settings' interceptors)."""
    import asyncio

    import grpc

    from config.grpc import grpc_handlers
    from infrastructure.system.maintenance import maintenance_interceptor

    async def run() -> Any:
        server = grpc.aio.server(interceptors=[maintenance_interceptor])
        port = server.add_insecure_port("127.0.0.1:0")
        grpc_handlers(server)
        await server.start()
        try:
            async with grpc.aio.insecure_channel(f"127.0.0.1:{port}") as channel:
                return await getattr(stub_class(channel), method)(request)
        finally:
            await server.stop(None)

    return asyncio.run(run())


def test_maintenance_mode_makes_grpc_unavailable_except_system(settings: Any) -> None:
    import grpc
    from google.protobuf.empty_pb2 import Empty

    from infrastructure.shortcuts.grpc import shortcuts_pb2, shortcuts_pb2_grpc
    from infrastructure.system.grpc import system_pb2_grpc

    stub = shortcuts_pb2_grpc.ShortcutControllerStub
    asked = shortcuts_pb2.ShortcutGetRequest()
    settings.MAINTENANCE_MODE = False
    with pytest.raises(grpc.aio.AioRpcError) as normal:
        _call_through_the_interceptor(stub, "Get", asked)
    settings.MAINTENANCE_MODE = True
    with pytest.raises(grpc.aio.AioRpcError) as down:
        _call_through_the_interceptor(stub, "Get", asked)
    with pytest.raises(grpc.aio.AioRpcError) as system:
        _call_through_the_interceptor(system_pb2_grpc.SystemControllerStub, "Info", Empty())

    assert normal.value.code() is not grpc.StatusCode.UNAVAILABLE  # off: reaches the handler
    assert down.value.code() is grpc.StatusCode.UNAVAILABLE
    assert "maintenance" in down.value.details()
    assert system.value.code() is not grpc.StatusCode.UNAVAILABLE  # exempt
