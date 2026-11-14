"""Tell the gRPC callers which method was called, so a DPoP proof can be checked against it.

grpc.aio never shows a servicer the path of the call it is serving, and a proof's ``htu`` is
exactly that path (``<origin>/<package.Service>/<Method>``). A server interceptor sees it, and
leaves it in a context variable that ``common.identity.grpc_caller`` reads in the same task.
Registered through ``GRPC_FRAMEWORK["SERVER_INTERCEPTORS"]``.
"""

import contextvars
from collections.abc import Awaitable, Callable
from typing import Any

import grpc

CURRENT_METHOD: contextvars.ContextVar[str] = contextvars.ContextVar(
    "taskforge_grpc_method", default=""
)


class MethodPathInterceptor(grpc.aio.ServerInterceptor):
    async def intercept_service(
        self,
        continuation: Callable[[Any], Awaitable[Any]],
        handler_call_details: Any,
    ) -> Any:
        CURRENT_METHOD.set(str(handler_call_details.method or ""))
        return await continuation(handler_call_details)


# The setting names this instance: django-socio-grpc imports the string and hands it to grpc.
method_path_interceptor = MethodPathInterceptor()
