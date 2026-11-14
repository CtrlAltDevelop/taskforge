import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// How a key result is measured.
enum KrType {
  number('number'),
  percentage('percentage'),
  boolean('boolean'),
  linked('linked');

  const KrType(this.wire);

  final String wire;

  static KrType parse(String wire) =>
      values.firstWhere((t) => t.wire == wire, orElse: () => KrType.number);
}

/// What a goal's health is called: computed from progress against the time
/// gone, or set by hand.
enum GoalStatus {
  onTrack('on_track'),
  atRisk('at_risk'),
  offTrack('off_track');

  const GoalStatus(this.wire);

  final String wire;

  static GoalStatus parse(String wire) =>
      values.firstWhere((s) => s.wire == wire, orElse: () => onTrack);
}

@immutable
class KeyResult {
  const KeyResult({
    required this.id,
    required this.goalId,
    required this.name,
    required this.type,
    required this.startValue,
    required this.targetValue,
    required this.currentValue,
    required this.filterText,
    required this.taskIds,
    required this.weight,
    required this.linkedDone,
    required this.linkedTotal,
    required this.progress,
    required this.version,
  });

  final String id;
  final String goalId;
  final String name;
  final KrType type;
  final String startValue;
  final String targetValue;
  final String currentValue;

  /// A TFQL filter over the workspace (linked key results).
  final String filterText;

  /// Hand-picked tasks (linked key results); they count with the filter.
  final List<String> taskIds;
  final String weight;
  final int linkedDone;
  final int linkedTotal;

  /// 0 to 1.
  final double progress;
  final int version;
}

@immutable
class Goal {
  const Goal({
    required this.id,
    required this.parentId,
    required this.folderId,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.private,
    required this.periodStart,
    required this.periodEnd,
    required this.statusOverride,
    required this.status,
    required this.statusHint,
    required this.weight,
    required this.progress,
    required this.version,
    required this.canEdit,
    required this.canCheckIn,
    required this.contributorIds,
    required this.childIds,
    required this.keyResults,
  });

  final String id;
  final String parentId;
  final String folderId;
  final String name;
  final String description;
  final String ownerId;
  final bool private;

  /// `YYYY-MM-DD`.
  final String periodStart;
  final String periodEnd;

  /// Empty unless set by hand.
  final String statusOverride;
  final GoalStatus status;
  final GoalStatus statusHint;
  final String weight;

  /// 0 to 1, child goals rolled up.
  final double progress;
  final int version;
  final bool canEdit;
  final bool canCheckIn;
  final List<String> contributorIds;
  final List<String> childIds;
  final List<KeyResult> keyResults;

  DateTime? get start => DateTime.tryParse(periodStart);
  DateTime? get end => DateTime.tryParse(periodEnd);
}

@immutable
class GoalFolder {
  const GoalFolder({
    required this.id,
    required this.name,
    required this.position,
  });

  final String id;
  final String name;
  final int position;
}

@immutable
class GoalCatalog {
  const GoalCatalog(this.goals, this.folders);

  static const empty = GoalCatalog([], []);

  final List<Goal> goals;
  final List<GoalFolder> folders;

  Goal? byId(String id) => goals.where((g) => g.id == id).firstOrNull;

  /// Goals with no parent the caller can see: the starting points of the
  /// tree (a goal whose parent is hidden is shown at the top too).
  List<Goal> get roots {
    final known = {for (final g in goals) g.id};
    return [
      for (final g in goals)
        if (g.parentId.isEmpty || !known.contains(g.parentId)) g,
    ];
  }

  List<Goal> childrenOf(String id) => [
    for (final g in goals)
      if (g.parentId == id) g,
  ];
}

@immutable
class CheckIn {
  const CheckIn({
    required this.id,
    required this.krId,
    required this.userId,
    required this.value,
    required this.previousValue,
    required this.progress,
    required this.note,
    required this.at,
  });

  final String id;
  final String krId;

  /// Empty for a reading the system took when linked tasks changed.
  final String userId;
  final String value;
  final String previousValue;
  final double progress;
  final String note;
  final DateTime? at;
}

@immutable
class Contribution {
  const Contribution({
    required this.goalId,
    required this.goalName,
    required this.krId,
    required this.krName,
  });

  final String goalId;
  final String goalName;
  final String krId;
  final String krName;
}

/// What the goal dialog edits.
@immutable
class GoalDraft {
  const GoalDraft({
    required this.name,
    required this.periodStart,
    required this.periodEnd,
    this.description = '',
    this.ownerId = '',
    this.parentId = '',
    this.folderId = '',
    this.private = false,
    this.weight = '1',
    this.statusOverride = '',
    this.contributorIds = const [],
  });

  final String name;
  final String periodStart;
  final String periodEnd;
  final String description;
  final String ownerId;
  final String parentId;
  final String folderId;
  final bool private;
  final String weight;
  final String statusOverride;
  final List<String> contributorIds;
}

/// What the key-result dialog edits.
@immutable
class KrDraft {
  const KrDraft({
    required this.name,
    required this.type,
    this.startValue = '0',
    this.targetValue = '100',
    this.currentValue = '0',
    this.weight = '1',
    this.filterText = '',
    this.taskIds = const [],
  });

  final String name;
  final KrType type;
  final String startValue;
  final String targetValue;
  final String currentValue;
  final String weight;
  final String filterText;
  final List<String> taskIds;
}

enum GoalsFailure { network, denied, invalid, notFound, conflict, other }

class GoalsException implements Exception {
  const GoalsException(this.failure, {this.detail});

  final GoalsFailure failure;
  final String? detail;

  @override
  String toString() => 'GoalsException($failure)';
}

String goalsErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! GoalsException) return t.grpLGeneric;
  final detail = error.detail;
  return switch (error.failure) {
    GoalsFailure.network => t.grpLNetCheckShort,
    GoalsFailure.denied => t.goalsDenied,
    GoalsFailure.notFound => t.goalsGone,
    GoalsFailure.conflict => t.goalsConflict,
    GoalsFailure.invalid =>
      detail != null && detail.isNotEmpty ? detail : t.grpLNotValid,
    GoalsFailure.other => t.grpLGeneric,
  };
}

/// A number as the user typed it, without trailing zeros ("12.50" -> "12.5").
String trimNumber(String text) {
  final value = double.tryParse(text);
  if (value == null) return text;
  if (value == value.roundToDouble()) return value.round().toString();
  return value
      .toStringAsFixed(4)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// 0.456 -> 46.
int percentOf(double progress) => (progress * 100).round().clamp(0, 100);

String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The calendar quarter containing [day] as (first day, last day).
(DateTime, DateTime) quarterOf(DateTime day) {
  final first = ((day.month - 1) ~/ 3) * 3 + 1;
  return (DateTime(day.year, first), DateTime(day.year, first + 3, 0));
}

const goalWeights = ['1', '2', '3', '5'];
