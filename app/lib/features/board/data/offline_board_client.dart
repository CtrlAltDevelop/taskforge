import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/features/board/data/board_client.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart'
    show fieldColumnPrefix;

/// The board that still shows, and still takes drops, without a connection.
///
/// Each read keeps the board as it came; when the server cannot be reached
/// the last one is shown, with the changes waiting in the outbox laid over it
/// (a dropped card sits in its new column, a task made here shows up, a
/// deleted one is gone). A drop that cannot be sent is an ordinary edit of
/// the task's status, priority, assignee or field, queued through [_tasks];
/// the card's place among its neighbours is not kept (the server places it
/// last). Moving the subtasks along, and later pages of a column, need the
/// server.
class OfflineBoardClient implements BoardClient {
  OfflineBoardClient(this._inner, this._tasks, this._env);

  final BoardClient _inner;
  final TasksClient _tasks;
  final OfflineEnv _env;

  static const _offline = TaskException(TaskFailure.network);

  /// The key a board column has for [task] under [groupBy] (null: grouping
  /// that is not known here).
  static String? columnKey(Task task, String groupBy) {
    if (groupBy == 'status') return task.statusId;
    if (groupBy == 'priority') return task.priority.wire;
    if (groupBy == 'assignee') return task.assigneeIds.firstOrNull ?? '';
    if (groupBy.startsWith(fieldColumnPrefix)) {
      return task.fieldValues[groupBy.substring(fieldColumnPrefix.length)] ??
          '';
    }
    return null;
  }

  Future<T?> _try<T>(Future<T> Function() call) async {
    if (!_env.online()) return null;
    try {
      final result = await call();
      _env.worked();
      return result;
    } on TaskException catch (e) {
      if (e.failure != TaskFailure.network) rethrow;
      _env.failed();
      return null;
    }
  }

  @override
  Future<List<BoardLane>> get(
    String workspaceId,
    String projectId, {
    required String groupBy,
    String swimlane = '',
    String filterAst = '',
  }) async {
    final store = await _env.store();
    if (store == null) {
      return _inner.get(
        workspaceId,
        projectId,
        groupBy: groupBy,
        swimlane: swimlane,
        filterAst: filterAst,
      );
    }
    final key = '$projectId|$groupBy|$swimlane|${filterAst.hashCode}';
    var lanes = await _try(
      () => _inner.get(
        workspaceId,
        projectId,
        groupBy: groupBy,
        swimlane: swimlane,
        filterAst: filterAst,
      ),
    );
    if (lanes != null) {
      await store.put(
        workspaceId,
        Kinds.board,
        key,
        lanesToJson(lanes),
        scope: projectId,
      );
    } else {
      final json = await store.get(workspaceId, Kinds.board, key);
      if (json == null) throw _offline;
      lanes = lanesFromJson(json);
    }
    return _overlay(store, workspaceId, projectId, groupBy, swimlane, lanes);
  }

  /// [lanes] with the changes waiting in the outbox laid over them.
  Future<List<BoardLane>> _overlay(
    OfflineStore store,
    String workspaceId,
    String projectId,
    String groupBy,
    String swimlane,
    List<BoardLane> lanes,
  ) async {
    // ponytail: with swimlanes the rows are not re-sorted offline.
    if (swimlane.isNotEmpty) return lanes;
    var out = lanes;
    final shown = {
      for (final l in out)
        for (final c in l.columns)
          for (final t in c.tasks) t.id: t,
    };
    for (final e in await store.queue(workspaceId)) {
      if (e.entity != OutboxEntity.task || e.projectId != projectId) continue;
      if (e.state == OutboxState.rejected) continue;
      switch (e.op) {
        case OutboxOp.delete:
          final gone = shown.remove(e.entityId);
          if (gone != null) {
            out = dropCard(out, gone, laneKey: '', toColumn: '\u0000');
          }
        case OutboxOp.update:
          final was = shown[e.entityId];
          if (was == null || e.state == OutboxState.conflict) continue;
          final now = was.apply(patchFromMap(e.payload));
          shown[now.id] = now;
          final key = columnKey(now, groupBy);
          out = key == null
              ? replaceCard(out, now)
              : dropCard(out, now, laneKey: '', toColumn: key);
        case OutboxOp.create:
          if (shown.containsKey(e.entityId)) continue;
          final json = await store.get(workspaceId, Kinds.task, e.entityId);
          final key = json == null
              ? null
              : columnKey(taskFromJson(json), groupBy);
          if (json == null || key == null) continue;
          final made = taskFromJson(json);
          shown[made.id] = made;
          out = dropCard(out, made, laneKey: '', toColumn: key);
      }
    }
    return out;
  }

  @override
  Future<({List<Task> tasks, String cursor})> listColumn(
    String workspaceId,
    String projectId, {
    required String groupBy,
    required String column,
    String swimlane = '',
    String lane = '',
    String cursor = '',
    String filterAst = '',
  }) async =>
      await _try(
        () => _inner.listColumn(
          workspaceId,
          projectId,
          groupBy: groupBy,
          column: column,
          swimlane: swimlane,
          lane: lane,
          cursor: cursor,
          filterAst: filterAst,
        ),
      ) ??
      (throw _offline);

  @override
  Future<Task> move(
    String workspaceId,
    Task task, {
    required String groupBy,
    required String column,
    String beforeId = '',
    String afterId = '',
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  }) async {
    final sent = await _try(
      () => _inner.move(
        workspaceId,
        task,
        groupBy: groupBy,
        column: column,
        beforeId: beforeId,
        afterId: afterId,
        includeSubtasks: includeSubtasks,
        overrideBlocked: overrideBlocked,
      ),
    );
    if (sent != null) return sent;
    if (includeSubtasks) throw _offline;
    if (groupBy == 'status') {
      return _tasks.move(
        workspaceId,
        task,
        column,
        overrideBlocked: overrideBlocked,
      );
    }
    final patch = switch (groupBy) {
      'priority' => TaskPatch(priority: TaskPriority.parse(column)),
      'assignee' => TaskPatch(assigneeIds: column.isEmpty ? [] : [column]),
      _ when groupBy.startsWith(fieldColumnPrefix) => TaskPatch(
        fieldValues: {groupBy.substring(fieldColumnPrefix.length): column},
      ),
      _ => throw _offline,
    };
    return _tasks.update(workspaceId, task, patch);
  }
}
