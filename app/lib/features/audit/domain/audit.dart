import 'dart:convert';

import 'package:flutter/foundation.dart';

/// One change as the server recorded it: who, what, to what, and the fields
/// that moved. Immutable.
@immutable
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.at,
    required this.actor,
    required this.actorName,
    required this.actorType,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.projectId = '',
    this.batchId = '',
    this.ip = '',
    this.userAgent = '',
    this.changes = const {},
  });

  final int id;
  final DateTime at;
  final String actor;
  final String actorName;

  /// `user`, `automation` or `system`.
  final String actorType;

  /// `task.status_changed`, `member.removed`, ...
  final String action;
  final String targetType;
  final String targetId;
  final String projectId;
  final String batchId;
  final String ip;
  final String userAgent;

  /// `{field: [before, after]}`, or `{field: value}` for what has no "before".
  final Map<String, dynamic> changes;

  /// Who did it, in words: a person's name, "An automation", or "The system".
  String get who => switch (actorType) {
    'automation' => 'An automation',
    'system' => 'The system',
    _ => actorName.isEmpty ? 'Someone' : actorName,
  };

  static Map<String, dynamic> decodeChanges(String json) {
    if (json.isEmpty) return const {};
    try {
      final decoded = jsonDecode(json);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}

/// One watched field of an entry: [before] is null for a value that has none
/// (a creation, or an id that says which row it was).
@immutable
class FieldChange {
  const FieldChange(
    this.name,
    this.before,
    this.after, {
    this.hasBefore = true,
  });

  final String name;
  final Object? before;
  final Object? after;
  final bool hasBefore;
}

List<FieldChange> fieldChanges(AuditEntry entry) => [
  for (final e in entry.changes.entries)
    if (e.value is List && (e.value as List).length == 2)
      FieldChange(e.key, (e.value as List)[0], (e.value as List)[1])
    else
      FieldChange(e.key, null, e.value, hasBefore: false),
];

/// A page of entries, newest first, with names for the ids they mention.
@immutable
class AuditPage {
  const AuditPage({
    this.entries = const [],
    this.labels = const {},
    this.nextBefore = 0,
  });

  final List<AuditEntry> entries;
  final Map<String, String> labels;

  /// The id to ask for the next page with; 0 when this was the last.
  final int nextBefore;
  bool get hasMore => nextBefore != 0;
}

@immutable
class AuditFilters {
  const AuditFilters({
    this.actor = '',
    this.action = '',
    this.targetType = '',
    this.projectId = '',
    this.since,
    this.until,
  });

  final String actor;

  /// Exact (`task.deleted`) or a prefix ending in a dot (`task.`).
  final String action;
  final String targetType;
  final String projectId;
  final DateTime? since;
  final DateTime? until;

  bool get isEmpty =>
      actor.isEmpty &&
      action.isEmpty &&
      targetType.isEmpty &&
      projectId.isEmpty &&
      since == null &&
      until == null;

  AuditFilters copyWith({
    String? actor,
    String? action,
    String? targetType,
    String? projectId,
    Object? since = _keep,
    Object? until = _keep,
  }) => AuditFilters(
    actor: actor ?? this.actor,
    action: action ?? this.action,
    targetType: targetType ?? this.targetType,
    projectId: projectId ?? this.projectId,
    since: identical(since, _keep) ? this.since : since as DateTime?,
    until: identical(until, _keep) ? this.until : until as DateTime?,
  );

  static const _keep = Object();

  @override
  bool operator ==(Object other) =>
      other is AuditFilters &&
      other.actor == actor &&
      other.action == action &&
      other.targetType == targetType &&
      other.projectId == projectId &&
      other.since == since &&
      other.until == until;

  @override
  int get hashCode =>
      Object.hash(actor, action, targetType, projectId, since, until);
}

enum AuditFailure { denied, notFound, invalid, network, other }

class AuditException implements Exception {
  const AuditException(this.failure, {this.detail = ''});

  final AuditFailure failure;
  final String detail;

  @override
  String toString() => 'AuditException($failure: $detail)';
}

String auditErrorMessage(Object error) {
  final failure = error is AuditException ? error.failure : AuditFailure.other;
  return switch (failure) {
    AuditFailure.denied => 'You are not allowed to read the audit log.',
    AuditFailure.notFound => 'That task is not available.',
    AuditFailure.invalid =>
      error is AuditException && error.detail.isNotEmpty
          ? error.detail
          : 'Those filters are not valid.',
    AuditFailure.network => 'Could not reach the server. Try again.',
    AuditFailure.other => 'Something went wrong. Try again.',
  };
}
