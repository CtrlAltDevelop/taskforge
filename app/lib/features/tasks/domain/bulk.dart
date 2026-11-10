import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// Most tasks one bulk call may take (the server's limit).
const maxBulkTasks = 500;

/// What a bulk edit does to every chosen task: set some fields, or delete.
@immutable
class BulkChange {
  const BulkChange({
    this.status,
    this.priority,
    this.assigneeIds,
    this.deleteMode,
    this.delete = false,
  });

  /// Delete the tasks; [deleteMode] says what happens to subtasks that were
  /// not chosen as well (the server refuses a task that has some without it).
  const BulkChange.delete({this.deleteMode = DeleteMode.subtree})
    : status = null,
      priority = null,
      assigneeIds = null,
      delete = true;

  final WorkflowStatus? status;
  final TaskPriority? priority;

  /// The new assignees of every task (empty: none); null leaves them alone.
  final List<String>? assigneeIds;
  final bool delete;
  final DeleteMode? deleteMode;

  /// The patch the list applies at once to a task that took the change.
  TaskPatch get patch =>
      TaskPatch(status: status, priority: priority, assigneeIds: assigneeIds);
}

/// What happened to one task of a bulk call.
@immutable
class BulkOutcome {
  const BulkOutcome({
    required this.id,
    required this.ok,
    this.task,
    this.code = '',
    this.message = '',
  });

  final String id;
  final bool ok;

  /// The task as it is now (a deleted one for a delete); null when it failed.
  final Task? task;

  /// The refusal's title (`TASK_BLOCKED`, `NOT_FOUND` ...) and its sentence.
  final String code;
  final String message;
}

/// How a whole bulk call went.
@immutable
class BulkSummary {
  const BulkSummary({
    required this.total,
    this.succeeded = const [],
    this.failed = const [],
  });

  final int total;
  final List<String> succeeded;
  final List<BulkOutcome> failed;

  bool get allOk => failed.isEmpty;
}
