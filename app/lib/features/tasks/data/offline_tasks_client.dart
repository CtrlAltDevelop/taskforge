import 'dart:async';

import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/bulk.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// What the client needs from its surroundings; tests bring their own.
class OfflineEnv {
  const OfflineEnv({
    required this.store,
    required this.online,
    required this.failed,
    required this.worked,
    required this.newId,
    required this.now,
    required this.me,
  });

  final Future<OfflineStore?> Function() store;

  /// Whether the server looks reachable; when it does not, calls are not even
  /// tried.
  final bool Function() online;
  final void Function() failed;
  final void Function() worked;
  final String Function() newId;
  final DateTime Function() now;

  /// The signed-in person's user id ('' when unknown).
  final String Function() me;
}

/// How the app shows a task that was made here and not yet numbered.
const pendingDisplayId = 'Pending';

/// Tasks that work without a connection.
///
/// Reads go to the server and are copied into the local database as they
/// arrive; when the server cannot be reached they are answered from that copy.
/// Edits made while it cannot be reached (or when a call fails for lack of a
/// connection) are applied to the copy at once and put in the outbox, to be
/// sent in order when the connection is back (see `OutboxWorker`); the
/// task shows as pending until then. Calls that need the server's answer
/// (links, moving with subtasks, bulk edits, restoring) fail with
/// [TaskFailure.network] while offline.
class OfflineTasksClient implements TasksClient {
  OfflineTasksClient(this._inner, this._env);

  final TasksClient _inner;
  final OfflineEnv _env;

  static const _offline = TaskException(TaskFailure.network);

  Future<T> _call<T>(Future<T> Function() call) async {
    if (!_env.online()) throw _offline;
    try {
      final result = await call();
      _env.worked();
      return result;
    } on TaskException catch (e) {
      if (e.failure == TaskFailure.network) _env.failed();
      rethrow;
    }
  }

  // ------------------------------------------------------------------ reads

  Future<Map<String, List<OutboxEntry>>> _pendingByTask(
    OfflineStore store,
    String workspaceId,
  ) async {
    final out = <String, List<OutboxEntry>>{};
    for (final e in await store.queue(workspaceId)) {
      if (e.entity == OutboxEntity.task) {
        out.putIfAbsent(e.entityId, () => []).add(e);
      }
    }
    return out;
  }

  /// [task] with the edits still waiting in the outbox laid over it.
  Task _withPending(Task task, List<OutboxEntry>? waiting) {
    var t = task;
    for (final e in waiting ?? const <OutboxEntry>[]) {
      if (e.op == OutboxOp.update && e.state == OutboxState.pending) {
        t = t.apply(patchFromMap(e.payload));
      }
    }
    return t;
  }

  @override
  Stream<Task> list(
    String workspaceId,
    String projectId, {
    ListQuery query = const ListQuery(),
  }) async* {
    final store = await _env.store();
    if (store == null) {
      yield* _inner.list(workspaceId, projectId, query: query);
      return;
    }
    final waiting = await _pendingByTask(store, workspaceId);
    var yielded = 0;
    if (_env.online()) {
      final seen = <String>{};
      final batch = <Task>[];
      try {
        await for (final t in _inner.list(
          workspaceId,
          projectId,
          query: query,
        )) {
          yielded++;
          seen.add(t.id);
          if (query.isDefault) batch.add(t);
          yield _withPending(t, waiting[t.id]);
          if (batch.length >= 200) {
            await _remember(store, workspaceId, projectId, batch);
            batch.clear();
          }
        }
        _env.worked();
        if (query.isDefault) {
          await _remember(store, workspaceId, projectId, batch);
          await store.markProjectRead(workspaceId, projectId);
          final mine = {
            for (final e in waiting.values.expand((l) => l))
              if (e.op == OutboxOp.create) e.entityId,
          };
          await store.sweep(
            workspaceId,
            Kinds.task,
            projectId,
            seen,
            protect: mine,
          );
          // What was made here and the server has not seen yet.
          for (final t in await _cachedTasks(store, workspaceId, projectId)) {
            if (!seen.contains(t.id) && mine.contains(t.id)) yield t;
          }
        }
        return;
      } on Object catch (e) {
        final failure = mapTaskError(e);
        if (failure.failure != TaskFailure.network) throw failure;
        _env.failed();
        if (yielded > 0) throw failure; // part of the list is on screen
      }
    }
    final cached = await _cachedTasks(store, workspaceId, projectId);
    if (cached.isEmpty && !await _hasProject(store, workspaceId, projectId)) {
      throw _offline;
    }
    for (final t in cached) {
      yield _withPending(t, waiting[t.id]);
    }
  }

  Future<bool> _hasProject(
    OfflineStore store,
    String ws,
    String project,
  ) async =>
      (await store.keptProjects(ws)).contains(project) ||
      await store.projectRead(ws, project) ||
      (await store.list(ws, Kinds.task, scope: project)).isNotEmpty;

  Future<void> _remember(
    OfflineStore store,
    String workspaceId,
    String projectId,
    List<Task> tasks,
  ) => store.putAll(workspaceId, Kinds.task, [
    for (final t in tasks) (id: t.id, json: taskToJson(t), version: t.version),
  ], scope: projectId);

  Future<List<Task>> _cachedTasks(
    OfflineStore store,
    String workspaceId,
    String projectId,
  ) async => inTreeOrder(
    [
      for (final j in await store.list(
        workspaceId,
        Kinds.task,
        scope: projectId,
      ))
        taskFromJson(j),
    ].where((t) => t.deletedAt.isEmpty),
  );

  @override
  Future<Task> get(String workspaceId, String projectId, String id) async {
    final store = await _env.store();
    final waiting = store == null
        ? const <String, List<OutboxEntry>>{}
        : await _pendingByTask(store, workspaceId);
    if (_env.online()) {
      try {
        final task = await _call(() => _inner.get(workspaceId, projectId, id));
        await store?.put(
          workspaceId,
          Kinds.task,
          id,
          taskToJson(task),
          scope: projectId,
          version: task.version,
        );
        return _withPending(task, waiting[id]);
      } on TaskException catch (e) {
        if (e.failure != TaskFailure.network || store == null) rethrow;
      }
    }
    final json = await store?.get(workspaceId, Kinds.task, id);
    if (json == null) throw _offline;
    return _withPending(taskFromJson(json), waiting[id]);
  }

  // ----------------------------------------------------------------- writes

  Future<void> _store(OfflineStore store, String workspaceId, Task task) =>
      store.put(
        workspaceId,
        Kinds.task,
        task.id,
        taskToJson(task),
        scope: task.projectId,
        version: task.version,
      );

  @override
  Future<Task> create(
    String workspaceId,
    String projectId, {
    required String title,
    TaskPriority priority = TaskPriority.none,
    List<String> assigneeIds = const [],
    String parentId = '',
    String statusId = '',
    Map<String, String> fieldValues = const {},
    String clientId = '',
    String mutationId = '',
  }) async {
    final id = clientId.isEmpty ? _env.newId() : clientId;
    final mutation = mutationId.isEmpty ? _env.newId() : mutationId;
    final store = await _env.store();
    var tried = false; // a send that may have reached the server
    if (_env.online()) {
      try {
        final made = await _call(
          () => _inner.create(
            workspaceId,
            projectId,
            title: title,
            priority: priority,
            assigneeIds: assigneeIds,
            parentId: parentId,
            statusId: statusId,
            fieldValues: fieldValues,
            clientId: id,
            mutationId: mutation,
          ),
        );
        if (store != null) await _store(store, workspaceId, made);
        return made;
      } on TaskException catch (e) {
        if (e.failure != TaskFailure.network || store == null) rethrow;
        tried = true;
      }
    }
    if (store == null) throw _offline;
    final parent = parentId.isEmpty
        ? null
        : await store.get(workspaceId, Kinds.task, parentId);
    final depth = parent == null ? 0 : taskFromJson(parent).depth + 1;
    final at = _env.now();
    final local = Task(
      id: id,
      projectId: projectId,
      number: 0,
      displayId: pendingDisplayId,
      title: title,
      statusId: statusId,
      statusName: 'New',
      priority: priority,
      assigneeIds: assigneeIds,
      fieldValues: fieldValues,
      parentId: parentId,
      depth: depth,
      // After every sibling the server knows (its ranks are letters).
      position: '~${at.microsecondsSinceEpoch.toString().padLeft(16, '0')}',
      createdAt: at.toIso8601String(),
      updatedAt: at.toIso8601String(),
      version: 0,
    );
    await _store(store, workspaceId, local);
    await store.enqueue(
      OutboxEntry(
        workspaceId: workspaceId,
        projectId: projectId,
        entity: OutboxEntity.task,
        entityId: id,
        op: OutboxOp.create,
        mutationId: mutation,
        attempts: tried ? 1 : 0,
        createdAt: at,
        payload: {
          'title': title,
          'priority': priority.wire,
          'assigneeIds': assigneeIds,
          'parentId': parentId,
          'statusId': statusId,
          'fieldValues': fieldValues,
        },
      ),
    );
    return local;
  }

  @override
  Future<Task> update(
    String workspaceId,
    Task task,
    TaskPatch patch, {
    int? expectedVersion,
    bool overrideBlocked = false,
    String mutationId = '',
  }) async {
    final mutation = mutationId.isEmpty ? _env.newId() : mutationId;
    final store = await _env.store();
    final queued =
        store != null && await _hasQueued(store, workspaceId, task.id);
    var tried = false; // a send that may have reached the server
    if (_env.online() && !queued) {
      try {
        final saved = await _call(
          () => _inner.update(
            workspaceId,
            task,
            patch,
            expectedVersion: expectedVersion,
            overrideBlocked: overrideBlocked,
            mutationId: mutation,
          ),
        );
        if (store != null) await _store(store, workspaceId, saved);
        return saved;
      } on TaskException catch (e) {
        if (e.failure != TaskFailure.network || store == null) rethrow;
        tried = true;
      }
    }
    if (store == null) throw _offline;
    final cachedJson = await store.get(workspaceId, Kinds.task, task.id);
    final base = cachedJson == null ? task : taskFromJson(cachedJson);
    final changed = base.apply(patch);
    await _store(store, workspaceId, changed);
    await store.enqueue(
      OutboxEntry(
        workspaceId: workspaceId,
        projectId: task.projectId,
        entity: OutboxEntity.task,
        entityId: task.id,
        op: OutboxOp.update,
        mutationId: mutation,
        attempts: tried ? 1 : 0,
        createdAt: _env.now(),
        expectedVersion: expectedVersion ?? task.version,
        payload: patchToMap(patch),
      ),
    );
    return changed;
  }

  /// Whether changes to the task wait in the outbox: a new one goes behind
  /// them (even when online) so the server sees them in the order made.
  Future<bool> _hasQueued(
    OfflineStore store,
    String workspaceId,
    String taskId,
  ) async =>
      (await store.queue(workspaceId))
          .any((e) => e.entity == OutboxEntity.task && e.entityId == taskId);

  @override
  Future<Task> delete(
    String workspaceId,
    String projectId,
    String id, {
    DeleteMode? mode,
    String mutationId = '',
  }) async {
    final mutation = mutationId.isEmpty ? _env.newId() : mutationId;
    final store = await _env.store();
    final queued = store != null && await _hasQueued(store, workspaceId, id);
    var tried = false; // a send that may have reached the server
    if (_env.online() && !queued) {
      try {
        final gone = await _call(
          () => _inner.delete(
            workspaceId,
            projectId,
            id,
            mode: mode,
            mutationId: mutation,
          ),
        );
        await store?.remove(workspaceId, Kinds.task, id);
        return gone;
      } on TaskException catch (e) {
        if (e.failure != TaskFailure.network || store == null) rethrow;
        tried = true;
      }
    }
    if (store == null) throw _offline;
    final json = await store.get(workspaceId, Kinds.task, id);
    final at = _env.now();
    await store.remove(workspaceId, Kinds.task, id);
    await store.enqueue(
      OutboxEntry(
        workspaceId: workspaceId,
        projectId: projectId,
        entity: OutboxEntity.task,
        entityId: id,
        op: OutboxOp.delete,
        mutationId: mutation,
        attempts: tried ? 1 : 0,
        createdAt: at,
        payload: {'mode': mode?.wire ?? ''},
      ),
    );
    final base = json == null
        ? Task(
            id: id,
            projectId: projectId,
            number: 0,
            displayId: '',
            title: '',
            statusId: '',
          )
        : taskFromJson(json);
    return Task(
      id: base.id,
      projectId: base.projectId,
      number: base.number,
      displayId: base.displayId,
      title: base.title,
      statusId: base.statusId,
      deletedAt: at.toIso8601String(),
      version: base.version,
    );
  }

  // ---------------------------------------------------- needs the server

  @override
  Future<Map<String, int>> groupCounts(
    String workspaceId,
    String projectId,
    String groupBy, {
    String filterAst = '',
  }) => _call(
    () => _inner.groupCounts(
      workspaceId,
      projectId,
      groupBy,
      filterAst: filterAst,
    ),
  );

  @override
  Stream<BulkOutcome> bulkUpdate(
    String workspaceId,
    String projectId,
    List<String> ids,
    BulkChange change,
  ) {
    if (!_env.online()) return Stream.error(_offline);
    return _inner.bulkUpdate(workspaceId, projectId, ids, change);
  }

  @override
  Future<Task> setParent(String workspaceId, Task task, String parentId) =>
      _call(() => _inner.setParent(workspaceId, task, parentId));

  /// A status change alone is an edit like any other: online it goes to the
  /// server, offline (or cut off) it is queued and shown at once. Moving the
  /// open subtasks with it needs the server.
  @override
  Future<Task> move(
    String workspaceId,
    Task task,
    String statusId, {
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  }) async {
    if (includeSubtasks) {
      return _call(
        () => _inner.move(
          workspaceId,
          task,
          statusId,
          includeSubtasks: true,
          overrideBlocked: overrideBlocked,
        ),
      );
    }
    final store = await _env.store();
    if (store == null) {
      return _call(
        () => _inner.move(
          workspaceId,
          task,
          statusId,
          overrideBlocked: overrideBlocked,
        ),
      );
    }
    final status = await _statusOf(
      store,
      workspaceId,
      task.projectId,
      statusId,
    );
    return update(
      workspaceId,
      task,
      TaskPatch(status: status),
      overrideBlocked: overrideBlocked,
    );
  }

  /// The status [statusId] as the local copy knows it (name and category come
  /// from a task that has it).
  Future<WorkflowStatus> _statusOf(
    OfflineStore store,
    String workspaceId,
    String projectId,
    String statusId,
  ) async {
    for (final t in await _cachedTasks(store, workspaceId, projectId)) {
      if (t.statusId == statusId) {
        return WorkflowStatus(
          id: statusId,
          name: t.statusName,
          category: t.statusCategory,
        );
      }
    }
    return WorkflowStatus(
      id: statusId,
      name: '',
      category: StatusCategory.active,
    );
  }

  @override
  Future<List<LinkCandidate>> searchTasks(String workspaceId, String query) =>
      _call(() => _inner.searchTasks(workspaceId, query));

  @override
  Future<List<TaskLink>> listLinks(String workspaceId, String taskId) =>
      _call(() => _inner.listLinks(workspaceId, taskId));

  @override
  Future<List<TaskLink>> addLink(
    String workspaceId,
    String taskId,
    String otherId,
    LinkKind kind, {
    bool closeDuplicate = false,
  }) => _call(
    () => _inner.addLink(
      workspaceId,
      taskId,
      otherId,
      kind,
      closeDuplicate: closeDuplicate,
    ),
  );

  @override
  Future<List<TaskLink>> removeLink(
    String workspaceId,
    String taskId,
    String linkId,
  ) => _call(() => _inner.removeLink(workspaceId, taskId, linkId));

  @override
  Future<Task> restore(String workspaceId, String projectId, String id) =>
      _call(() => _inner.restore(workspaceId, projectId, id));

  @override
  Future<List<Task>> listTrash(String workspaceId, String projectId) =>
      _call(() => _inner.listTrash(workspaceId, projectId));
}
