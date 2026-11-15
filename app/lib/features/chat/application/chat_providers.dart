import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/chat/data/chat_client.dart';
import 'package:taskforge/features/chat/data/offline_chat_client.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comments.dart'
    show Person, SendState;
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// The server's chat, with nothing local in between (the outbox sends with
/// this).
final rawChatClientProvider = Provider<ChatClient>(
  (ref) => GrpcChatClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// What the app uses: chat that can be written without a connection.
final chatClientProvider = Provider<ChatClient>(
  (ref) => OfflineChatClient(
    ref.watch(rawChatClientProvider),
    ref.watch(offlineEnvProvider),
  ),
);

/// This person's id as the server names them in chat.
final chatMeProvider = Provider<String>(
  (ref) => ref.watch(accountProvider).value?.id ?? '',
);

@immutable
class SpacesState {
  const SpacesState({
    this.list = const SpaceList(),
    this.loading = true,
    this.error,
  });

  final SpaceList list;
  final bool loading;
  final ChatException? error;

  SpacesState copyWith({
    SpaceList? list,
    bool? loading,
    ChatException? Function()? error,
  }) => SpacesState(
    list: list ?? this.list,
    loading: loading ?? this.loading,
    error: error == null ? this.error : error(),
  );
}

/// Every place to talk in the current workspace. Kept alive so the unread
/// badge in the navigation follows even while Chat is closed.
final spacesProvider = NotifierProvider<SpacesNotifier, SpacesState>(
  SpacesNotifier.new,
);

/// What the Chat entry's badge shows.
final chatUnreadProvider = Provider<int>(
  (ref) => unreadTotal(ref.watch(spacesProvider).list),
);

class SpacesNotifier extends Notifier<SpacesState> {
  var _generation = 0;

  ChatClient get _client => ref.read(chatClientProvider);

  String? get _workspace => ref.read(workspaceScopeProvider);

  @override
  SpacesState build() {
    ref.watch(workspaceScopeProvider);
    ref.listen(outboxDrainedProvider, (_, _) => unawaited(refresh()));
    Future.microtask(load);
    return const SpacesState();
  }

  /// Reads the list again (what is on screen stays until it is here).
  Future<void> load() async {
    final workspace = _workspace;
    if (workspace == null) {
      state = state.copyWith(loading: false);
      return;
    }
    final generation = ++_generation;
    try {
      final list = await _client.listSpaces(workspace);
      if (generation != _generation || !ref.mounted) return;
      state = SpacesState(list: list, loading: false);
    } on Object catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => mapChatError(e));
    }
  }

  Future<void> refresh() => load();

  /// Puts [space] (what the server answered) in the list.
  void apply(Space space) =>
      state = state.copyWith(list: state.list.withSpace(space));

  Future<Space> create(
    SpaceKind kind,
    String name,
    List<String> members,
  ) async {
    final space = await _call(
      (ws) => _client.createSpace(ws, kind, name, members),
    );
    apply(space);
    return space;
  }

  Future<Space> openDm(String userId) async {
    final space = await _call((ws) => _client.openDm(ws, userId));
    apply(space);
    return space;
  }

  Future<void> join(String spaceId) async {
    apply(await _call((ws) => _client.join(ws, spaceId)));
  }

  Future<void> leave(String spaceId) async {
    await _call((ws) => _client.leave(ws, spaceId));
    unawaited(refresh());
  }

  Future<void> mute(
    String spaceId, {
    DateTime? until,
    bool forever = false,
    bool completely = false,
  }) async {
    apply(
      await _call(
        (ws) => _client.mute(
          ws,
          spaceId,
          until: until,
          forever: forever,
          completely: completely,
        ),
      ),
    );
  }

  Future<void> notify(String spaceId, {required bool allMessages}) async {
    apply(
      await _call(
        (ws) => _client.notify(ws, spaceId, allMessages: allMessages),
      ),
    );
  }

  /// Marks the space read up to [messageId]; the badge drops at once.
  Future<void> markRead(String spaceId, String messageId) async {
    final before = state.list.byId(spaceId);
    if (before == null) return;
    apply(before.copyWith(unreadCount: 0, lastReadAt: DateTime.now()));
    try {
      final saved = await _call(
        (ws) => _client.markRead(ws, spaceId, messageId),
      );
      if (ref.mounted) apply(saved);
    } on ChatException {
      if (ref.mounted) apply(before);
    }
  }

  Future<T> _call<T>(Future<T> Function(String workspace) call) async {
    final ws = _workspace;
    if (ws == null) throw const ChatException(ChatFailure.other);
    return call(ws);
  }
}

@immutable
class MessagesState {
  const MessagesState({
    this.messages = const [],
    this.cursor = '',
    this.loading = true,
    this.loadingEarlier = false,
    this.error,
  });

  /// Oldest first, replies included (the screen nests them).
  final List<ChatMessage> messages;
  final String cursor;
  final bool loading;
  final bool loadingEarlier;
  final ChatException? error;

  bool get hasEarlier => cursor.isNotEmpty;

  MessagesState copyWith({
    List<ChatMessage>? messages,
    String? cursor,
    bool? loading,
    bool? loadingEarlier,
    ChatException? Function()? error,
  }) => MessagesState(
    messages: messages ?? this.messages,
    cursor: cursor ?? this.cursor,
    loading: loading ?? this.loading,
    loadingEarlier: loadingEarlier ?? this.loadingEarlier,
    error: error == null ? this.error : error(),
  );
}

/// The messages of one space: the newest page first, earlier ones on request;
/// what is sent shows at once as "sending" (with its id as client id, so the
/// live copy of the same message is the same message).
final messagesProvider = NotifierProvider.autoDispose
    .family<MessagesNotifier, MessagesState, String>(MessagesNotifier.new);

class MessagesNotifier extends Notifier<MessagesState> {
  MessagesNotifier(this.spaceId);

  final String spaceId;
  var _generation = 0;

  final _pending =
      <String, ({String body, String parentId, bool grant, bool confirm})>{};

  ChatClient get _client => ref.read(chatClientProvider);

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const ChatException(ChatFailure.other);
    return id;
  }

  @override
  MessagesState build() {
    ref.watch(workspaceScopeProvider);
    ref.listen(outboxDrainedProvider, (_, _) => unawaited(refresh()));
    Future.microtask(load);
    return const MessagesState();
  }

  Future<void> load() async {
    final generation = ++_generation;
    try {
      final page = await _client.listMessages(_workspace, spaceId);
      if (generation != _generation || !ref.mounted) return;
      final known = {for (final m in page.messages) m.id};
      final first = page.messages.isEmpty
          ? null
          : page.messages.first.createdAt;
      state = MessagesState(
        messages: List.unmodifiable([
          // Earlier pages already loaded stay.
          if (first != null)
            for (final m in state.messages)
              if (!m.isLocal && m.createdAt.isBefore(first)) m,
          ...page.messages,
          for (final m in state.messages)
            if (m.isLocal && !known.contains(m.id)) m,
        ]),
        cursor:
            state.cursor.isNotEmpty &&
                state.messages.length > page.messages.length
            ? state.cursor
            : page.cursor,
        loading: false,
      );
    } on ChatException catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  Future<void> refresh() => load();

  Future<void> loadEarlier() async {
    if (!state.hasEarlier || state.loadingEarlier) return;
    state = state.copyWith(loadingEarlier: true);
    try {
      final page = await _client.listMessages(
        _workspace,
        spaceId,
        before: state.cursor,
      );
      if (!ref.mounted) return;
      var next = state.messages;
      for (final m in page.messages) {
        next = upsertMessage(next, m);
      }
      state = state.copyWith(
        messages: next,
        cursor: page.cursor,
        loadingEarlier: false,
      );
    } on ChatException {
      if (ref.mounted) state = state.copyWith(loadingEarlier: false);
    }
  }

  /// Reads the replies of [parentId] into the list.
  Future<void> loadThread(String parentId) async {
    try {
      final page = await _client.listMessages(
        _workspace,
        spaceId,
        threadId: parentId,
      );
      if (!ref.mounted) return;
      var next = state.messages;
      for (final m in page.messages) {
        next = upsertMessage(next, m);
      }
      state = state.copyWith(messages: next);
    } on ChatException {
      // The thread shows what is already here.
    }
  }

  /// Puts a message that arrived (or was answered) in the list.
  void apply(ChatMessage message) =>
      state = state.copyWith(messages: upsertMessage(state.messages, message));

  // ---------------------------------------------------------------- sending

  /// Sends a message (or a reply to [parentId]). It shows at once; the
  /// returned future ends when the server has answered. A refusal that needs
  /// an answer from the person ([ChatFailure.broadcastConfirm],
  /// [ChatFailure.mentionNoAccess]) takes the draft back and is thrown, for
  /// the screen to ask and send again with the matching flag; any other
  /// failure stays on the message ("failed", with retry) and is thrown too.
  Future<void> send(
    String body, {
    String parentId = '',
    bool confirmBroadcast = false,
    bool grantAccess = false,
  }) async {
    final id = newClientId();
    _pending[id] = (
      body: body,
      parentId: parentId,
      grant: grantAccess,
      confirm: confirmBroadcast,
    );
    state = state.copyWith(
      messages: upsertMessage(
        state.messages,
        ChatMessage(
          id: id,
          spaceId: spaceId,
          authorId: ref.read(chatMeProvider),
          parentId: parentId,
          body: body,
          createdAt: DateTime.now(),
          version: 0,
          sendState: SendState.sending,
        ),
      ),
    );
    await _transmit(id);
  }

  Future<void> retry(String id) async {
    if (!_pending.containsKey(id)) return;
    _swap(id, (m) => m.copyWith(sendState: SendState.sending));
    await _transmit(id);
  }

  void discard(String id) {
    _pending.remove(id);
    _drop(id);
  }

  void _drop(String id) => state = state.copyWith(
    messages: [
      for (final m in state.messages)
        if (m.id != id) m,
    ],
  );

  Future<void> _transmit(String id) async {
    final job = _pending[id];
    if (job == null) return;
    try {
      final saved = await _client.send(
        _workspace,
        spaceId,
        job.body,
        parentId: job.parentId,
        clientId: id,
        confirmBroadcast: job.confirm,
        grantAccess: job.grant,
      );
      _pending.remove(id);
      if (!ref.mounted) return;
      apply(saved);
    } on ChatException catch (e) {
      if (e.failure == ChatFailure.broadcastConfirm ||
          e.failure == ChatFailure.mentionNoAccess) {
        _pending.remove(id);
        if (ref.mounted) _drop(id);
      } else if (ref.mounted) {
        _swap(id, (m) => m.copyWith(sendState: SendState.failed));
      }
      rethrow;
    }
  }

  void _swap(String id, ChatMessage Function(ChatMessage) change) {
    state = state.copyWith(
      messages: [for (final m in state.messages) m.id == id ? change(m) : m],
    );
  }

  // ---------------------------------------------------------------- changing

  Future<void> edit(
    ChatMessage message,
    String body, {
    bool confirmBroadcast = false,
    bool grantAccess = false,
  }) async {
    final saved = await _client.edit(
      _workspace,
      message,
      body,
      confirmBroadcast: confirmBroadcast,
      grantAccess: grantAccess,
    );
    if (ref.mounted) apply(saved);
  }

  Future<void> delete(ChatMessage message) async {
    _swap(message.id, (m) => m.copyWith(deleted: true, body: ''));
    try {
      final saved = await _client.delete(_workspace, message);
      if (ref.mounted) apply(saved);
    } on ChatException {
      if (ref.mounted) apply(message);
      rethrow;
    }
  }

  Future<void> react(ChatMessage message, String emoji) async {
    final me = ref.read(chatMeProvider);
    final on = !message.reactedBy(emoji, me);
    _swap(message.id, (m) => withReaction(m, emoji, me, on: on));
    try {
      final saved = await _client.react(_workspace, message, emoji, on: on);
      if (ref.mounted) apply(saved);
    } on ChatException {
      if (ref.mounted) apply(message);
      rethrow;
    }
  }

  /// Tells the server this person has read up to the newest message, and the
  /// list's badge follows.
  Future<void> markRead() async {
    final seen = [
      for (final m in state.messages)
        if (!m.isLocal) m,
    ];
    if (seen.isEmpty) return;
    await ref.read(spacesProvider.notifier).markRead(spaceId, seen.last.id);
  }
}

/// People who can see a space and match a query, with how many it has.
final chatMentionableProvider = FutureProvider.autoDispose
    .family<
      ({List<Person> people, int memberCount}),
      ({String space, String query})
    >((ref, key) async {
      final workspace = ref.watch(workspaceScopeProvider);
      if (workspace == null) return (people: const <Person>[], memberCount: 0);
      try {
        return await ref
            .watch(chatClientProvider)
            .mentionable(workspace, key.space, query: key.query);
      } on ChatException {
        return (people: const <Person>[], memberCount: 0);
      }
    });
