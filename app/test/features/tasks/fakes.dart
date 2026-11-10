import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/bulk.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
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
  bool isBlocked = false,
  List<String> blockedBy = const [],
  Map<String, String> fieldValues = const {},
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
  isBlocked: isBlocked,
  blockedBy: blockedBy,
  fieldValues: fieldValues,
);

/// [t] listed under [group] in a grouped list.
Task withGroup(Task t, String group) => Task(
  id: t.id,
  projectId: t.projectId,
  number: t.number,
  displayId: t.displayId,
  title: t.title,
  description: t.description,
  statusId: t.statusId,
  statusName: t.statusName,
  statusCategory: t.statusCategory,
  priority: t.priority,
  startDate: t.startDate,
  dueDate: t.dueDate,
  assigneeIds: t.assigneeIds,
  version: t.version,
  position: t.position,
  parentId: t.parentId,
  depth: t.depth,
  isBlocked: t.isBlocked,
  blockedBy: t.blockedBy,
  fieldValues: t.fieldValues,
  groupKey: group,
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
    fieldValues: t.fieldValues,
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

  /// The field values each create was sent with.
  final createdWith = <Map<String, String>>[];
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

  /// task id -> the blockers' display ids: completing it is refused unless the
  /// call overrides.
  final blockedBy = <String, String>{};

  /// What the fake server says about the caller's right to override.
  bool canOverride = true;

  /// Ids the call was allowed through with `overrideBlocked`.
  final overridden = <String>[];

  /// task id -> its links, as that task sees them.
  final links = <String, List<TaskLink>>{};
  final addedLinks =
      <({String task, String other, LinkKind kind, bool close})>[];
  final removedLinks = <String>[];
  TaskException? failLink;

  void _guardBlocked(Task task, String statusId, bool overrideBlocked) {
    final blockers = blockedBy[task.id];
    final toDone = fakeStatuses[statusId]?.$2 == StatusCategory.done;
    if (blockers == null || !toDone) return;
    if (!overrideBlocked) {
      throw TaskException(
        TaskFailure.blocked,
        detail: blockers,
        canOverride: canOverride,
      );
    }
    overridden.add(task.id);
  }

  /// Tasks the picker can offer, whatever their project (default: [tasks]).
  List<LinkCandidate>? candidates;

  @override
  Future<List<LinkCandidate>> searchTasks(
    String workspaceId,
    String query,
  ) async {
    final q = query.trim().toLowerCase();
    return candidates ??
        [
          for (final t in tasks)
            if (q.isEmpty ||
                t.title.toLowerCase().contains(q) ||
                t.displayId.toLowerCase().contains(q))
              LinkCandidate(
                id: t.id,
                projectId: t.projectId,
                displayId: t.displayId,
                title: t.title,
                statusName: t.statusName,
              ),
        ];
  }

  @override
  Future<List<TaskLink>> listLinks(String workspaceId, String taskId) async =>
      List.of(links[taskId] ?? const []);

  @override
  Future<List<TaskLink>> addLink(
    String workspaceId,
    String taskId,
    String otherId,
    LinkKind kind, {
    bool closeDuplicate = false,
  }) async {
    final failure = failLink;
    if (failure != null) {
      failLink = null;
      throw failure;
    }
    addedLinks.add((
      task: taskId,
      other: otherId,
      kind: kind,
      close: closeDuplicate,
    ));
    final other = tasks.firstWhere((t) => t.id == otherId);
    links[taskId] = [
      ...?links[taskId],
      TaskLink(
        id: 'l${addedLinks.length}',
        kind: kind,
        otherId: other.id,
        otherProjectId: other.projectId,
        otherDisplayId: other.displayId,
        otherTitle: other.title,
        otherStatusName: other.statusName,
      ),
    ];
    return List.of(links[taskId]!);
  }

  @override
  Future<List<TaskLink>> removeLink(
    String workspaceId,
    String taskId,
    String linkId,
  ) async {
    removedLinks.add(linkId);
    links[taskId] = [
      for (final l in links[taskId] ?? const <TaskLink>[])
        if (l.id != linkId) l,
    ];
    return List.of(links[taskId]!);
  }

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

  /// The queries [list] was asked, in order.
  final queries = <ListQuery>[];

  /// How many times [list] was called.
  int get listCalls => queries.length;

  static const _statusOrder = ['todo', 'doing', 'done'];

  /// The group a task falls under for [groupBy] (what the real server sends).
  String _groupOf(Task t, String groupBy) => switch (groupBy) {
    'status' => t.statusId,
    'priority' => t.priority.wire,
    'assignee' => t.assigneeIds.isEmpty ? '' : t.assigneeIds.first,
    _ => '',
  };

  int _groupRank(Task t, String groupBy) => switch (groupBy) {
    'status' => _statusOrder.indexOf(t.statusId),
    'priority' => TaskPriority.values.indexOf(t.priority),
    'assignee' => t.assigneeIds.isEmpty ? 1 << 20 : 0,
    _ => 0,
  };

  /// Empty values last, like the server, whichever the direction.
  int _compare(Task a, Task b, SortKey key) {
    String text(Task t) => switch (key.key) {
      'title' => t.title.toLowerCase(),
      'due_date' => t.dueDate,
      'start_date' => t.startDate,
      _ => '',
    };
    if (key.key == 'priority') {
      final c =
          TaskPriority.values.indexOf(a.priority) -
          TaskPriority.values.indexOf(b.priority);
      return key.desc ? -c : c;
    }
    if (key.key == 'status') {
      final c =
          _statusOrder.indexOf(a.statusId) - _statusOrder.indexOf(b.statusId);
      return key.desc ? -c : c;
    }
    final x = text(a);
    final y = text(b);
    if (x.isEmpty != y.isEmpty) return x.isEmpty ? 1 : -1;
    final c = x.compareTo(y);
    return key.desc ? -c : c;
  }

  @override
  Stream<Task> list(
    String workspaceId,
    String projectId, {
    ListQuery query = const ListQuery(),
  }) async* {
    queries.add(query);
    await gate?.future;
    final failure = failList;
    if (failure != null) throw failure;
    var rows = _treeOrder(projectId);
    if (!query.isDefault) {
      rows = [...rows];
      rows.sort((a, b) {
        if (query.groupBy.isNotEmpty) {
          final g = _groupRank(a, query.groupBy) - _groupRank(b, query.groupBy);
          if (g != 0) return g;
        }
        for (final key in query.sort) {
          final c = _compare(a, b, key);
          if (c != 0) return c;
        }
        return a.number - b.number;
      });
    }
    for (final t in rows) {
      yield query.groupBy.isEmpty
          ? t
          : withGroup(t, _groupOf(t, query.groupBy));
    }
  }

  @override
  Future<Map<String, int>> groupCounts(
    String workspaceId,
    String projectId,
    String groupBy,
  ) async {
    final counts = <String, int>{};
    final rows = [..._treeOrder(projectId)]
      ..sort((a, b) => _groupRank(a, groupBy) - _groupRank(b, groupBy));
    for (final t in rows) {
      counts.update(_groupOf(t, groupBy), (n) => n + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  /// What the next bulk call answers per id instead of applying it (id ->
  /// the refusal's code and sentence).
  final bulkRefusals = <String, ({String code, String message})>{};
  final bulkCalls = <({List<String> ids, BulkChange change})>[];

  /// When set, a bulk call waits for it before answering each task.
  Completer<void>? bulkGate;
  TaskException? failBulk;

  @override
  Stream<BulkOutcome> bulkUpdate(
    String workspaceId,
    String projectId,
    List<String> ids,
    BulkChange change,
  ) async* {
    bulkCalls.add((ids: ids, change: change));
    final failure = failBulk;
    if (failure != null) {
      failBulk = null;
      throw failure;
    }
    for (final id in ids) {
      await bulkGate?.future;
      final refusal = bulkRefusals[id];
      final index = tasks.indexWhere((t) => t.id == id);
      if (refusal != null || index < 0) {
        yield BulkOutcome(
          id: id,
          ok: false,
          code: refusal?.code ?? 'NOT_FOUND',
          message: refusal?.message ?? 'No such task.',
        );
        continue;
      }
      if (change.delete) {
        for (final gone in _subtree(id)) {
          trashed.add(gone);
        }
        yield BulkOutcome(id: id, ok: true, task: tasks[index]);
        continue;
      }
      final next = tasks[index].apply(change.patch);
      tasks[index] = Task(
        id: next.id,
        projectId: next.projectId,
        number: next.number,
        displayId: next.displayId,
        title: next.title,
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
        fieldValues: next.fieldValues,
      );
      yield BulkOutcome(id: id, ok: true, task: tasks[index]);
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
    String statusId = '',
    Map<String, String> fieldValues = const {},
  }) async {
    await createGate?.future;
    createdWith.add(fieldValues);
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
      fieldValues: fieldValues,
      statusId: statusId.isEmpty ? 'todo' : statusId,
      statusName: fakeStatuses[statusId.isEmpty ? 'todo' : statusId]!.$1,
      category: fakeStatuses[statusId.isEmpty ? 'todo' : statusId]!.$2,
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
    bool overrideBlocked = false,
  }) async {
    _maybeFail();
    _guardBlocked(task, statusId, overrideBlocked);
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
    bool overrideBlocked = false,
  }) async {
    updates.add((task: task, patch: patch, expectedVersion: expectedVersion));
    await updateGate?.future;
    _maybeFail();
    final target = patch.status;
    if (target != null) _guardBlocked(task, target.id, overrideBlocked);
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
      dueTime: next.dueTime,
      assigneeIds: next.assigneeIds,
      isBlocked: next.isBlocked,
      blockedBy: next.blockedBy,
      blockersDue: next.blockersDue,
      blocksDue: next.blocksDue,
      version: tasks[index].version + 1,
      parentId: next.parentId,
      depth: next.depth,
      fieldValues: next.fieldValues,
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

/// The status [name] shown in the list row of task [id].
Finder statusCell(String id, String name) => find.descendant(
  of: find.byKey(Key('cell-status-$id')),
  matching: find.text(name),
);
