import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/foundation.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';

/// How near an edge (in pixels) a press counts as grabbing that edge.
const edgeGrab = 7.0;

/// What a press landed on: a task's bar, or one edge of it.
@immutable
class BarHit {
  const BarHit(this.task, this.rect, {this.edge});

  final Task task;
  final Rect rect;
  final BarEdge? edge;
}

/// Everything the chart draws, worked out once per change: the rows, the time
/// axis, the links between bars and the tasks lit as critical. Pure, so the
/// painter and the gestures answer from the same layout.
class TimelineScene {
  TimelineScene({
    required this.rows,
    required this.axis,
    required this.lastDay,
    this.links = const [],
    this.critical = const {},
    this.nonWorking = _never,
  }) {
    for (var i = 0; i < rows.length; i++) {
      final t = rows[i].task;
      if (t != null) {
        rowOf[t.id] = i;
        byId[t.id] = t;
      }
    }
  }

  final List<TimelineRow> rows;
  final TimeAxis axis;

  /// The last day the chart reaches.
  final Day lastDay;
  final List<TimelineLink> links;
  final Set<String> critical;

  /// Whether a day is off (a weekend or holiday), shaded on the chart.
  final bool Function(Day) nonWorking;

  final rowOf = <String, int>{};
  final byId = <String, Task>{};

  static bool _never(Day _) => false;

  Size get size =>
      Size(axis.widthOf(axis.origin, lastDay), rows.length * rowHeight);

  /// [task]'s bar (null when it has no dates or is not in the rows).
  Rect? rectOf(Task task) {
    final row = rowOf[task.id];
    return row == null ? null : barRect(task, axis, row);
  }

  /// The bar (or edge of a bar) under [point] in chart coordinates; null on
  /// empty space, a group heading or a task without dates.
  BarHit? hit(Offset point) {
    final row = (point.dy / rowHeight).floor();
    if (point.dy < 0 || row < 0 || row >= rows.length) return null;
    final task = rows[row].task;
    if (task == null) return null;
    final rect = barRect(task, axis, row);
    if (rect == null || point.dx < rect.left || point.dx > rect.right) {
      return null;
    }
    if (isMilestone(task) || rect.width < 3 * edgeGrab) {
      return BarHit(task, rect);
    }
    if (point.dx - rect.left <= edgeGrab) {
      return BarHit(task, rect, edge: BarEdge.start);
    }
    if (rect.right - point.dx <= edgeGrab) {
      return BarHit(task, rect, edge: BarEdge.end);
    }
    return BarHit(task, rect);
  }

  /// The links to draw whose rows can show in [rows] (see [linkVisible]).
  Iterable<TimelineLink> linksIn(({int first, int last}) range) sync* {
    for (final l in links) {
      final a = rowOf[l.blockerId];
      final b = rowOf[l.dependentId];
      if (a != null && b != null && linkVisible(a, b, range)) yield l;
    }
  }
}
