import 'dart:async';

import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// The default workflow's statuses as the fakes know them.
const fakeStatuses = {
  'todo': ('To do', StatusCategory.notStarted),
  'doing': ('In progress', StatusCategory.active),
  'done': ('Done', StatusCategory.done),
};

Task task(
  String id,
  String title, {
  int number = 1,
  String project = 'p1',
  String statusId = 'todo',
  String statusName = 'To do',
  StatusCategory category = StatusCategory.notStarted,
  TaskPriority priority = TaskPriority.none,
  String dueDate = '',
  List<String> assignees = const [],
  int version = 1,
  String parent = '',
  int depth = 0,
}) => Task(
  id: id,
  projectId: project,
  number: number,
  displayId: 'WEB-$number',
  title: title,
  statusId: statusId,
  statusName: statusName,
  statusCategory: category,
  priority: priority,
  dueDate: dueDate,
  assigneeIds: assignees,
  version: version,
  parentId: parent,
  depth: depth,
);

/// [t] changed field by field: any argument left out keeps [t]'s value.
Task changed(
  Task t, {
  String? statusId,
  String? parentId,
  int? depth,
  int? version,
}) {
  final status = statusId == null ? null : fakeStatuses[statusId]!;
  return Task(
    id: t.id,
    projectId: t.projectId,
    number: t.number,
    displayId: t.displayId,
    title: t.title,
    description: t.description,
    statusId: statusId ?? t.statusId,
    statusName: status?.$1 ?? t.statusName,
    statusCategory: status?.$2 ?? t.statusCategory,
    priority: t.priority,
    startDate: t.startDate,
    dueDate: t.dueDate,
    assigneeIds: t.assigneeIds,
    version: version ?? t.version,
    position: t.position,
    parentId: parentId ?? t.parentId,
    depth: depth ?? t.depth,
  );
}

/// In-memory tasks server: keeps tasks per id, numbers new ones and can be told
/// to refuse the next call or to answer an update with a conflict. [list]
/// answers in tree order, like the real one.
class FakeTasksClient implements TasksClient {
  FakeTasksClient([List<Task> initial = const []]) : tasks = [...initial];

  final List<Task> tasks;
  final updates = <({Task task, TaskPatch patch, int? expectedVersion})>[];
  final parentCalls = <({String task, String parent})>[];
  final moves = <({String task, String status, bool withSubtasks})>[];
  final deleted = <String>[];
  final deleteModes = <DeleteMode?>[];
  TaskException? failNext;
  TaskException? failList;

  /// When set, [update] waits for it (to overlap edits in tests).
  Completer<void>? updateGate;

  /// When set, [create] waits for it (to close a panel while a add is in flight).
  Completer<void>? createGate;

  /// When set, [list] waits for it before streaming (to test the skeleton).
  Completer<void>? gate;

  /// When set, the next update fails with this conflict after changing [theirs].
  ({String field, Task theirs})? conflictNext;

  /// Ids the fake treats as deleted: [delete] adds, [restore] removes.
  final trashed = <String>[];

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  /// Tasks in tree order: each top-level task, then its subtasks, depth first.
  List<Task> _treeOrder(String project) {
    final byParent = <String, List<Task>>{};
    for (final t in tasks) {
      if (t.projectId == project && !trashed.contains(t.id)) {
        byParent.putIfAbsent(t.parentId, () => []).add(t);
      }
    }
    final out = <Task>[];
    void visit(String parent) {
      for (final t in byParent[parent] ?? const <Task>[]) {
        out.add(t);
        visit(t.id);
      }
    }

    visit('');
    return out;
  }

  Set<String> _subtree(String id) {
    final out = {id};
    var grew = true;
    while (grew) {
      grew = false;
      for (final t in tasks) {
        if (out.contains(t.parentId) && out.add(t.id)) grew = true;
      }
    }
    return out;
  }

  void _replace(String id, Task Function(Task) change) {
    final i = tasks.indexWhere((t) => t.id == id);
    tasks[i] = change(tasks[i]);
  }

  @override
  Stream<Task> list(String workspaceId, String projectId) async* {
    await gate?.future;
    final failure = failList;
    if (failure != null) throw failure;
    for (final t in _treeOrder(projectId)) {
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
    String parentId = '',
  }) async {
    await createGate?.future;
    _maybeFail();
    final depth = parentId.isEmpty
        ? 0
        : tasks.firstWhere((t) => t.id == parentId).depth + 1;
    final created = task(
      't${tasks.length + 1}',
      title,
      number: tasks.length + 1,
      project: projectId,
      priority: priority,
      assignees: assigneeIds,
      parent: parentId,
      depth: depth,
    );
    tasks.add(created);
    return created;
  }

  @override
  Future<Task> setParent(String workspaceId, Task task, String parentId) async {
    _maybeFail();
    parentCalls.add((task: task.id, parent: parentId));
    final below = _subtree(task.id);
    if (below.contains(parentId)) {
      throw const TaskException(TaskFailure.cycle);
    }
    final newDepth = parentId.isEmpty
        ? 0
        : tasks.firstWhere((t) => t.id == parentId).depth + 1;
    final shift = newDepth - task.depth;
    for (final id in below) {
      _replace(
        id,
        (t) => changed(
          t,
          depth: t.depth + shift,
          parentId: t.id == task.id ? parentId : null,
          version: t.id == task.id ? t.version + 1 : null,
        ),
      );
    }
    return tasks.firstWhere((t) => t.id == task.id);
  }

  @override
  Future<Task> move(
    String workspaceId,
    Task task,
    String statusId, {
    bool includeSubtasks = false,
  }) async {
    _maybeFail();
    moves.add((task: task.id, status: statusId, withSubtasks: includeSubtasks));
    final toDone = fakeStatuses[statusId]!.$2 == StatusCategory.done;
    for (final id in includeSubtasks ? _subtree(task.id) : {task.id}) {
      _replace(id, (t) {
        final skip =
            t.statusId == statusId ||
            (id != task.id &&
                toDone &&
                t.statusCategory == StatusCategory.done);
        return skip
            ? t
            : changed(t, statusId: statusId, version: t.version + 1);
      });
    }
    return tasks.firstWhere((t) => t.id == task.id);
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
      _replace(task.id, (_) => clash.theirs);
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
      statusId: next.statusId,
      statusName: next.statusName,
      statusCategory: next.statusCategory,
      priority: next.priority,
      startDate: next.startDate,
      dueDate: next.dueDate,
      assigneeIds: next.assigneeIds,
      version: tasks[index].version + 1,
      parentId: next.parentId,
      depth: next.depth,
    );
    return tasks[index];
  }

  @override
  Future<Task> delete(
    String workspaceId,
    String projectId,
    String id, {
    DeleteMode? mode,
  }) async {
    _maybeFail();
    final kids = [
      for (final t in tasks)
        if (t.parentId == id && !trashed.contains(t.id)) t,
    ];
    if (kids.isNotEmpty && mode == null) {
      throw TaskException(
        TaskFailure.hasSubtasks,
        subtaskCount: _subtree(id).length - 1,
      );
    }
    deleteModes.add(mode);
    deleted.add(id);
    final gone = tasks.firstWhere((t) => t.id == id);
    if (mode == DeleteMode.subtree) {
      trashed.addAll(_subtree(id));
    } else {
      for (final kid in kids) {
        final shift = gone.depth - kid.depth;
        for (final below in _subtree(kid.id)) {
          _replace(
            below,
            (t) => changed(
              t,
              depth: t.depth + shift,
              parentId: t.id == kid.id ? gone.parentId : null,
            ),
          );
        }
      }
      trashed.add(id);
    }
    return gone;
  }

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
      for (final id in trashed.reversed.toSet())
        tasks.firstWhere((t) => t.id == id).apply(const TaskPatch()),
    ];
  }
}
