"""The unversioned operational routes: health, version, metrics.

Plain Django views rather than Ninja operations: they must answer without a credential, without
the API's envelope and throttles (a probe every few seconds would eat the anonymous budget), and
for a client too old to understand the current API. Public, and listed as such in
``infrastructure/common/public_routes.py``.
"""

import hmac

from django.conf import settings
from django.http import HttpRequest, HttpResponse, JsonResponse
from django.views.decorators.cache import never_cache
from django.views.decorators.http import require_GET

from infrastructure.common.services import health_service
from infrastructure.system import metrics, status
from infrastructure.system.version import version_info


@require_GET
@never_cache
def live(request: HttpRequest) -> JsonResponse:
    """The process answers. Checks nothing else, so a database outage never gets it restarted."""
    return JsonResponse({"status": "ok"})


@require_GET
@never_cache
def ready(request: HttpRequest) -> JsonResponse:
    """Whether the database (and Redis, when configured) are reachable: 200, else 503."""
    checks = {"database": "ok" if health_service.database_is_ready() else "unavailable"}
    redis_state = status.redis_state()
    if redis_state != "not_configured":
        checks["redis"] = redis_state
    healthy = all(state == "ok" for state in checks.values())
    return JsonResponse(
        {"status": "ok" if healthy else "unavailable", "checks": checks},
        status=200 if healthy else 503,
    )


@require_GET
@never_cache
def version(request: HttpRequest) -> JsonResponse:
    """The server's version and the oldest client it still supports."""
    return JsonResponse(version_info())


def _bearer(request: HttpRequest) -> str:
    header = request.headers.get("Authorization", "")
    scheme, _, token = header.partition(" ")
    return token.strip() if scheme.lower() == "bearer" else ""


@require_GET
@never_cache
def prometheus(request: HttpRequest) -> HttpResponse:
    """Prometheus scrape target, behind ``DJANGO_METRICS_TOKEN`` as a bearer token.

    No token configured: 404, so a deployment that does not scrape does not publish anything.
    """
    expected = str(getattr(settings, "METRICS_TOKEN", ""))
    if not expected:
        return HttpResponse(status=404)
    if not hmac.compare_digest(_bearer(request).encode(), expected.encode()):
        response = HttpResponse("Unauthorized\n", status=401, content_type="text/plain")
        response["WWW-Authenticate"] = 'Bearer realm="metrics"'
        return response
    return HttpResponse(metrics.render(), content_type="text/plain; version=0.0.4; charset=utf-8")
