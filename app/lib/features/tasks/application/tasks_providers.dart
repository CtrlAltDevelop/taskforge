import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/bulk.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// How many streamed tasks are gathered before the list is rebuilt.
const streamBatch = 100;

/// The server's tasks, with nothing local in between (the outbox sends with
/// this).
final rawTasksClientProvider = Provider<TasksClient>(
  (ref) => GrpcTasksClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
  ),
);

/// What the app uses: the server's tasks, kept locally and still working
/// without a connection.
final tasksClientProvider = Provider<TasksClient>(
  (ref) => OfflineTasksClient(
    ref.watch(rawTasksClientProvider),
    ref.watch(offlineEnvProvider),
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

  /// The sort and grouping asked of the server; a change of either reads the
  /// list again (see [build]).
  ListQuery get _query => ref.read(listQueryProvider(projectId));

  @override
  TaskListState build() {
    ref.watch(workspaceScopeProvider);
    ref.watch(refusalCountProvider);
    ref.watch(listQueryProvider(projectId));
    // What was changed offline has been sent: show what the server now says.
    ref.listen(outboxDrainedProvider, (_, _) => unawaited(refresh()));
    // The person's saved layout is read first, so the list is read once, in
    // the order they chose, instead of twice.
    if (ref.watch(listLayoutReadyProvider(projectId))) {
      Future.microtask(load);
    }
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
      await for (final task in _client.list(
        workspace,
        projectId,
        query: _query,
      )) {
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
      await for (final task in _client.list(
        workspace,
        projectId,
        query: _query,
      )) {
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
  void _replace(Task answer, {bool ignoreOlder = false}) {
    final task = answer.withGroupKey(groupKeyOf(answer, _query.groupBy));
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
    final keyed = created.withGroupKey(groupKeyOf(created, _query.groupBy));
    state = state.copyWith(tasks: _insertInTreeOrder(keyed));
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

  /// Applies [change] to every task of [ids] in one call. Each task that took
  /// it is updated in the list as its result arrives ([onProgress] is told how
  /// many of [ids] are done); the ones that did not are in the summary. A
  /// delete reads the list again, as the server also took their subtasks.
  Future<BulkSummary> bulk(
    List<String> ids,
    BulkChange change, {
    void Function(int done, int total)? onProgress,
  }) async {
    final succeeded = <String>[];
    final failed = <BulkOutcome>[];
    // Read now: leaving the project disposes this notifier, but the edit
    // still runs to the end (it only stops updating a list nobody sees).
    final client = _client;
    final workspace = _workspace;
    try {
      // The server takes [maxBulkTasks] at a time; more are sent in turn.
      for (var from = 0; from < ids.length; from += maxBulkTasks) {
        final chunk = ids.sublist(
          from,
          from + maxBulkTasks > ids.length ? ids.length : from + maxBulkTasks,
        );
        await for (final outcome in client.bulkUpdate(
          workspace,
          projectId,
          chunk,
          change,
        )) {
          final task = outcome.task;
          if (outcome.ok) {
            succeeded.add(outcome.id);
            if (ref.mounted && task != null && !change.delete) {
              _replace(task, ignoreOlder: true);
            }
          } else {
            failed.add(outcome);
          }
          onProgress?.call(succeeded.length + failed.length, ids.length);
        }
      }
    } on Object catch (e) {
      throw mapTaskError(e);
    }
    if (change.delete && ref.mounted) {
      ref.invalidate(taskTrashProvider(projectId));
      await refresh();
    }
    return BulkSummary(
      total: ids.length,
      succeeded: List.unmodifiable(succeeded),
      failed: List.unmodifiable(failed),
    );
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

/// The tasks picked in one project's list, by id: they stay picked while the
/// list scrolls, regroups or reloads.
final taskSelectionProvider = NotifierProvider.autoDispose
    .family<TaskSelection, Set<String>, String>(TaskSelection.new);

class TaskSelection extends Notifier<Set<String>> {
  TaskSelection(this.projectId);

  final String projectId;

  @override
  Set<String> build() => const {};

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};

  void addAll(Iterable<String> ids) => state = {...state, ...ids};

  void removeAll(Iterable<String> ids) => state = state.difference({...ids});

  void clear() {
    if (state.isNotEmpty) state = const {};
  }
}

/// The folded-shut groups of one project's grouped list (group keys).
final collapsedGroupsProvider = NotifierProvider.autoDispose
    .family<CollapsedGroups, Set<String>, String>(CollapsedGroups.new);

class CollapsedGroups extends Notifier<Set<String>> {
  CollapsedGroups(this.projectId);

  final String projectId;

  @override
  Set<String> build() => const {};

  void toggle(String key) =>
      state = state.contains(key) ? ({...state}..remove(key)) : {...state, key};
}

/// How many tasks each group holds, as the server counts them: what a group
/// header shows while the list is still streaming in.
final groupCountsProvider = FutureProvider.autoDispose
    .family<Map<String, int>, String>((ref, projectId) async {
      ref.watch(refusalCountProvider);
      final workspace = ref.watch(workspaceScopeProvider);
      final groupBy = ref.watch(
        listLayoutProvider(projectId).select((s) => s.layout.groupBy),
      );
      if (workspace == null || groupBy.isEmpty) return const {};
      try {
        return await ref
            .watch(tasksClientProvider)
            .groupCounts(
              workspace,
              projectId,
              groupBy,
              filterAst: ref.watch(filterJsonProvider(projectId)),
            );
      } on Object catch (e) {
        throw mapTaskError(e);
      }
    }, retry: (_, _) => null);
