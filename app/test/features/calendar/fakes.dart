import 'dart:async';

import 'package:taskforge/features/calendar/data/calendar_client.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../tasks/fakes.dart';

/// Reads the tasks of a [FakeTasksClient], so a reschedule through it shows on
/// the next read.
class FakeCalendarClient implements CalendarClient {
  FakeCalendarClient(this.source);

  final FakeTasksClient source;
  int trayPageSize = 50;
  final ranges = <({String first, String last, bool includeDone})>[];
  final trayCursors = <String>[];

  /// The cancel token of every range read, to see which were stopped.
  final tokens = <CancelToken?>[];

  /// The next range read is refused with this.
  TaskException? failRange;

  /// When set, [listRange] waits for it (to flip months while one is in flight).
  Completer<void>? rangeGate;

  @override
  Future<List<Task>> listRange(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    CancelToken? cancel,
  }) async {
    tokens.add(cancel);
    ranges.add((
      first: formatDay(first),
      last: formatDay(last),
      includeDone: includeDone,
    ));
    final gate = rangeGate;
    final snapshot = [
      for (final t in source.tasks)
        if (spanOf(t) case final s?
            when !s.last.isBefore(first) &&
                !s.first.isAfter(last) &&
                (includeDone || t.statusCategory != StatusCategory.done))
          t,
    ];
    if (gate != null) await gate.future;
    final failure = failRange;
    if (failure != null) {
      failRange = null;
      throw failure;
    }
    return snapshot;
  }

  @override
  Future<({List<Task> tasks, String cursor})> listUnscheduled(
    String workspaceId,
    String projectId, {
    String cursor = '',
  }) async {
    trayCursors.add(cursor);
    final open = [
      for (final t in source.tasks)
        if (spanOf(t) == null && t.statusCategory != StatusCategory.done) t,
    ];
    final from = cursor.isEmpty ? 0 : int.parse(cursor);
    final end = from + trayPageSize;
    return (
      tasks: open.skip(from).take(trayPageSize).toList(),
      cursor: end < open.length ? '$end' : '',
    );
  }
}
