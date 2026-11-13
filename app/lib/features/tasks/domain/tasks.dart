import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/rich_text.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

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

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    urgent => l.grpMPriUrgent,
    high => l.grpMPriHigh,
    normal => l.grpMPriNormal,
    low => l.grpMPriLow,
    none => l.grpMPriNone,
  };

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
    this.dueTime = '',
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
    this.blockersDue = '',
    this.blocksDue = '',
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

  /// `HH:MM` in UTC (see [dueTimeLocal] for the viewer's clock); empty for none.
  /// It never moves the due date.
  final String dueTime;
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
  /// Calendar reads: the latest due date (`YYYY-MM-DD`) among the open tasks
  /// that block this one and the earliest among those it blocks; empty for none.
  final String blockersDue;
  final String blocksDue;
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
    dueTime: patch.dueDate == '' ? '' : patch.dueTime ?? dueTime,
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
    blockersDue: blockersDue,
    blocksDue: blocksDue,
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
          dueTime: dueTime,
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
          blockersDue: blockersDue,
          blocksDue: blocksDue,
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
    'due_time' => dueTime,
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
    this.dueTime,
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

  /// `HH:MM` in UTC; empty clears it.
  final String? dueTime;
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
    dueTime: task.dueTime,
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
    if (dueTime != null) 'due_time',
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
    dueTime: dueTime,
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
    dueTime: names.contains('due_time') ? dueTime : null,
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
String taskErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! TaskException) return t.grpLGeneric;
  return switch (error.failure) {
    TaskFailure.conflict => t.grpLTaskConflict,
    TaskFailure.transitionNotAllowed => error.detail ?? t.grpLTaskTransition,
    TaskFailure.hasSubtasks => t.grpLTaskHasSubtasks,
    TaskFailure.cycle => t.grpLTaskCycle,
    TaskFailure.blocked => t.grpLTaskBlocked(error.detail ?? 'open tasks'),
    TaskFailure.linkCycle => t.grpLTaskLinkCycle(error.detail ?? ''),
    TaskFailure.linkExists => t.grpLTaskLinkExists,
    TaskFailure.fieldRequired => error.detail ?? t.grpLFieldRequired,
    TaskFailure.denied => error.detail ?? t.grpLNoPerm,
    TaskFailure.forbidden => t.grpLNoPermDo,
    TaskFailure.invalid => error.detail ?? t.grpLCheckValues,
    TaskFailure.archived => t.grpLArchived,
    TaskFailure.notFound => t.grpLTaskGone,
    TaskFailure.network => t.grpLNetOffline,
    TaskFailure.other => t.grpLGeneric,
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

/// The clock time of [task]'s due time as the viewer's zone reads it
/// (`HH:MM`), or empty. The due date itself is never shifted.
String dueTimeLocal(Task task) => localClock(task.dueDate, task.dueTime);

/// [utcTime] (`HH:MM` UTC) on [date] (`YYYY-MM-DD`) as local `HH:MM`.
String localClock(String date, String utcTime) {
  final d = DateTime.tryParse(date);
  final t = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(utcTime);
  if (d == null || t == null) return '';
  final local = DateTime.utc(
    d.year,
    d.month,
    d.day,
    int.parse(t[1]!),
    int.parse(t[2]!),
  ).toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

/// The local `HH:MM` the viewer picked on [date] as `HH:MM` UTC.
String utcClock(String date, int hour, int minute) {
  final d = DateTime.parse(date);
  final utc = DateTime(d.year, d.month, d.day, hour, minute).toUtc();
  return '${utc.hour.toString().padLeft(2, '0')}:'
      '${utc.minute.toString().padLeft(2, '0')}';
}
