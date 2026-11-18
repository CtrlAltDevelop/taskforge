import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

/// Asks what becomes of the subtasks of [task] when it is deleted. Null when
/// cancelled.
Future<DeleteMode?> askDeleteMode(
  BuildContext context,
  Task task,
  int subtaskCount,
) => showDialog<DeleteMode>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(context.l10n.grpFDeleteTaskTitle(task.displayId)),
    content: Text(
      context.l10n.grpFDeleteSubtasksExplain(subtaskCount),
      key: const Key('delete-mode-explain'),
    ),
    actions: [
      TextButton(
        key: const Key('delete-mode-cancel'),
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      OutlinedButton(
        key: const Key('delete-mode-promote'),
        onPressed: () => Navigator.pop(context, DeleteMode.promote),
        child: Text(context.l10n.grpFKeepSubtasks),
      ),
      FilledButton(
        key: const Key('delete-mode-subtree'),
        onPressed: () => Navigator.pop(context, DeleteMode.subtree),
        child: Text(context.l10n.grpFDeleteThemToo),
      ),
    ],
  ),
);

/// What to do with the open subtasks of a task being completed.
enum CompleteChoice { all, leave }

/// A task is being moved to a finished status while [open] subtasks are still
/// open: complete them too, or leave them open. Null when cancelled.
Future<CompleteChoice?> askCompleteSubtasks(
  BuildContext context,
  Task task,
  int open,
  String statusName,
) => showDialog<CompleteChoice>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(context.l10n.grpFOpenSubtasksTitle(task.displayId)),
    content: Text(
      context.l10n.grpFOpenSubtasksExplain(open, statusName),
      key: const Key('complete-explain'),
    ),
    actions: [
      TextButton(
        key: const Key('complete-cancel'),
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      OutlinedButton(
        key: const Key('leave-open'),
        onPressed: () => Navigator.pop(context, CompleteChoice.leave),
        child: Text(context.l10n.grpFLeaveOpen),
      ),
      FilledButton(
        key: const Key('complete-all'),
        onPressed: () => Navigator.pop(context, CompleteChoice.all),
        child: Text(context.l10n.grpFCompleteAll),
      ),
    ],
  ),
);

/// Where to put [task]: any task that is not itself or under itself (and not
/// so deep that the subtree would pass the app's depth limit), or the top
/// level. Returns the chosen parent's id, `''` for the top level, null when
/// cancelled.
Future<String?> pickParent(BuildContext context, TaskTree tree, Task task) =>
    showDialog<String>(
      context: context,
      builder: (context) {
        final candidates = tree.candidateParents(task.id);
        return AlertDialog(
          title: Text(context.l10n.grpFMoveUnderTitle(task.displayId)),
          content: SizedBox(
            width: 420,
            height: 360,
            child: ListView(
              key: const Key('pick-parent-list'),
              children: [
                if (task.parentId.isNotEmpty)
                  ListTile(
                    key: const Key('pick-parent-top'),
                    leading: const TfIcon(TfIcons.arrowUpToLine),
                    title: Text(context.l10n.grpFTopLevel),
                    onTap: () => Navigator.pop(context, ''),
                  ),
                for (final t in candidates)
                  if (t.id != task.parentId)
                    ListTile(
                      key: Key('pick-parent-${t.id}'),
                      contentPadding: EdgeInsetsDirectional.only(
                        start: 16.0 + t.depth * 16,
                      ),
                      title: Text(
                        '${t.displayId}  ${t.title}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.pop(context, t.id),
                    ),
                if (candidates.where((t) => t.id != task.parentId).isEmpty &&
                    task.parentId.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      context.l10n.grpFNoOtherParent,
                      key: const Key('pick-parent-none'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              key: const Key('pick-parent-cancel'),
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
          ],
        );
      },
    );
