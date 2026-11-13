import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;

import 'package:taskforge/l10n/gen/app_localizations.dart';

const maxStatusNameLength = 40;
const maxStatuses = 30;

/// Swatches a status may use (`#RRGGBB`); the server accepts any such value.
const statusColors = [
  '#9E9E9E',
  '#1E88E5',
  '#43A047',
  '#FB8C00',
  '#E53935',
  '#8E24AA',
  '#00897B',
  '#6D4C41',
];

/// What a status means to reports and boards, whatever it is called.
enum StatusCategory {
  notStarted('not_started', 'Not started'),
  active('active', 'Active'),
  done('done', 'Done'),
  cancelled('cancelled', 'Cancelled');

  const StatusCategory(this.wire, this.label);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    notStarted => l.grpMCatNotStarted,
    active => l.grpMCatActive,
    done => l.grpMCatDone,
    cancelled => l.grpMCatCancelled,
  };

  /// Done and Cancelled end a task's life: nothing needs to lead out of them.
  bool get isFinal => this == done || this == cancelled;

  static StatusCategory parse(String wire) => values.firstWhere(
    (c) => c.wire == wire,
    orElse: () => StatusCategory.active,
  );
}

/// `#RRGGBB` as a colour; grey when empty or not a colour.
Color parseStatusColor(String hex) {
  final match = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(hex);
  if (match == null) return const Color(0xFF9E9E9E);
  return Color(0xFF000000 | int.parse(match.group(1)!, radix: 16));
}

@immutable
class WorkflowStatus {
  const WorkflowStatus({
    required this.id,
    required this.name,
    this.color = '',
    this.category = StatusCategory.active,
    this.position = 0,
    this.isDefault = false,
    this.taskCount = 0,
  });

  final String id;
  final String name;
  final String color;
  final StatusCategory category;
  final int position;
  final bool isDefault;

  /// Tasks in this status, trashed ones included: how many a delete moves.
  final int taskCount;

  Color get swatch => parseStatusColor(color);
}

@immutable
class WorkflowTransition {
  const WorkflowTransition({
    required this.from,
    required this.to,
    this.requiredRoleId = '',
    this.requireAssignee = false,
    this.requireSubtasksDone = false,
  });

  final String from;
  final String to;

  /// Only this role may make the move; empty means any role.
  final String requiredRoleId;
  final bool requireAssignee;

  /// Every subtask (at any depth) must be done or cancelled first.
  final bool requireSubtasksDone;
}

/// Why a move is refused, in words (also what the server says).
@immutable
class MoveRefusal {
  const MoveRefusal(this.reason);

  final String reason;
}

@immutable
class Workflow {
  const Workflow({
    required this.projectId,
    required this.statuses,
    this.transitions = const [],
    this.restrict = false,
    this.restrictCreation = false,
    this.version = 1,
  });

  final String projectId;

  /// In display order.
  final List<WorkflowStatus> statuses;
  final List<WorkflowTransition> transitions;

  /// Off: any status may move to any other.
  final bool restrict;

  /// On: a new task can only start in the default status (it reaches the others
  /// by being moved). Off (the default): it may be created in any status.
  final bool restrictCreation;
  final int version;

  WorkflowStatus? statusById(String id) =>
      statuses.where((s) => s.id == id).firstOrNull;

  WorkflowStatus get defaultStatus =>
      statuses.firstWhere((s) => s.isDefault, orElse: () => statuses.first);

  /// Null when the move is allowed, else why not. [roleId] is the caller's role.
  MoveRefusal? refusal({
    required String from,
    required String to,
    required bool hasAssignee,
    required String roleId,
  }) {
    if (from == to || !restrict) return null;
    final source = statusById(from)?.name ?? '?';
    final target = statusById(to)?.name ?? '?';
    final rule = transitions
        .where((t) => t.from == from && t.to == to)
        .firstOrNull;
    final arrow = '$source → $target';
    if (rule == null) return MoveRefusal('$arrow is not allowed.');
    if (rule.requireAssignee && !hasAssignee) {
      return MoveRefusal('$arrow needs an assignee first.');
    }
    if (rule.requiredRoleId.isNotEmpty && rule.requiredRoleId != roleId) {
      return MoveRefusal('$arrow is only for a specific role.');
    }
    return null;
  }

  /// The statuses a task in [from] may be moved to (and [from] itself), in
  /// display order. The server enforces the same rules.
  List<WorkflowStatus> targets({
    required String from,
    required bool hasAssignee,
    required String roleId,
  }) => [
    for (final s in statuses)
      if (s.id == from ||
          refusal(
                from: from,
                to: s.id,
                hasAssignee: hasAssignee,
                roleId: roleId,
              ) ==
              null)
        s,
  ];
}

/// One thing wrong with a workflow; [code] is stable, [statusKey] empty for the
/// whole workflow.
@immutable
class WorkflowProblem {
  const WorkflowProblem(this.code, this.message, [this.statusKey = '']);

  final String code;
  final String message;
  final String statusKey;
}

enum WorkflowFailure {
  invalid,
  conflict,
  denied,
  forbidden,
  archived,
  notFound,
  network,
  other,
}

class WorkflowException implements Exception {
  const WorkflowException(
    this.failure, {
    this.detail,
    this.problems = const [],
  });

  final WorkflowFailure failure;
  final String? detail;

  /// For [WorkflowFailure.invalid]: every problem the server found.
  final List<WorkflowProblem> problems;

  @override
  String toString() => 'WorkflowException($failure, $detail)';
}

String workflowErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! WorkflowException) return t.grpLGeneric;
  return switch (error.failure) {
    WorkflowFailure.invalid => t.grpLWfInvalid,
    WorkflowFailure.conflict => t.grpLWfConflict,
    WorkflowFailure.denied => error.detail ?? t.grpLNoPerm,
    WorkflowFailure.forbidden => t.grpLNoPermDo,
    WorkflowFailure.archived => t.grpLArchived,
    WorkflowFailure.notFound => t.grpLProjectGone,
    WorkflowFailure.network => t.grpLNetCheck,
    WorkflowFailure.other => t.grpLGeneric,
  };
}
