import 'dart:async';

import 'package:taskforge/features/calendar/data/calendar_client.dart'
    show CancelToken;
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../tasks/fakes.dart';

/// Reads the tasks of a [FakeTasksClient]; a move changes them there, so the
/// next read shows it. What a move pushes is whatever the test puts in
/// [shifts] (task id -> the dependents it would push).
class FakeTimelineClient implements TimelineClient {
  FakeTimelineClient(this.source);

  final FakeTasksClient source;
  final links = <TimelineLink>[];
  List<String> critical = const [];
  final shifts = <String, List<ShiftPreview>>{};
  WorkingDays days = const WorkingDays();

  final reads = <({String first, String last, bool includeDone})>[];
  final previews = <({String task, Dates dates})>[];
  final applied = <({String task, Dates dates, List<String> affected})>[];
  final savedDays = <WorkingDays>[];
  var criticalReads = 0;

  /// The next read / apply is refused with this.
  TaskException? failRead;
  TaskException? failApply;

  @override
  Future<TimelineRead> read(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    String filterAst = '',
    CancelToken? cancel,
  }) async {
    reads.add((
      first: formatDay(first),
      last: formatDay(last),
      includeDone: includeDone,
    ));
    final failure = failRead;
    if (failure != null) {
      failRead = null;
      throw failure;
    }
    final tasks = [
      for (final t in source.tasks)
        if (spanOf(t) case final s?
            when !s.last.isBefore(first) &&
                !s.first.isAfter(last) &&
                (includeDone || t.statusCategory != StatusCategory.done))
          t,
    ];
    final shown = {for (final t in tasks) t.id};
    return TimelineRead(
      tasks: tasks,
      links: [
        for (final l in links)
          if (shown.contains(l.blockerId) || shown.contains(l.dependentId)) l,
      ],
    );
  }

  @override
  Future<List<String>> criticalPath(
    String workspaceId,
    String projectId,
  ) async {
    criticalReads++;
    return critical;
  }

  @override
  Future<List<ShiftPreview>> previewShift(
    String workspaceId,
    Task task,
    Dates dates,
  ) async {
    previews.add((task: task.id, dates: dates));
    return shifts[task.id] ?? const [];
  }

  void _set(String id, String start, String due) {
    final i = source.tasks.indexWhere((t) => t.id == id);
    if (i < 0) return;
    source.tasks[i] = source.tasks[i].apply(
      TaskPatch(startDate: start, dueDate: due),
    );
  }

  @override
  Future<List<Task>> applyShift(
    String workspaceId,
    Task task,
    Dates dates,
    List<String> affectedIds,
  ) async {
    applied.add((task: task.id, dates: dates, affected: affectedIds));
    final failure = failApply;
    if (failure != null) {
      failApply = null;
      throw failure;
    }
    _set(task.id, dates.startIso, dates.dueIso);
    for (final s in shifts[task.id] ?? const <ShiftPreview>[]) {
      _set(s.task.id, s.newStart, s.newDue);
    }
    return [
      for (final id in [task.id, ...affectedIds])
        source.tasks.firstWhere((t) => t.id == id),
    ];
  }

  @override
  Future<WorkingDays> workingDays(String workspaceId) async => days;

  @override
  Future<WorkingDays> setWorkingDays(
    String workspaceId,
    WorkingDays value,
  ) async {
    savedDays.add(value);
    return days = value;
  }
}
