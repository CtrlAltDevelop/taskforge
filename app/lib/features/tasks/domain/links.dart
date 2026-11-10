import 'package:flutter/foundation.dart';

/// How a task relates to the one whose links are shown, from that task's side.
enum LinkKind {
  blocks('blocks', 'Blocks'),
  blockedBy('blocked_by', 'Is blocked by'),
  relates('relates', 'Relates to'),
  duplicates('duplicates', 'Duplicates'),
  duplicatedBy('duplicated_by', 'Is duplicated by');

  const LinkKind(this.wire, this.label);

  final String wire;
  final String label;

  static LinkKind parse(String wire) =>
      values.firstWhere((k) => k.wire == wire, orElse: () => LinkKind.relates);
}

const restrictedTaskLabel = 'Restricted task';

/// One link of a task. When the viewer cannot open the other task it is
/// [restricted] and carries no id, title or status.
@immutable
class TaskLink {
  const TaskLink({
    required this.id,
    required this.kind,
    this.restricted = false,
    this.otherId = '',
    this.otherProjectId = '',
    this.otherDisplayId = '',
    this.otherTitle = '',
    this.otherStatusName = '',
    this.otherDone = false,
  });

  final String id;
  final LinkKind kind;
  final bool restricted;
  final String otherId;
  final String otherProjectId;
  final String otherDisplayId;
  final String otherTitle;
  final String otherStatusName;

  /// The other task is in a done or cancelled status.
  final bool otherDone;

  String get otherLabel =>
      restricted ? restrictedTaskLabel : '$otherDisplayId $otherTitle';
}

/// A task offered by the link picker, from any project the viewer can open.
@immutable
class LinkCandidate {
  const LinkCandidate({
    required this.id,
    required this.projectId,
    required this.displayId,
    required this.title,
    this.statusName = '',
  });

  final String id;
  final String projectId;
  final String displayId;
  final String title;
  final String statusName;
}
