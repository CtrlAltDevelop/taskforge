import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
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

/// The lock shown on a task that still has an open blocker; its tooltip names
/// them ("Blocked by WEB-4 (In progress)") when they are known.
class BlockedBadge extends StatelessWidget {
  const BlockedBadge({super.key, this.blockedBy = const []});

  final List<String> blockedBy;

  String get message => blockedBy.isEmpty
      ? 'Blocked by tasks that are not done yet'
      : 'Blocked by ${blockedBy.join(', ')}';

  @override
  Widget build(BuildContext context) => Tooltip(
    message: message,
    child: const Icon(
      Icons.lock,
      key: Key('blocked-badge'),
      size: 18,
      color: Colors.red,
      semanticLabel: 'Blocked',
    ),
  );
}

/// Saves [patch] on [task]. A refusal becomes a snackbar; a clash on a field
/// someone else changed opens the keep-mine / take-theirs dialog; completing a
/// blocked task asks first (and lets a project manager do it anyway).
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
    if (e.failure == TaskFailure.blocked && context.mounted) {
      await _confirmOverride(context, ref, task, patch, e);
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
  }
}

Future<void> _confirmOverride(
  BuildContext context,
  WidgetRef ref,
  Task task,
  TaskPatch patch,
  TaskException blocked,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final list = ref.read(taskListProvider(task.projectId).notifier);
  if (!await askOverride(context, blocked)) return;
  try {
    await list.update(task, patch, overrideBlocked: true);
  } on TaskException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
  }
}

/// Tells the user which tasks block this one. True when they chose "Complete
/// anyway", which only the people the server allows to override are offered.
Future<bool> askOverride(BuildContext context, TaskException blocked) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => BlockedDialog(
        blockers: blocked.detail ?? '',
        canOverride: blocked.canOverride,
      ),
    ) ??
    false;

/// A blocked task cannot be completed: names the blockers and, for a project
/// manager, offers to complete it anyway (recorded on the server).
class BlockedDialog extends StatelessWidget {
  const BlockedDialog({
    super.key,
    required this.blockers,
    required this.canOverride,
  });

  final String blockers;
  final bool canOverride;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('This task is blocked'),
    content: Text(
      'It is blocked by $blockers, which ${blockers.contains(',') ? 'are' : 'is'} '
      'not done yet.',
      key: const Key('blocked-text'),
    ),
    actions: [
      TextButton(
        key: const Key('blocked-cancel'),
        onPressed: () => Navigator.pop(context, false),
        child: Text(canOverride ? 'Cancel' : 'OK'),
      ),
      if (canOverride)
        FilledButton(
          key: const Key('complete-anyway'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Complete anyway'),
        ),
    ],
  );
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
  // A custom field is named `field:<id>` and holds an id or code: show its
  // name and its values as people read them.
  final custom = ref
      .read(fieldsProvider(task.projectId))
      .value
      ?.where((f) => conflict.field == '$fieldKeyPrefix${f.id}')
      .firstOrNull;
  String show(String wire) =>
      custom == null ? wire : fieldDisplay(custom, wire);
  final keepMine = await showDialog<bool>(
    context: context,
    builder: (context) => ConflictDialog(
      field: custom?.name ?? conflict.field,
      mine: show(task.apply(patch).valueOf(conflict.field)),
      theirs: show(theirs?.valueOf(conflict.field) ?? conflict.current),
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
