import 'dart:async';

import 'package:taskforge/features/chat/data/chat_client.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart' show Person;

final t0 = DateTime.utc(2026, 11, 12, 10);

Space space(
  String id,
  String name, {
  SpaceKind kind = SpaceKind.channel,
  int unread = 0,
  bool joined = true,
  bool archived = false,
  bool readOnly = false,
  String peer = '',
  int members = 3,
  DateTime? lastRead,
  bool isDefault = false,
}) => Space(
  id: id,
  kind: kind,
  name: name,
  unreadCount: unread,
  joined: joined,
  archived: archived,
  readOnly: readOnly,
  peerId: peer,
  memberCount: members,
  lastReadAt: lastRead,
  isDefault: isDefault,
);

ChatMessage msg(
  String id,
  String spaceId,
  String text, {
  String author = 'u2',
  DateTime? at,
  String parent = '',
  int version = 1,
}) => ChatMessage(
  id: id,
  spaceId: spaceId,
  authorId: author,
  authorName: author == 'u2' ? 'Hank Hill' : 'Me',
  parentId: parent,
  body: bodyFromComposer(text, const []),
  createdAt: at ?? t0,
  version: version,
);

/// An in-memory chat server. [me] makes the calls.
class FakeChatClient implements ChatClient {
  FakeChatClient({
    this.me = 'u1',
    List<Space> spaces = const [],
    List<TaskChatRef> taskChats = const [],
    List<ChatMessage> messages = const [],
  }) : spaces = [...spaces],
       taskChats = [...taskChats],
       messages = [...messages];

  final String me;
  final List<Space> spaces;
  final List<TaskChatRef> taskChats;
  final List<ChatMessage> messages;
  final people = <Person>[
    const Person('u2', 'Hank Hill'),
    const Person('u-ana', 'Ana Silva'),
  ];

  /// A message with `@channel` / `@here` needs `confirmBroadcast` when this
  /// many people would be told (0: never).
  int broadcastLimit = 0;
  var memberCount = 80;

  /// The next call that changes something fails with this.
  ChatException? failNext;
  var reachable = true;
  Completer<void>? gate;
  Object? listError;
  Object? messagesError;

  final sent =
      <({String body, String parentId, String clientId, bool confirm})>[];
  final reads = <String>[]; // "space:message"
  final mutes = <String>[];
  final opened = <String>[];
  final created = <String>[];
  var listCalls = 0;
  var messageCalls = 0;
  var _next = 1;

  void _check() {
    if (!reachable) throw const ChatException(ChatFailure.network);
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  @override
  Future<SpaceList> listSpaces(
    String workspaceId, {
    String query = '',
    bool includeArchived = false,
  }) async {
    listCalls++;
    if (!reachable) throw const ChatException(ChatFailure.network);
    final e = listError;
    if (e != null) throw e;
    return SpaceList(
      channels: [
        for (final s in spaces)
          if (s.kind == SpaceKind.channel) s,
      ],
      groups: [
        for (final s in spaces)
          if (s.kind == SpaceKind.group) s,
      ],
      dms: [
        for (final s in spaces)
          if (s.kind == SpaceKind.dm) s,
      ],
      taskChats: taskChats,
    );
  }

  void _put(Space s) {
    final i = spaces.indexWhere((x) => x.id == s.id);
    if (i < 0) {
      spaces.add(s);
    } else {
      spaces[i] = s;
    }
  }

  @override
  Future<Space> createSpace(
    String workspaceId,
    SpaceKind kind,
    String name,
    List<String> memberIds,
  ) async {
    _check();
    created.add('${kind.wire}:$name:${memberIds.join(',')}');
    final s = space(
      'n${_next++}',
      name,
      kind: kind,
      members: memberIds.length + 1,
    );
    _put(s);
    return s;
  }

  @override
  Future<Space> openDm(String workspaceId, String userId) async {
    _check();
    opened.add(userId);
    final existing = spaces.where((s) => s.peerId == userId).firstOrNull;
    if (existing != null) return existing;
    final s = space(
      'dm-$userId',
      '',
      kind: SpaceKind.dm,
      peer: userId,
      members: 2,
    );
    _put(s);
    return s;
  }

  @override
  Future<Space> join(String workspaceId, String spaceId) async {
    _check();
    final old = spaces.firstWhere((s) => s.id == spaceId);
    final s = space(
      old.id,
      old.name,
      joined: true,
      members: old.memberCount + 1,
    );
    _put(s);
    return s;
  }

  @override
  Future<void> leave(String workspaceId, String spaceId) async {
    _check();
    spaces.removeWhere((s) => s.id == spaceId);
  }

  @override
  Future<Space> markRead(
    String workspaceId,
    String spaceId,
    String messageId,
  ) async {
    _check();
    reads.add('$spaceId:$messageId');
    final s = spaces
        .firstWhere((s) => s.id == spaceId)
        .copyWith(unreadCount: 0, lastReadAt: DateTime.now().toUtc());
    _put(s);
    return s;
  }

  @override
  Future<Space> mute(
    String workspaceId,
    String spaceId, {
    DateTime? until,
    bool forever = false,
    bool completely = false,
  }) async {
    _check();
    mutes.add('$spaceId:${until != null}:$forever:$completely');
    return spaces.firstWhere((s) => s.id == spaceId);
  }

  @override
  Future<Space> notify(
    String workspaceId,
    String spaceId, {
    required bool allMessages,
  }) async {
    _check();
    return spaces.firstWhere((s) => s.id == spaceId);
  }

  @override
  Future<MessagePage> listMessages(
    String workspaceId,
    String spaceId, {
    String before = '',
    String threadId = '',
    int pageSize = 50,
  }) async {
    messageCalls++;
    if (!reachable) throw const ChatException(ChatFailure.network);
    final e = messagesError;
    if (e != null) throw e;
    var all = [
      for (final m in messages)
        if (m.spaceId == spaceId &&
            (threadId.isEmpty || m.parentId == threadId))
          m,
    ];
    final end = before.isEmpty ? all.length : int.parse(before);
    final start = (end - pageSize).clamp(0, end);
    all = all.sublist(start, end);
    return MessagePage(all, start > 0 ? '$start' : '');
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
    await gate?.future;
    _check();
    if (broadcastLimit > 0 &&
        !confirmBroadcast &&
        memberCount > broadcastLimit &&
        isBroadcast(body)) {
      throw ChatException(
        ChatFailure.broadcastConfirm,
        memberCount: memberCount,
      );
    }
    sent.add((
      body: body,
      parentId: parentId,
      clientId: clientId,
      confirm: confirmBroadcast,
    ));
    final id = clientId.isEmpty ? 'm${_next++}' : clientId;
    final have = messages.where((m) => m.id == id).firstOrNull;
    if (have != null) return have; // idempotent
    final made = ChatMessage(
      id: id,
      spaceId: spaceId,
      authorId: me,
      authorName: 'Me',
      parentId: parentId,
      body: body,
      createdAt: DateTime.now().toUtc(),
    );
    messages.add(made);
    return made;
  }

  @override
  Future<ChatMessage> edit(
    String workspaceId,
    ChatMessage message,
    String body, {
    bool confirmBroadcast = false,
    bool grantAccess = false,
  }) async {
    _check();
    final i = messages.indexWhere((m) => m.id == message.id);
    final old = messages[i];
    return messages[i] = ChatMessage(
      id: old.id,
      spaceId: old.spaceId,
      authorId: old.authorId,
      authorName: old.authorName,
      parentId: old.parentId,
      body: body,
      createdAt: old.createdAt,
      editedAt: DateTime.now().toUtc(),
      version: old.version + 1,
      reactions: old.reactions,
    );
  }

  @override
  Future<ChatMessage> delete(String workspaceId, ChatMessage message) async {
    _check();
    final i = messages.indexWhere((m) => m.id == message.id);
    return messages[i] = messages[i].copyWith(deleted: true, body: '');
  }

  @override
  Future<ChatMessage> react(
    String workspaceId,
    ChatMessage message,
    String emoji, {
    required bool on,
  }) async {
    _check();
    final i = messages.indexWhere((m) => m.id == message.id);
    return messages[i] = withReaction(messages[i], emoji, me, on: on);
  }

  @override
  Future<({List<Person> people, int memberCount})> mentionable(
    String workspaceId,
    String spaceId, {
    String query = '',
  }) async => (
    people: [
      for (final p in people)
        if (p.displayName.toLowerCase().contains(query.toLowerCase())) p,
    ],
    memberCount: memberCount,
  );
}
