import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/gen/infrastructure/timetracking/grpc/timetracking.pbgrpc.dart'
    as pb;

/// What starting a timer did: the new entry, and the timer it replaced.
typedef TimerStarted = ({TimeEntry entry, TimeEntry? stopped});

abstract interface class TimeClient {
  Future<TimerStarted> start(
    String workspaceId,
    String projectId,
    String taskId,
  );
  Future<TimeEntry> stop(String workspaceId);
  Future<TimerState> current(String workspaceId);
  Future<TimeEntry> createEntry(
    String workspaceId,
    String projectId,
    String taskId, {
    required DateTime startedAt,
    required int durationSec,
    String note = '',
    bool billable = false,
  });
  Future<TimeEntry> updateEntry(
    String workspaceId,
    String id, {
    DateTime? startedAt,
    int? durationSec,
    String? note,
    bool? billable,
  });
  Future<void> deleteEntry(String workspaceId, String id);
  Future<List<TimeEntry>> entries(
    String workspaceId,
    String projectId,
    String taskId,
  );
  Future<TimeSummary> summary(
    String workspaceId,
    String projectId,
    String taskId,
  );

  /// 0 clears the estimate.
  Future<void> setEstimate(
    String workspaceId,
    String projectId,
    String taskId,
    int seconds,
  );

  /// [userId] empty means the caller; anyone else needs `time.edit_others`.
  Future<Timesheet> timesheet(
    String workspaceId,
    DateTime weekStart,
    int utcOffsetMinutes, {
    String userId = '',
  });

  /// Time in a project by entries that started in [start, end), per person.
  Future<List<PersonTotal>> totals(
    String workspaceId,
    String projectId,
    DateTime start,
    DateTime end,
  );
}

TimeException mapTimeError(Object error) {
  if (error is TimeException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument ||
      StatusCode.aborted => TimeException(TimeFailure.invalid, detail: message),
      StatusCode.permissionDenied => const TimeException(TimeFailure.denied),
      StatusCode.notFound => const TimeException(TimeFailure.notFound),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const TimeException(TimeFailure.network),
      _ => const TimeException(TimeFailure.other),
    };
  }
  return const TimeException(TimeFailure.network);
}

DateTime? _time(String raw) => raw.isEmpty ? null : DateTime.tryParse(raw);

TimeEntry entryFromPb(pb.Entry e) => TimeEntry(
  id: e.id,
  taskId: e.taskId,
  projectId: e.projectId,
  key: e.key,
  title: e.title,
  userId: e.userId,
  userName: e.userName,
  startedAt: _time(e.startedAt) ?? DateTime.now(),
  endedAt: _time(e.endedAt),
  durationSec: e.durationSec,
  note: e.note,
  billable: e.billable,
  source: e.source,
  flags: List.unmodifiable(e.flags),
);

class GrpcTimeClient implements TimeClient {
  GrpcTimeClient(ClientChannelBase channel, this._session)
    : _client = pb.TimeControllerClient(channel);

  final pb.TimeControllerClient _client;
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
      throw mapTimeError(e);
    }
  }

  @override
  Future<TimerStarted> start(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(() async {
    final a = await _client.start(
      pb.TimeStartRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
      ),
      options: _options,
    );
    return (
      entry: entryFromPb(a.entry),
      stopped: a.stopped.id.isEmpty ? null : entryFromPb(a.stopped),
    );
  });

  @override
  Future<TimeEntry> stop(String workspaceId) => _run(
    () async => entryFromPb(
      (await _client.stop(
        pb.TimeStopRequest(workspaceId: workspaceId),
        options: _options,
      )).entry,
    ),
  );

  @override
  Future<TimerState> current(String workspaceId) => _run(() async {
    final a = await _client.current(
      pb.TimeCurrentRequest(workspaceId: workspaceId),
      options: _options,
    );
    return TimerState(
      entry: a.running ? entryFromPb(a.entry) : null,
      receivedAt: DateTime.now(),
    );
  });

  @override
  Future<TimeEntry> createEntry(
    String workspaceId,
    String projectId,
    String taskId, {
    required DateTime startedAt,
    required int durationSec,
    String note = '',
    bool billable = false,
  }) => _run(
    () async => entryFromPb(
      await _client.createEntry(
        pb.EntryCreateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
          startedAt: startedAt.toUtc().toIso8601String().replaceFirst(
            'Z',
            '+00:00',
          ),
          durationSec: durationSec,
          note: note,
          billable: billable,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<TimeEntry> updateEntry(
    String workspaceId,
    String id, {
    DateTime? startedAt,
    int? durationSec,
    String? note,
    bool? billable,
  }) => _run(
    () async => entryFromPb(
      await _client.updateEntry(
        pb.EntryUpdateRequest(
          workspaceId: workspaceId,
          id: id,
          fields: [
            if (startedAt != null) 'started_at',
            if (durationSec != null) 'duration_sec',
            if (note != null) 'note',
            if (billable != null) 'billable',
          ],
          startedAt: startedAt?.toUtc().toIso8601String().replaceFirst(
            'Z',
            '+00:00',
          ),
          durationSec: durationSec,
          note: note,
          billable: billable,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<void> deleteEntry(String workspaceId, String id) => _run(
    () => _client.deleteEntry(
      pb.EntryDeleteRequest(workspaceId: workspaceId, id: id),
      options: _options,
    ),
  );

  @override
  Future<List<TimeEntry>> entries(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(
    () async => List.unmodifiable(
      (await _client.entries(
        pb.EntriesRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
        ),
        options: _options,
      )).entries.map(entryFromPb),
    ),
  );

  @override
  Future<TimeSummary> summary(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(() async {
    final a = await _client.summary(
      pb.TimeSummaryRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
      ),
      options: _options,
    );
    return TimeSummary(
      estimateSec: a.estimateSec,
      loggedSec: a.loggedSec,
      billableSec: a.billableSec,
      running: a.running,
    );
  });

  @override
  Future<void> setEstimate(
    String workspaceId,
    String projectId,
    String taskId,
    int seconds,
  ) => _run(
    () => _client.setEstimate(
      pb.EstimateSetRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        estimateSec: seconds,
      ),
      options: _options,
    ),
  );

  @override
  Future<Timesheet> timesheet(
    String workspaceId,
    DateTime weekStart,
    int utcOffsetMinutes, {
    String userId = '',
  }) => _run(() async {
    final a = await _client.timesheet(
      pb.TimesheetRequest(
        workspaceId: workspaceId,
        weekStart: isoDate(weekStart),
        utcOffsetMinutes: utcOffsetMinutes,
        userId: userId,
      ),
      options: _options,
    );
    return Timesheet(
      weekStart: weekStart,
      rows: List.unmodifiable([
        for (final r in a.rows)
          SheetRow(
            taskId: r.taskId,
            projectId: r.projectId,
            key: r.key,
            title: r.title,
            seconds: List.unmodifiable(r.seconds),
            total: r.total,
            billable: r.billable,
          ),
      ]),
      dayTotals: List.unmodifiable(a.dayTotals),
      total: a.total,
    );
  });

  @override
  Future<List<PersonTotal>> totals(
    String workspaceId,
    String projectId,
    DateTime start,
    DateTime end,
  ) => _run(() async {
    String at(DateTime d) =>
        d.toUtc().toIso8601String().replaceFirst('Z', '+00:00');
    final a = await _client.totals(
      pb.TotalsRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        start: at(start),
        end: at(end),
      ),
      options: _options,
    );
    return List.unmodifiable([
      for (final p in a.people)
        PersonTotal(
          userId: p.userId,
          name: p.name,
          seconds: p.seconds,
          billable: p.billable,
        ),
    ]);
  });
}
