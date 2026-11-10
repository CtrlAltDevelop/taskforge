import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/calendar/data/calendar_client.dart'
    show CancelToken;
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart'
    show localToday;
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/gen/infrastructure/tasks/grpc/tasks.pbgrpc.dart'
    as pb;

/// A blocking link: [blockerId] has to finish before [dependentId] starts.
@immutable
class TimelineLink {
  const TimelineLink(this.blockerId, this.dependentId);

  final String blockerId;
  final String dependentId;

  @override
  bool operator ==(Object other) =>
      other is TimelineLink &&
      other.blockerId == blockerId &&
      other.dependentId == dependentId;

  @override
  int get hashCode => Object.hash(blockerId, dependentId);
}

/// What the chart shows: the tasks on the days read and the links touching them.
@immutable
class TimelineRead {
  const TimelineRead({this.tasks = const [], this.links = const []});

  final List<Task> tasks;
  final List<TimelineLink> links;
}

/// A dependent a move would push, and the dates it would get.
@immutable
class ShiftPreview {
  const ShiftPreview(this.task, {required this.newStart, required this.newDue});

  final Task task;
  final String newStart;
  final String newDue;
}

/// The workspace's working weekdays (0 Monday ... 6 Sunday) and holidays.
@immutable
class WorkingDays {
  const WorkingDays({
    this.days = const [0, 1, 2, 3, 4, 5, 6],
    this.holidays = const [],
  });

  final List<int> days;
  final List<String> holidays;
}

abstract interface class TimelineClient {
  Future<TimelineRead> read(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    String filterAst = '',
    CancelToken? cancel,
  });

  /// Ids of the longest chain of linked open tasks, first blocker first.
  Future<List<String>> criticalPath(String workspaceId, String projectId);

  /// The dependents that would move if [task] took [dates].
  Future<List<ShiftPreview>> previewShift(
    String workspaceId,
    Task task,
    Dates dates,
  );

  /// Moves [task] and its dependents together; [affectedIds] are the tasks the
  /// preview showed. Returns the moved tasks, [task] first.
  Future<List<Task>> applyShift(
    String workspaceId,
    Task task,
    Dates dates,
    List<String> affectedIds,
  );

  Future<WorkingDays> workingDays(String workspaceId);

  Future<WorkingDays> setWorkingDays(String workspaceId, WorkingDays days);
}

class GrpcTimelineClient implements TimelineClient {
  GrpcTimelineClient(ClientChannelBase channel, this._session)
    : _stub = pb.TimelineControllerClient(channel);

  final pb.TimelineControllerClient _stub;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapTaskError(e);
    }
  }

  @override
  Future<TimelineRead> read(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    String filterAst = '',
    CancelToken? cancel,
  }) => _run(() async {
    final call = _stub.get(
      pb.TimelineGetRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        rangeStart: formatDay(first),
        rangeEnd: formatDay(last),
        includeDone: includeDone,
        filterAst: filterAst,
        today: filterAst.isEmpty ? '' : localToday(),
      ),
      options: _options,
    );
    unawaited(cancel?.whenCancelled.then((_) => call.cancel()));
    final tasks = <String, Task>{};
    final links = <TimelineLink>{};
    try {
      await for (final chunk in call) {
        for (final t in chunk.tasks) {
          tasks.putIfAbsent(t.id, () => taskFromPb(t));
        }
        for (final l in chunk.links) {
          links.add(TimelineLink(l.fromId, l.toId));
        }
      }
    } on GrpcError {
      if (cancel?.isCancelled ?? false) return const TimelineRead();
      rethrow;
    }
    return TimelineRead(
      tasks: List.unmodifiable(tasks.values),
      links: List.unmodifiable(links),
    );
  });

  @override
  Future<List<String>> criticalPath(String workspaceId, String projectId) =>
      _run(() async {
        final reply = await _stub.criticalPath(
          pb.TimelineCriticalPathRequest(
            workspaceId: workspaceId,
            projectId: projectId,
          ),
          options: _options,
        );
        return List<String>.unmodifiable(reply.taskIds);
      });

  pb.TimelinePreviewRequest _preview(String workspaceId, Task t, Dates d) =>
      pb.TimelinePreviewRequest(
        workspaceId: workspaceId,
        projectId: t.projectId,
        taskId: t.id,
        startDate: d.startIso,
        dueDate: d.dueIso,
      );

  @override
  Future<List<ShiftPreview>> previewShift(
    String workspaceId,
    Task task,
    Dates dates,
  ) => _run(() async {
    final reply = await _stub.previewShift(
      _preview(workspaceId, task, dates),
      options: _options,
    );
    return [
      for (final s in reply.shifts)
        ShiftPreview(
          taskFromPb(s.task),
          newStart: s.newStart,
          newDue: s.newDue,
        ),
    ];
  });

  @override
  Future<List<Task>> applyShift(
    String workspaceId,
    Task task,
    Dates dates,
    List<String> affectedIds,
  ) => _run(() async {
    final reply = await _stub.applyShift(
      pb.TimelineApplyRequest(
        workspaceId: workspaceId,
        projectId: task.projectId,
        taskId: task.id,
        startDate: dates.startIso,
        dueDate: dates.dueIso,
        expectedVersion: task.version,
        affectedIds: affectedIds,
      ),
      options: _options,
    );
    return List.unmodifiable(reply.tasks.map(taskFromPb));
  });

  WorkingDays _days(pb.TimelineWorkingDays r) => WorkingDays(
    days: List.unmodifiable(r.days),
    holidays: List.unmodifiable(r.holidays),
  );

  @override
  Future<WorkingDays> workingDays(String workspaceId) => _run(
    () async => _days(
      await _stub.getWorkingDays(
        pb.TimelineWorkingDaysGetRequest(workspaceId: workspaceId),
        options: _options,
      ),
    ),
  );

  @override
  Future<WorkingDays> setWorkingDays(String workspaceId, WorkingDays days) =>
      _run(
        () async => _days(
          await _stub.setWorkingDays(
            pb.TimelineWorkingDaysSetRequest(
              workspaceId: workspaceId,
              days: days.days,
              holidays: days.holidays,
            ),
            options: _options,
          ),
        ),
      );
}
