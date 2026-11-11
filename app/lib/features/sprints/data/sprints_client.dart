import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/gen/infrastructure/sprints/grpc/sprints.pbgrpc.dart'
    as pb;

abstract interface class SprintsClient {
  Future<List<Sprint>> list(
    String workspaceId,
    String projectId, {
    List<String> states = const [],
  });
  Future<SprintAnswer> create(
    String workspaceId,
    String projectId, {
    required String name,
    String goal = '',
    required DateTime start,
    required DateTime end,
  });

  /// Only the named [fields] change (`name`, `goal`, `start_date`, `end_date`).
  Future<SprintAnswer> update(
    String workspaceId,
    String projectId,
    String sprintId, {
    required List<String> fields,
    required int expectedVersion,
    String name = '',
    String goal = '',
    DateTime? start,
    DateTime? end,
  });
  Future<SprintAnswer> start(
    String workspaceId,
    String projectId,
    String sprintId,
  );

  /// [carryOver] is `next` or `backlog`.
  Future<SprintAnswer> complete(
    String workspaceId,
    String projectId,
    String sprintId, {
    required String carryOver,
    String nextSprintId = '',
  });
  Future<TasksChanged> addTasks(
    String workspaceId,
    String projectId,
    String sprintId,
    List<String> taskIds,
  );
  Future<TasksChanged> removeTasks(
    String workspaceId,
    String projectId,
    String sprintId,
    List<String> taskIds,
  );
  Future<List<SprintTask>> tasks(
    String workspaceId,
    String projectId,
    String sprintId,
  );
  Future<List<SprintTask>> backlog(
    String workspaceId,
    String projectId, {
    int limit = 0,
  });

  /// An empty [points] clears the estimate.
  Future<SprintTask> setPoints(
    String workspaceId,
    String projectId,
    String taskId,
    String points, {
    int expectedVersion = 0,
  });
  Future<Burndown> burndown(
    String workspaceId,
    String projectId,
    String sprintId,
  );
}

SprintException mapSprintError(Object error) {
  if (error is SprintException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => SprintException(
        SprintFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists || StatusCode.aborted => SprintException(
        SprintFailure.conflict,
        detail: message,
      ),
      StatusCode.permissionDenied => const SprintException(
        SprintFailure.denied,
      ),
      StatusCode.notFound => const SprintException(SprintFailure.notFound),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const SprintException(SprintFailure.network),
      _ => const SprintException(SprintFailure.other),
    };
  }
  return const SprintException(SprintFailure.network);
}

DateTime _date(String raw) => parseDay(raw) ?? DateTime.now();

Sprint sprintFromPb(pb.Sprint s) => Sprint(
  id: s.id,
  projectId: s.projectId,
  name: s.name,
  goal: s.goal,
  startDate: _date(s.startDate),
  endDate: _date(s.endDate),
  state: SprintState.parse(s.state),
  version: s.version,
  baselinePoints: s.baselinePoints,
  baselineTasks: s.baselineTasks,
  completedPoints: s.completedPoints,
  completedTasks: s.completedTasks,
  unfinishedTasks: s.unfinishedTasks,
  taskCount: s.taskCount,
  pointsTotal: s.pointsTotal,
  openTasks: s.openTasks,
  openPoints: s.openPoints,
  doneTasks: s.doneTasks,
  donePoints: s.donePoints,
  estimateSecTotal: s.estimateSecTotal,
);

SprintTask taskFromPb(pb.SprintTask t) => SprintTask(
  id: t.id,
  key: t.key,
  title: t.title,
  statusName: t.statusName,
  statusCategory: t.statusCategory,
  priority: t.priority,
  points: t.hasPoints_10 ? t.points : null,
  estimateSec: t.estimateSec,
  sprintId: t.sprintId,
  version: t.version,
  late: t.late,
);

Burndown burndownFromPb(pb.BurndownAnswer a) => Burndown(
  sprint: sprintFromPb(a.sprint),
  baselinePoints: a.baselinePoints,
  baselineTasks: a.baselineTasks,
  averageVelocity: a.averageVelocity,
  days: [
    for (final d in a.days)
      BurndownDay(
        date: _date(d.date),
        idealPoints: d.idealPoints,
        idealTasks: d.idealTasks,
        hasActual: d.hasActual,
        live: d.live,
        backfilled: d.backfilled,
        remainingPoints: d.remainingPoints,
        remainingTasks: d.remainingTasks,
        scopePoints: d.scopePoints,
        scopeTasks: d.scopeTasks,
      ),
  ],
  scopeChanges: [
    for (final c in a.scopeChanges)
      ScopeChange(date: _date(c.date), points: c.points, tasks: c.tasks),
  ],
  velocity: [
    for (final v in a.velocity)
      VelocityItem(
        sprintId: v.sprintId,
        name: v.name,
        committedPoints: v.committedPoints,
        completedPoints: v.completedPoints,
        committedTasks: v.committedTasks,
        completedTasks: v.completedTasks,
      ),
  ],
);

class GrpcSprintsClient implements SprintsClient {
  GrpcSprintsClient(ClientChannelBase channel, this._session)
    : _client = pb.SprintControllerClient(channel),
      _backlog = pb.BacklogControllerClient(channel);

  final pb.SprintControllerClient _client;
  final pb.BacklogControllerClient _backlog;
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
      throw mapSprintError(e);
    }
  }

  SprintAnswer _answer(pb.SprintAnswer a) =>
      SprintAnswer(sprintFromPb(a.sprint), List.unmodifiable(a.warnings));

  TasksChanged _changed(pb.SprintTasksChanged c) => TasksChanged(
    sprint: sprintFromPb(c.sprint),
    changed: c.changed,
    addedAfterStart: c.addedAfterStart,
  );

  @override
  Future<List<Sprint>> list(
    String workspaceId,
    String projectId, {
    List<String> states = const [],
  }) => _run(() async {
    final a = await _client.list(
      pb.SprintListRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        states: states,
      ),
      options: _options,
    );
    return List.unmodifiable(a.sprints.map(sprintFromPb));
  });

  @override
  Future<SprintAnswer> create(
    String workspaceId,
    String projectId, {
    required String name,
    String goal = '',
    required DateTime start,
    required DateTime end,
  }) => _run(
    () async => _answer(
      await _client.create(
        pb.SprintCreateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          name: name,
          goal: goal,
          startDate: dayText(start),
          endDate: dayText(end),
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<SprintAnswer> update(
    String workspaceId,
    String projectId,
    String sprintId, {
    required List<String> fields,
    required int expectedVersion,
    String name = '',
    String goal = '',
    DateTime? start,
    DateTime? end,
  }) => _run(
    () async => _answer(
      await _client.update(
        pb.SprintUpdateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          sprintId: sprintId,
          fields: fields,
          expectedVersion: expectedVersion,
          name: name,
          goal: goal,
          startDate: start == null ? '' : dayText(start),
          endDate: end == null ? '' : dayText(end),
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<SprintAnswer> start(
    String workspaceId,
    String projectId,
    String sprintId,
  ) => _run(
    () async => _answer(
      await _client.start(
        pb.SprintStartRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          sprintId: sprintId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<SprintAnswer> complete(
    String workspaceId,
    String projectId,
    String sprintId, {
    required String carryOver,
    String nextSprintId = '',
  }) => _run(
    () async => _answer(
      await _client.complete(
        pb.SprintCompleteRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          sprintId: sprintId,
          carryOver: carryOver,
          nextSprintId: nextSprintId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<TasksChanged> addTasks(
    String workspaceId,
    String projectId,
    String sprintId,
    List<String> taskIds,
  ) => _run(
    () async => _changed(
      await _client.addTasks(
        pb.SprintTasksChangeRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          sprintId: sprintId,
          taskIds: taskIds,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<TasksChanged> removeTasks(
    String workspaceId,
    String projectId,
    String sprintId,
    List<String> taskIds,
  ) => _run(
    () async => _changed(
      await _client.removeTasks(
        pb.SprintTasksChangeRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          sprintId: sprintId,
          taskIds: taskIds,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<SprintTask>> tasks(
    String workspaceId,
    String projectId,
    String sprintId,
  ) => _run(() async {
    final a = await _client.tasks(
      pb.SprintTasksRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        sprintId: sprintId,
      ),
      options: _options,
    );
    return List.unmodifiable(a.tasks.map(taskFromPb));
  });

  @override
  Future<List<SprintTask>> backlog(
    String workspaceId,
    String projectId, {
    int limit = 0,
  }) => _run(() async {
    final a = await _backlog.list(
      pb.BacklogListRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        limit: limit,
      ),
      options: _options,
    );
    return List.unmodifiable(a.tasks.map(taskFromPb));
  });

  @override
  Future<SprintTask> setPoints(
    String workspaceId,
    String projectId,
    String taskId,
    String points, {
    int expectedVersion = 0,
  }) => _run(
    () async => taskFromPb(
      await _client.setPoints(
        pb.PointsSetRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
          points: points,
          expectedVersion: expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Burndown> burndown(
    String workspaceId,
    String projectId,
    String sprintId,
  ) => _run(
    () async => burndownFromPb(
      await _client.burndown(
        pb.BurndownRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          sprintId: sprintId,
        ),
        options: _options,
      ),
    ),
  );
}
