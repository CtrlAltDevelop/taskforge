import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/rich_text.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

const maxTitleLength = 500;

/// How a custom field is named in a conflict (`field:<id>`).
const fieldKeyPrefix = 'field:';

Map<String, String> _withValues(
  Map<String, String> current,
  Map<String, String> changes,
) => Map.unmodifiable({
  for (final e in {...current, ...changes}.entries)
    if (e.value.isNotEmpty) e.key: e.value,
});

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
    required this.statusId,
    this.statusName = '',
    this.statusCategory = StatusCategory.notStarted,
    this.priority = TaskPriority.none,
    this.startDate = '',
    this.dueDate = '',
    this.assigneeIds = const [],
    this.version = 1,
    this.position = '',
    this.deletedAt = '',
    this.parentId = '',
    this.depth = 0,
    this.isBlocked = false,
    this.blockedBy = const [],
    this.fieldValues = const {},
    this.groupKey = '',
    this.progressDone = 0,
    this.progressTotal = 0,
    this.createdAt = '',
    this.updatedAt = '',
  });

  final String id;
  final String projectId;
  final int number;

  /// `KEY-N`, e.g. `WEB-12`.
  final String displayId;
  final String title;

  /// The rich-text document as JSON, empty when there is none.
  final String description;

  /// One of the project's statuses (see the workflow); the name and category
  /// are copies for display.
  final String statusId;
  final String statusName;
  final StatusCategory statusCategory;
  final TaskPriority priority;

  /// `YYYY-MM-DD`, empty when unset.
  final String startDate;
  final String dueDate;
  final List<String> assigneeIds;
  final int version;
  final String position;
  final String deletedAt;

  /// The task this is a subtask of, empty at the top; [depth] is how far down.
  final String parentId;
  final int depth;

  /// Has a blocker that is not done yet: it cannot be completed until it is.
  final bool isBlocked;

  /// The open blockers as you may see them: `WEB-4 (In progress)`, or
  /// `Restricted task`.
  final List<String> blockedBy;

  /// Custom field id -> value in its wire form (only fields that have one).
  final Map<String, String> fieldValues;

  /// In a grouped list: the group the server listed this task under (a status
  /// id, a priority, a user id, an option id; empty: the group without one).
  final String groupKey;

  /// How many of this task's subtasks (all levels) are done, and how many it
  /// has, as the server counts them (the board has no tree to count in).
  final int progressDone;
  final int progressTotal;

  /// ISO timestamps; empty when the server did not say.
  final String createdAt;
  final String updatedAt;

  bool get isDeleted => deletedAt.isNotEmpty;

  /// The task with [patch] applied (the optimistic view; version unchanged).
  Task apply(TaskPatch patch) => Task(
    id: id,
    projectId: projectId,
    number: number,
    displayId: displayId,
    title: patch.title ?? title,
    description: patch.description ?? description,
    statusId: patch.status?.id ?? statusId,
    statusName: patch.status?.name ?? statusName,
    statusCategory: patch.status?.category ?? statusCategory,
    priority: patch.priority ?? priority,
    startDate: patch.startDate ?? startDate,
    dueDate: patch.dueDate ?? dueDate,
    assigneeIds: patch.assigneeIds ?? assigneeIds,
    version: version,
    position: position,
    deletedAt: deletedAt,
    parentId: parentId,
    depth: depth,
    isBlocked: isBlocked,
    blockedBy: blockedBy,
    fieldValues: patch.fieldValues == null
        ? fieldValues
        : _withValues(fieldValues, patch.fieldValues!),
    groupKey: groupKey,
    progressDone: progressDone,
    progressTotal: progressTotal,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// The same task listed under [key] (see [groupKey]).
  Task withGroupKey(String key) => key == groupKey
      ? this
      : Task(
          id: id,
          projectId: projectId,
          number: number,
          displayId: displayId,
          title: title,
          description: description,
          statusId: statusId,
          statusName: statusName,
          statusCategory: statusCategory,
          priority: priority,
          startDate: startDate,
          dueDate: dueDate,
          assigneeIds: assigneeIds,
          version: version,
          position: position,
          deletedAt: deletedAt,
          parentId: parentId,
          depth: depth,
          isBlocked: isBlocked,
          blockedBy: blockedBy,
          fieldValues: fieldValues,
          groupKey: key,
          progressDone: progressDone,
          progressTotal: progressTotal,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// The value of field [name] as the server names it, for conflict screens.
  String valueOf(String name) => switch (name) {
    'title' => title,
    'description' => docToMarkdown(description),
    'status' => statusName,
    'priority' => priority.label,
    'start_date' => startDate,
    'due_date' => dueDate,
    'assignee_ids' => assigneeIds.join(','),
    _ when name.startsWith(fieldKeyPrefix) =>
      fieldValues[name.substring(fieldKeyPrefix.length)] ?? '',
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
    this.fieldValues,
  });

  final String? title;
  final String? description;

  /// Only its id is sent; the rest lets the list show the move at once.
  final WorkflowStatus? status;
  final TaskPriority? priority;
  final String? startDate;
  final String? dueDate;
  final List<String>? assigneeIds;

  /// Custom field id -> new wire value; empty clears the field.
  final Map<String, String>? fieldValues;

  /// Every field of [task], to put some of them back (see [only]).
  factory TaskPatch.of(Task task) => TaskPatch(
    title: task.title,
    description: task.description,
    status: WorkflowStatus(
      id: task.statusId,
      name: task.statusName,
      category: task.statusCategory,
    ),
    priority: task.priority,
    startDate: task.startDate,
    dueDate: task.dueDate,
    assigneeIds: task.assigneeIds,
    fieldValues: Map.unmodifiable({
      for (final k in task.fieldValues.keys) k: task.fieldValues[k]!,
    }),
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
    for (final id in fieldValues?.keys ?? const <String>[])
      '$fieldKeyPrefix$id',
  ];

  /// This patch with its custom field values replaced by [values].
  TaskPatch withFieldValues(Map<String, String>? values) => TaskPatch(
    title: title,
    description: description,
    status: status,
    priority: priority,
    startDate: startDate,
    dueDate: dueDate,
    assigneeIds: assigneeIds,
    fieldValues: values,
  );

  /// Only the fields in [names]: what is left to retry after a partial merge.
  TaskPatch only(Set<String> names) => TaskPatch(
    title: names.contains('title') ? title : null,
    description: names.contains('description') ? description : null,
    status: names.contains('status') ? status : null,
    priority: names.contains('priority') ? priority : null,
    startDate: names.contains('start_date') ? startDate : null,
    dueDate: names.contains('due_date') ? dueDate : null,
    assigneeIds: names.contains('assignee_ids') ? assigneeIds : null,
    fieldValues: fieldValues == null
        ? null
        : {
            for (final e in fieldValues!.entries)
              if (names.contains('$fieldKeyPrefix${e.key}')) e.key: e.value,
          },
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
  transitionNotAllowed,
  hasSubtasks,
  cycle,
  blocked,
  linkCycle,
  linkExists,
  fieldRequired,
  denied,
  forbidden,
  invalid,
  archived,
  notFound,
  network,
  other,
}

class TaskException implements Exception {
  const TaskException(
    this.failure, {
    this.detail,
    this.conflict,
    this.subtaskCount = 0,
    this.canOverride = false,
    this.fieldIds = const [],
  });

  final TaskFailure failure;
  final String? detail;
  final TaskConflict? conflict;

  /// For [TaskFailure.hasSubtasks]: how many subtasks the task has.
  final int subtaskCount;

  /// For [TaskFailure.blocked]: the server would accept completing it anyway
  /// from this person.
  final bool canOverride;

  /// For [TaskFailure.fieldRequired]: the custom fields missing a value.
  final List<String> fieldIds;

  @override
  String toString() => 'TaskException($failure, $detail)';
}

/// What to tell the user about a failed tasks call.
String taskErrorMessage(Object error) {
  if (error is! TaskException) return 'Something went wrong. Try again.';
  return switch (error.failure) {
    TaskFailure.conflict => 'Someone else changed this task first.',
    TaskFailure.transitionNotAllowed =>
      error.detail ?? 'The workflow does not allow that move.',
    TaskFailure.hasSubtasks =>
      'This task has subtasks: choose what happens to them.',
    TaskFailure.cycle =>
      'A task cannot become a subtask of itself or of one of its own subtasks.',
    TaskFailure.blocked =>
      'Blocked by ${error.detail ?? 'open tasks'}: finish those first.',
    TaskFailure.linkCycle =>
      'Those tasks would block each other in a loop: ${error.detail ?? ''}.',
    TaskFailure.linkExists => 'These tasks are already linked that way.',
    TaskFailure.fieldRequired =>
      error.detail ?? 'A required field has no value.',
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

/// What happens to the subtasks of a task that is deleted.
enum DeleteMode {
  /// Delete them with it.
  subtree('subtree'),

  /// Move them up to its own parent.
  promote('promote');

  const DeleteMode(this.wire);

  final String wire;
}
