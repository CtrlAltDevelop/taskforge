import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/recurrence/data/recurrence_client.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final recurrenceClientProvider = Provider<RecurrenceClient>(
  (ref) => GrpcRecurrenceClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// A task and the project it is in.
typedef RepeatTarget = ({String project, String task});

/// The repeat rule of a task (null: it does not repeat).
final repeatProvider = FutureProvider.autoDispose
    .family<RepeatSeries?, RepeatTarget>((ref, target) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return null;
      return ref
          .watch(recurrenceClientProvider)
          .get(ws, target.project, target.task);
    }, retry: (_, _) => null);

/// The next dates of a draft, as the server would make them. A draft that
/// cannot be saved has none.
/// [startsOn] is where the rule counts from; [after] the day of the latest
/// instance of a series that already runs (empty for a new one).
typedef PreviewKey = ({RepeatDraft draft, String startsOn, String after});

final repeatPreviewProvider = FutureProvider.autoDispose
    .family<RepeatPreview?, PreviewKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null || key.draft.problem != null) return null;
      return ref
          .watch(recurrenceClientProvider)
          .preview(ws, key.draft, startsOn: key.startsOn, after: key.after);
    }, retry: (_, _) => null);

/// The dates still to be made on the days the calendar shows.
typedef GhostRange = ({String project, String start, String end});

final repeatGhostsProvider = FutureProvider.autoDispose
    .family<List<RepeatGhost>, GhostRange>((ref, range) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref
          .watch(recurrenceClientProvider)
          .upcoming(
            ws,
            start: range.start,
            end: range.end,
            projectId: range.project,
          );
    }, retry: (_, _) => null);

/// What the buttons do. Each call acts on the server, then reads again, even
/// when it failed: a call that timed out may still have happened.
class RepeatActions {
  RepeatActions(this._ref);

  final Ref _ref;

  String get _ws {
    final id = _ref.read(workspaceScopeProvider);
    if (id == null) throw const RepeatException(RepeatFailure.other);
    return id;
  }

  Future<T> _then<T>(Future<T> Function() call) async {
    try {
      return await call();
    } finally {
      _ref.invalidate(repeatProvider);
      _ref.invalidate(repeatGhostsProvider);
    }
  }

  Future<RepeatSeries> set(RepeatTarget t, RepeatDraft draft) => _then(
    () =>
        _ref.read(recurrenceClientProvider).set(_ws, t.project, t.task, draft),
  );

  Future<void> clear(RepeatTarget t) => _then(
    () => _ref.read(recurrenceClientProvider).clear(_ws, t.project, t.task),
  );

  Future<RepeatSeries> pause(RepeatTarget t, {required bool paused}) => _then(
    () => _ref
        .read(recurrenceClientProvider)
        .pause(_ws, t.project, t.task, paused: paused),
  );

  Future<int> updateFuture(RepeatTarget t) => _then(
    () async =>
        (await _ref
                .read(recurrenceClientProvider)
                .updateFuture(_ws, t.project, t.task))
            .changed,
  );
}

final repeatActionsProvider = Provider<RepeatActions>(RepeatActions.new);
