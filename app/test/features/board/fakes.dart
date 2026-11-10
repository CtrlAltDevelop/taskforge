import 'dart:async';

import 'package:taskforge/features/board/data/board_client.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../tasks/fakes.dart';

/// An in-memory board: [tasks] in rank order, grouped like the server does.
class FakeBoardClient implements BoardClient {
  FakeBoardClient([List<Task> initial = const []]) : tasks = [...initial];

  /// Top-level tasks in rank order.
  final List<Task> tasks;
  int pageSize = boardPageSize;
  final getCalls = <({String groupBy, String swimlane})>[];
  final listColumnCalls = <({String column, String cursor, String lane})>[];
  final moves =
      <
        ({
          String task,
          String column,
          String beforeId,
          String afterId,
          bool overrideBlocked,
        })
      >[];

  /// The next move is refused with this.
  TaskException? failMove;

  /// When set, [move] waits for it (to overlap drops in tests).
  Completer<void>? moveGate;

  /// When set, [get] waits for it (to test the skeleton).
  Completer<void>? getGate;

  static String keyOf(Task t, String groupBy) => switch (groupBy) {
    'status' => t.statusId,
    'priority' => t.priority.wire,
    'assignee' => t.assigneeIds.firstOrNull ?? '',
    _ => t.fieldValues[groupBy.substring(6)] ?? '',
  };

  List<(String, String)> _columns(String groupBy) => switch (groupBy) {
    'status' => [for (final e in fakeStatuses.entries) (e.key, e.value.$1)],
    'priority' => [for (final p in TaskPriority.values) (p.wire, p.label)],
    _ => [
      for (final k in {for (final t in tasks) keyOf(t, groupBy)}..remove(''))
        (k, ''),
      ('', 'Unassigned'),
    ],
  };

  List<Task> _cell(
    String groupBy,
    String column,
    String swimlane,
    String lane,
  ) => [
    for (final t in tasks)
      if (keyOf(t, groupBy) == column &&
          (swimlane.isEmpty || keyOf(t, swimlane) == lane))
        t,
  ];

  @override
  Future<List<BoardLane>> get(
    String workspaceId,
    String projectId, {
    required String groupBy,
    String swimlane = '',
  }) async {
    getCalls.add((groupBy: groupBy, swimlane: swimlane));
    await getGate?.future;
    final lanes = swimlane.isEmpty
        ? ['']
        : [
            for (final k in {
              for (final t in tasks) keyOf(t, swimlane),
            }..remove(''))
              k,
            '',
          ];
    return [
      for (final lane in lanes)
        BoardLane(
          key: lane,
          columns: [
            for (final (key, name) in _columns(groupBy))
              () {
                final cell = _cell(groupBy, key, swimlane, lane);
                return BoardColumn(
                  key: key,
                  name: name,
                  count: cell.length,
                  tasks: cell.take(pageSize).toList(),
                  cursor: cell.length > pageSize ? '$pageSize' : '',
                );
              }(),
          ],
        ),
    ];
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
  }) async {
    listColumnCalls.add((column: column, cursor: cursor, lane: lane));
    final cell = _cell(groupBy, column, swimlane, lane);
    final from = int.parse(cursor);
    final end = from + pageSize;
    return (
      tasks: cell.skip(from).take(pageSize).toList(),
      cursor: end < cell.length ? '$end' : '',
    );
  }

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
    moves.add((
      task: task.id,
      column: column,
      beforeId: beforeId,
      afterId: afterId,
      overrideBlocked: overrideBlocked,
    ));
    await moveGate?.future;
    final failure = failMove;
    if (failure != null) {
      failMove = null;
      throw failure;
    }
    final i = tasks.indexWhere((t) => t.id == task.id);
    final current = tasks.removeAt(i);
    var moved = current.version == task.version
        ? current.apply(_patchFor(groupBy, column))
        : current;
    moved = _bumped(moved);
    var at = tasks.length;
    final before = tasks.indexWhere((t) => t.id == beforeId);
    final after = tasks.indexWhere((t) => t.id == afterId);
    if (before >= 0) {
      at = before;
    } else if (after >= 0) {
      at = after + 1;
    }
    tasks.insert(at, moved);
    return moved;
  }

  TaskPatch _patchFor(String groupBy, String column) => switch (groupBy) {
    'status' => TaskPatch(
      status: WorkflowStatus(
        id: column,
        name: fakeStatuses[column]!.$1,
        category: fakeStatuses[column]!.$2,
      ),
    ),
    'priority' => TaskPatch(priority: TaskPriority.parse(column)),
    'assignee' => TaskPatch(assigneeIds: column.isEmpty ? [] : [column]),
    _ => const TaskPatch(),
  };

  Task _bumped(Task t) => Task(
    id: t.id,
    projectId: t.projectId,
    number: t.number,
    displayId: t.displayId,
    title: t.title,
    statusId: t.statusId,
    statusName: t.statusName,
    statusCategory: t.statusCategory,
    priority: t.priority,
    dueDate: t.dueDate,
    assigneeIds: t.assigneeIds,
    version: t.version + 1,
    position: t.position,
    fieldValues: t.fieldValues,
  );
}
