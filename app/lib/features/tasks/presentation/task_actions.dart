import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What a row's menu can do.
enum TaskAction {
  addSubtask('Add subtask'),
  moveUnder('Move under\u2026'),
  makeTopLevel('Make top level'),
  delete('Delete');

  const TaskAction(this.label);

  /// The English name; [labelIn] gives it in the language on screen.
  final String label;

  String labelIn(AppLocalizations l10n) => switch (this) {
    addSubtask => l10n.grpFActionAddSubtask,
    moveUnder => l10n.grpFActionMoveUnder,
    makeTopLevel => l10n.grpFActionMakeTopLevel,
    delete => l10n.grpFDelete,
  };
}

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

  String get message => messageIn(lookupAppLocalizations(const Locale('en')));

  String messageIn(AppLocalizations l10n) => blockedBy.isEmpty
      ? l10n.grpFBlockedByPending
      : l10n.grpFBlockedBy(blockedBy.join(', '));

  @override
  Widget build(BuildContext context) => Tooltip(
    message: messageIn(context.l10n),
    child: Icon(
      Icons.lock,
      key: const Key('blocked-badge'),
      size: 18,
      color: Colors.red,
      semanticLabel: context.l10n.grpFBlocked,
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
  final l10n = context.l10n;
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
      ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
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
  final l10n = context.l10n;
  final list = ref.read(taskListProvider(task.projectId).notifier);
  if (!await askOverride(context, blocked)) return;
  try {
    await list.update(task, patch, overrideBlocked: true);
  } on TaskException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
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
    title: Text(context.l10n.grpFBlockedTitle),
    content: Text(
      blockers.contains(',')
          ? context.l10n.grpFBlockedTextMany(blockers)
          : context.l10n.grpFBlockedTextOne(blockers),
      key: const Key('blocked-text'),
    ),
    actions: [
      TextButton(
        key: const Key('blocked-cancel'),
        onPressed: () => Navigator.pop(context, false),
        child: Text(canOverride ? context.l10n.cancel : context.l10n.grpFOk),
      ),
      if (canOverride)
        FilledButton(
          key: const Key('complete-anyway'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.grpFCompleteAnyway),
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
      custom == null ? wire : fieldDisplay(custom, wire, l10n: context.l10n);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(taskErrorMessage(e, context.l10n))));
  }
}

String fieldLabel(String field, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  return switch (field) {
    'title' => t.grpFFieldTitle,
    'description' => t.grpFFieldDescription,
    'status' => t.grpFFieldStatus,
    'priority' => t.grpFFieldPriority,
    'start_date' => t.grpFFieldStartDate,
    'due_date' => t.grpFFieldDueDate,
    'assignee_ids' => t.grpFFieldAssignees,
    _ => field,
  };
}

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
    title: Text(
      context.l10n.grpFConflictTitle(fieldLabel(field, context.l10n)),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.grpFTheirs),
        Text(
          theirs.isEmpty ? context.l10n.grpFEmpty : theirs,
          key: const Key('theirs'),
        ),
        const SizedBox(height: 12),
        Text(context.l10n.grpFYours),
        Text(
          mine.isEmpty ? context.l10n.grpFEmpty : mine,
          key: const Key('mine'),
        ),
      ],
    ),
    actions: [
      TextButton(
        key: const Key('take-theirs'),
        onPressed: () => Navigator.pop(context, false),
        child: Text(context.l10n.grpFTakeTheirs),
      ),
      FilledButton(
        key: const Key('keep-mine'),
        onPressed: () => Navigator.pop(context, true),
        child: Text(context.l10n.grpFKeepMine),
      ),
    ],
  );
}
