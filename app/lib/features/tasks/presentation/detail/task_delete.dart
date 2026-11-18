import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/subtask_dialogs.dart';
import 'package:taskforge/features/recurrence/presentation/repeat_section.dart'
    show confirmDeleteTemplate;

/// Deletes [task] after asking what should happen to its subtasks (and to the
/// series a repeating task belongs to). The window closes first; a snack bar
/// offers Undo.
Future<void> deleteTaskFlow(
  BuildContext context,
  WidgetRef ref,
  Task task, {
  required VoidCallback close,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final list = ref.read(taskListProvider(task.projectId).notifier);
  final below =
      ref.read(taskTreeProvider(task.projectId)).subtreeIds(task.id).length - 1;
  DeleteMode? mode;
  if (below > 0) {
    mode = await askDeleteMode(context, task, below);
    if (mode == null || !context.mounted) return;
  }
  // Last, so cancelling an earlier question never stops a series.
  if (!await confirmDeleteTemplate(context, ref, task)) return;
  if (!context.mounted) return;
  close();
  try {
    final moved = await list.delete(task, mode: mode);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.grpDTaskDeleted(task.displayId)),
          action: SnackBarAction(
            label: l10n.grpDUndo,
            onPressed: () async {
              try {
                await list.restore(task, adopt: moved);
              } on TaskException catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(taskErrorMessage(e, l10n))),
                );
              }
            },
          ),
        ),
      );
  } on TaskException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
  }
}
