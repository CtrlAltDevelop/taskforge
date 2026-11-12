import 'dart:convert';

import 'package:flutter/foundation.dart';

/// What an outbox entry is about.
enum OutboxEntity { task, comment, attachment }

enum OutboxOp { create, update, delete }

/// Where an entry is: waiting, on its way, stopped by a conflict, or refused.
enum OutboxState {
  pending,
  sending,
  conflict,
  rejected;

  /// Entries a person has to look at.
  bool get needsAttention => this == conflict || this == rejected;
}

/// One change made here and not yet accepted by the server.
///
/// [payload] is what the change needs, by operation: a task `create` carries
/// the new task's fields, an `update` the fields that changed (a field mask),
/// a comment `create` the body; a `delete` carries its mode. [expectedVersion]
/// is the version the person saw when they made the change (0: none, a create).
/// [mutationId] makes sending it twice harmless.
@immutable
class OutboxEntry {
  const OutboxEntry({
    required this.workspaceId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.payload,
    required this.mutationId,
    required this.createdAt,
    this.id = 0,
    this.projectId = '',
    this.expectedVersion = 0,
    this.state = OutboxState.pending,
    this.error = '',
    this.theirs = '',
    this.attempts = 0,
  });

  final int id;
  final String workspaceId;
  final String projectId;
  final OutboxEntity entity;
  final String entityId;
  final OutboxOp op;
  final Map<String, dynamic> payload;
  final int expectedVersion;
  final String mutationId;
  final OutboxState state;
  final String error;

  /// For a conflict: the server's version of the entity, as JSON.
  final String theirs;
  final int attempts;
  final DateTime createdAt;

  /// Whether it may still be folded into another change: nothing has been
  /// sent yet (a send that was tried may have been applied, and its mutation
  /// id would then answer for a folded edit without applying it).
  bool get canCoalesce => state == OutboxState.pending && attempts == 0;

  OutboxEntry copyWith({
    int? id,
    Map<String, dynamic>? payload,
    int? expectedVersion,
    OutboxState? state,
    String? error,
    String? theirs,
    int? attempts,
  }) => OutboxEntry(
    id: id ?? this.id,
    workspaceId: workspaceId,
    projectId: projectId,
    entity: entity,
    entityId: entityId,
    op: op,
    payload: payload ?? this.payload,
    expectedVersion: expectedVersion ?? this.expectedVersion,
    mutationId: mutationId,
    state: state ?? this.state,
    error: error ?? this.error,
    theirs: theirs ?? this.theirs,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt,
  );

  String get payloadJson => jsonEncode(payload);

  static Map<String, dynamic> payloadOf(String json) =>
      Map<String, dynamic>.from(jsonDecode(json) as Map<dynamic, dynamic>);
}

/// The queue after [added] joins it, and what to do with the rows already
/// there.
@immutable
class QueueChange {
  const QueueChange({this.drop = const [], this.replace = const {}, this.add});

  /// Entries to remove (by id).
  final List<int> drop;

  /// Entries to rewrite (by id).
  final Map<int, OutboxEntry> replace;

  /// A new entry to append, if any.
  final OutboxEntry? add;
}

/// Folds a new change into the changes waiting for the same thing, so the
/// server is sent the least that gives the same result:
///
/// * create, then update: one create holding the changes;
/// * create, then delete: nothing at all (it never existed there), and the
///   comments written meanwhile go with it;
/// * update, then update: one update (later values win; the version the first
///   saw is kept);
/// * update, then delete: just the delete.
///
/// Only entries still `pending` are folded; one that is being sent or waits on
/// a decision is left alone and the new change follows it.
QueueChange foldIntoQueue(List<OutboxEntry> queue, OutboxEntry added) {
  final same = [
    for (final e in queue)
      if (e.entity == added.entity &&
          e.entityId == added.entityId &&
          e.canCoalesce)
        e,
  ];
  if (added.entity == OutboxEntity.task) {
    return _task(queue, same, added);
  }
  return QueueChange(add: added);
}

QueueChange _task(
  List<OutboxEntry> queue,
  List<OutboxEntry> same,
  OutboxEntry added,
) {
  final create = same.where((e) => e.op == OutboxOp.create).firstOrNull;
  final update = same.where((e) => e.op == OutboxOp.update).firstOrNull;
  switch (added.op) {
    case OutboxOp.create:
      return QueueChange(add: added);
    case OutboxOp.update:
      if (create != null) {
        return QueueChange(
          replace: {
            create.id: create.copyWith(
              payload: {...create.payload, ...added.payload},
            ),
          },
        );
      }
      if (update != null) {
        return QueueChange(
          replace: {
            update.id: update.copyWith(
              payload: {...update.payload, ...added.payload},
            ),
          },
        );
      }
      return QueueChange(add: added);
    case OutboxOp.delete:
      if (create != null) {
        // Never reached the server: forget it, and what hung on it.
        return QueueChange(
          drop: [
            for (final e in queue)
              if (e.canCoalesce &&
                  (e.entityId == added.entityId && e.entity == added.entity ||
                      e.entity != OutboxEntity.task &&
                          e.payload['taskId'] == added.entityId))
                e.id,
          ],
        );
      }
      return QueueChange(drop: [if (update != null) update.id], add: added);
  }
}
