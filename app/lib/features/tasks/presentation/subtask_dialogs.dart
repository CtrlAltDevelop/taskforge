import 'package:flutter/material.dart';

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
    title: Text('Delete ${task.displayId}?'),
    content: Text(
      subtaskCount == 1
          ? 'It has 1 subtask. What should happen to it?'
          : 'It has $subtaskCount subtasks. What should happen to them?',
      key: const Key('delete-mode-explain'),
    ),
    actions: [
      TextButton(
        key: const Key('delete-mode-cancel'),
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      OutlinedButton(
        key: const Key('delete-mode-promote'),
        onPressed: () => Navigator.pop(context, DeleteMode.promote),
        child: const Text('Keep them (move up a level)'),
      ),
      FilledButton(
        key: const Key('delete-mode-subtree'),
        onPressed: () => Navigator.pop(context, DeleteMode.subtree),
        child: const Text('Delete them too'),
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
    title: Text('${task.displayId} has open subtasks'),
    content: Text(
      open == 1
          ? '1 subtask is not finished. Move it to $statusName too?'
          : '$open subtasks are not finished. Move them to $statusName too?',
      key: const Key('complete-explain'),
    ),
    actions: [
      TextButton(
        key: const Key('complete-cancel'),
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      OutlinedButton(
        key: const Key('leave-open'),
        onPressed: () => Navigator.pop(context, CompleteChoice.leave),
        child: const Text('Leave them open'),
      ),
      FilledButton(
        key: const Key('complete-all'),
        onPressed: () => Navigator.pop(context, CompleteChoice.all),
        child: const Text('Complete all'),
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
          title: Text('Move ${task.displayId} under…'),
          content: SizedBox(
            width: 420,
            height: 360,
            child: ListView(
              key: const Key('pick-parent-list'),
              children: [
                if (task.parentId.isNotEmpty)
                  ListTile(
                    key: const Key('pick-parent-top'),
                    leading: const Icon(Icons.vertical_align_top),
                    title: const Text('Top level (no parent)'),
                    onTap: () => Navigator.pop(context, ''),
                  ),
                for (final t in candidates)
                  if (t.id != task.parentId)
                    ListTile(
                      key: Key('pick-parent-${t.id}'),
                      contentPadding: EdgeInsets.only(
                        left: 16.0 + t.depth * 16,
                      ),
                      title: Text(
                        '${t.displayId}  ${t.title}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.pop(context, t.id),
                    ),
                if (candidates.where((t) => t.id != task.parentId).isEmpty &&
                    task.parentId.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'There is no other task to put it under.',
                      key: Key('pick-parent-none'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              key: const Key('pick-parent-cancel'),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
