import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/features/chat/data/chat_client.dart';
import 'package:taskforge/features/chat/data/chat_codecs.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comments.dart'
    show Person, SendState;
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart'
    show OfflineEnv;

/// Chat that can be written without a connection.
///
/// Spaces and messages are copied into the local database as they are read and
/// answered from there when the server cannot be reached. A message written
/// offline shows at once (as sending) and goes into the outbox with its own id
/// as client id, so a send that was cut off is repeated safely; everything
/// else (reacting, editing, joining ...) needs the server and fails with
/// [ChatFailure.network] meanwhile.
class OfflineChatClient implements ChatClient {
  OfflineChatClient(this._inner, this._env);

  final ChatClient _inner;
  final OfflineEnv _env;

  static const _offline = ChatException(ChatFailure.network);

  Future<T> _call<T>(Future<T> Function() call) async {
    if (!_env.online()) throw _offline;
    try {
      final result = await call();
      _env.worked();
      return result;
    } on ChatException catch (e) {
      if (e.failure == ChatFailure.network) _env.failed();
      rethrow;
    }
  }

  Future<List<ChatMessage>> _waiting(
    OfflineStore store,
    String workspaceId,
    String spaceId,
  ) async => [
    for (final e in await store.queue(workspaceId))
      if (e.entity == OutboxEntity.chat && e.payload['spaceId'] == spaceId)
        _local(e),
  ];

  ChatMessage _local(OutboxEntry e) => ChatMessage(
    id: e.entityId,
    spaceId: '${e.payload['spaceId']}',
    authorId: '${e.payload['authorId'] ?? ''}',
    parentId: '${e.payload['parentId'] ?? ''}',
    body: '${e.payload['body'] ?? ''}',
    createdAt: e.createdAt,
    version: 0,
    sendState: e.state.needsAttention ? SendState.failed : SendState.sending,
  );

  @override
  Future<SpaceList> listSpaces(
    String workspaceId, {
    String query = '',
    bool includeArchived = false,
  }) async {
    final store = await _env.store();
    if (_env.online()) {
      try {
        final list = await _call(
          () => _inner.listSpaces(
            workspaceId,
            query: query,
            includeArchived: includeArchived,
          ),
        );
        if (store != null && query.isEmpty) {
          await store.putAll(workspaceId, Kinds.chatSpace, [
            for (final s in list.all)
              (id: s.id, json: spaceToJson(s), version: s.version),
          ]);
          await store.sweep(workspaceId, Kinds.chatSpace, '', {
            for (final s in list.all) s.id,
          });
        }
        return list;
      } on ChatException catch (e) {
        if (e.failure != ChatFailure.network || store == null) rethrow;
      }
    }
    if (store == null) throw _offline;
    final cached = [
      for (final j in await store.list(workspaceId, Kinds.chatSpace))
        spaceFromJson(j),
    ];
    return SpaceList(
      channels: [
        for (final s in cached)
          if (s.kind == SpaceKind.channel) s,
      ],
      groups: [
        for (final s in cached)
          if (s.kind == SpaceKind.group) s,
      ],
      dms: [
        for (final s in cached)
          if (s.kind == SpaceKind.dm) s,
      ],
    );
  }

  @override
  Future<MessagePage> listMessages(
    String workspaceId,
    String spaceId, {
    String before = '',
    String threadId = '',
    int pageSize = 50,
  }) async {
    final store = await _env.store();
    if (_env.online()) {
      try {
        final page = await _call(
          () => _inner.listMessages(
            workspaceId,
            spaceId,
            before: before,
            threadId: threadId,
            pageSize: pageSize,
          ),
        );
        if (store != null) {
          await store.putAll(workspaceId, Kinds.chatMessage, [
            for (final m in page.messages)
              (id: m.id, json: chatMessageToJson(m), version: m.version),
          ], scope: spaceId);
        }
        final waiting = store != null && before.isEmpty && threadId.isEmpty
            ? await _waiting(store, workspaceId, spaceId)
            : <ChatMessage>[];
        final have = {for (final m in page.messages) m.id};
        return MessagePage([
          ...page.messages,
          for (final m in waiting)
            if (!have.contains(m.id)) m,
        ], page.cursor);
      } on ChatException catch (e) {
        if (e.failure != ChatFailure.network || store == null) rethrow;
      }
    }
    if (store == null) throw _offline;
    final cached = [
      for (final j in await store.list(
        workspaceId,
        Kinds.chatMessage,
        scope: spaceId,
      ))
        chatMessageFromJson(j),
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final sent = {for (final m in cached) m.id};
    return MessagePage([
      for (final m in cached)
        if (threadId.isEmpty || m.parentId == threadId) m,
      for (final m in await _waiting(store, workspaceId, spaceId))
        if (!sent.contains(m.id)) m,
    ], '');
  }

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
  }) async {
    final id = clientId.isEmpty ? _env.newId() : clientId;
    final mutation = mutationId.isEmpty ? _env.newId() : mutationId;
    final store = await _env.store();
    if (_env.online()) {
      try {
        final made = await _call(
          () => _inner.send(
            workspaceId,
            spaceId,
            body,
            parentId: parentId,
            clientId: id,
            mutationId: mutation,
            confirmBroadcast: confirmBroadcast,
            grantAccess: grantAccess,
          ),
        );
        await store?.put(
          workspaceId,
          Kinds.chatMessage,
          made.id,
          chatMessageToJson(made),
          scope: spaceId,
          version: made.version,
        );
        return made;
      } on ChatException catch (e) {
        if (e.failure != ChatFailure.network || store == null) rethrow;
      }
    }
    if (store == null) throw _offline;
    final entry = OutboxEntry(
      workspaceId: workspaceId,
      entity: OutboxEntity.chat,
      entityId: id,
      op: OutboxOp.create,
      mutationId: mutation,
      createdAt: _env.now(),
      payload: {
        'spaceId': spaceId,
        'body': body,
        'parentId': parentId,
        'confirmBroadcast': confirmBroadcast,
        'grantAccess': grantAccess,
        'authorId': _env.me(),
      },
    );
    await store.enqueue(entry);
    return _local(entry);
  }

  @override
  Future<Space> createSpace(
    String workspaceId,
    SpaceKind kind,
    String name,
    List<String> memberIds,
  ) => _call(() => _inner.createSpace(workspaceId, kind, name, memberIds));

  @override
  Future<Space> openDm(String workspaceId, String userId) =>
      _call(() => _inner.openDm(workspaceId, userId));

  @override
  Future<Space> join(String workspaceId, String spaceId) =>
      _call(() => _inner.join(workspaceId, spaceId));

  @override
  Future<void> leave(String workspaceId, String spaceId) =>
      _call(() => _inner.leave(workspaceId, spaceId));

  @override
  Future<Space> markRead(
    String workspaceId,
    String spaceId,
    String messageId,
  ) => _call(() => _inner.markRead(workspaceId, spaceId, messageId));

  @override
  Future<Space> mute(
    String workspaceId,
    String spaceId, {
    DateTime? until,
    bool forever = false,
    bool completely = false,
  }) => _call(
    () => _inner.mute(
      workspaceId,
      spaceId,
      until: until,
      forever: forever,
      completely: completely,
    ),
  );

  @override
  Future<Space> notify(
    String workspaceId,
    String spaceId, {
    required bool allMessages,
  }) => _call(
    () => _inner.notify(workspaceId, spaceId, allMessages: allMessages),
  );

  @override
  Future<ChatMessage> edit(
    String workspaceId,
    ChatMessage message,
    String body, {
    bool confirmBroadcast = false,
    bool grantAccess = false,
  }) => _call(
    () => _inner.edit(
      workspaceId,
      message,
      body,
      confirmBroadcast: confirmBroadcast,
      grantAccess: grantAccess,
    ),
  );

  @override
  Future<ChatMessage> delete(String workspaceId, ChatMessage message) =>
      _call(() => _inner.delete(workspaceId, message));

  @override
  Future<ChatMessage> react(
    String workspaceId,
    ChatMessage message,
    String emoji, {
    required bool on,
  }) => _call(() => _inner.react(workspaceId, message, emoji, on: on));

  @override
  Future<({List<Person> people, int memberCount})> mentionable(
    String workspaceId,
    String spaceId, {
    String query = '',
  }) => _call(() => _inner.mentionable(workspaceId, spaceId, query: query));
}
