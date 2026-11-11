import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show TaskRef;
import 'package:taskforge/features/time/data/time_client.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final timeClientProvider = Provider<TimeClient>(
  (ref) => GrpcTimeClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// "Now" for the running clock (tests bring their own).
final timeNowProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// The caller's timer in the current workspace.
final currentTimerProvider = FutureProvider<TimerState>((ref) async {
  final ws = ref.watch(workspaceScopeProvider);
  final now = ref.read(timeNowProvider);
  if (ws == null) return TimerState(receivedAt: now());
  // A failed read keeps the last good answer on screen (the state carries it),
  // so a network blip never makes a running timer vanish.
  final state = await ref.watch(timeClientProvider).current(ws);
  return TimerState(entry: state.entry, receivedAt: now());
});

/// Logged against estimated time of a task.
final timeSummaryProvider = FutureProvider.autoDispose
    .family<TimeSummary, TaskRef>((ref, task) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const TimeSummary();
      return ref.watch(timeClientProvider).summary(ws, task.project, task.task);
    });

/// Everyone's entries on a task, newest first.
final timeEntriesProvider = FutureProvider.autoDispose
    .family<List<TimeEntry>, TaskRef>((ref, task) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(timeClientProvider).entries(ws, task.project, task.task);
    });

/// A week of one person's time: [week] is a local Monday, [user] empty for
/// the caller.
typedef SheetKey = ({DateTime week, String user});

final timesheetProvider = FutureProvider.autoDispose
    .family<Timesheet, SheetKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) {
        return Timesheet(
          weekStart: key.week,
          rows: const [],
          dayTotals: List.filled(7, 0),
          total: 0,
        );
      }
      // The device's offset on that Monday: the server clips days by it.
      final offset = key.week.timeZoneOffset.inMinutes;
      return ref
          .watch(timeClientProvider)
          .timesheet(ws, key.week, offset, userId: key.user);
    });

/// Per-person time in a project over a week (local days, [week] a Monday).
typedef TotalsKey = ({String project, DateTime week});

final projectTotalsProvider = FutureProvider.autoDispose
    .family<List<PersonTotal>, TotalsKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref
          .watch(timeClientProvider)
          .totals(
            ws,
            key.project,
            key.week,
            key.week.add(const Duration(days: 7)),
          );
    });

/// Everything that shows time reads again (the person's timer or entries
/// changed here or on another device).
void readTimeAgain(Ref ref) {
  ref.invalidate(currentTimerProvider);
  ref.invalidate(timeSummaryProvider);
  ref.invalidate(timeEntriesProvider);
  ref.invalidate(timesheetProvider);
  ref.invalidate(projectTotalsProvider);
}

/// What the buttons do. Each call acts on the server, then refreshes.
class TimeActions {
  TimeActions(this._ref);

  final Ref _ref;

  TimeClient get _client => _ref.read(timeClientProvider);
  String get _ws => _ref.read(workspaceScopeProvider) ?? '';

  /// Runs [call], then reads everything again, even when it failed: a call
  /// that timed out may still have happened.
  Future<T> _then<T>(Future<T> call) async {
    try {
      return await call;
    } finally {
      readTimeAgain(_ref);
    }
  }

  Future<TimerStarted> start(String projectId, String taskId) =>
      _then(_client.start(_ws, projectId, taskId));

  Future<TimeEntry> stop() => _then(_client.stop(_ws));

  Future<TimeEntry> add(
    String projectId,
    String taskId, {
    required DateTime startedAt,
    required int durationSec,
    String note = '',
    bool billable = false,
  }) => _then(
    _client.createEntry(
      _ws,
      projectId,
      taskId,
      startedAt: startedAt,
      durationSec: durationSec,
      note: note,
      billable: billable,
    ),
  );

  Future<TimeEntry> edit(
    String id, {
    DateTime? startedAt,
    int? durationSec,
    String? note,
    bool? billable,
  }) => _then(
    _client.updateEntry(
      _ws,
      id,
      startedAt: startedAt,
      durationSec: durationSec,
      note: note,
      billable: billable,
    ),
  );

  Future<void> remove(String id) => _then(_client.deleteEntry(_ws, id));

  Future<void> estimate(String projectId, String taskId, int seconds) =>
      _then(_client.setEstimate(_ws, projectId, taskId, seconds));
}

final timeActionsProvider = Provider<TimeActions>(TimeActions.new);
