import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/gen/infrastructure/goals/grpc/goals.pbgrpc.dart'
    as pb;

/// Goals, key results and check-ins over gRPC.
abstract interface class GoalsClient {
  Future<GoalCatalog> list(String workspaceId);
  Future<Goal> createGoal(String workspaceId, GoalDraft draft);

  /// Changes the named fields (the server's `changed` names).
  Future<Goal> updateGoal(
    String workspaceId,
    Goal goal,
    GoalDraft draft,
    List<String> changed,
  );
  Future<void> deleteGoal(String workspaceId, String goalId);
  Future<GoalFolder> saveFolder(
    String workspaceId,
    String name, {
    String folderId = '',
  });
  Future<void> deleteFolder(String workspaceId, String folderId);
  Future<Goal> createKeyResult(
    String workspaceId,
    String goalId,
    KrDraft draft,
  );
  Future<Goal> updateKeyResult(
    String workspaceId,
    KeyResult kr,
    KrDraft draft,
    List<String> changed,
  );
  Future<Goal> deleteKeyResult(String workspaceId, String krId);
  Future<List<Contribution>> forTask(String workspaceId, String taskId);
  Future<Goal> addCheckIn(
    String workspaceId,
    String krId,
    String value,
    String note,
  );
  Future<List<CheckIn>> checkIns(String workspaceId, String krId);
}

GoalsException mapGoalsError(Object error) {
  if (error is GoalsException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => GoalsException(
        GoalsFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists ||
      StatusCode.aborted => const GoalsException(GoalsFailure.conflict),
      StatusCode.permissionDenied => const GoalsException(GoalsFailure.denied),
      StatusCode.notFound => const GoalsException(GoalsFailure.notFound),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const GoalsException(GoalsFailure.network),
      _ => const GoalsException(GoalsFailure.other),
    };
  }
  return const GoalsException(GoalsFailure.other);
}

KeyResult keyResultFromPb(pb.KeyResult k) => KeyResult(
  id: k.id,
  goalId: k.goalId,
  name: k.name,
  type: KrType.parse(k.type),
  startValue: k.startValue,
  targetValue: k.targetValue,
  currentValue: k.currentValue,
  filterText: k.filterText,
  taskIds: List.unmodifiable(k.taskIds),
  weight: k.weight,
  linkedDone: k.linkedDone,
  linkedTotal: k.linkedTotal,
  progress: k.progress,
  version: k.version,
);

Goal goalFromPb(pb.Goal g) => Goal(
  id: g.id,
  parentId: g.parentId,
  folderId: g.folderId,
  name: g.name,
  description: g.description,
  ownerId: g.ownerId,
  private: g.private,
  periodStart: g.periodStart,
  periodEnd: g.periodEnd,
  statusOverride: g.statusOverride,
  status: GoalStatus.parse(g.status),
  statusHint: GoalStatus.parse(g.statusHint),
  weight: g.weight,
  progress: g.progress,
  version: g.version,
  canEdit: g.canEdit,
  canCheckIn: g.canCheckIn,
  contributorIds: List.unmodifiable(g.contributorIds),
  childIds: List.unmodifiable(g.childIds),
  keyResults: List.unmodifiable(g.keyResults.map(keyResultFromPb)),
);

CheckIn checkInFromPb(pb.CheckIn c) => CheckIn(
  id: c.id,
  krId: c.krId,
  userId: c.userId,
  value: c.value,
  previousValue: c.previousValue,
  progress: c.progress,
  note: c.note,
  at: DateTime.tryParse(c.at)?.toLocal(),
);

class GrpcGoalsClient implements GoalsClient {
  GrpcGoalsClient(ClientChannelBase channel, this._session)
    : _goals = pb.GoalControllerClient(channel),
      _krs = pb.KeyResultControllerClient(channel),
      _checkIns = pb.CheckInControllerClient(channel);

  final pb.GoalControllerClient _goals;
  final pb.KeyResultControllerClient _krs;
  final pb.CheckInControllerClient _checkIns;
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
      throw mapGoalsError(e);
    }
  }

  @override
  Future<GoalCatalog> list(String workspaceId) => _run(() async {
    final r = await _goals.list(
      pb.GoalListRequest(workspaceId: workspaceId),
      options: _options,
    );
    return GoalCatalog(
      List.unmodifiable(r.goals.map(goalFromPb)),
      List.unmodifiable(
        r.folders.map(
          (f) => GoalFolder(id: f.id, name: f.name, position: f.position),
        ),
      ),
    );
  });

  @override
  Future<Goal> createGoal(String workspaceId, GoalDraft d) => _run(() async {
    final r = await _goals.create(
      pb.GoalCreateRequest(
        workspaceId: workspaceId,
        name: d.name.trim(),
        description: d.description.trim(),
        ownerId: d.ownerId,
        parentId: d.parentId,
        folderId: d.folderId,
        private: d.private,
        periodStart: d.periodStart,
        periodEnd: d.periodEnd,
        weight: d.weight,
        contributorIds: d.contributorIds,
      ),
      options: _options,
    );
    return goalFromPb(r.goal);
  });

  @override
  Future<Goal> updateGoal(
    String workspaceId,
    Goal goal,
    GoalDraft d,
    List<String> changed,
  ) => _run(() async {
    final r = await _goals.update(
      pb.GoalUpdateRequest(
        workspaceId: workspaceId,
        goalId: goal.id,
        expectedVersion: goal.version,
        changed: changed,
        name: d.name.trim(),
        description: d.description.trim(),
        ownerId: d.ownerId,
        parentId: d.parentId,
        folderId: d.folderId,
        private: d.private,
        periodStart: d.periodStart,
        periodEnd: d.periodEnd,
        statusOverride: d.statusOverride,
        weight: d.weight,
        contributorIds: d.contributorIds,
      ),
      options: _options,
    );
    return goalFromPb(r.goal);
  });

  @override
  Future<void> deleteGoal(String workspaceId, String goalId) => _run(() async {
    await _goals.delete(
      pb.GoalDeleteRequest(workspaceId: workspaceId, goalId: goalId),
      options: _options,
    );
  });

  @override
  Future<GoalFolder> saveFolder(
    String workspaceId,
    String name, {
    String folderId = '',
  }) => _run(() async {
    final r = await _goals.saveFolder(
      pb.FolderSaveRequest(
        workspaceId: workspaceId,
        folderId: folderId,
        name: name.trim(),
      ),
      options: _options,
    );
    return GoalFolder(
      id: r.folder.id,
      name: r.folder.name,
      position: r.folder.position,
    );
  });

  @override
  Future<void> deleteFolder(String workspaceId, String folderId) =>
      _run(() async {
        await _goals.deleteFolder(
          pb.FolderDeleteRequest(workspaceId: workspaceId, folderId: folderId),
          options: _options,
        );
      });

  @override
  Future<Goal> createKeyResult(String workspaceId, String goalId, KrDraft d) =>
      _run(() async {
        final r = await _krs.create(
          pb.KeyResultCreateRequest(
            workspaceId: workspaceId,
            goalId: goalId,
            type: d.type.wire,
            name: d.name.trim(),
            startValue: d.startValue,
            targetValue: d.targetValue,
            currentValue: d.currentValue,
            weight: d.weight,
            filterText: d.filterText.trim(),
            taskIds: d.taskIds,
          ),
          options: _options,
        );
        return goalFromPb(r.goal);
      });

  @override
  Future<Goal> updateKeyResult(
    String workspaceId,
    KeyResult kr,
    KrDraft d,
    List<String> changed,
  ) => _run(() async {
    final r = await _krs.update(
      pb.KeyResultUpdateRequest(
        workspaceId: workspaceId,
        krId: kr.id,
        expectedVersion: kr.version,
        changed: changed,
        name: d.name.trim(),
        startValue: d.startValue,
        targetValue: d.targetValue,
        weight: d.weight,
        filterText: d.filterText.trim(),
        taskIds: d.taskIds,
      ),
      options: _options,
    );
    return goalFromPb(r.goal);
  });

  @override
  Future<Goal> deleteKeyResult(String workspaceId, String krId) =>
      _run(() async {
        final r = await _krs.delete(
          pb.KeyResultDeleteRequest(workspaceId: workspaceId, krId: krId),
          options: _options,
        );
        return goalFromPb(r.goal);
      });

  @override
  Future<List<Contribution>> forTask(String workspaceId, String taskId) =>
      _run(() async {
        final r = await _krs.forTask(
          pb.ForTaskRequest(workspaceId: workspaceId, taskId: taskId),
          options: _options,
        );
        return List.unmodifiable(
          r.contributions.map(
            (c) => Contribution(
              goalId: c.goalId,
              goalName: c.goalName,
              krId: c.krId,
              krName: c.krName,
            ),
          ),
        );
      });

  @override
  Future<Goal> addCheckIn(
    String workspaceId,
    String krId,
    String value,
    String note,
  ) => _run(() async {
    final r = await _checkIns.add(
      pb.CheckInAddRequest(
        workspaceId: workspaceId,
        krId: krId,
        value: value,
        note: note.trim(),
      ),
      options: _options,
    );
    return goalFromPb(r.goal);
  });

  @override
  Future<List<CheckIn>> checkIns(String workspaceId, String krId) => _run(
    () async {
      final r = await _checkIns.list(
        pb.CheckInListRequest(workspaceId: workspaceId, krId: krId, limit: 60),
        options: _options,
      );
      return List.unmodifiable(r.checkIns.map(checkInFromPb));
    },
  );
}
