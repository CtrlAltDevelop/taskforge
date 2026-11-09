import 'dart:async';

import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

Task task(
  String id,
  String title, {
  int number = 1,
  String project = 'p1',
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.none,
  String dueDate = '',
  List<String> assignees = const [],
  int version = 1,
}) => Task(
  id: id,
  projectId: project,
  number: number,
  displayId: 'WEB-$number',
  title: title,
  status: status,
  priority: priority,
  dueDate: dueDate,
  assigneeIds: assignees,
  version: version,
);

/// In-memory tasks server: keeps tasks per id, numbers new ones and can be told
/// to refuse the next call or to answer an update with a conflict.
class FakeTasksClient implements TasksClient {
  FakeTasksClient([List<Task> initial = const []]) : tasks = [...initial];

  final List<Task> tasks;
  final updates = <({Task task, TaskPatch patch, int? expectedVersion})>[];
  final deleted = <String>[];
  TaskException? failNext;
  TaskException? failList;

  /// When set, [update] waits for it (to overlap edits in tests).
  Completer<void>? updateGate;

  /// When set, [list] waits for it before streaming (to test the skeleton).
  Completer<void>? gate;

  /// When set, the next update fails with this conflict after changing [theirs].
  ({String field, Task theirs})? conflictNext;

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Stream<Task> list(String workspaceId, String projectId) async* {
    await gate?.future;
    final failure = failList;
    if (failure != null) throw failure;
    for (final t in tasks.where((t) => t.projectId == projectId)) {
      yield t;
    }
  }

  @override
  Future<Task> get(String workspaceId, String projectId, String id) async =>
      tasks.firstWhere((t) => t.id == id);

  @override
  Future<Task> create(
    String workspaceId,
    String projectId, {
    required String title,
    TaskPriority priority = TaskPriority.none,
    List<String> assigneeIds = const [],
  }) async {
    _maybeFail();
    final created = task(
      't${tasks.length + 1}',
      title,
      number: tasks.length + 1,
      project: projectId,
      priority: priority,
      assignees: assigneeIds,
    );
    tasks.add(created);
    return created;
  }

  @override
  Future<Task> update(
    String workspaceId,
    Task task,
    TaskPatch patch, {
    int? expectedVersion,
  }) async {
    updates.add((task: task, patch: patch, expectedVersion: expectedVersion));
    await updateGate?.future;
    _maybeFail();
    final clash = conflictNext;
    if (clash != null) {
      conflictNext = null;
      final index = tasks.indexWhere((t) => t.id == task.id);
      tasks[index] = clash.theirs;
      throw TaskException(
        TaskFailure.conflict,
        conflict: TaskConflict(
          field: clash.field,
          current: clash.theirs.valueOf(clash.field),
          version: clash.theirs.version,
        ),
      );
    }
    final index = tasks.indexWhere((t) => t.id == task.id);
    final next = tasks[index].apply(patch);
    tasks[index] = Task(
      id: next.id,
      projectId: next.projectId,
      number: next.number,
      displayId: next.displayId,
      title: next.title,
      description: next.description,
      status: next.status,
      priority: next.priority,
      startDate: next.startDate,
      dueDate: next.dueDate,
      assigneeIds: next.assigneeIds,
      version: tasks[index].version + 1,
    );
    return tasks[index];
  }

  @override
  Future<Task> delete(String workspaceId, String projectId, String id) async {
    _maybeFail();
    deleted.add(id);
    trashed.add(id);
    return tasks.firstWhere((t) => t.id == id);
  }

  /// Ids the fake treats as deleted: [delete] adds, [restore] removes.
  final trashed = <String>[];

  @override
  Future<Task> restore(String workspaceId, String projectId, String id) async {
    _maybeFail();
    trashed.remove(id);
    return tasks.firstWhere((t) => t.id == id);
  }

  @override
  Future<List<Task>> listTrash(String workspaceId, String projectId) async {
    _maybeFail();
    return [
      for (final id in trashed.reversed)
        tasks.firstWhere((t) => t.id == id).apply(const TaskPatch()),
    ];
  }
}
