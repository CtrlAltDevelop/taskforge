import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/tasks.dart';

/// A calendar day with no time and no zone: UTC midnight, so adding days never
/// meets a daylight-saving jump and a date reads the same everywhere.
typedef Day = DateTime;

Day day(int year, int month, int date) => DateTime.utc(year, month, date);

/// The day [iso] (`YYYY-MM-DD`) names, or null when it is empty or not a date.
Day? parseDay(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
  if (m == null) return null;
  final d = day(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  return d.month == int.parse(m[2]!) ? d : null;
}

String formatDay(Day d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// [d] moved by [days] whole calendar days.
Day addDays(Day d, int days) => day(d.year, d.month, d.day + days);

int daysBetween(Day from, Day to) =>
    to.difference(from).inHours ~/ 24 +
    (to.difference(from).inHours % 24 >= 12 ? 1 : 0);

/// The local calendar date of [moment] as a [Day].
Day dayOf(DateTime moment) => day(moment.year, moment.month, moment.day);

enum CalendarMode { month, week, day }

/// The first day of the week that contains [d], for a week that starts on ISO
/// weekday [weekStart] (1 Monday ... 7 Sunday).
Day weekStartOf(Day d, int weekStart) =>
    addDays(d, -((d.weekday - weekStart + 7) % 7));

/// The days a screen shows around [anchor]: a month grid is whole weeks, a
/// week is seven days, a day is itself.
({Day first, Day last}) visibleRange(
  CalendarMode mode,
  Day anchor,
  int weekStart,
) => switch (mode) {
  CalendarMode.day => (first: anchor, last: anchor),
  CalendarMode.week => (
    first: weekStartOf(anchor, weekStart),
    last: addDays(weekStartOf(anchor, weekStart), 6),
  ),
  CalendarMode.month => () {
    final first = weekStartOf(day(anchor.year, anchor.month, 1), weekStart);
    final end = day(anchor.year, anchor.month + 1, 0); // the month's last day
    final last = addDays(weekStartOf(end, weekStart), 6);
    return (first: first, last: last);
  }(),
};

/// [anchor] one [mode] step forward (or back with a negative [steps]).
Day step(CalendarMode mode, Day anchor, int steps) => switch (mode) {
  CalendarMode.day => addDays(anchor, steps),
  CalendarMode.week => addDays(anchor, 7 * steps),
  CalendarMode.month => day(anchor.year, anchor.month + steps, 1),
};

/// The days [task] covers: its start to its due date, or the one day it has.
/// Null for a task with neither.
({Day first, Day last})? spanOf(Task task) {
  final start = parseDay(task.startDate);
  final due = parseDay(task.dueDate);
  if (start == null && due == null) return null;
  final first = start ?? due!;
  final last = due ?? start!;
  return last.isBefore(first)
      ? (first: last, last: first)
      : (first: first, last: last);
}

/// One piece of a task's bar inside one week row: columns [startCol]..[endCol]
/// (0-based, inclusive), on [lane] (0 is the top line of the row).
@immutable
class BarSegment {
  const BarSegment({
    required this.task,
    required this.startCol,
    required this.endCol,
    required this.lane,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  final Task task;
  final int startCol;
  final int endCol;
  final int lane;

  /// The bar started in an earlier week / goes on into the next one (no rounded
  /// end, no resize handle there).
  final bool continuesBefore;
  final bool continuesAfter;
}

/// The bars of one week row and how many tasks each day has beyond [maxLanes].
@immutable
class WeekRow {
  const WeekRow({required this.segments, required this.hidden});

  /// Segments on a lane below [maxLanes] only.
  final List<BarSegment> segments;

  /// Per column: tasks that do not fit ("+N more").
  final List<int> hidden;
}

/// Lays [tasks] out as bars in the week of seven days that starts on [weekFirst]:
/// longer bars first, each on the highest free lane, so no two overlap. Tasks
/// outside the week are skipped. A day's tasks beyond [maxLanes] are only
/// counted ([WeekRow.hidden]).
WeekRow layoutWeek(List<Task> tasks, Day weekFirst, {int maxLanes = 3}) {
  final weekLast = addDays(weekFirst, 6);
  final pieces = <({Task task, int from, int to, bool before, bool after})>[];
  for (final task in tasks) {
    final span = spanOf(task);
    if (span == null ||
        span.last.isBefore(weekFirst) ||
        span.first.isAfter(weekLast)) {
      continue;
    }
    pieces.add((
      task: task,
      from: span.first.isBefore(weekFirst)
          ? 0
          : daysBetween(weekFirst, span.first),
      to: span.last.isAfter(weekLast) ? 6 : daysBetween(weekFirst, span.last),
      before: span.first.isBefore(weekFirst),
      after: span.last.isAfter(weekLast),
    ));
  }
  pieces.sort((a, b) {
    final byLength = (b.to - b.from).compareTo(a.to - a.from);
    if (byLength != 0) return byLength;
    final byStart = a.from.compareTo(b.from);
    return byStart != 0 ? byStart : a.task.number.compareTo(b.task.number);
  });
  final taken = <List<bool>>[]; // lane -> column -> used
  final segments = <BarSegment>[];
  final hidden = List.filled(7, 0);
  for (final p in pieces) {
    var lane = 0;
    while (lane < taken.length &&
        taken[lane].sublist(p.from, p.to + 1).any((used) => used)) {
      lane++;
    }
    if (lane == taken.length) taken.add(List.filled(7, false));
    for (var c = p.from; c <= p.to; c++) {
      taken[lane][c] = true;
    }
    if (lane >= maxLanes) {
      for (var c = p.from; c <= p.to; c++) {
        hidden[c]++;
      }
      continue;
    }
    segments.add(
      BarSegment(
        task: p.task,
        startCol: p.from,
        endCol: p.to,
        lane: lane,
        continuesBefore: p.before,
        continuesAfter: p.after,
      ),
    );
  }
  segments.sort((a, b) {
    final byLane = a.lane.compareTo(b.lane);
    return byLane != 0 ? byLane : a.startCol.compareTo(b.startCol);
  });
  return WeekRow(segments: segments, hidden: hidden);
}

/// Why giving [task] [dates] may break a link, or null. A task is due the day
/// it ends: that must not be before the latest due date of what blocks it, nor
/// after the earliest due date of what it blocks.
String? linkWarning(Task task, Dates dates) {
  final end = dates.due ?? dates.start;
  if (end == null) return null;
  final blockers = parseDay(task.blockersDue);
  if (blockers != null && end.isBefore(blockers)) {
    return 'It is due before ${formatDay(blockers)}, when a task that blocks '
        'it is due.';
  }
  final blocks = parseDay(task.blocksDue);
  if (blocks != null && end.isAfter(blocks)) {
    return 'It is due after ${formatDay(blocks)}, when a task it blocks is due.';
  }
  return null;
}

/// The tasks that fall on [d], by the day they begin and then number.
List<Task> tasksOn(List<Task> tasks, Day d) {
  final found = <Task>[
    for (final t in tasks)
      if (spanOf(t) case final s?
          when !d.isBefore(s.first) && !d.isAfter(s.last))
        t,
  ];
  found.sort((a, b) {
    final byStart = spanOf(a)!.first.compareTo(spanOf(b)!.first);
    if (byStart != 0) return byStart;
    // Within a day, tasks with a due time come first, earliest first.
    final byTime = (a.dueTime.isEmpty ? '99:99' : a.dueTime).compareTo(
      b.dueTime.isEmpty ? '99:99' : b.dueTime,
    );
    return byTime != 0 ? byTime : a.number.compareTo(b.number);
  });
  return found;
}

/// A task's dates as they should be after an edit: both, one, or neither.
@immutable
class Dates {
  const Dates({this.start, this.due});

  final Day? start;
  final Day? due;

  String get startIso => start == null ? '' : formatDay(start!);
  String get dueIso => due == null ? '' : formatDay(due!);

  @override
  bool operator ==(Object other) =>
      other is Dates && other.start == start && other.due == due;

  @override
  int get hashCode => Object.hash(start, due);

  @override
  String toString() => 'Dates($startIso → $dueIso)';
}

/// [task] picked up on day [grabbed] and dropped on [target]: it keeps its
/// length (both dates shift by the same number of days); a task with one date
/// takes [target] as that date; an unscheduled one (null [grabbed]) gets it as
/// its due date.
Dates moveTask(Task task, Day target, {Day? grabbed}) {
  final start = parseDay(task.startDate);
  final due = parseDay(task.dueDate);
  if (start == null && due == null) return Dates(due: target);
  if (start != null && due != null) {
    final delta = daysBetween(grabbed ?? start, target);
    return Dates(start: addDays(start, delta), due: addDays(due, delta));
  }
  return start != null ? Dates(start: target) : Dates(due: target);
}

enum BarEdge { start, end }

/// [task]'s bar with one edge dragged to [target]: the other edge stays, and
/// the edge cannot pass it (it stops on the same day). A task with one date
/// grows a second one.
Dates resizeTask(Task task, BarEdge edge, Day target) {
  final span = spanOf(task);
  if (span == null) return Dates(due: target);
  if (edge == BarEdge.start) {
    return Dates(
      start: target.isAfter(span.last) ? span.last : target,
      due: span.last,
    );
  }
  return Dates(
    start: span.first,
    due: target.isBefore(span.first) ? span.first : target,
  );
}
