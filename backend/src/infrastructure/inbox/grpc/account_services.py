"""The caller's own notification choices (``PrefController``: Get, Set, SetSettings) and the
devices they can be pushed to (``DeviceController``: Register, Unregister). Account-level: they
belong to the person, not to a workspace."""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.inbox import prefs
from infrastructure.inbox.grpc.serializers import InboxSettings, PrefRow


def _pb() -> Any:
    from infrastructure.inbox.grpc import inbox_pb2

    return inbox_pb2


def _answer(data: dict[str, Any]) -> Any:
    pb = _pb()
    return pb.PrefsAnswer(
        prefs=[pb.PrefRow(**row) for row in data["prefs"]],
        settings=pb.InboxSettings(**data["settings"]),
    )


ANSWER = {
    "response": [
        {"name": "prefs", "cardinality": "repeated", "type": PrefRow},
        {"name": "settings", "type": InboxSettings},
    ],
    "response_name": "PrefsAnswer",
}


class PrefService(generics.GenericService):
    @grpc_action(request=[], request_name="PrefsGetRequest", **ANSWER)
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        return await sync_to_async(lambda: _answer(prefs.get(user)))()

    @grpc_action(
        request=[
            {"name": "event_type", "type": "string"},
            {"name": "inbox", "type": "bool"},
            {"name": "push", "type": "bool"},
            {"name": "email_mode", "type": "string"},
        ],
        request_name="PrefSetRequest",
        **ANSWER,
    )
    @action
    async def Set(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))

        def write() -> Any:
            prefs.set_pref(
                user,
                request.event_type,
                inbox=request.inbox,
                push=request.push,
                email_mode=request.email_mode,
            )
            return _answer(prefs.get(user))

        return await sync_to_async(write)()

    @grpc_action(
        request=[
            {"name": "timezone", "type": "string"},
            {"name": "quiet_start", "type": "string"},
            {"name": "quiet_end", "type": "string"},
            {"name": "digest_hour", "type": "int32"},
        ],
        request_name="SettingsSetRequest",
        **ANSWER,
    )
    @action
    async def SetSettings(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))

        def write() -> Any:
            prefs.set_settings(
                user,
                timezone=request.timezone,
                quiet_start=request.quiet_start,
                quiet_end=request.quiet_end,
                digest_hour=request.digest_hour,
            )
            return _answer(prefs.get(user))

        return await sync_to_async(write)()


class DeviceService(generics.GenericService):
    @grpc_action(
        request=[{"name": "platform", "type": "string"}, {"name": "token", "type": "string"}],
        request_name="DeviceRegisterRequest",
        response=[{"name": "registered", "type": "bool"}],
        response_name="DeviceAnswer",
    )
    @action
    async def Register(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        await sync_to_async(lambda: prefs.register_device(user, request.platform, request.token))()
        return _pb().DeviceAnswer(registered=True)

    @grpc_action(
        request=[{"name": "token", "type": "string"}],
        request_name="DeviceUnregisterRequest",
        response=[{"name": "registered", "type": "bool"}],
        response_name="DeviceAnswer",
    )
    @action
    async def Unregister(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        await sync_to_async(lambda: prefs.unregister_device(user, request.token))()
        return _pb().DeviceAnswer(registered=False)
