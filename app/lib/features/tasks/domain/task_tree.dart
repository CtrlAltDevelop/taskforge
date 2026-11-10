import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// How many levels the app nests before it stops offering more (depths 0 to
/// this minus one; the server allows more).
const softDepthLimit = 8;

/// One row of the task list: a task, how far it is indented, and whether it has
/// subtasks (and so a chevron).
@immutable
class TreeRow {
  const TreeRow({
    required this.task,
    required this.depth,
    required this.hasChildren,
    required this.expanded,
  });

  final Task task;
  final int depth;
  final bool hasChildren;
  final bool expanded;
}

/// How many of a task's subtasks (at any depth) are done, out of how many.
@immutable
class Progress {
  const Progress(this.done, this.total);

  static const none = Progress(0, 0);

  final int done;
  final int total;

  bool get isEmpty => total == 0;
  double get fraction => total == 0 ? 0 : done / total;
}

/// The tasks of a project as a tree. [tasks] come in tree order (a parent right
/// before its own subtasks), as the server lists them with `include_subtasks`.
/// Built once per list; every question below is a lookup, so a list of
/// thousands stays cheap.
class TaskTree {
  TaskTree(this.tasks) {
    for (final t in tasks) {
      _byId[t.id] = t;
    }
    for (final t in tasks) {
      // A task whose parent is not in the list (not loaded, or deleted) is shown at the top.
      final parent = _byId.containsKey(t.parentId) ? t.parentId : '';
      _children.putIfAbsent(parent, () => []).add(t);
    }
    for (final t in tasks.reversed) {
      final kids = _children[t.id] ?? const <Task>[];
      var done = 0;
      var total = 0;
      for (final k in kids) {
        total += 1 + (_progress[k.id]?.total ?? 0);
        done +=
            (k.statusCategory == StatusCategory.done ? 1 : 0) +
            (_progress[k.id]?.done ?? 0);
      }
      _progress[t.id] = Progress(done, total);
    }
  }

  final List<Task> tasks;
  final _byId = <String, Task>{};
  final _children = <String, List<Task>>{};
  final _progress = <String, Progress>{};

  Task? task(String id) => _byId[id];

  List<Task> childrenOf(String id) => _children[id] ?? const [];

  bool hasChildren(String id) => childrenOf(id).isNotEmpty;

  /// Everything under [id] at any depth: the ring on a parent.
  Progress progressOf(String id) => _progress[id] ?? Progress.none;

  /// The rows to show: every task whose ancestors are all expanded
  /// ([collapsed] holds the ids that are folded shut).
  List<TreeRow> visibleRows(Set<String> collapsed) {
    final rows = <TreeRow>[];
    final hidden = <String>{};
    final depth = <String, int>{};
    for (final t in tasks) {
      final parent = _byId.containsKey(t.parentId) ? t.parentId : '';
      if (parent.isNotEmpty &&
          (hidden.contains(parent) || collapsed.contains(parent))) {
        hidden.add(t.id);
        continue;
      }
      final d = parent.isEmpty ? 0 : (depth[parent] ?? 0) + 1;
      depth[t.id] = d;
      rows.add(
        TreeRow(
          task: t,
          depth: d,
          hasChildren: hasChildren(t.id),
          expanded: !collapsed.contains(t.id),
        ),
      );
    }
    return rows;
  }

  /// The ancestors of [id] from the top down, then the task itself: the
  /// breadcrumb `WEB-3 › WEB-9 › WEB-14`.
  List<Task> breadcrumb(String id) {
    final chain = <Task>[];
    var current = _byId[id];
    final seen = <String>{};
    while (current != null && seen.add(current.id)) {
      chain.add(current);
      current = _byId[current.parentId];
    }
    return chain.reversed.toList();
  }

  /// [id] and every task under it.
  Set<String> subtreeIds(String id) {
    final out = <String>{};
    final stack = [id];
    while (stack.isNotEmpty) {
      final next = stack.removeLast();
      if (!out.add(next)) continue;
      stack.addAll(childrenOf(next).map((t) => t.id));
    }
    return out;
  }

  /// How many levels lie below [id] (0 when it has no subtasks).
  int levelsBelow(String id) {
    var deepest = 0;
    final stack = <(String, int)>[(id, 0)];
    while (stack.isNotEmpty) {
      final (next, level) = stack.removeLast();
      if (level > deepest) deepest = level;
      for (final k in childrenOf(next)) {
        stack.add((k.id, level + 1));
      }
    }
    return deepest;
  }

  /// Whether making [taskId] a subtask of [parentId] would put it under itself.
  bool wouldCycle(String taskId, String parentId) =>
      parentId == taskId || subtreeIds(taskId).contains(parentId);

  /// Where [taskId] may go: every task except itself and its own subtasks, and
  /// except those so deep that the moved subtree would pass [softDepthLimit].
  List<Task> candidateParents(String taskId) {
    final blocked = subtreeIds(taskId);
    final below = levelsBelow(taskId);
    return [
      for (final t in tasks)
        if (!blocked.contains(t.id) && t.depth + 1 + below < softDepthLimit) t,
    ];
  }

  /// Live subtasks that are not finished (done or cancelled).
  int openBelow(String id) {
    var open = 0;
    for (final sid in subtreeIds(id)) {
      if (sid == id) continue;
      final t = _byId[sid]!;
      if (!t.statusCategory.isFinal) open++;
    }
    return open;
  }
}
