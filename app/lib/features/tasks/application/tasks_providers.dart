import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
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

/// The links of one task, as that task sees them. Read again after the links
/// change (`ref.invalidate`) or the user's permissions might have.
final taskLinksProvider = FutureProvider.autoDispose
    .family<List<TaskLink>, String>((ref, taskId) async {
      ref.watch(refusalCountProvider);
      final workspace = ref.watch(workspaceScopeProvider);
      if (workspace == null) return const [];
      try {
        return await ref
            .watch(tasksClientProvider)
            .listLinks(workspace, taskId);
      } on Object catch (e) {
        throw mapTaskError(e);
      }
    });

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

  /// Reads the list again without blanking it, e.g. after links changed which
  /// tasks are blocked. While the first load is still running it is simply
  /// restarted; a failed read leaves what is shown as it is. Per task the
  /// newer version wins, so an edit that came back meanwhile is kept.
  Future<void> refresh() async {
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) return;
    if (state.loading) return load();
    final generation = ++_generation;
    final seen = <Task>[];
    try {
      await for (final task in _client.list(workspace, projectId)) {
        seen.add(task);
      }
    } on Object {
      return;
    }
    if (generation != _generation || !ref.mounted) return;
    final now = {for (final t in state.tasks) t.id: t};
    state = state.copyWith(
      tasks: List.unmodifiable([
        for (final t in seen)
          if ((now[t.id]?.version ?? 0) > t.version) now[t.id]! else t,
      ]),
    );
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
    final restore = TaskPatch.of(before).only(patch.fields.toSet());
    final changed = patch.fieldValues?.keys;
    _replace(
      current.apply(
        changed == null
            ? restore
            : restore.withFieldValues({
                for (final id in changed) id: before.fieldValues[id] ?? '',
              }),
      ),
    );
  }

  /// Adds a task at the end once the server has numbered it.
  Future<Task> create(
    String title, {
    TaskPriority priority = TaskPriority.none,
    List<String> assigneeIds = const [],
    String parentId = '',
    Map<String, String> fieldValues = const {},
  }) async {
    final created = await _client.create(
      _workspace,
      projectId,
      title: title,
      priority: priority,
      assigneeIds: assigneeIds,
      parentId: parentId,
      fieldValues: fieldValues,
    );
    state = state.copyWith(tasks: _insertInTreeOrder(created));
    if (state.loading) _createdDuringLoad.add(created);
    return created;
  }

  /// [task] placed after the last task of its parent's subtree (at the end for a
  /// top-level task), where the server's tree order would put a new last child.
  List<Task> _insertInTreeOrder(Task task) {
    final tasks = state.tasks;
    if (task.parentId.isEmpty || !tasks.any((t) => t.id == task.parentId)) {
      return [...tasks, task];
    }
    final inside = TaskTree(tasks).subtreeIds(task.parentId);
    final last = tasks.lastIndexWhere((t) => inside.contains(t.id));
    return [...tasks.sublist(0, last + 1), task, ...tasks.sublist(last + 1)];
  }

  /// Applies [patch] at once and sends it. On a refusal the task is put back;
  /// a clash on the same field also reloads that task, so the list shows the
  /// other person's value, and the [TaskException] carries the conflict.
  /// [expectedVersion] lets "keep mine" resend against the current version.
  Future<Task> update(
    Task task,
    TaskPatch patch, {
    int? expectedVersion,
    bool overrideBlocked = false,
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
        overrideBlocked: overrideBlocked,
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

  /// Removes the task at once; it comes back if the server refuses. A task with
  /// subtasks needs a [mode]: [DeleteMode.subtree] removes them with it,
  /// [DeleteMode.promote] moves them up (the list is then read again, as the
  /// server renumbers the levels). Without a mode the server refuses with
  /// [TaskFailure.hasSubtasks].
  ///
  /// Returns the ids of the subtasks that were moved up ([DeleteMode.promote]),
  /// which [restore] needs to put them back under the task on Undo.
  Future<List<String>> delete(Task task, {DeleteMode? mode}) async {
    final before = state.tasks;
    if (mode == DeleteMode.promote) {
      final kids = [
        for (final t in before)
          if (t.parentId == task.id) t.id,
      ];
      try {
        await _client.delete(_workspace, projectId, task.id, mode: mode);
      } on Object catch (e) {
        throw mapTaskError(e);
      }
      if (!ref.mounted) return const [];
      ref.invalidate(taskTrashProvider(projectId));
      await load();
      return kids;
    }
    final gone = mode == DeleteMode.subtree
        ? TaskTree(before).subtreeIds(task.id)
        : {task.id};
    state = state.copyWith(
      tasks: [
        for (final t in before)
          if (!gone.contains(t.id)) t,
      ],
    );
    try {
      await _client.delete(_workspace, projectId, task.id, mode: mode);
      if (ref.mounted) ref.invalidate(taskTrashProvider(projectId));
    } on Object catch (e) {
      state = state.copyWith(tasks: before);
      throw mapTaskError(e);
    }
    return const [];
  }

  /// Puts a deleted task back with the subtasks deleted alongside it; the list
  /// is read again, because the server decides where it lands. [adopt] are the
  /// subtasks a promote-delete moved up: they are put back under the task
  /// (best effort: one that has since gone or moved elsewhere is left alone).
  Future<Task> restore(Task task, {List<String> adopt = const []}) async {
    try {
      final back = await _client.restore(_workspace, projectId, task.id);
      if (!ref.mounted) return back;
      ref.invalidate(taskTrashProvider(projectId));
      await load();
      for (final id in adopt) {
        if (!ref.mounted) break;
        final kid = state.tasks.where((t) => t.id == id).firstOrNull;
        if (kid == null || kid.parentId != back.parentId) continue;
        try {
          await _client.setParent(_workspace, kid, back.id);
        } on Object {
          // Undo is a courtesy: a child that cannot be put back stays where it is.
        }
      }
      if (adopt.isNotEmpty && ref.mounted) await load();
      return back;
    } on Object catch (e) {
      throw mapTaskError(e);
    }
  }

  /// Makes [task] a subtask of [parentId] (empty: top level) with everything
  /// under it. The server rewrites the whole subtree, so the list is read again.
  Future<Task> setParent(Task task, String parentId) async {
    final Task moved;
    try {
      moved = await _client.setParent(_workspace, task, parentId);
    } on Object catch (e) {
      throw mapTaskError(e);
    }
    if (ref.mounted) await load();
    return moved;
  }

  /// Moves [task] to [status] and its open subtasks with it, all or nothing.
  Future<Task> moveWithSubtasks(
    Task task,
    WorkflowStatus status, {
    bool overrideBlocked = false,
  }) async {
    final Task moved;
    try {
      moved = await _client.move(
        _workspace,
        task,
        status.id,
        includeSubtasks: true,
        overrideBlocked: overrideBlocked,
      );
    } on Object catch (e) {
      throw mapTaskError(e);
    }
    if (ref.mounted) await load();
    return moved;
  }
}

/// The folded-shut parents of one project's task list (everything starts open).
final collapsedTasksProvider = NotifierProvider.autoDispose
    .family<CollapsedTasks, Set<String>, String>(CollapsedTasks.new);

class CollapsedTasks extends Notifier<Set<String>> {
  CollapsedTasks(this.projectId);

  final String projectId;

  @override
  Set<String> build() => const {};

  void toggle(String taskId) {
    state = state.contains(taskId)
        ? ({...state}..remove(taskId))
        : {...state, taskId};
  }

  void expand(String taskId) {
    if (state.contains(taskId)) state = ({...state}..remove(taskId));
  }
}

/// The tasks of a project as a tree, rebuilt whenever the list changes.
final taskTreeProvider = Provider.autoDispose.family<TaskTree, String>(
  (ref, projectId) =>
      TaskTree(ref.watch(taskListProvider(projectId).select((s) => s.tasks))),
);
