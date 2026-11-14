import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workload/data/workload_client.dart';
import 'package:taskforge/features/workload/domain/workload.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final workloadClientProvider = Provider<WorkloadClient>(
  (ref) => GrpcWorkloadClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// The zoom, first day and filters of the workload screen.
class WorkloadQueryNotifier extends Notifier<WorkloadQuery> {
  @override
  WorkloadQuery build() => WorkloadQuery(
    zoom: WorkloadZoom.week,
    anchor: columnStart(WorkloadZoom.week, DateTime.now()),
  );

  void setZoom(WorkloadZoom zoom) => state = state.copyWith(
    zoom: zoom,
    anchor: columnStart(zoom, state.anchor),
  );

  /// Moves by [pages] screens (negative: back).
  void page(int pages) {
    var anchor = state.anchor;
    final steps = state.zoom.columns * pages.abs();
    for (var i = 0; i < steps; i++) {
      anchor = pages > 0
          ? nextColumn(state.zoom, anchor)
          : columnStart(state.zoom, addDays(anchor, -1));
    }
    state = state.copyWith(anchor: anchor);
  }

  void today() =>
      state = state.copyWith(anchor: columnStart(state.zoom, DateTime.now()));

  void setProjects(List<String> ids) => state = state.copyWith(projectIds: ids);

  void setPeople(List<String> ids) => state = state.copyWith(userIds: ids);
}

final workloadQueryProvider =
    NotifierProvider<WorkloadQueryNotifier, WorkloadQuery>(
      WorkloadQueryNotifier.new,
    );

/// The grid. Reassigning and moving show their totals at once, then persist
/// through `Tasks.Update`; a refusal puts the grid back and rethrows.
class WorkloadNotifier extends AsyncNotifier<WorkloadData> {
  @override
  Future<WorkloadData> build() async {
    final ws = ref.watch(workspaceScopeProvider);
    final query = ref.watch(workloadQueryProvider);
    if (ws == null) return WorkloadData.empty;
    return ref.watch(workloadClientProvider).get(ws, query);
  }

  Future<void> reload() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final fresh = await ref
        .read(workloadClientProvider)
        .get(ws, ref.read(workloadQueryProvider));
    if (ref.mounted) state = AsyncData(fresh);
  }

  /// Hands [taskId] from [from] to [to] (who may already be on it).
  Future<void> reassign(String taskId, String from, String to) {
    final task = state.value?.tasks[taskId];
    if (task == null || from == to) return Future.value();
    final people = [
      for (final a in task.assigneeIds)
        if (a != from) a,
      if (!task.assigneeIds.contains(to)) to,
    ];
    return _change(
      task,
      task.copyWith(assigneeIds: people),
      TaskPatch(assigneeIds: people),
    );
  }

  /// Moves [taskId] by [days] days (negative: earlier), keeping its length.
  Future<void> shift(String taskId, int days) {
    final task = state.value?.tasks[taskId];
    if (task == null || days == 0) return Future.value();
    final start = task.start == null ? null : addDays(task.start!, days);
    final due = task.due == null ? null : addDays(task.due!, days);
    return _change(
      task,
      task.copyWith(start: start, due: due),
      TaskPatch(
        startDate: start == null ? null : isoDay(start),
        dueDate: due == null ? null : isoDay(due),
      ),
    );
  }

  Future<void> _change(LoadTask before, LoadTask after, TaskPatch patch) async {
    final ws = ref.read(workspaceScopeProvider);
    final data = state.value;
    if (ws == null || data == null) return;
    state = AsyncData(recount(data, after));
    try {
      final saved = await ref
          .read(tasksClientProvider)
          .update(
            ws,
            Task(
              id: before.id,
              projectId: before.projectId,
              number: 0,
              displayId: before.displayId,
              title: before.title,
              statusId: '',
              version: before.version,
              startDate: before.start == null ? '' : isoDay(before.start!),
              dueDate: before.due == null ? '' : isoDay(before.due!),
              assigneeIds: before.assigneeIds,
            ),
            patch,
          );
      if (!ref.mounted) return;
      final now = state.value ?? data;
      state = AsyncData(
        now.copyWith(
          tasks: {
            ...now.tasks,
            after.id: after.copyWith(version: saved.version),
          },
        ),
      );
    } on Object {
      if (ref.mounted) state = AsyncData(data);
      rethrow;
    }
  }
}

final workloadProvider =
    AsyncNotifierProvider.autoDispose<WorkloadNotifier, WorkloadData>(
      WorkloadNotifier.new,
      retry: (_, _) => null,
    );

/// Everybody's capacity (only the caller's without `workload.view`).
final capacitiesProvider = FutureProvider.autoDispose<List<Capacity>>((
  ref,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(workloadClientProvider).capacities(ws);
}, retry: (_, _) => null);

final timeOffProvider = FutureProvider.autoDispose<List<TimeOff>>((ref) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(workloadClientProvider).listTimeOff(ws);
}, retry: (_, _) => null);

final holidaysProvider = FutureProvider.autoDispose<List<Holiday>>((ref) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(workloadClientProvider).holidays(ws);
}, retry: (_, _) => null);
