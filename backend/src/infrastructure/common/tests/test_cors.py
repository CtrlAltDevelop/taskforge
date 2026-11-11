"""Flutter web runs on another origin than the API, so preflights must be answered."""

from django.test import Client, override_settings


@override_settings(CORS_ALLOWED_ORIGINS=["http://localhost:5000"])
def test_preflight_from_an_allowed_origin_is_answered() -> None:
    response = Client().options(
        "/api/v1/health/live",
        HTTP_ORIGIN="http://localhost:5000",
        HTTP_ACCESS_CONTROL_REQUEST_METHOD="GET",
    )

    assert response["Access-Control-Allow-Origin"] == "http://localhost:5000"


@override_settings(CORS_ALLOWED_ORIGINS=["http://localhost:5000"])
def test_a_foreign_origin_gets_no_cors_headers() -> None:
    response = Client().get("/api/v1/health/live", HTTP_ORIGIN="https://evil.example")

    assert "Access-Control-Allow-Origin" not in response


# The metadata the Flutter client sends on every call (app/lib/core/workspace/scoped_requests.dart):
# a browser asks permission for each one first, and a header that is not allowed fails the call.
CLIENT_HEADERS = ("authorization", "x-workspace", "x-client-id")


@override_settings(CORS_ALLOWED_ORIGINS=["http://localhost:5000"])
def test_the_rest_api_allows_the_headers_the_app_sends() -> None:
    response = Client().options(
        "/api/v1/health/live",
        HTTP_ORIGIN="http://localhost:5000",
        HTTP_ACCESS_CONTROL_REQUEST_METHOD="GET",
        HTTP_ACCESS_CONTROL_REQUEST_HEADERS=",".join(CLIENT_HEADERS),
    )

    allowed = {h.strip() for h in response["Access-Control-Allow-Headers"].split(",")}
    assert set(CLIENT_HEADERS) <= allowed


def test_envoy_allows_the_headers_the_app_sends_over_grpc_web() -> None:
    from pathlib import Path

    envoy = (Path(__file__).resolve().parents[5] / "deploy" / "envoy.yaml").read_text()
    line = next(row for row in envoy.splitlines() if "allow_headers" in row)

    assert all(header in line for header in CLIENT_HEADERS)
