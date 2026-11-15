"""Chat over gRPC (``ChatController``): ListSpaces, CreateSpace, UpdateSpace, Join, Leave,
AddMembers, RemoveMember, OpenDm, ListMessages, Send, Edit, Delete, React, MarkRead, Mute, Notify,
Mentionable.

Every call needs ``chat.read`` (PERMISSION_DENIED) and a space the caller can see: a private group
or direct message of other people, like a space of another workspace, is NOT_FOUND. Writing needs
``chat.post`` and being in the space (a read-only space: FAILED_PRECONDITION CHAT_READ_ONLY).
``Send`` with ``confirm_broadcast`` unset on a space over 50 members and an @channel/@here is
FAILED_PRECONDITION CHAT_BROADCAST_CONFIRM with ``x-error-member_count-bin``. ``ListMessages``
returns the newest ``page_size`` messages oldest first and a ``cursor`` for ``before``. Rules and
queries are in ``infrastructure.chat.services`` and ``infrastructure.chat.messages``.
"""

import json
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.chat import messages, services
from infrastructure.chat.grpc.serializers import Message, Person, Space, TaskChat
from infrastructure.chat.models import ChatMessage, ChatSpace
from infrastructure.comments import mentions
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.workspaces.scoping import require_workspace

WS = [{"name": "workspace_id", "type": "string"}]
SPACE = [*WS, {"name": "space_id", "type": "string"}]
ONE = [*SPACE, {"name": "id", "type": "string"}]


def _pb() -> Any:
    from infrastructure.chat.grpc import chat_pb2

    return chat_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def _space(space: ChatSpace) -> Any:
    row = getattr(space, "my_row", None)
    return _pb().Space(
        id=str(space.pk),
        kind=space.kind,
        name=getattr(space, "display_name", space.name),
        project_id=str(space.project_id or ""),
        is_default=space.is_default,
        archived=space.is_archived,
        joined=getattr(space, "joined", False),
        role=getattr(space, "my_role", ""),
        unread_count=getattr(space, "unread", 0),
        last_message_at=_iso(getattr(space, "last_message_at", None)),
        last_read_at=_iso(row.last_read_at if row else None),
        member_count=getattr(space, "member_count", 0),
        muted_until=_iso(row.muted_until if row and row.muted else None),
        muted_completely=bool(row and row.muted and row.muted_completely),
        notify_all=bool(row and row.notify_all),
        read_only=getattr(space, "read_only", False),
        peer_id=getattr(space, "peer_id", ""),
        version=space.version,
        created_at=_iso(space.created_at),
        created_by=str(space.created_by_id or ""),
    )


def _message(message: ChatMessage) -> Any:
    return _pb().Message(
        id=str(message.pk),
        space_id=str(message.space_id),
        author_id=str(message.author_id),
        author_name=getattr(message, "author_name", ""),
        parent_id=str(message.parent_id or ""),
        body=json.dumps(message.body) if message.body else "",
        created_at=_iso(message.created_at),
        edited_at=_iso(message.edited_at),
        deleted=message.is_deleted,
        version=message.version,
        reactions=[
            _pb().ReactionResponse(emoji=e, user_ids=u)
            for e, u in getattr(message, "reaction_map", {}).items()
        ],
    )


async def _scope(request: Any, context: Any) -> tuple[Any, Any]:
    user = require_caller(await grpc_caller(context))
    return user, await sync_to_async(require_workspace)(user, request.workspace_id)


class ChatService(generics.GenericService):
    @grpc_action(
        request=[
            *WS,
            {"name": "query", "type": "string"},
            {"name": "include_archived", "type": "bool"},
        ],
        request_name="ChatListSpacesRequest",
        response=[
            {"name": "channels", "cardinality": "repeated", "type": Space},
            {"name": "groups", "cardinality": "repeated", "type": Space},
            {"name": "dms", "cardinality": "repeated", "type": Space},
            {"name": "task_chats", "cardinality": "repeated", "type": TaskChat},
        ],
        response_name="ChatSpaceList",
    )
    @action
    async def ListSpaces(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            found = services.list_spaces(
                user,
                workspace,
                query=request.query,
                include_archived=request.include_archived,
            )
            return _pb().ChatSpaceList(
                channels=[_space(s) for s in found.channels],
                groups=[_space(s) for s in found.groups],
                dms=[_space(s) for s in found.dms],
                task_chats=[_pb().TaskChat(**t) for t in found.task_chats],
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=[
            *WS,
            {"name": "kind", "type": "string"},
            {"name": "name", "type": "string"},
            {"name": "member_ids", "cardinality": "repeated", "type": "string"},
        ],
        request_name="ChatCreateSpaceRequest",
        response=Space,
        response_name="Space",
    )
    @action
    async def CreateSpace(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(
                services.create_space(
                    user, workspace, request.kind, request.name, list(request.member_ids)
                )
            )
        )()

    @grpc_action(
        request=[
            *SPACE,
            {"name": "name", "type": "string"},
            {"name": "set_archived", "type": "bool"},
            {"name": "archived", "type": "bool"},
        ],
        request_name="ChatUpdateSpaceRequest",
        response=Space,
        response_name="Space",
    )
    @action
    async def UpdateSpace(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(
                services.update_space(
                    user,
                    workspace,
                    request.space_id,
                    name=request.name,
                    set_archived=request.set_archived,
                    archived=request.archived,
                )
            )
        )()

    @grpc_action(
        request=SPACE, request_name="ChatJoinRequest", response=Space, response_name="Space"
    )
    @action
    async def Join(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(services.join(user, workspace, request.space_id))
        )()

    @grpc_action(
        request=SPACE,
        request_name="ChatLeaveRequest",
        response=[{"name": "ok", "type": "bool"}],
        response_name="ChatDone",
    )
    @action
    async def Leave(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        await sync_to_async(services.leave)(user, workspace, request.space_id)
        return _pb().ChatDone(ok=True)

    @grpc_action(
        request=[*SPACE, {"name": "user_ids", "cardinality": "repeated", "type": "string"}],
        request_name="ChatAddMembersRequest",
        response=Space,
        response_name="Space",
    )
    @action
    async def AddMembers(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(
                services.add_members(user, workspace, request.space_id, list(request.user_ids))
            )
        )()

    @grpc_action(
        request=[*SPACE, {"name": "user_id", "type": "string"}],
        request_name="ChatRemoveMemberRequest",
        response=[{"name": "ok", "type": "bool"}],
        response_name="ChatDone",
    )
    @action
    async def RemoveMember(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        await sync_to_async(services.remove_member)(
            user, workspace, request.space_id, request.user_id
        )
        return _pb().ChatDone(ok=True)

    @grpc_action(
        request=[*WS, {"name": "user_id", "type": "string"}],
        request_name="ChatOpenDmRequest",
        response=Space,
        response_name="Space",
    )
    @action
    async def OpenDm(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(services.open_dm(user, workspace, request.user_id))
        )()

    @grpc_action(
        request=[
            *SPACE,
            {"name": "before", "type": "string"},
            {"name": "page_size", "type": "int32"},
            {"name": "thread_id", "type": "string"},
        ],
        request_name="ChatListMessagesRequest",
        response=[
            {"name": "messages", "cardinality": "repeated", "type": Message},
            {"name": "cursor", "type": "string"},
        ],
        response_name="ChatMessagePage",
    )
    @action
    async def ListMessages(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            page = messages.list_page(
                user,
                workspace,
                request.space_id,
                before=request.before,
                limit=request.page_size,
                thread_id=request.thread_id,
            )
            return _pb().ChatMessagePage(
                messages=[_message(m) for m in page.messages], cursor=page.cursor
            )

        return await sync_to_async(read)()

    @grpc_action(
        request=[
            *SPACE,
            {"name": "body", "type": "string"},
            {"name": "parent_id", "type": "string"},
            {"name": "client_id", "type": "string"},
            {"name": "client_mutation_id", "type": "string"},
            {"name": "confirm_broadcast", "type": "bool"},
            {"name": "grant_access", "type": "bool"},
        ],
        request_name="ChatSendRequest",
        response=Message,
        response_name="Message",
    )
    @action
    async def Send(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                messages.send(
                    user,
                    workspace,
                    request.space_id,
                    request.body,
                    parent_id=request.parent_id,
                    client_id=request.client_id,
                    client_mutation_id=request.client_mutation_id,
                    confirm_broadcast=request.confirm_broadcast,
                    grant_access=request.grant_access,
                )
            )
        )()

    @grpc_action(
        request=[
            *ONE,
            {"name": "expected_version", "type": "int32"},
            {"name": "body", "type": "string"},
            {"name": "confirm_broadcast", "type": "bool"},
            {"name": "grant_access", "type": "bool"},
        ],
        request_name="ChatEditRequest",
        response=Message,
        response_name="Message",
    )
    @action
    async def Edit(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                messages.edit(
                    user,
                    workspace,
                    request.space_id,
                    request.id,
                    request.expected_version,
                    request.body,
                    grant_access=request.grant_access,
                    confirm_broadcast=request.confirm_broadcast,
                )
            )
        )()

    @grpc_action(
        request=ONE, request_name="ChatDeleteRequest", response=Message, response_name="Message"
    )
    @action
    async def Delete(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(messages.delete(user, workspace, request.space_id, request.id))
        )()

    @grpc_action(
        request=[*ONE, {"name": "emoji", "type": "string"}, {"name": "on", "type": "bool"}],
        request_name="ChatReactRequest",
        response=Message,
        response_name="Message",
    )
    @action
    async def React(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _message(
                messages.react(
                    user, workspace, request.space_id, request.id, request.emoji, request.on
                )
            )
        )()

    @grpc_action(
        request=[*SPACE, {"name": "message_id", "type": "string"}],
        request_name="ChatMarkReadRequest",
        response=Space,
        response_name="Space",
    )
    @action
    async def MarkRead(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(
                services.mark_read(user, workspace, request.space_id, request.message_id)
            )
        )()

    @grpc_action(
        request=[
            *SPACE,
            {"name": "until", "type": "string"},
            {"name": "forever", "type": "bool"},
            {"name": "completely", "type": "bool"},
        ],
        request_name="ChatMuteRequest",
        response=Space,
        response_name="Space",
    )
    @action
    async def Mute(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(
                services.mute(
                    user,
                    workspace,
                    request.space_id,
                    until=request.until,
                    forever=request.forever,
                    completely=request.completely,
                )
            )
        )()

    @grpc_action(
        request=[*SPACE, {"name": "all_messages", "type": "bool"}],
        request_name="ChatNotifyRequest",
        response=Space,
        response_name="Space",
    )
    @action
    async def Notify(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)
        return await sync_to_async(
            lambda: _space(
                services.set_notify(user, workspace, request.space_id, request.all_messages)
            )
        )()

    @grpc_action(
        request=[*SPACE, {"name": "query", "type": "string"}],
        request_name="ChatMentionableRequest",
        response=[
            {"name": "people", "cardinality": "repeated", "type": Person},
            {"name": "member_count", "type": "int32"},
        ],
        response_name="ChatMentionable",
    )
    @action
    async def Mentionable(self, request: Any, context: Any) -> Any:
        user, workspace = await _scope(request, context)

        def read() -> Any:
            found, count = services.mentionable(user, workspace, request.space_id, request.query)
            return _pb().ChatMentionable(
                people=[
                    _pb().Person(user_id=str(u.pk), display_name=mentions.display_name(u))
                    for u in found
                ],
                member_count=count,
            )

        return await sync_to_async(read)()


GRPC_SERVICES = [ChatService]
