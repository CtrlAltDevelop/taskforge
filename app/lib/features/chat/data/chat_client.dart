import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart'
    show errorTrailer;
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comments.dart' show Person;
import 'package:taskforge/features/tasks/data/tasks_client.dart'
    show mapTaskError;
import 'package:taskforge/features/tasks/domain/tasks.dart' show TaskFailure;
import 'package:taskforge/gen/infrastructure/chat/grpc/chat.pbgrpc.dart' as pb;

abstract interface class ChatClient {
  Future<SpaceList> listSpaces(
    String workspaceId, {
    String query = '',
    bool includeArchived = false,
  });

  Future<Space> createSpace(
    String workspaceId,
    SpaceKind kind,
    String name,
    List<String> memberIds,
  );

  Future<Space> openDm(String workspaceId, String userId);

  Future<Space> join(String workspaceId, String spaceId);

  Future<void> leave(String workspaceId, String spaceId);

  Future<Space> markRead(String workspaceId, String spaceId, String messageId);

  /// Neither [forever] nor [until] nor [completely]: unmute.
  Future<Space> mute(
    String workspaceId,
    String spaceId, {
    DateTime? until,
    bool forever = false,
    bool completely = false,
  });

  Future<Space> notify(
    String workspaceId,
    String spaceId, {
    required bool allMessages,
  });

  /// The newest messages of a space (or those before [before]; or the replies
  /// of [threadId]), oldest first.
  Future<MessagePage> listMessages(
    String workspaceId,
    String spaceId, {
    String before = '',
    String threadId = '',
    int pageSize = 50,
  });

  Future<ChatMessage> send(
    String workspaceId,
    String spaceId,
    String body, {
    String parentId = '',
    String clientId = '',
    String mutationId = '',
    bool confirmBroadcast = false,
    bool grantAccess = false,
  });

  Future<ChatMessage> edit(
    String workspaceId,
    ChatMessage message,
    String body, {
    bool confirmBroadcast = false,
    bool grantAccess = false,
  });

  Future<ChatMessage> delete(String workspaceId, ChatMessage message);

  Future<ChatMessage> react(
    String workspaceId,
    ChatMessage message,
    String emoji, {
    required bool on,
  });

  /// People who can see the space and match [query], and how many are in it.
  Future<({List<Person> people, int memberCount})> mentionable(
    String workspaceId,
    String spaceId, {
    String query = '',
  });
}

/// Maps whatever a call threw to what the screens understand.
ChatException mapChatError(Object error) {
  if (error is ChatException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    if (error.code == StatusCode.failedPrecondition &&
        title == 'CHAT_BROADCAST_CONFIRM') {
      final count = errorTrailer(error, 'x-error-member_count-bin');
      return ChatException(
        ChatFailure.broadcastConfirm,
        memberCount: int.tryParse(count) ?? 0,
      );
    }
    if (error.code == StatusCode.invalidArgument &&
        title == 'MENTION_NO_ACCESS') {
      final users = errorTrailer(error, 'x-error-users-bin');
      return ChatException(
        ChatFailure.mentionNoAccess,
        people: users.isEmpty ? const [] : users.split(','),
      );
    }
  }
  final task = mapTaskError(error);
  return ChatException(switch (task.failure) {
    TaskFailure.conflict => ChatFailure.conflict,
    TaskFailure.denied => ChatFailure.denied,
    TaskFailure.forbidden => ChatFailure.forbidden,
    TaskFailure.invalid => ChatFailure.invalid,
    TaskFailure.archived => ChatFailure.archived,
    TaskFailure.notFound => ChatFailure.notFound,
    TaskFailure.network => ChatFailure.network,
    _ => ChatFailure.other,
  }, detail: task.detail);
}

DateTime? _time(String iso) => iso.isEmpty ? null : DateTime.tryParse(iso);

Space spaceFromPb(pb.Space s) => Space(
  id: s.id,
  kind: SpaceKind.parse(s.kind),
  name: s.name,
  projectId: s.projectId,
  isDefault: s.isDefault,
  archived: s.archived,
  joined: s.joined,
  role: s.role,
  unreadCount: s.unreadCount,
  lastMessageAt: _time(s.lastMessageAt),
  lastReadAt: _time(s.lastReadAt),
  memberCount: s.memberCount,
  mutedUntil: _time(s.mutedUntil),
  mutedCompletely: s.mutedCompletely,
  notifyAll: s.notifyAll,
  readOnly: s.readOnly,
  peerId: s.peerId,
  version: s.version,
);

ChatMessage messageFromPb(pb.Message m) => ChatMessage(
  id: m.id,
  spaceId: m.spaceId,
  authorId: m.authorId,
  authorName: m.authorName,
  parentId: m.parentId,
  body: m.body,
  createdAt: DateTime.tryParse(m.createdAt) ?? DateTime.now(),
  editedAt: _time(m.editedAt),
  deleted: m.deleted,
  version: m.version,
  reactions: {
    for (final r in m.reactions) r.emoji: List.unmodifiable(r.userIds),
  },
);

class GrpcChatClient implements ChatClient {
  GrpcChatClient(ClientChannelBase channel, this._session)
    : _stub = pb.ChatControllerClient(channel);

  final pb.ChatControllerClient _stub;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapChatError(e);
    }
  }

  @override
  Future<SpaceList> listSpaces(
    String workspaceId, {
    String query = '',
    bool includeArchived = false,
  }) => _run(() async {
    final r = await _stub.listSpaces(
      pb.ChatListSpacesRequest(
        workspaceId: workspaceId,
        query: query,
        includeArchived: includeArchived,
      ),
      options: _options,
    );
    return SpaceList(
      channels: List.unmodifiable(r.channels.map(spaceFromPb)),
      groups: List.unmodifiable(r.groups.map(spaceFromPb)),
      dms: List.unmodifiable(r.dms.map(spaceFromPb)),
      taskChats: List.unmodifiable([
        for (final t in r.taskChats)
          TaskChatRef(
            taskId: t.taskId,
            projectId: t.projectId,
            displayId: t.displayId,
            title: t.title,
            lastMessageAt: _time(t.lastMessageAt),
          ),
      ]),
    );
  });

  @override
  Future<Space> createSpace(
    String workspaceId,
    SpaceKind kind,
    String name,
    List<String> memberIds,
  ) => _run(
    () async => spaceFromPb(
      await _stub.createSpace(
        pb.ChatCreateSpaceRequest(
          workspaceId: workspaceId,
          kind: kind.wire,
          name: name,
          memberIds: memberIds,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Space> openDm(String workspaceId, String userId) => _run(
    () async => spaceFromPb(
      await _stub.openDm(
        pb.ChatOpenDmRequest(workspaceId: workspaceId, userId: userId),
        options: _options,
      ),
    ),
  );

  @override
  Future<Space> join(String workspaceId, String spaceId) => _run(
    () async => spaceFromPb(
      await _stub.join(
        pb.ChatJoinRequest(workspaceId: workspaceId, spaceId: spaceId),
        options: _options,
      ),
    ),
  );

  @override
  Future<void> leave(String workspaceId, String spaceId) => _run(
    () async => _stub.leave(
      pb.ChatLeaveRequest(workspaceId: workspaceId, spaceId: spaceId),
      options: _options,
    ),
  );

  @override
  Future<Space> markRead(
    String workspaceId,
    String spaceId,
    String messageId,
  ) => _run(
    () async => spaceFromPb(
      await _stub.markRead(
        pb.ChatMarkReadRequest(
          workspaceId: workspaceId,
          spaceId: spaceId,
          messageId: messageId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Space> mute(
    String workspaceId,
    String spaceId, {
    DateTime? until,
    bool forever = false,
    bool completely = false,
  }) => _run(
    () async => spaceFromPb(
      await _stub.mute(
        pb.ChatMuteRequest(
          workspaceId: workspaceId,
          spaceId: spaceId,
          until: until?.toUtc().toIso8601String() ?? '',
          forever: forever,
          completely: completely,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Space> notify(
    String workspaceId,
    String spaceId, {
    required bool allMessages,
  }) => _run(
    () async => spaceFromPb(
      await _stub.notify(
        pb.ChatNotifyRequest(
          workspaceId: workspaceId,
          spaceId: spaceId,
          allMessages: allMessages,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<MessagePage> listMessages(
    String workspaceId,
    String spaceId, {
    String before = '',
    String threadId = '',
    int pageSize = 50,
  }) => _run(() async {
    final r = await _stub.listMessages(
      pb.ChatListMessagesRequest(
        workspaceId: workspaceId,
        spaceId: spaceId,
        before: before,
        threadId: threadId,
        pageSize: pageSize,
      ),
      options: _options,
    );
    return MessagePage(
      List.unmodifiable(r.messages.map(messageFromPb)),
      r.cursor,
    );
  });

  @override
  Future<ChatMessage> send(
    String workspaceId,
    String spaceId,
    String body, {
    String parentId = '',
    String clientId = '',
    String mutationId = '',
    bool confirmBroadcast = false,
    bool grantAccess = false,
  }) => _run(
    () async => messageFromPb(
      await _stub.send(
        pb.ChatSendRequest(
          workspaceId: workspaceId,
          spaceId: spaceId,
          body: body,
          parentId: parentId,
          clientId: clientId,
          clientMutationId: mutationId,
          confirmBroadcast: confirmBroadcast,
          grantAccess: grantAccess,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<ChatMessage> edit(
    String workspaceId,
    ChatMessage message,
    String body, {
    bool confirmBroadcast = false,
    bool grantAccess = false,
  }) => _run(
    () async => messageFromPb(
      await _stub.edit(
        pb.ChatEditRequest(
          workspaceId: workspaceId,
          spaceId: message.spaceId,
          id: message.id,
          expectedVersion: message.version,
          body: body,
          confirmBroadcast: confirmBroadcast,
          grantAccess: grantAccess,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<ChatMessage> delete(String workspaceId, ChatMessage message) => _run(
    () async => messageFromPb(
      await _stub.delete(
        pb.ChatDeleteRequest(
          workspaceId: workspaceId,
          spaceId: message.spaceId,
          id: message.id,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<ChatMessage> react(
    String workspaceId,
    ChatMessage message,
    String emoji, {
    required bool on,
  }) => _run(
    () async => messageFromPb(
      await _stub.react(
        pb.ChatReactRequest(
          workspaceId: workspaceId,
          spaceId: message.spaceId,
          id: message.id,
          emoji: emoji,
          on: on,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<({List<Person> people, int memberCount})> mentionable(
    String workspaceId,
    String spaceId, {
    String query = '',
  }) => _run(() async {
    final r = await _stub.mentionable(
      pb.ChatMentionableRequest(
        workspaceId: workspaceId,
        spaceId: spaceId,
        query: query,
      ),
      options: _options,
    );
    return (
      people: [for (final p in r.people) Person(p.userId, p.displayName)],
      memberCount: r.memberCount,
    );
  });
}
