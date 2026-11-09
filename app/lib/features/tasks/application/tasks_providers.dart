import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// How many streamed tasks are gathered before the list is rebuilt.
const streamBatch = 100;

final tasksClientProvider = Provider<TasksClient>(
  (ref) => GrpcTasksClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
  ),
);

/// The deleted tasks of one project, newest deletion first. Only read by
/// people who may restore them (`task.delete`).
final taskTrashProvider = FutureProvider.autoDispose.family<List<Task>, String>(
  (ref, projectId) async {
    ref.watch(refusalCountProvider);
    final id = ref.watch(workspaceScopeProvider);
    if (id == null) return const [];
    return ref.watch(tasksClientProvider).listTrash(id, projectId);
  },
  retry: (_, _) => null,
);

/// What the task list shows: [tasks] fill in while the server streams, so the
/// first page is on screen before the last one has arrived.
@immutable
class TaskListState {
  const TaskListState({this.tasks = const [], this.loading = true, this.error});

  final List<Task> tasks;
  final bool loading;
  final TaskException? error;

  TaskListState copyWith({
    List<Task>? tasks,
    bool? loading,
    TaskException? Function()? error,
  }) => TaskListState(
    tasks: tasks ?? this.tasks,
    loading: loading ?? this.loading,
    error: error == null ? this.error : error(),
  );
}

/// The tasks of one project and the edits to them. Edits are optimistic: the
/// list changes at once and is put back if the server refuses.
final taskListProvider = NotifierProvider.autoDispose
    .family<TaskList, TaskListState, String>(TaskList.new);

class TaskList extends Notifier<TaskListState> {
  TaskList(this.projectId);

  final String projectId;
  var _generation = 0;

  /// Tasks created while a load was still streaming: the load must keep them.
  final _createdDuringLoad = <Task>[];

  TasksClient get _client => ref.read(tasksClientProvider);

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const TaskException(TaskFailure.other);
    return id;
  }

  @override
  TaskListState build() {
    ref.watch(workspaceScopeProvider);
    ref.watch(refusalCountProvider);
    Future.microtask(load);
    return const TaskListState();
  }

  /// (Re)reads the whole list from the stream.
  Future<void> load() async {
    final generation = ++_generation;
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) {
      state = const TaskListState(loading: false);
      return;
    }
    state = const TaskListState();
    _createdDuringLoad.clear();
    final seen = <Task>[];
    try {
      var pending = 0;
      await for (final task in _client.list(workspace, projectId)) {
        if (generation != _generation) return;
        seen.add(task);
        if (++pending >= streamBatch) {
          pending = 0;
          state = TaskListState(tasks: List.unmodifiable(seen));
        }
      }
      if (generation != _generation) return;
      final known = {for (final t in seen) t.id};
      seen.addAll(_createdDuringLoad.where((t) => !known.contains(t.id)));
      _createdDuringLoad.clear();
      state = TaskListState(tasks: List.unmodifiable(seen), loading: false);
    } on Object catch (e) {
      if (generation != _generation) return;
      state = TaskListState(
        tasks: List.unmodifiable(seen),
        loading: false,
        error: mapTaskError(e),
      );
    }
  }

  /// Swaps in [task]. A server answer older than what the list already holds
  /// (answers can overtake each other) is ignored.
  void _replace(Task task, {bool ignoreOlder = false}) {
    state = state.copyWith(
      tasks: [
        for (final t in state.tasks)
          if (t.id != task.id)
            t
          else if (ignoreOlder && t.version > task.version)
            t
          else
            task,
      ],
    );
  }

  Task? _current(String id) => state.tasks.where((t) => t.id == id).firstOrNull;

  /// Puts back only the fields of [patch] as they were in [before], so an
  /// edit that failed does not undo a different edit that succeeded.
  void _revert(Task before, TaskPatch patch) {
    final current = _current(before.id);
    if (current == null) return;
    _replace(current.apply(TaskPatch.of(before).only(patch.fields.toSet())));
  }

  /// Adds a task at the end once the server has numbered it.
  Future<Task> create(
    String title, {
    TaskPriority priority = TaskPriority.none,
    List<String> assigneeIds = const [],
  }) async {
    final created = await _client.create(
      _workspace,
      projectId,
      title: title,
      priority: priority,
      assigneeIds: assigneeIds,
    );
    state = state.copyWith(tasks: [...state.tasks, created]);
    if (state.loading) _createdDuringLoad.add(created);
    return created;
  }

  /// Applies [patch] at once and sends it. On a refusal the task is put back;
  /// a clash on the same field also reloads that task, so the list shows the
  /// other person's value, and the [TaskException] carries the conflict.
  /// [expectedVersion] lets "keep mine" resend against the current version.
  Future<Task> update(
    Task task,
    TaskPatch patch, {
    int? expectedVersion,
  }) async {
    // Work from what the list holds now: [task] may be a stale snapshot taken
    // when the widget last built, before an earlier edit came back.
    final current = _current(task.id) ?? task;
    _replace(current.apply(patch));
    try {
      final saved = await _client.update(
        _workspace,
        current,
        patch,
        expectedVersion: expectedVersion,
      );
      _replace(saved, ignoreOlder: true);
      return saved;
    } on Object catch (e) {
      final mapped = mapTaskError(e);
      _revert(current, patch);
      if (mapped.failure == TaskFailure.conflict) await _refreshOne(task);
      throw mapped;
    }
  }

  Future<void> _refreshOne(Task task) async {
    try {
      _replace(await _client.get(_workspace, projectId, task.id));
    } on Object {
      // The conflict is still reported; the list is reloaded on the next visit.
    }
  }

  /// Removes the task at once; it comes back if the server refuses.
  Future<void> delete(Task task) async {
    final before = state.tasks;
    state = state.copyWith(
      tasks: [
        for (final t in before)
          if (t.id != task.id) t,
      ],
    );
    try {
      await _client.delete(_workspace, projectId, task.id);
      if (ref.mounted) ref.invalidate(taskTrashProvider(projectId));
    } on Object catch (e) {
      state = state.copyWith(tasks: before);
      throw mapTaskError(e);
    }
  }

  /// Puts a deleted task back at the end of the list (its position is kept
  /// by the server; the next load shows it in place).
  Future<Task> restore(Task task) async {
    try {
      final back = await _client.restore(_workspace, projectId, task.id);
      if (!ref.mounted) return back;
      ref.invalidate(taskTrashProvider(projectId));
      state = state.copyWith(
        tasks: [
          for (final t in state.tasks)
            if (t.id != back.id) t,
          back,
        ],
      );
      return back;
    } on Object catch (e) {
      throw mapTaskError(e);
    }
  }
}
