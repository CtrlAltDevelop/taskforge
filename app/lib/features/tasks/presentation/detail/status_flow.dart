import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/subtask_dialogs.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// Moves [task] to [target]. Moving to a finished status while subtasks are
/// open asks whether to finish them too; either way the workflow still has
/// the last word (a refusal puts the status back and says why).
Future<void> pickStatus(
  BuildContext context,
  WidgetRef ref,
  TaskTree tree,
  Task task,
  WorkflowStatus target,
) async {
  final open = tree.openBelow(task.id);
  if (target.category != StatusCategory.done || open == 0) {
    await saveTask(context, ref, task, TaskPatch(status: target));
    return;
  }
  final choice = await askCompleteSubtasks(context, task, open, target.name);
  if (choice == null || !context.mounted) return;
  if (choice == CompleteChoice.leave) {
    await saveTask(context, ref, task, TaskPatch(status: target));
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final list = ref.read(taskListProvider(task.projectId).notifier);
  try {
    try {
      await list.moveWithSubtasks(task, target);
    } on TaskException catch (e) {
      if (e.failure != TaskFailure.blocked) rethrow;
      if (!context.mounted || !await askOverride(context, e)) return;
      await list.moveWithSubtasks(task, target, overrideBlocked: true);
    }
  } on TaskException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
  }
}

/// Adds or removes one assignee. Built from the task as it is now, so two
/// quick toggles both count.
void toggleAssignee(
  BuildContext context,
  WidgetRef ref,
  Task task,
  String userId, {
  required bool on,
}) {
  final current =
      ref
          .read(taskListProvider(task.projectId))
          .tasks
          .where((t) => t.id == task.id)
          .firstOrNull ??
      task;
  final others = [
    for (final id in current.assigneeIds)
      if (id != userId) id,
  ];
  saveTask(
    context,
    ref,
    current,
    TaskPatch(assigneeIds: on ? [...others, userId] : others),
  );
}
