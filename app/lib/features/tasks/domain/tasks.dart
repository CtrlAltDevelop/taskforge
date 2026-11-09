import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/rich_text.dart';

const maxTitleLength = 500;

enum TaskStatus {
  todo('todo', 'To do'),
  inProgress('in_progress', 'In progress'),
  done('done', 'Done');

  const TaskStatus(this.wire, this.label);

  final String wire;
  final String label;

  static TaskStatus parse(String wire) =>
      values.firstWhere((s) => s.wire == wire, orElse: () => TaskStatus.todo);
}

enum TaskPriority {
  urgent('urgent', 'Urgent'),
  high('high', 'High'),
  normal('normal', 'Normal'),
  low('low', 'Low'),
  none('none', 'None');

  const TaskPriority(this.wire, this.label);

  final String wire;
  final String label;

  static TaskPriority parse(String wire) =>
      values.firstWhere((p) => p.wire == wire, orElse: () => TaskPriority.none);
}

@immutable
class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.number,
    required this.displayId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.none,
    this.startDate = '',
    this.dueDate = '',
    this.assigneeIds = const [],
    this.version = 1,
    this.position = '',
    this.deletedAt = '',
  });

  final String id;
  final String projectId;
  final int number;

  /// `KEY-N`, e.g. `WEB-12`.
  final String displayId;
  final String title;

  /// The rich-text document as JSON, empty when there is none.
  final String description;
  final TaskStatus status;
  final TaskPriority priority;

  /// `YYYY-MM-DD`, empty when unset.
  final String startDate;
  final String dueDate;
  final List<String> assigneeIds;
  final int version;
  final String position;
  final String deletedAt;

  bool get isDeleted => deletedAt.isNotEmpty;

  /// The task with [patch] applied (the optimistic view; version unchanged).
  Task apply(TaskPatch patch) => Task(
    id: id,
    projectId: projectId,
    number: number,
    displayId: displayId,
    title: patch.title ?? title,
    description: patch.description ?? description,
    status: patch.status ?? status,
    priority: patch.priority ?? priority,
    startDate: patch.startDate ?? startDate,
    dueDate: patch.dueDate ?? dueDate,
    assigneeIds: patch.assigneeIds ?? assigneeIds,
    version: version,
    position: position,
    deletedAt: deletedAt,
  );

  /// The value of field [name] as the server names it, for conflict screens.
  String valueOf(String name) => switch (name) {
    'title' => title,
    'description' => docToMarkdown(description),
    'status' => status.label,
    'priority' => priority.label,
    'start_date' => startDate,
    'due_date' => dueDate,
    'assignee_ids' => assigneeIds.join(','),
    _ => '',
  };
}

/// The fields of one edit. Only the non-null ones are sent (a field mask); an
/// empty date string clears the date.
@immutable
class TaskPatch {
  const TaskPatch({
    this.title,
    this.description,
    this.status,
    this.priority,
    this.startDate,
    this.dueDate,
    this.assigneeIds,
  });

  final String? title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? startDate;
  final String? dueDate;
  final List<String>? assigneeIds;

  /// Every field of [task], to put some of them back (see [only]).
  factory TaskPatch.of(Task task) => TaskPatch(
    title: task.title,
    description: task.description,
    status: task.status,
    priority: task.priority,
    startDate: task.startDate,
    dueDate: task.dueDate,
    assigneeIds: task.assigneeIds,
  );

  bool get isEmpty => fields.isEmpty;

  /// Server field names this patch changes.
  List<String> get fields => [
    if (title != null) 'title',
    if (description != null) 'description',
    if (status != null) 'status',
    if (priority != null) 'priority',
    if (startDate != null) 'start_date',
    if (dueDate != null) 'due_date',
    if (assigneeIds != null) 'assignee_ids',
  ];

  /// Only the fields in [names]: what is left to retry after a partial merge.
  TaskPatch only(Set<String> names) => TaskPatch(
    title: names.contains('title') ? title : null,
    description: names.contains('description') ? description : null,
    status: names.contains('status') ? status : null,
    priority: names.contains('priority') ? priority : null,
    startDate: names.contains('start_date') ? startDate : null,
    dueDate: names.contains('due_date') ? dueDate : null,
    assigneeIds: names.contains('assignee_ids') ? assigneeIds : null,
  );
}

/// The other person's value for a field, as the server reports a clash.
@immutable
class TaskConflict {
  const TaskConflict({
    required this.field,
    required this.current,
    required this.version,
  });

  final String field;
  final String current;
  final int version;
}

enum TaskFailure {
  conflict,
  denied,
  forbidden,
  invalid,
  archived,
  notFound,
  network,
  other,
}

class TaskException implements Exception {
  const TaskException(this.failure, {this.detail, this.conflict});

  final TaskFailure failure;
  final String? detail;
  final TaskConflict? conflict;

  @override
  String toString() => 'TaskException($failure, $detail)';
}

/// What to tell the user about a failed tasks call.
String taskErrorMessage(Object error) {
  if (error is! TaskException) return 'Something went wrong. Try again.';
  return switch (error.failure) {
    TaskFailure.conflict => 'Someone else changed this task first.',
    TaskFailure.denied => error.detail ?? 'You do not have permission.',
    TaskFailure.forbidden => 'You do not have permission to do that.',
    TaskFailure.invalid => error.detail ?? 'Check the values and try again.',
    TaskFailure.archived =>
      'This project is archived. Restore it to make changes.',
    TaskFailure.notFound => 'That task no longer exists.',
    TaskFailure.network =>
      'Cannot reach the server. Check your connection and try again.',
    TaskFailure.other => 'Something went wrong. Try again.',
  };
}
