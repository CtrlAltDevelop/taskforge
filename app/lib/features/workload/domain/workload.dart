import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// How many days one column covers.
enum WorkloadZoom {
  day,
  week,
  month;

  /// How many columns a fetch shows.
  int get columns => switch (this) {
    WorkloadZoom.day => 14,
    WorkloadZoom.week => 10,
    WorkloadZoom.month => 6,
  };
}

/// Why an open task is listed beside the grid instead of in it.
enum UnplacedReason {
  noEstimate('no_estimate'),
  noDates('no_dates');

  const UnplacedReason(this.wire);

  final String wire;

  static UnplacedReason parse(String wire) => values.firstWhere(
    (r) => r.wire == wire,
    orElse: () => UnplacedReason.noEstimate,
  );
}

enum TimeOffKind {
  vacation('vacation'),
  sick('sick'),
  personal('personal'),
  other('other');

  const TimeOffKind(this.wire);

  final String wire;

  static TimeOffKind parse(String wire) =>
      values.firstWhere((k) => k.wire == wire, orElse: () => other);
}

/// Hours per day on some weekdays (0 Monday ... 6 Sunday). [isSet] is false
/// while nobody chose it: the defaults are shown and the screen asks.
@immutable
class Capacity {
  const Capacity({
    required this.userId,
    required this.hoursPerDay,
    required this.workingDays,
    required this.isSet,
  });

  final String userId;
  final double hoursPerDay;
  final List<int> workingDays;
  final bool isSet;

  int get secondsPerDay => (hoursPerDay * 3600).round();
}

@immutable
class TimeOff {
  const TimeOff({
    required this.id,
    required this.userId,
    required this.start,
    required this.end,
    required this.kind,
    required this.note,
  });

  final String id;
  final String userId;
  final DateTime start;
  final DateTime end;
  final TimeOffKind kind;
  final String note;

  bool covers(DateTime day) => !day.isBefore(start) && !day.isAfter(end);
}

@immutable
class Holiday {
  const Holiday({required this.id, required this.date, required this.name});

  final String id;
  final DateTime date;
  final String name;
}

/// A task behind the grid, or one that cannot be placed ([reason]).
@immutable
class LoadTask {
  const LoadTask({
    required this.id,
    required this.projectId,
    required this.displayId,
    required this.title,
    required this.version,
    required this.start,
    required this.due,
    required this.estimateSec,
    required this.assigneeIds,
    required this.own,
    this.reason,
  });

  final String id;
  final String projectId;
  final String displayId;
  final String title;
  final int version;
  final DateTime? start;
  final DateTime? due;
  final int estimateSec;
  final List<String> assigneeIds;

  /// Per-person estimates (seconds); they replace the equal split.
  final Map<String, int> own;
  final UnplacedReason? reason;

  LoadTask copyWith({
    DateTime? start,
    DateTime? due,
    List<String>? assigneeIds,
    int? version,
  }) => LoadTask(
    id: id,
    projectId: projectId,
    displayId: displayId,
    title: title,
    version: version ?? this.version,
    start: start ?? this.start,
    due: due ?? this.due,
    estimateSec: estimateSec,
    assigneeIds: assigneeIds ?? this.assigneeIds,
    own: own,
    reason: reason,
  );
}

/// One task's share of one person's day.
@immutable
class Contribution {
  const Contribution(this.taskId, this.seconds, {this.warning = false});

  final String taskId;
  final int seconds;
  final bool warning;
}

/// One person: their calendar and the load per day (only days with load).
@immutable
class PersonLoad {
  const PersonLoad({
    required this.userId,
    required this.capacity,
    required this.timeOff,
    required this.days,
  });

  final String userId;
  final Capacity capacity;
  final List<TimeOff> timeOff;

  /// Day (midnight, no time zone) -> the tasks that put load on it.
  final Map<DateTime, List<Contribution>> days;

  int loadOn(DateTime day) =>
      (days[day] ?? const []).fold(0, (sum, c) => sum + c.seconds);
}

/// What `Workload.Get` answered.
@immutable
class WorkloadData {
  const WorkloadData({
    required this.start,
    required this.end,
    required this.canSeeAll,
    required this.people,
    required this.tasks,
    required this.unplaced,
    required this.holidays,
    required this.truncated,
  });

  final DateTime start;
  final DateTime end;
  final bool canSeeAll;
  final List<PersonLoad> people;
  final Map<String, LoadTask> tasks;
  final List<LoadTask> unplaced;
  final Set<DateTime> holidays;
  final bool truncated;

  static final empty = WorkloadData(
    start: DateTime.utc(2000),
    end: DateTime.utc(2000),
    canSeeAll: false,
    people: const [],
    tasks: const {},
    unplaced: const [],
    holidays: const {},
    truncated: false,
  );

  /// Open tasks the grid cannot count because they have no estimate.
  int get unestimatedCount =>
      unplaced.where((t) => t.reason == UnplacedReason.noEstimate).length;

  int get undatedCount =>
      unplaced.where((t) => t.reason == UnplacedReason.noDates).length;

  WorkloadData copyWith({
    List<PersonLoad>? people,
    Map<String, LoadTask>? tasks,
  }) => WorkloadData(
    start: start,
    end: end,
    canSeeAll: canSeeAll,
    people: people ?? this.people,
    tasks: tasks ?? this.tasks,
    unplaced: unplaced,
    holidays: holidays,
    truncated: truncated,
  );
}

/// What the filters ask for: projects, people ("team") and the first day.
@immutable
class WorkloadQuery {
  const WorkloadQuery({
    required this.zoom,
    required this.anchor,
    this.projectIds = const [],
    this.userIds = const [],
  });

  final WorkloadZoom zoom;

  /// Any day inside the first column; the range is snapped from it.
  final DateTime anchor;
  final List<String> projectIds;
  final List<String> userIds;

  /// First and last day fetched, as calendar dates.
  (DateTime, DateTime) get range {
    final first = columnStart(zoom, anchor);
    final last = switch (zoom) {
      WorkloadZoom.day => addDays(first, zoom.columns - 1),
      WorkloadZoom.week => addDays(first, zoom.columns * 7 - 1),
      WorkloadZoom.month => DateTime.utc(
        first.year,
        first.month + zoom.columns,
        0,
      ),
    };
    return (first, last);
  }

  WorkloadQuery copyWith({
    WorkloadZoom? zoom,
    DateTime? anchor,
    List<String>? projectIds,
    List<String>? userIds,
  }) => WorkloadQuery(
    zoom: zoom ?? this.zoom,
    anchor: anchor ?? this.anchor,
    projectIds: projectIds ?? this.projectIds,
    userIds: userIds ?? this.userIds,
  );

  @override
  bool operator ==(Object other) =>
      other is WorkloadQuery &&
      other.zoom == zoom &&
      other.anchor == anchor &&
      listEquals(other.projectIds, projectIds) &&
      listEquals(other.userIds, userIds);

  @override
  int get hashCode => Object.hash(
    zoom,
    anchor,
    Object.hashAll(projectIds),
    Object.hashAll(userIds),
  );
}

// ------------------------------------------------------------------- dates

/// A calendar date as UTC midnight, so adding days never meets a daylight
/// saving change.
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) =>
    DateTime.utc(d.year, d.month, d.day + days);

DateTime? parseDay(String iso) {
  if (iso.isEmpty) return null;
  final d = DateTime.tryParse(iso);
  return d == null ? null : dateOnly(d);
}

String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The first day of the column that holds [day]: itself, its Monday, or the
/// first of its month.
DateTime columnStart(WorkloadZoom zoom, DateTime day) {
  final d = dateOnly(day);
  return switch (zoom) {
    WorkloadZoom.day => d,
    WorkloadZoom.week => addDays(d, -(d.weekday - 1)),
    WorkloadZoom.month => DateTime.utc(d.year, d.month),
  };
}

/// The first day of the next column.
DateTime nextColumn(WorkloadZoom zoom, DateTime start) => switch (zoom) {
  WorkloadZoom.day => addDays(start, 1),
  WorkloadZoom.week => addDays(start, 7),
  WorkloadZoom.month => DateTime.utc(start.year, start.month + 1),
};

// -------------------------------------------------------------- allocation

/// A person's working rule: the Dart twin of the server's `PersonCalendar`.
@immutable
class WorkCalendar {
  const WorkCalendar({
    required this.capacity,
    required this.holidays,
    required this.timeOff,
  });

  final Capacity capacity;
  final Set<DateTime> holidays;
  final List<TimeOff> timeOff;

  /// `DateTime.weekday` is 1 Monday ... 7 Sunday; the wire is 0 ... 6.
  bool isWorking(DateTime day) {
    if (holidays.contains(day)) return false;
    if (!capacity.workingDays.contains(day.weekday - 1)) return false;
    return !timeOff.any((t) => t.covers(day));
  }

  int capacityOn(DateTime day) => isWorking(day) ? capacity.secondsPerDay : 0;
}

const maxSpanDays = 3660;

/// Where [estimateSec] lands: equal whole-second shares on working days
/// between [start] and [due] (a missing date makes a one-day range), or all on
/// the due date when none works. Mirrors `workload.allocation.spread`.
Map<DateTime, int> spreadEstimate(
  int estimateSec,
  DateTime? start,
  DateTime? due,
  bool Function(DateTime) isWorking,
) {
  var first = start ?? due;
  final last = due ?? start;
  if (first == null || last == null || estimateSec <= 0) return const {};
  if (first.isAfter(last)) first = last;
  if (last.difference(first).inDays >= maxSpanDays) {
    first = addDays(last, -(maxSpanDays - 1));
  }
  final days = <DateTime>[];
  for (var d = first; !d.isAfter(last); d = addDays(d, 1)) {
    if (isWorking(d)) days.add(d);
  }
  if (days.isEmpty) return {last: estimateSec};
  final share = estimateSec ~/ days.length;
  final extra = estimateSec % days.length;
  return {
    for (var i = 0; i < days.length; i++) days[i]: share + (i < extra ? 1 : 0),
  };
}

/// Each assignee's share (seconds): their own estimate when set, the rest
/// share what is left equally. Mirrors `workload.allocation.split_estimate`.
Map<String, int> splitEstimate(
  int estimateSec,
  List<String> assignees,
  Map<String, int> own,
) {
  final shares = <String, int>{
    for (final a in assignees)
      if ((own[a] ?? 0) > 0) a: own[a]!,
  };
  final rest = [
    for (final a in assignees)
      if (!shares.containsKey(a)) a,
  ];
  if (estimateSec > 0 && rest.isNotEmpty) {
    final taken = shares.values.fold(0, (s, v) => s + v);
    final left = estimateSec > taken ? estimateSec - taken : 0;
    for (var i = 0; i < rest.length; i++) {
      shares[rest[i]] = left ~/ rest.length + (i < left % rest.length ? 1 : 0);
    }
  }
  return {
    for (final e in shares.entries)
      if (e.value > 0) e.key: e.value,
  };
}

/// [data] with [taskId] changed to [moved] and every row's cells recounted for
/// that task: the instant, local twin of what the server will answer.
WorkloadData recount(WorkloadData data, LoadTask moved) {
  final shares = splitEstimate(moved.estimateSec, moved.assigneeIds, moved.own);
  final people = <PersonLoad>[];
  for (final p in data.people) {
    final days = <DateTime, List<Contribution>>{};
    p.days.forEach((day, list) {
      final kept = [
        for (final c in list)
          if (c.taskId != moved.id) c,
      ];
      if (kept.isNotEmpty) days[day] = kept;
    });
    final cal = WorkCalendar(
      capacity: p.capacity,
      holidays: data.holidays,
      timeOff: p.timeOff,
    );
    final spread = spreadEstimate(
      shares[p.userId] ?? 0,
      moved.start,
      moved.due,
      cal.isWorking,
    );
    spread.forEach((day, seconds) {
      if (day.isBefore(data.start) || day.isAfter(data.end)) return;
      days[day] = [...?days[day], Contribution(moved.id, seconds)];
    });
    people.add(
      PersonLoad(
        userId: p.userId,
        capacity: p.capacity,
        timeOff: p.timeOff,
        days: days,
      ),
    );
  }
  return data.copyWith(people: people, tasks: {...data.tasks, moved.id: moved});
}

// ------------------------------------------------------------------ errors

enum WorkloadFailure { network, denied, invalid, notFound, conflict, other }

class WorkloadException implements Exception {
  const WorkloadException(this.failure, {this.detail});

  final WorkloadFailure failure;
  final String? detail;

  @override
  String toString() => 'WorkloadException($failure)';
}

String workloadErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! WorkloadException) return t.grpLGeneric;
  final detail = error.detail;
  return switch (error.failure) {
    WorkloadFailure.network => t.grpLNetCheckShort,
    WorkloadFailure.denied => t.wlDenied,
    WorkloadFailure.notFound => t.wlGone,
    WorkloadFailure.conflict => t.wlConflict,
    WorkloadFailure.invalid =>
      detail != null && detail.isNotEmpty ? detail : t.grpLNotValid,
    WorkloadFailure.other => t.grpLGeneric,
  };
}

/// 3600 -> "1", 5400 -> "1.5", 2700 -> "0.75" hours, no trailing zeros.
String hoursText(int seconds) {
  final hours = seconds / 3600;
  if (hours == hours.roundToDouble()) return hours.round().toString();
  return hours
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
