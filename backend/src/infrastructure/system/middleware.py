"""Response headers Django's SecurityMiddleware does not set."""

from collections.abc import Callable

from django.http import HttpRequest, HttpResponse

HEADERS = {
    # Nothing in the app needs the camera or microphone from the page itself, or geolocation.
    "Permissions-Policy": "camera=(), microphone=(), geolocation=(), payment=()",
    "Cross-Origin-Opener-Policy": "same-origin",
}


class SecurityHeadersMiddleware:
    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        response = self.get_response(request)
        for name, value in HEADERS.items():
            response.headers.setdefault(name, value)
        return response
