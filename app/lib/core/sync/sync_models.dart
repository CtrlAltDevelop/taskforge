import 'package:flutter/foundation.dart';

/// Where the live connection is.
enum SyncState {
  /// Not started (signed out, or no workspace chosen).
  offline,

  /// The first connect.
  connecting,

  /// Connected and caught up: changes arrive as they happen.
  live,

  /// The socket dropped; trying again, and reading what was missed once back.
  reconnecting,
}

/// A change somebody made: what, where and how far it got. A hint, never
/// content. Clients trust [version], not the order events arrive in.
@immutable
class SyncEvent {
  const SyncEvent({
    required this.type,
    this.workspace = '',
    this.project = '',
    this.entityId = '',
    this.version = 0,
    this.actor = '',
    this.origin = '',
    this.cursor = 0,
  });

  factory SyncEvent.fromJson(Map<String, dynamic> json) => SyncEvent(
    type: json['type'] as String? ?? '',
    workspace: json['workspace'] as String? ?? '',
    project: json['project'] as String? ?? '',
    entityId: json['entity_id'] as String? ?? '',
    version: (json['version'] as num?)?.toInt() ?? 0,
    actor: json['actor'] as String? ?? '',
    origin: json['origin'] as String? ?? '',
    cursor: (json['cursor'] as num?)?.toInt() ?? 0,
  );

  /// `task.created`, `task.updated`, `task.deleted`, `project.created`,
  /// `project.updated`, `workflow.updated`, `fields.updated`,
  /// `access.changed`, or `sync.gap` (made here: what was missed is gone, read
  /// the screens again).
  final String type;
  final String workspace;
  final String project;
  final String entityId;
  final int version;
  final String actor;

  /// The id of the client that made the change (empty when it is not known).
  final String origin;
  final int cursor;

  bool get isTask => type.startsWith('task.');
  bool get isGap => type == gapType;

  static const gapType = 'sync.gap';

  @override
  bool operator ==(Object other) =>
      other is SyncEvent &&
      other.type == type &&
      other.entityId == entityId &&
      other.version == version &&
      other.cursor == cursor &&
      other.project == project;

  @override
  int get hashCode => Object.hash(type, entityId, version, cursor, project);

  @override
  String toString() => 'SyncEvent($type $entityId v$version #$cursor)';
}

/// One person looking at a task, and whether they are typing in it.
@immutable
class PresenceUser {
  const PresenceUser(this.id, {this.editing = false});

  final String id;
  final bool editing;

  @override
  bool operator ==(Object other) =>
      other is PresenceUser && other.id == id && other.editing == editing;

  @override
  int get hashCode => Object.hash(id, editing);
}

/// Who is on a task right now (everyone, including this person).
@immutable
class PresenceUpdate {
  const PresenceUpdate({
    required this.project,
    required this.task,
    required this.users,
  });

  final String project;
  final String task;
  final List<PresenceUser> users;
}

/// A room the server took this connection out of (its access went, or the
/// join was refused).
@immutable
class RoomLost {
  const RoomLost(this.room, this.reason);

  final String room;

  /// `access` (it was taken away) or `forbidden` (never allowed).
  final String reason;
}

String workspaceRoom(String id) => 'ws:$id';
String projectRoom(String id) => 'proj:$id';
