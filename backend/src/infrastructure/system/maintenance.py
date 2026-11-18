"""Maintenance mode: while ``MAINTENANCE_MODE`` is on, every REST route answers 503
``{"maintenance": true}`` and every gRPC call UNAVAILABLE with a message that says so, so a client
shows the maintenance screen instead of an error. Health, version and metrics (and the admin, so an
operator can still get in) stay up. It is read from the environment at start: change it and restart.
"""

from collections.abc import Awaitable, Callable
from typing import Any, Final

import grpc
from django.conf import settings
from django.http import HttpRequest, HttpResponse, JsonResponse

MESSAGE: Final = "The service is down for maintenance. Try again shortly."
RETRY_AFTER_SECONDS: Final = 60
EXEMPT_PATHS: Final = ("/api/health", "/api/version", "/metrics", "/admin")
EXEMPT_GRPC_PREFIXES: Final = ("/config.system.",)


def enabled() -> bool:
    return bool(getattr(settings, "MAINTENANCE_MODE", False))


class MaintenanceMiddleware:
    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        if not enabled() or request.path.startswith(EXEMPT_PATHS):
            return self.get_response(request)
        return JsonResponse(
            {"maintenance": True, "message": MESSAGE},
            status=503,
            headers={"Retry-After": str(RETRY_AFTER_SECONDS)},
        )


async def _refuse(request: Any, context: Any) -> Any:
    await context.abort(grpc.StatusCode.UNAVAILABLE, f"maintenance: {MESSAGE}")


async def _refuse_stream(request: Any, context: Any) -> Any:
    await context.abort(grpc.StatusCode.UNAVAILABLE, f"maintenance: {MESSAGE}")
    yield  # pragma: no cover - makes this an async generator; abort never returns


class MaintenanceInterceptor(grpc.aio.ServerInterceptor):
    async def intercept_service(
        self, continuation: Callable[[Any], Awaitable[Any]], handler_call_details: Any
    ) -> Any:
        handler = await continuation(handler_call_details)
        method = str(handler_call_details.method or "")
        if handler is None or not enabled() or method.startswith(EXEMPT_GRPC_PREFIXES):
            return handler
        kinds = {
            (False, False): grpc.unary_unary_rpc_method_handler,
            (False, True): grpc.unary_stream_rpc_method_handler,
            (True, False): grpc.stream_unary_rpc_method_handler,
            (True, True): grpc.stream_stream_rpc_method_handler,
        }
        make = kinds[(bool(handler.request_streaming), bool(handler.response_streaming))]
        return make(
            _refuse_stream if handler.response_streaming else _refuse,
            request_deserializer=handler.request_deserializer,
            response_serializer=handler.response_serializer,
        )


maintenance_interceptor = MaintenanceInterceptor()
