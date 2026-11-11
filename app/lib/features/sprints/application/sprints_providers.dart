import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/sprints/data/sprints_client.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final sprintsClientProvider = Provider<SprintsClient>(
  (ref) => GrpcSprintsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// "Today" for days left (tests bring their own).
final sprintTodayProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// A sprint of a project.
typedef SprintKey = ({String project, String sprint});

/// Every sprint of a project, active first.
final sprintsProvider = FutureProvider.autoDispose.family<List<Sprint>, String>(
  (ref, project) async {
    final ws = ref.watch(workspaceScopeProvider);
    if (ws == null) return const [];
    return ref.watch(sprintsClientProvider).list(ws, project);
  },
);

/// Open tasks of the project that are in no sprint.
final backlogProvider = FutureProvider.autoDispose
    .family<List<SprintTask>, String>((ref, project) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(sprintsClientProvider).backlog(ws, project);
    });

final sprintTasksProvider = FutureProvider.autoDispose
    .family<List<SprintTask>, SprintKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref
          .watch(sprintsClientProvider)
          .tasks(ws, key.project, key.sprint);
    });

final burndownProvider = FutureProvider.autoDispose.family<Burndown, SprintKey>(
  (ref, key) async {
    final ws = ref.watch(workspaceScopeProvider);
    if (ws == null) throw const SprintException(SprintFailure.notFound);
    return ref
        .watch(sprintsClientProvider)
        .burndown(ws, key.project, key.sprint);
  },
);

/// Whether a project's board shows only the cards of its active sprint. It
/// lasts for the session (not saved with the layout: a sprint ends).
final boardCurrentSprintProvider =
    NotifierProvider.family<BoardCurrentSprint, bool, String>(
      BoardCurrentSprint.new,
    );

class BoardCurrentSprint extends Notifier<bool> {
  BoardCurrentSprint(this.projectId);

  final String projectId;

  @override
  bool build() => false;

  void set({required bool on}) => state = on;
}

/// Everything that shows sprints reads again.
void readSprintsAgain(Ref ref) {
  ref.invalidate(sprintsProvider);
  ref.invalidate(backlogProvider);
  ref.invalidate(sprintTasksProvider);
  ref.invalidate(burndownProvider);
}

String _pointsText(double? points) => points == null ? '' : decimalText(points);

/// What the buttons do. Each call acts on the server, then reads again, even
/// when it failed: a call that timed out may still have happened.
class SprintActions {
  SprintActions(this._ref);

  final Ref _ref;

  SprintsClient get _client => _ref.read(sprintsClientProvider);
  String get _ws => _ref.read(workspaceScopeProvider) ?? '';

  Future<T> _then<T>(Future<T> call) async {
    try {
      return await call;
    } finally {
      readSprintsAgain(_ref);
    }
  }

  Future<SprintAnswer> create(
    String project, {
    required String name,
    String goal = '',
    required DateTime start,
    required DateTime end,
    String capacityPoints = '',
    int capacitySec = 0,
  }) => _then(
    _client.create(
      _ws,
      project,
      name: name,
      goal: goal,
      start: start,
      end: end,
      capacityPoints: capacityPoints,
      capacitySec: capacitySec,
    ),
  );

  Future<SprintAnswer> edit(
    Sprint sprint, {
    required String name,
    required String goal,
    required DateTime start,
    required DateTime end,
    String capacityPoints = '',
    int capacitySec = 0,
  }) => _then(
    _client.update(
      _ws,
      sprint.projectId,
      sprint.id,
      fields: [
        if (name != sprint.name) 'name',
        if (goal != sprint.goal) 'goal',
        if (start != sprint.startDate) 'start_date',
        if (end != sprint.endDate) 'end_date',
        if (capacityPoints != _pointsText(sprint.capacityPoints))
          'capacity_points',
        if (capacitySec != (sprint.capacitySec ?? 0)) 'capacity_sec',
      ],
      expectedVersion: sprint.version,
      name: name,
      goal: goal,
      start: start,
      end: end,
      capacityPoints: capacityPoints,
      capacitySec: capacitySec,
    ),
  );

  /// Sets (an empty [text] clears) the capacity in points, or in hours.
  Future<SprintAnswer> setCapacity(
    Sprint sprint, {
    required bool hours,
    required String text,
  }) {
    final value = double.tryParse(text.trim());
    return _then(
      _client.update(
        _ws,
        sprint.projectId,
        sprint.id,
        fields: [hours ? 'capacity_sec' : 'capacity_points'],
        expectedVersion: sprint.version,
        capacityPoints: hours || value == null ? '' : decimalText(value),
        capacitySec: hours && value != null ? (value * 3600).round() : 0,
      ),
    );
  }

  Future<SprintAnswer> start(Sprint sprint) =>
      _then(_client.start(_ws, sprint.projectId, sprint.id));

  Future<SprintAnswer> complete(
    Sprint sprint, {
    required String carryOver,
    String nextSprintId = '',
  }) => _then(
    _client.complete(
      _ws,
      sprint.projectId,
      sprint.id,
      carryOver: carryOver,
      nextSprintId: nextSprintId,
    ),
  );

  Future<TasksChanged> add(Sprint sprint, List<String> taskIds) =>
      _then(_client.addTasks(_ws, sprint.projectId, sprint.id, taskIds));

  Future<TasksChanged> remove(Sprint sprint, List<String> taskIds) =>
      _then(_client.removeTasks(_ws, sprint.projectId, sprint.id, taskIds));

  /// An empty [points] clears the estimate.
  Future<SprintTask> setPoints(
    String project,
    SprintTask task,
    String points,
  ) => _then(
    _client.setPoints(
      _ws,
      project,
      task.id,
      points,
      expectedVersion: task.version,
    ),
  );
}

final sprintActionsProvider = Provider<SprintActions>(SprintActions.new);
