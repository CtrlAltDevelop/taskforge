import 'dart:async';

import 'package:taskforge/features/time/data/time_client.dart';
import 'package:taskforge/features/time/domain/time.dart';

/// An in-memory time server: one timer for the caller, entries, estimates.
/// Time passes only when a test says so ([clock]).
class FakeTimeClient implements TimeClient {
  FakeTimeClient({DateTime? now, this.me = 'u1'})
    : clock = now ?? DateTime.utc(2026, 11, 11, 12);

  DateTime clock;
  final String me;
  final entries_ = <TimeEntry>[];
  final estimates = <String, int>{}; // by task
  final startCalls = <String>[];
  final stopCalls = <int>[];
  final timesheetAsks = <({DateTime week, int offset, String user})>[];
  final totalsAsks = <({String project, DateTime start, DateTime end})>[];
  var _n = 0;
  TimeException? failNext;

  /// Every timesheet read fails while set (a provider retries once on its own).
  TimeException? failSheets;

  /// Every read of the timer fails while set.
  TimeException? failCurrent;

  /// While set, [start] waits for it (keeps a request in flight).
  Completer<void>? startGate;
  Completer<void>? gate;

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  TimeEntry? get running => entries_.where((e) => e.running).firstOrNull;

  TimeEntry make({
    required String task,
    String project = 'p1',
    DateTime? startedAt,
    int seconds = 0,
    bool running = false,
    String user = 'u1',
    String note = '',
    bool billable = false,
    List<String> flags = const [],
  }) {
    final start = startedAt ?? clock;
    return TimeEntry(
      id: 'e${++_n}',
      taskId: task,
      projectId: project,
      key: 'WEB-$task',
      title: 'Task $task',
      userId: user,
      userName: user == me ? 'You' : 'Hank',
      startedAt: start,
      endedAt: running ? null : start.add(Duration(seconds: seconds)),
      durationSec: seconds,
      note: note,
      billable: billable,
      source: running ? 'timer' : 'manual',
      flags: flags,
    );
  }

  TimeEntry add(TimeEntry e) {
    entries_.add(e);
    return e;
  }

  int _seconds(TimeEntry e) =>
      e.running ? clock.difference(e.startedAt).inSeconds : e.durationSec;

  TimeEntry _closed(TimeEntry e) => TimeEntry(
    id: e.id,
    taskId: e.taskId,
    projectId: e.projectId,
    key: e.key,
    title: e.title,
    userId: e.userId,
    userName: e.userName,
    startedAt: e.startedAt,
    endedAt: clock,
    durationSec: clock.difference(e.startedAt).inSeconds,
    note: e.note,
    billable: e.billable,
  );

  @override
  Future<TimerStarted> start(
    String workspaceId,
    String projectId,
    String taskId,
  ) async {
    _maybeFail();
    startCalls.add(taskId);
    final hold = startGate;
    if (hold != null) await hold.future;
    TimeEntry? stopped;
    final r = running;
    if (r != null) {
      stopped = _closed(r);
      entries_[entries_.indexOf(r)] = stopped;
    }
    final made = make(
      task: taskId,
      project: projectId,
      running: true,
      startedAt: clock,
    );
    entries_.add(made);
    return (entry: made, stopped: stopped);
  }

  @override
  Future<TimeEntry> stop(String workspaceId) async {
    _maybeFail();
    final r = running;
    if (r == null) {
      throw const TimeException(
        TimeFailure.invalid,
        detail: 'No timer is running.',
      );
    }
    stopCalls.add(1);
    final closed = _closed(r);
    entries_[entries_.indexOf(r)] = closed;
    return closed;
  }

  @override
  Future<TimerState> current(String workspaceId) async {
    final broken = failCurrent;
    if (broken != null) throw broken;
    final g = gate;
    if (g != null) await g.future;
    final r = running;
    return TimerState(
      entry: r == null
          ? null
          : TimeEntry(
              id: r.id,
              taskId: r.taskId,
              projectId: r.projectId,
              key: r.key,
              title: r.title,
              userId: r.userId,
              userName: r.userName,
              startedAt: r.startedAt,
              durationSec: _seconds(r),
            ),
      receivedAt: DateTime.now(),
    );
  }

  @override
  Future<TimeEntry> createEntry(
    String workspaceId,
    String projectId,
    String taskId, {
    required DateTime startedAt,
    required int durationSec,
    String note = '',
    bool billable = false,
  }) async {
    _maybeFail();
    return add(
      make(
        task: taskId,
        project: projectId,
        startedAt: startedAt,
        seconds: durationSec,
        note: note,
        billable: billable,
      ),
    );
  }

  @override
  Future<TimeEntry> updateEntry(
    String workspaceId,
    String id, {
    DateTime? startedAt,
    int? durationSec,
    String? note,
    bool? billable,
  }) async {
    _maybeFail();
    final i = entries_.indexWhere((e) => e.id == id);
    final e = entries_[i];
    final start = startedAt ?? e.startedAt;
    final seconds = durationSec ?? e.durationSec;
    return entries_[i] = TimeEntry(
      id: e.id,
      taskId: e.taskId,
      projectId: e.projectId,
      key: e.key,
      title: e.title,
      userId: e.userId,
      userName: e.userName,
      startedAt: start,
      endedAt: e.running ? null : start.add(Duration(seconds: seconds)),
      durationSec: seconds,
      note: note ?? e.note,
      billable: billable ?? e.billable,
      source: e.source,
      flags: e.flags,
    );
  }

  @override
  Future<void> deleteEntry(String workspaceId, String id) async {
    _maybeFail();
    entries_.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<TimeEntry>> entries(
    String workspaceId,
    String projectId,
    String taskId,
  ) async => [
    for (final e in entries_.reversed)
      if (e.taskId == taskId) e,
  ];

  @override
  Future<TimeSummary> summary(
    String workspaceId,
    String projectId,
    String taskId,
  ) async {
    final mine = entries_.where((e) => e.taskId == taskId);
    return TimeSummary(
      estimateSec: estimates[taskId] ?? 0,
      loggedSec: mine.fold(0, (a, e) => a + _seconds(e)),
      billableSec: mine
          .where((e) => e.billable)
          .fold(0, (a, e) => a + _seconds(e)),
      running: mine.any((e) => e.running),
    );
  }

  @override
  Future<void> setEstimate(
    String workspaceId,
    String projectId,
    String taskId,
    int seconds,
  ) async {
    _maybeFail();
    if (seconds == 0) {
      estimates.remove(taskId);
    } else {
      estimates[taskId] = seconds;
    }
  }

  @override
  Future<Timesheet> timesheet(
    String workspaceId,
    DateTime weekStart,
    int utcOffsetMinutes, {
    String userId = '',
  }) async {
    final stuck = failSheets;
    if (stuck != null) throw stuck;
    _maybeFail();
    timesheetAsks.add((
      week: weekStart,
      offset: utcOffsetMinutes,
      user: userId,
    ));
    final who = userId.isEmpty ? me : userId;
    final rows = <String, List<int>>{};
    final meta = <String, TimeEntry>{};
    for (final e in entries_.where((e) => e.userId == who && !e.running)) {
      final day = DateTime(
        e.startedAt.year,
        e.startedAt.month,
        e.startedAt.day,
      ).difference(weekStart).inDays;
      if (day < 0 || day > 6) continue;
      rows.putIfAbsent(e.taskId, () => List.filled(7, 0))[day] += e.durationSec;
      meta[e.taskId] = e;
    }
    final list = [
      for (final t in rows.keys)
        SheetRow(
          taskId: t,
          projectId: meta[t]!.projectId,
          key: meta[t]!.key,
          title: meta[t]!.title,
          seconds: rows[t]!,
          total: rows[t]!.fold(0, (a, b) => a + b),
        ),
    ];
    final days = [
      for (var i = 0; i < 7; i++) list.fold(0, (a, r) => a + r.seconds[i]),
    ];
    return Timesheet(
      weekStart: weekStart,
      rows: list,
      dayTotals: days,
      total: days.fold(0, (a, b) => a + b),
    );
  }

  @override
  Future<List<PersonTotal>> totals(
    String workspaceId,
    String projectId,
    DateTime start,
    DateTime end,
  ) async {
    _maybeFail();
    totalsAsks.add((project: projectId, start: start, end: end));
    final by = <String, List<TimeEntry>>{};
    for (final e in entries_.where(
      (e) =>
          e.projectId == projectId &&
          !e.startedAt.isBefore(start) &&
          e.startedAt.isBefore(end),
    )) {
      by.putIfAbsent(e.userId, () => []).add(e);
    }
    return [
      for (final u in by.keys)
        PersonTotal(
          userId: u,
          name: u == me ? 'You' : 'Hank',
          seconds: by[u]!.fold(0, (a, e) => a + e.durationSec),
          billable: by[u]!
              .where((e) => e.billable)
              .fold(0, (a, e) => a + e.durationSec),
        ),
    ];
  }
}
