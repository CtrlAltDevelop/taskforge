import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

/// The deleted tasks of a project, with Restore. Anyone who may delete tasks
/// may restore them; an archived project is read-only, so it cannot.
class TaskTrashScreen extends ConsumerWidget {
  const TaskTrashScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trash = ref.watch(taskTrashProvider(project.id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.grpFTrashTitle(project.name))),
      body: switch (trash) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(
            context.l10n.grpFTrashEmpty,
            key: const Key('trash-empty'),
          ),
        ),
        AsyncData(:final value) => ListView(
          key: const Key('trash-list'),
          children: [
            for (final task in value)
              ListTile(
                key: Key('trashed-${task.id}'),
                title: Text(task.title),
                subtitle: Text(context.l10n.grpFTrashedRow(task.displayId)),
                trailing: TextButton(
                  key: Key('restore-${task.id}'),
                  onPressed: project.isArchived
                      ? null
                      : () => _restore(context, ref, task),
                  child: Text(context.l10n.grpFRestore),
                ),
              ),
          ],
        ),
        AsyncError(:final error) => Center(
          child: TextButton(
            key: const Key('retry-trash'),
            onPressed: () => ref.invalidate(taskTrashProvider(project.id)),
            child: Text(
              context.l10n.grpFErrorRetry(
                taskErrorMessage(mapTrashError(error), context.l10n),
              ),
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref, Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(taskListProvider(project.id).notifier).restore(task);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.grpFTaskRestored(task.displayId))),
        );
    } on TaskException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(taskErrorMessage(e, l10n))),
      );
    }
  }
}

/// A failed trash read as a [TaskException] (anything else is "other").
TaskException mapTrashError(Object error) =>
    error is TaskException ? error : const TaskException(TaskFailure.other);
