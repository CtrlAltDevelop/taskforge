import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The project feature switch for sprints.
const sprintsFeature = 'sprints';

enum SprintState {
  planned,
  active,
  completed;

  static SprintState parse(String raw) => SprintState.values.firstWhere(
    (s) => s.name == raw,
    orElse: () => SprintState.planned,
  );
}

/// A sprint with the figures the server counted when it answered.
@immutable
class Sprint {
  const Sprint({
    required this.id,
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.goal = '',
    this.state = SprintState.planned,
    this.version = 1,
    this.baselinePoints = 0,
    this.baselineTasks = 0,
    this.completedPoints = 0,
    this.completedTasks = 0,
    this.unfinishedTasks = 0,
    this.taskCount = 0,
    this.pointsTotal = 0,
    this.openTasks = 0,
    this.openPoints = 0,
    this.doneTasks = 0,
    this.donePoints = 0,
    this.estimateSecTotal = 0,
    this.capacityPoints,
    this.capacitySec,
  });

  final String id;
  final String projectId;
  final String name;
  final String goal;

  /// Calendar days (no time of day).
  final DateTime startDate;
  final DateTime endDate;
  final SprintState state;
  final int version;
  final double baselinePoints;
  final int baselineTasks;
  final double completedPoints;
  final int completedTasks;
  final int unfinishedTasks;
  final int taskCount;
  final double pointsTotal;
  final int openTasks;
  final double openPoints;
  final int doneTasks;
  final double donePoints;
  final int estimateSecTotal;

  /// What the team said it can take on, in points and in seconds of work;
  /// null when nobody said.
  final double? capacityPoints;
  final int? capacitySec;

  /// The capacity in the chosen unit (points, or hours), null when unset.
  double? capacityIn({required bool hours}) => hours
      ? (capacitySec == null ? null : capacitySec! / 3600)
      : capacityPoints;

  bool get isPlanned => state == SprintState.planned;
  bool get isActive => state == SprintState.active;
  bool get isCompleted => state == SprintState.completed;
}

/// A task as the planning screen shows it.
@immutable
class SprintTask {
  const SprintTask({
    required this.id,
    required this.key,
    required this.title,
    this.statusName = '',
    this.statusCategory = '',
    this.priority = '',
    this.points,
    this.estimateSec = 0,
    this.sprintId = '',
    this.version = 1,
    this.late = false,
  });

  final String id;
  final String key;
  final String title;
  final String statusName;

  /// The workflow category (`done` counts as finished).
  final String statusCategory;
  final String priority;

  /// Null when the task has no estimate in points.
  final double? points;
  final int estimateSec;
  final String sprintId;
  final int version;

  /// Added after the sprint started.
  final bool late;

  bool get isDone => statusCategory == 'done';
}

@immutable
class SprintAnswer {
  const SprintAnswer(this.sprint, [this.warnings = const []]);

  final Sprint sprint;
  final List<String> warnings;
}

@immutable
class TasksChanged {
  const TasksChanged({
    required this.sprint,
    required this.changed,
    this.addedAfterStart = 0,
  });

  final Sprint sprint;
  final int changed;
  final int addedAfterStart;
}

/// One day of a burndown, as the server computed it.
@immutable
class BurndownDay {
  const BurndownDay({
    required this.date,
    this.idealPoints = 0,
    this.idealTasks = 0,
    this.hasActual = false,
    this.live = false,
    this.backfilled = false,
    this.remainingPoints = 0,
    this.remainingTasks = 0,
    this.scopePoints = 0,
    this.scopeTasks = 0,
  });

  final DateTime date;
  final double idealPoints;
  final double idealTasks;
  final bool hasActual;
  final bool live;
  final bool backfilled;
  final double remainingPoints;
  final int remainingTasks;
  final double scopePoints;
  final int scopeTasks;
}

@immutable
class ScopeChange {
  const ScopeChange({required this.date, this.points = 0, this.tasks = 0});

  final DateTime date;
  final double points;
  final int tasks;
}

@immutable
class VelocityItem {
  const VelocityItem({
    required this.sprintId,
    required this.name,
    this.committedPoints = 0,
    this.completedPoints = 0,
    this.committedTasks = 0,
    this.completedTasks = 0,
  });

  final String sprintId;
  final String name;
  final double committedPoints;
  final double completedPoints;
  final int committedTasks;
  final int completedTasks;
}

@immutable
class Burndown {
  const Burndown({
    required this.sprint,
    this.baselinePoints = 0,
    this.baselineTasks = 0,
    this.days = const [],
    this.scopeChanges = const [],
    this.velocity = const [],
    this.averageVelocity = 0,
  });

  final Sprint sprint;
  final double baselinePoints;
  final int baselineTasks;
  final List<BurndownDay> days;
  final List<ScopeChange> scopeChanges;
  final List<VelocityItem> velocity;
  final double averageVelocity;
}

/// What a burndown counts.
enum BurndownMetric { points, tasks }

/// One plotted day: [actual] is null for days with nothing measured (the
/// future), so the line stops there.
@immutable
class ChartPoint {
  const ChartPoint({
    required this.date,
    required this.ideal,
    this.actual,
    this.backfilled = false,
  });

  final DateTime date;
  final double ideal;
  final double? actual;

  /// The day was written late: its count is as of the late run.
  final bool backfilled;
}

/// A step where scope grew (or shrank) after the start: [index] is the day.
@immutable
class ScopeStep {
  const ScopeStep({required this.index, required this.delta});

  final int index;
  final double delta;
}

@immutable
class ChartData {
  const ChartData({
    required this.points,
    required this.steps,
    required this.maxY,
  });

  final List<ChartPoint> points;
  final List<ScopeStep> steps;
  final double maxY;

  bool get isEmpty => points.isEmpty;

  /// Days with a measurement that was written late.
  int get backfilledDays =>
      points.where((p) => p.backfilled && p.actual != null).length;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Turns a burndown into what the chart draws: ideal line, actual line (blank
/// where nothing was measured) and the steps where scope changed.
ChartData buildBurndownChart(Burndown b, BurndownMetric metric) {
  final byPoints = metric == BurndownMetric.points;
  final points = [
    for (final d in b.days)
      ChartPoint(
        date: d.date,
        ideal: byPoints ? d.idealPoints : d.idealTasks,
        actual: d.hasActual
            ? (byPoints ? d.remainingPoints : d.remainingTasks.toDouble())
            : null,
        backfilled: d.backfilled,
      ),
  ];
  final steps = <ScopeStep>[];
  for (final c in b.scopeChanges) {
    final delta = byPoints ? c.points : c.tasks.toDouble();
    if (delta == 0 || points.isEmpty) continue;
    var index = points.indexWhere((p) => !_day(p.date).isBefore(_day(c.date)));
    if (index < 0) index = points.length - 1;
    steps.add(ScopeStep(index: index, delta: delta));
  }
  var maxY = byPoints ? b.baselinePoints : b.baselineTasks.toDouble();
  for (final p in points) {
    if (p.ideal > maxY) maxY = p.ideal;
    final a = p.actual;
    if (a != null && a > maxY) maxY = a;
  }
  return ChartData(points: points, steps: steps, maxY: maxY <= 0 ? 1 : maxY);
}

/// The last [count] sprints, oldest first (the order a chart reads).
List<VelocityItem> lastVelocity(List<VelocityItem> all, [int count = 6]) =>
    all.length <= count ? all : all.sublist(all.length - count);

/// What the capacity bar compares: planned [load] against [capacity].
@immutable
class Capacity {
  const Capacity({required this.load, this.capacity});

  final double load;

  /// Null while nobody has set one and there is no velocity to go by.
  final double? capacity;

  bool get known => capacity != null && capacity! > 0;
  bool get over => known && load > capacity!;

  /// 0..1 for the bar (a load above capacity fills it).
  double get fraction => !known ? 0 : (load / capacity!).clamp(0.0, 1.0);

  double get remaining => known ? capacity! - load : 0;
}

/// The sprint's load in the chosen unit: story points, or hours of estimate.
double sprintLoad(Sprint s, {required bool hours}) =>
    hours ? s.estimateSecTotal / 3600 : s.pointsTotal;

/// Whole days from [today] to the end of [s], counting the end day itself;
/// 0 once it is past.
int daysLeft(Sprint s, DateTime today) {
  final left = _day(s.endDate).difference(_day(today)).inDays + 1;
  return left < 0 ? 0 : left;
}

/// Other open sprints whose dates overlap [start]..[end].
List<Sprint> overlapping(
  List<Sprint> sprints,
  DateTime start,
  DateTime end, {
  String exceptId = '',
}) => [
  for (final s in sprints)
    if (s.id != exceptId &&
        !s.isCompleted &&
        !_day(s.startDate).isAfter(_day(end)) &&
        !_day(s.endDate).isBefore(_day(start)))
      s,
];

/// Formats a number of points without a pointless `.0`.
String pointsText(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// A number with up to two decimals and no trailing zeros (`12.5`, `8`).
String decimalText(double v) => v
    .toStringAsFixed(2)
    .replaceFirst(RegExp(r'0+$'), '')
    .replaceFirst(RegExp(r'\.$'), '');

String _two(int n) => n.toString().padLeft(2, '0');

String dayText(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${_two(d.month)}-${_two(d.day)}';

/// `YYYY-MM-DD` (a time after it is ignored) or null.
DateTime? parseDay(String raw) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw.trim());
  if (m == null) return null;
  final month = int.parse(m[2]!);
  final d = DateTime(int.parse(m[1]!), month, int.parse(m[3]!));
  return d.month == month ? d : null;
}

enum SprintFailure { network, denied, invalid, notFound, conflict, other }

class SprintException implements Exception {
  const SprintException(this.failure, {this.detail});

  final SprintFailure failure;
  final String? detail;

  @override
  String toString() => 'SprintException($failure)';
}

String sprintErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! SprintException) return t.grpLGeneric;
  final detail = error.detail;
  final hasDetail = detail != null && detail.isNotEmpty;
  return switch (error.failure) {
    SprintFailure.network => t.grpLNetCheckShort,
    SprintFailure.denied => t.grpLNoAccess,
    SprintFailure.notFound => t.grpLGone,
    SprintFailure.conflict => hasDetail ? detail : t.grpLSprintConflict,
    SprintFailure.invalid => hasDetail ? detail : t.grpLNotValid,
    SprintFailure.other => t.grpLGeneric,
  };
}
