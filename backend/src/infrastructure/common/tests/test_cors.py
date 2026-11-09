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
