import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

IconData priorityIcon(TaskPriority priority) => switch (priority) {
  TaskPriority.urgent => Icons.priority_high,
  TaskPriority.high => Icons.keyboard_double_arrow_up,
  TaskPriority.normal => Icons.drag_handle,
  TaskPriority.low => Icons.keyboard_arrow_down,
  TaskPriority.none => Icons.remove,
};

Color priorityColor(TaskPriority priority) => switch (priority) {
  TaskPriority.urgent => Colors.red,
  TaskPriority.high => Colors.orange,
  TaskPriority.normal => Colors.blue,
  TaskPriority.low => Colors.blueGrey,
  TaskPriority.none => Colors.grey,
};

/// Saves [patch] on [task]. A refusal becomes a snackbar; a clash on a field
/// someone else changed opens the keep-mine / take-theirs dialog.
Future<void> saveTask(
  BuildContext context,
  WidgetRef ref,
  Task task,
  TaskPatch patch,
) async {
  // Captured before the await: the page may be rebuilt meanwhile.
  final messenger = ScaffoldMessenger.of(context);
  final list = ref.read(taskListProvider(task.projectId).notifier);
  try {
    await list.update(task, patch);
  } on TaskException catch (e) {
    final conflict = e.conflict;
    if (e.failure == TaskFailure.conflict && conflict != null) {
      if (!context.mounted) return;
      await _resolveConflict(context, ref, task, patch, conflict);
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
  }
}

Future<void> _resolveConflict(
  BuildContext context,
  WidgetRef ref,
  Task task,
  TaskPatch patch,
  TaskConflict conflict,
) async {
  final list = ref.read(taskListProvider(task.projectId).notifier);
  final theirs = ref
      .read(taskListProvider(task.projectId))
      .tasks
      .where((t) => t.id == task.id)
      .firstOrNull;
  final keepMine = await showDialog<bool>(
    context: context,
    builder: (context) => ConflictDialog(
      field: conflict.field,
      mine: task.apply(patch).valueOf(conflict.field),
      theirs: theirs?.valueOf(conflict.field) ?? conflict.current,
    ),
  );
  if (keepMine != true || theirs == null) return;
  try {
    await list.update(
      theirs,
      patch.only({conflict.field}),
      expectedVersion: conflict.version,
    );
  } on TaskException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
  }
}

String fieldLabel(String field) => switch (field) {
  'title' => 'title',
  'description' => 'description',
  'status' => 'status',
  'priority' => 'priority',
  'start_date' => 'start date',
  'due_date' => 'due date',
  'assignee_ids' => 'assignees',
  _ => field,
};

/// Someone else changed the same field: pick whose value stays.
class ConflictDialog extends StatelessWidget {
  const ConflictDialog({
    super.key,
    required this.field,
    required this.mine,
    required this.theirs,
  });

  final String field;
  final String mine;
  final String theirs;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Someone changed the ${fieldLabel(field)}'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Theirs'),
        Text(theirs.isEmpty ? '(empty)' : theirs, key: const Key('theirs')),
        const SizedBox(height: 12),
        const Text('Yours'),
        Text(mine.isEmpty ? '(empty)' : mine, key: const Key('mine')),
      ],
    ),
    actions: [
      TextButton(
        key: const Key('take-theirs'),
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Take theirs'),
      ),
      FilledButton(
        key: const Key('keep-mine'),
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Keep mine'),
      ),
    ],
  );
}
