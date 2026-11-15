import 'package:flutter/foundation.dart';

import 'package:taskforge/features/comments/domain/comments.dart'
    show SendState;

/// What a place to talk is.
enum SpaceKind {
  channel,
  group,
  dm;

  static SpaceKind parse(String wire) => switch (wire) {
    'group' => group,
    'dm' => dm,
    _ => channel,
  };

  String get wire => name;
}

/// A channel, a private group or a direct message.
@immutable
class Space {
  const Space({
    required this.id,
    required this.kind,
    this.name = '',
    this.projectId = '',
    this.isDefault = false,
    this.archived = false,
    this.joined = true,
    this.role = '',
    this.unreadCount = 0,
    this.lastMessageAt,
    this.lastReadAt,
    this.memberCount = 0,
    this.mutedUntil,
    this.mutedCompletely = false,
    this.notifyAll = false,
    this.readOnly = false,
    this.peerId = '',
    this.version = 1,
  });

  final String id;
  final SpaceKind kind;
  final String name;
  final String projectId;
  final bool isDefault;
  final bool archived;
  final bool joined;
  final String role;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime? lastReadAt;
  final int memberCount;
  final DateTime? mutedUntil;
  final bool mutedCompletely;
  final bool notifyAll;

  /// Nobody can post (archived, or this person left the workspace).
  final bool readOnly;

  /// For a direct message: the other person.
  final String peerId;
  final int version;

  bool isMuted(DateTime now) =>
      mutedCompletely || (mutedUntil?.isAfter(now) ?? false);

  /// A message can be written here.
  bool get canPost => joined && !readOnly && !archived;

  /// Joining is offered (an open channel this person is not in).
  bool get canJoin => !joined && kind == SpaceKind.channel && !archived;

  Space copyWith({
    int? unreadCount,
    DateTime? lastMessageAt,
    DateTime? lastReadAt,
  }) => Space(
    id: id,
    kind: kind,
    name: name,
    projectId: projectId,
    isDefault: isDefault,
    archived: archived,
    joined: joined,
    role: role,
    unreadCount: unreadCount ?? this.unreadCount,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    lastReadAt: lastReadAt ?? this.lastReadAt,
    memberCount: memberCount,
    mutedUntil: mutedUntil,
    mutedCompletely: mutedCompletely,
    notifyAll: notifyAll,
    readOnly: readOnly,
    peerId: peerId,
    version: version,
  );
}

/// A task's chat (phase 42), listed beside the spaces.
@immutable
class TaskChatRef {
  const TaskChatRef({
    required this.taskId,
    required this.projectId,
    this.displayId = '',
    this.title = '',
    this.lastMessageAt,
  });

  final String taskId;
  final String projectId;
  final String displayId;
  final String title;
  final DateTime? lastMessageAt;
}

/// Everything the Chat list shows.
@immutable
class SpaceList {
  const SpaceList({
    this.channels = const [],
    this.groups = const [],
    this.dms = const [],
    this.taskChats = const [],
  });

  final List<Space> channels;
  final List<Space> groups;
  final List<Space> dms;
  final List<TaskChatRef> taskChats;

  List<Space> get all => [...channels, ...groups, ...dms];

  bool get isEmpty => all.isEmpty && taskChats.isEmpty;

  Space? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// The list with [space] in place of the one with its id (added when new).
  SpaceList withSpace(Space space) {
    List<Space> put(List<Space> from) => [
      for (final s in from)
        if (s.id == space.id) space else s,
    ];
    if (byId(space.id) != null) {
      return SpaceList(
        channels: put(channels),
        groups: put(groups),
        dms: put(dms),
        taskChats: taskChats,
      );
    }
    return switch (space.kind) {
      SpaceKind.channel => SpaceList(
        channels: [...channels, space],
        groups: groups,
        dms: dms,
        taskChats: taskChats,
      ),
      SpaceKind.group => SpaceList(
        channels: channels,
        groups: [...groups, space],
        dms: dms,
        taskChats: taskChats,
      ),
      SpaceKind.dm => SpaceList(
        channels: channels,
        groups: groups,
        dms: [...dms, space],
        taskChats: taskChats,
      ),
    };
  }

  /// Only what matches [query] (names, case-insensitive). [nameOfDm] gives a
  /// direct message its person's name.
  SpaceList matching(String query, String Function(Space) nameOfDm) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return this;
    bool hit(String s) => s.toLowerCase().contains(q);
    return SpaceList(
      channels: [
        for (final s in channels)
          if (hit(s.name)) s,
      ],
      groups: [
        for (final s in groups)
          if (hit(s.name)) s,
      ],
      dms: [
        for (final s in dms)
          if (hit(nameOfDm(s))) s,
      ],
      taskChats: [
        for (final t in taskChats)
          if (hit(t.title) || hit(t.displayId)) t,
      ],
    );
  }
}

/// The number the Chat entry shows: what is unread in every space this person
/// has not muted completely.
int unreadTotal(SpaceList list) => [
  for (final s in list.all)
    if (!s.mutedCompletely) s.unreadCount,
].fold(0, (a, b) => a + b);

/// A message or a reply.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.spaceId,
    required this.authorId,
    required this.createdAt,
    this.authorName = '',
    this.parentId = '',
    this.body = '',
    this.editedAt,
    this.deleted = false,
    this.version = 1,
    this.reactions = const {},
    this.sendState = SendState.sent,
  });

  final String id;
  final String spaceId;
  final String authorId;
  final String authorName;
  final String parentId;

  /// The rich-text document as JSON (empty once removed).
  final String body;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool deleted;
  final int version;

  /// Emoji -> ids of those who gave it.
  final Map<String, List<String>> reactions;
  final SendState sendState;

  bool get isReply => parentId.isNotEmpty;
  bool get edited => editedAt != null;
  bool get isLocal => sendState != SendState.sent;

  bool reactedBy(String emoji, String userId) =>
      reactions[emoji]?.contains(userId) ?? false;

  ChatMessage copyWith({
    String? body,
    bool? deleted,
    SendState? sendState,
    Map<String, List<String>>? reactions,
  }) => ChatMessage(
    id: id,
    spaceId: spaceId,
    authorId: authorId,
    authorName: authorName,
    createdAt: createdAt,
    parentId: parentId,
    body: body ?? this.body,
    editedAt: editedAt,
    deleted: deleted ?? this.deleted,
    version: version,
    reactions: reactions ?? this.reactions,
    sendState: sendState ?? this.sendState,
  );
}

@immutable
class MessagePage {
  const MessagePage(this.messages, this.cursor);

  /// Oldest first.
  final List<ChatMessage> messages;

  /// Pass as `before` to read earlier ones (empty: none).
  final String cursor;
}

/// How long an author may edit (the server has the last word).
const chatEditWindow = Duration(hours: 24);

/// Whether [me] may still edit [m] at [now].
bool canEditMessage(ChatMessage m, String me, DateTime now) =>
    !m.deleted &&
    !m.isLocal &&
    m.authorId == me &&
    now.difference(m.createdAt) < chatEditWindow;

/// [messages] (oldest first) with [incoming] added, or replacing the message
/// with its id unless what is there is newer.
List<ChatMessage> upsertMessage(
  List<ChatMessage> messages,
  ChatMessage incoming,
) {
  final at = messages.indexWhere((m) => m.id == incoming.id);
  if (at >= 0) {
    if (messages[at].version > incoming.version &&
        incoming.sendState == SendState.sent) {
      return messages;
    }
    return List.unmodifiable([
      for (final m in messages)
        if (m.id == incoming.id) incoming else m,
    ]);
  }
  final next = [...messages, incoming]
    ..sort((a, b) {
      final c = a.createdAt.compareTo(b.createdAt);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  return List.unmodifiable(next);
}

/// [m] with [me]'s [emoji] given or taken back.
ChatMessage withReaction(
  ChatMessage m,
  String emoji,
  String me, {
  required bool on,
}) {
  final next = {
    for (final e in m.reactions.entries) e.key: [...e.value],
  };
  final users = next.putIfAbsent(emoji, () => []);
  if (on) {
    if (!users.contains(me)) users.add(me);
  } else {
    users.remove(me);
    if (users.isEmpty) next.remove(emoji);
  }
  return m.copyWith(reactions: next);
}

/// What the timeline shows: messages that are not replies.
List<ChatMessage> topLevel(List<ChatMessage> messages) => [
  for (final m in messages)
    if (!m.isReply) m,
];

List<ChatMessage> repliesOf(List<ChatMessage> messages, String parentId) => [
  for (final m in messages)
    if (m.parentId == parentId) m,
];

/// The id of the first message of [timeline] that is new to [me]: written
/// after [readAt] by somebody else (null when none, or when nothing was ever
/// read, so that everything would be "new").
String? firstUnreadId(List<ChatMessage> timeline, DateTime? readAt, String me) {
  if (readAt == null) return null;
  for (final m in timeline) {
    if (m.isLocal || m.authorId == me) continue;
    if (m.createdAt.isAfter(readAt)) return m.id;
  }
  return null;
}

/// How many messages [me] has not seen yet.
int unreadAfter(List<ChatMessage> timeline, DateTime? readAt, String me) {
  if (readAt == null) return 0;
  return timeline
      .where(
        (m) => !m.isLocal && m.authorId != me && m.createdAt.isAfter(readAt),
      )
      .length;
}

/// Whether [body] (the JSON document) mentions everyone with `@channel` or
/// `@here`.
bool isBroadcast(String body) =>
    RegExp(r'"id"\s*:\s*"(channel|here)"').hasMatch(body);

enum ChatFailure {
  conflict,
  broadcastConfirm,
  mentionNoAccess,
  denied,
  forbidden,
  invalid,
  archived,
  notFound,
  network,
  other,
}

class ChatException implements Exception {
  const ChatException(
    this.failure, {
    this.detail,
    this.memberCount = 0,
    this.people = const [],
  });

  final ChatFailure failure;
  final String? detail;

  /// For [ChatFailure.broadcastConfirm]: how many people would be notified.
  final int memberCount;

  /// For [ChatFailure.mentionNoAccess]: ids of those who cannot see the space.
  final List<String> people;

  @override
  String toString() => 'ChatException($failure, $detail)';
}
