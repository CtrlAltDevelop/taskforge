import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// One line of the list: a group header or a task.
sealed class ListEntry {
  const ListEntry();
}

@immutable
class GroupEntry extends ListEntry {
  const GroupEntry({
    required this.key,
    required this.count,
    required this.collapsed,
  });

  /// The group's key as the server names it (empty: tasks with no value).
  final String key;
  final int count;
  final bool collapsed;
}

@immutable
class TaskEntry extends ListEntry {
  const TaskEntry({
    required this.task,
    this.depth = 0,
    this.hasChildren = false,
    this.expanded = true,
  });

  final Task task;

  /// Indent and chevron: only in the plain tree order. A sorted or grouped
  /// list is flat (a subtask sits wherever the sort puts it).
  final int depth;
  final bool hasChildren;
  final bool expanded;
}

/// The lines of the list for [tasks] as the server streamed them for [query].
///
/// Without sort or grouping that is the tree (folded parents hide their
/// subtasks); otherwise a flat list, with a header before each group when
/// grouped. A header's count is what the list holds once it has fully loaded;
/// while [loading] it is the server's [serverCounts], so it is right at once.
/// A collapsed group keeps its header and drops its tasks.
List<ListEntry> listEntries(
  List<Task> tasks,
  ListQuery query, {
  required Set<String> collapsedTasks,
  required Set<String> collapsedGroups,
  required bool loading,
  Map<String, int> serverCounts = const {},
}) {
  if (query.groupBy.isNotEmpty) {
    return _grouped(
      tasks,
      collapsedGroups,
      loading: loading,
      serverCounts: serverCounts,
    );
  }
  if (query.sort.isNotEmpty || query.filterAst.isNotEmpty) {
    return [for (final t in tasks) TaskEntry(task: t)];
  }
  return [
    for (final row in TaskTree(tasks).visibleRows(collapsedTasks))
      TaskEntry(
        task: row.task,
        depth: row.depth,
        hasChildren: row.hasChildren,
        expanded: row.expanded,
      ),
  ];
}

List<ListEntry> _grouped(
  List<Task> tasks,
  Set<String> collapsedGroups, {
  required bool loading,
  required Map<String, int> serverCounts,
}) {
  // Bucket by key, in the order each group first appears, so a task edited
  // into another group joins it instead of splitting it with a second header.
  final buckets = <String, List<Task>>{};
  for (final t in tasks) {
    buckets.putIfAbsent(t.groupKey, () => []).add(t);
  }
  final entries = <ListEntry>[];
  for (final MapEntry(:key, value: members) in buckets.entries) {
    final collapsed = collapsedGroups.contains(key);
    entries.add(
      GroupEntry(
        key: key,
        count: loading ? (serverCounts[key] ?? members.length) : members.length,
        collapsed: collapsed,
      ),
    );
    if (!collapsed) {
      entries.addAll([for (final t in members) TaskEntry(task: t)]);
    }
  }
  return entries;
}

/// The group [task] falls under when the list is grouped by [groupBy], as the
/// server names it. The server only keys tasks it lists; every other answer
/// (an edit, a bulk result, a new task) is keyed here.
String groupKeyOf(Task task, String groupBy) {
  if (groupBy.isEmpty) return '';
  if (groupBy.startsWith(fieldColumnPrefix)) {
    return task.fieldValues[groupBy.substring(fieldColumnPrefix.length)] ?? '';
  }
  return switch (groupBy) {
    'status' => task.statusId,
    'priority' => task.priority.wire,
    'assignee' => task.assigneeIds.firstOrNull ?? '',
    _ => task.groupKey,
  };
}

/// The ids of the tasks among [entries] (what "select all" picks).
List<String> taskIds(Iterable<ListEntry> entries) => [
  for (final e in entries)
    if (e is TaskEntry) e.task.id,
];
