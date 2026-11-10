import 'dart:ui' show Offset, Rect;

import 'package:flutter/foundation.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

const rowHeight = 32.0;
const barHeight = 20.0;
const arrowGap = 8.0;

/// How much time the chart shows per screen width: a day is a column wide at
/// [day] and a few pixels at [quarter].
enum TimelineZoom {
  day(48),
  week(18),
  month(6),
  quarter(2);

  const TimelineZoom(this.pxPerDay);

  final double pxPerDay;

  /// The days a read covers around the day the chart is centred on.
  int get readDays => switch (this) {
    day => 30,
    week => 120,
    month => 400,
    quarter => 540,
  };

  TimelineZoom get finer => index == 0 ? this : values[index - 1];
  TimelineZoom get coarser =>
      index == values.length - 1 ? this : values[index + 1];
}

/// The zoom after a pinch of [scale] (above 1 spreads the days out).
TimelineZoom zoomAfter(TimelineZoom zoom, double scale) {
  if (scale > 1.3) return zoom.finer;
  if (scale < 0.77) return zoom.coarser;
  return zoom;
}

/// The days a chart centred on [anchor] reads, first to last.
({Day first, Day last}) readRange(TimelineZoom zoom, Day anchor) => (
  first: addDays(anchor, -zoom.readDays),
  last: addDays(anchor, zoom.readDays),
);

/// Maps days to horizontal pixels: [origin] is x = 0.
@immutable
class TimeAxis {
  const TimeAxis(this.origin, this.pxPerDay);

  final Day origin;
  final double pxPerDay;

  double xOf(Day d) => daysBetween(origin, d) * pxPerDay;

  /// The day under pixel [x].
  Day dayAt(double x) => addDays(origin, (x / pxPerDay).floor());

  double widthOf(Day first, Day last) =>
      (daysBetween(first, last) + 1) * pxPerDay;
}

/// A line of the left panel: a task, or a group heading.
@immutable
class TimelineRow {
  const TimelineRow.task(Task this.task, {this.depth = 0}) : header = null;
  const TimelineRow.header(String this.header) : task = null, depth = 0;

  final Task? task;
  final String? header;
  final int depth;
}

const groupNone = '';
const groupAssignee = 'assignee';
const groupStatus = 'status';

/// The rows of [tasks]: in tree order (a parent right before its subtasks; a
/// subtask whose parent is not among [tasks] stands at the top level), or one
/// group after another when [groupBy] says so. [assigneeName] names an
/// assignee id for a group heading.
List<TimelineRow> buildRows(
  List<Task> tasks,
  String groupBy, {
  String Function(String id) assigneeName = _same,
  String unassigned = 'Unassigned',
}) {
  if (groupBy == groupNone ||
      (groupBy != groupAssignee && groupBy != groupStatus)) {
    return _tree(tasks);
  }
  final groups = <String, List<Task>>{};
  for (final t in tasks) {
    final key = groupBy == groupStatus
        ? t.statusName
        : (t.assigneeIds.isEmpty ? '' : assigneeName(t.assigneeIds.first));
    (groups[key] ??= []).add(t);
  }
  final keys = groups.keys.toList()
    ..sort((a, b) {
      if (a.isEmpty != b.isEmpty) return a.isEmpty ? 1 : -1; // unassigned last
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
  return [
    for (final key in keys) ...[
      TimelineRow.header(key.isEmpty ? unassigned : key),
      for (final t in groups[key]!) TimelineRow.task(t),
    ],
  ];
}

String _same(String id) => id;

List<TimelineRow> _tree(List<Task> tasks) {
  final ids = {for (final t in tasks) t.id};
  final kids = <String, List<Task>>{};
  final roots = <Task>[];
  for (final t in tasks) {
    if (t.parentId.isNotEmpty && ids.contains(t.parentId)) {
      (kids[t.parentId] ??= []).add(t);
    } else {
      roots.add(t);
    }
  }
  final rows = <TimelineRow>[];
  final seen = <String>{};
  void walk(Task t, int depth) {
    if (!seen.add(t.id)) return; // bad data never loops
    rows.add(TimelineRow.task(t, depth: depth));
    for (final k in kids[t.id] ?? const <Task>[]) {
      walk(k, depth + 1);
    }
  }

  for (final t in [...roots, ...tasks]) {
    walk(t, 0); // the second pass picks up whatever a parent cycle left out
  }
  return rows;
}

/// A task with exactly one date is a milestone: a point, not a bar.
bool isMilestone(Task task) =>
    (task.startDate.isEmpty) != (task.dueDate.isEmpty);

/// Where [task]'s bar sits on [row] (null when it has no dates). A milestone is
/// a square centred on its day.
Rect? barRect(Task task, TimeAxis axis, int row) {
  final span = spanOf(task);
  if (span == null) return null;
  final top = row * rowHeight + (rowHeight - barHeight) / 2;
  if (isMilestone(task)) {
    final centre = axis.xOf(span.first) + axis.pxPerDay / 2;
    return Rect.fromLTWH(centre - barHeight / 2, top, barHeight, barHeight);
  }
  return Rect.fromLTWH(
    axis.xOf(span.first),
    top,
    axis.widthOf(span.first, span.last),
    barHeight,
  );
}

/// The rows to paint for a viewport scrolled [scrollY] down and [height] tall,
/// one row of slack either side; empty when there are no rows.
({int first, int last}) visibleRows(double scrollY, double height, int count) {
  if (count == 0) return (first: 0, last: -1);
  final first = (scrollY / rowHeight).floor() - 1;
  final last = ((scrollY + height) / rowHeight).ceil() + 1;
  return (first: first.clamp(0, count - 1), last: last.clamp(0, count - 1));
}

/// Whether a link between rows [a] and [b] can show in [range] (a line that
/// crosses the viewport counts although both its ends are off screen).
bool linkVisible(int a, int b, ({int first, int last}) range) =>
    (a > b ? a : b) >= range.first && (a < b ? a : b) <= range.last;

/// The corners of the arrow from the end of [from] to the start of [to]: a
/// short elbow when [to] starts well after, else around it through the gap
/// between the rows.
List<Offset> arrowPoints(Rect from, Rect to) {
  final start = from.centerRight;
  final end = to.centerLeft;
  if (end.dx - start.dx >= 2 * arrowGap) {
    final mid = (start.dx + end.dx) / 2;
    return [start, Offset(mid, start.dy), Offset(mid, end.dy), end];
  }
  final midY = (start.dy + end.dy) / 2;
  return [
    start,
    Offset(start.dx + arrowGap, start.dy),
    Offset(start.dx + arrowGap, midY),
    Offset(end.dx - arrowGap, midY),
    Offset(end.dx - arrowGap, end.dy),
    end,
  ];
}

/// A blocking link whose [dependent] starts on or before the day its
/// [blocker] is due: the order the link asks for is broken.
bool linkConflicts(Task blocker, Task dependent) {
  final finish = parseDay(blocker.dueDate) ?? parseDay(blocker.startDate);
  final begin = parseDay(dependent.startDate) ?? parseDay(dependent.dueDate);
  if (finish == null || begin == null) return false;
  return !begin.isAfter(finish);
}

/// One mark on the time axis.
@immutable
class AxisTick {
  const AxisTick(this.day, this.label, {this.major = false});

  final Day day;
  final String label;

  /// A month (or year) boundary, drawn heavier.
  final bool major;
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
]; // dart format: keep as a table

/// The marks to draw between [first] and [last] at [zoom]: every day, every
/// Monday, every month start, or every quarter start.
List<AxisTick> axisTicks(TimelineZoom zoom, Day first, Day last) {
  final ticks = <AxisTick>[];
  for (var d = first; !d.isAfter(last); d = addDays(d, 1)) {
    final first1 = d.day == 1;
    switch (zoom) {
      case TimelineZoom.day:
        ticks.add(
          AxisTick(
            d,
            first1 ? _months[d.month - 1] : '${d.day}',
            major: first1,
          ),
        );
      case TimelineZoom.week:
        if (d.weekday == DateTime.monday) {
          ticks.add(
            AxisTick(d, '${d.day} ${_months[d.month - 1]}', major: first1),
          );
        }
      case TimelineZoom.month:
        if (first1) {
          ticks.add(
            AxisTick(
              d,
              d.month == 1 ? '${d.year}' : _months[d.month - 1],
              major: d.month == 1,
            ),
          );
        }
      case TimelineZoom.quarter:
        if (first1 && (d.month - 1) % 3 == 0) {
          ticks.add(
            AxisTick(
              d,
              'Q${(d.month - 1) ~/ 3 + 1} ${d.year}',
              major: d.month == 1,
            ),
          );
        }
    }
  }
  return ticks;
}
