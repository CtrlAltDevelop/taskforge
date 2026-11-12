"""A person's keyboard shortcuts over gRPC (``ShortcutController``): Get, Set.

Personal, not per workspace: any signed-in caller reads and writes only their own rows.
``Set`` binds ``action_id`` to ``keys`` (empty: unbound), or with ``reset`` drops the override.
INVALID_ARGUMENT SHORTCUT_INVALID for a chord that means nothing or one the browser keeps;
ALREADY_EXISTS SHORTCUT_CONFLICT (the other action in the error data) for a chord another
action of theirs already holds. The reply is the full list so a client never has to merge.
"""

from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.shortcuts import services
from infrastructure.shortcuts.grpc.serializers import Shortcut

LIST_RESPONSE = [{"name": "shortcuts", "cardinality": "repeated", "type": Shortcut}]


def _reply(user: Any) -> Any:
    from infrastructure.shortcuts.grpc import shortcuts_pb2

    return shortcuts_pb2.ShortcutList(
        shortcuts=[
            shortcuts_pb2.Shortcut(action_id=s.action_id, keys=s.keys) for s in services.get(user)
        ]
    )


class ShortcutService(generics.GenericService):
    @grpc_action(
        request=[],
        request_name="ShortcutGetRequest",
        response=LIST_RESPONSE,
        response_name="ShortcutList",
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))
        return await sync_to_async(_reply)(user)

    @grpc_action(
        request=[
            {"name": "action_id", "type": "string"},
            {"name": "keys", "type": "string"},
            {"name": "reset", "type": "bool"},
        ],
        request_name="ShortcutSetRequest",
        response=LIST_RESPONSE,
        response_name="ShortcutList",
    )
    @action
    async def Set(self, request: Any, context: Any) -> Any:
        user = require_caller(await grpc_caller(context))

        def run() -> Any:
            services.set_binding(user, request.action_id, request.keys, reset=request.reset)
            return _reply(user)

        return await sync_to_async(run)()


GRPC_SERVICES = [ShortcutService]
