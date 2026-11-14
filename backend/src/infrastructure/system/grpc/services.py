"""``SystemController``: the admin System page's read (``Info``). Staff only.

The server version also answers unauthenticated over REST (``GET /api/version``) because a
client too old to sign in must be able to learn it is too old; everything else needs staff.
"""

from importlib import import_module
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.common.responses import ResponseTitle

INFO = [
    {"name": "version", "type": "string"},
    {"name": "min_client_version", "type": "string"},
    {"name": "api", "type": "string"},
    {"name": "commit", "type": "string"},
    {"name": "redis", "type": "string"},
    {"name": "broker", "type": "string"},
    {"name": "eager", "type": "bool"},
    {"name": "workers", "type": "int32"},
    {"name": "backlog", "type": "map<string,int32>"},
    {"name": "collect_device_info", "type": "bool"},
    {"name": "device_pepper_set", "type": "bool"},
]


def _info() -> Any:
    system_pb2: Any = import_module("infrastructure.system.grpc.system_pb2")
    from infrastructure.system.status import system_summary

    data = system_summary()
    queue = data["queue"]
    return system_pb2.SystemInfo(
        version=data["version"],
        min_client_version=data["min_client_version"],
        api=data["api"],
        commit=data["commit"],
        redis=queue.redis,
        broker=queue.broker,
        eager=queue.eager,
        workers=queue.workers,
        backlog=queue.backlog,
        collect_device_info=data["collect_device_info"],
        device_pepper_set=data["device_pepper_set"],
    )


def _set_collect_device_info(user: Any, enabled: bool) -> Any:
    from django.conf import settings

    from infrastructure.system import toggles

    if enabled and not settings.DEVICE_FINGERPRINT_PEPPER:
        raise ApiError(
            "Set DJANGO_DEVICE_FINGERPRINT_PEPPER on the server before turning this on.",
            status=409,
            title=ResponseTitle.CONFLICT,
        )
    toggles.set_enabled(toggles.COLLECT_DEVICE_INFO, enabled, by=user)
    return _info()


def _require_admin(user: Any) -> None:
    if not (user.is_staff or user.is_superuser):
        raise ApiError(
            "Only administrators can see the system status.",
            status=403,
            title=ResponseTitle.FORBIDDEN,
        )


class SystemService(generics.GenericService):
    @grpc_action(request=[], response=INFO, response_name="SystemInfo")
    @action
    async def Info(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        _require_admin(user)
        return await sync_to_async(_info)()

    @grpc_action(
        request=[{"name": "enabled", "type": "bool"}],
        request_name="SetCollectDeviceInfoRequest",
        response=INFO,
        response_name="SystemInfo",
    )
    @action
    async def SetCollectDeviceInfo(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        _require_admin(user)
        return await sync_to_async(_set_collect_device_info)(user, request.enabled)


GRPC_SERVICES = [SystemService]
