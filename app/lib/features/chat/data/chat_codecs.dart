import 'dart:convert';

import 'package:taskforge/features/chat/domain/chat.dart';

/// JSON for the local copy of chat messages and spaces.
String chatMessageToJson(ChatMessage m) => jsonEncode({
  'id': m.id,
  'spaceId': m.spaceId,
  'authorId': m.authorId,
  'authorName': m.authorName,
  'parentId': m.parentId,
  'body': m.body,
  'createdAt': m.createdAt.toIso8601String(),
  'editedAt': m.editedAt?.toIso8601String(),
  'deleted': m.deleted,
  'version': m.version,
  'reactions': m.reactions,
});

ChatMessage chatMessageFromJson(String json) {
  final m = jsonDecode(json) as Map<String, dynamic>;
  final edited = m['editedAt'] as String?;
  return ChatMessage(
    id: '${m['id']}',
    spaceId: '${m['spaceId']}',
    authorId: '${m['authorId']}',
    authorName: '${m['authorName'] ?? ''}',
    parentId: '${m['parentId'] ?? ''}',
    body: '${m['body'] ?? ''}',
    createdAt: DateTime.tryParse('${m['createdAt']}') ?? DateTime.now(),
    editedAt: edited == null ? null : DateTime.tryParse(edited),
    deleted: m['deleted'] == true,
    version: (m['version'] as num?)?.toInt() ?? 1,
    reactions: {
      for (final e in ((m['reactions'] as Map?) ?? const {}).entries)
        '${e.key}': [for (final u in (e.value as List)) '$u'],
    },
  );
}

String spaceToJson(Space s) => jsonEncode({
  'id': s.id,
  'kind': s.kind.wire,
  'name': s.name,
  'projectId': s.projectId,
  'isDefault': s.isDefault,
  'archived': s.archived,
  'joined': s.joined,
  'role': s.role,
  'unread': s.unreadCount,
  'lastMessageAt': s.lastMessageAt?.toIso8601String(),
  'lastReadAt': s.lastReadAt?.toIso8601String(),
  'memberCount': s.memberCount,
  'mutedUntil': s.mutedUntil?.toIso8601String(),
  'mutedCompletely': s.mutedCompletely,
  'notifyAll': s.notifyAll,
  'readOnly': s.readOnly,
  'peerId': s.peerId,
  'version': s.version,
});

Space spaceFromJson(String json) {
  final m = jsonDecode(json) as Map<String, dynamic>;
  DateTime? at(String k) => m[k] == null ? null : DateTime.tryParse('${m[k]}');
  return Space(
    id: '${m['id']}',
    kind: SpaceKind.parse('${m['kind']}'),
    name: '${m['name'] ?? ''}',
    projectId: '${m['projectId'] ?? ''}',
    isDefault: m['isDefault'] == true,
    archived: m['archived'] == true,
    joined: m['joined'] != false,
    role: '${m['role'] ?? ''}',
    unreadCount: (m['unread'] as num?)?.toInt() ?? 0,
    lastMessageAt: at('lastMessageAt'),
    lastReadAt: at('lastReadAt'),
    memberCount: (m['memberCount'] as num?)?.toInt() ?? 0,
    mutedUntil: at('mutedUntil'),
    mutedCompletely: m['mutedCompletely'] == true,
    notifyAll: m['notifyAll'] == true,
    readOnly: m['readOnly'] == true,
    peerId: '${m['peerId'] ?? ''}',
    version: (m['version'] as num?)?.toInt() ?? 1,
  );
}
