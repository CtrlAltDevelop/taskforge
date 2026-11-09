import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(title: Text('${project.name} · Trash')),
      body: switch (trash) {
        AsyncData(:final value) when value.isEmpty => const Center(
          child: Text('The trash is empty.', key: Key('trash-empty')),
        ),
        AsyncData(:final value) => ListView(
          key: const Key('trash-list'),
          children: [
            for (final task in value)
              ListTile(
                key: Key('trashed-${task.id}'),
                title: Text(task.title),
                subtitle: Text('${task.displayId} · deleted'),
                trailing: TextButton(
                  key: Key('restore-${task.id}'),
                  onPressed: project.isArchived
                      ? null
                      : () => _restore(context, ref, task),
                  child: const Text('Restore'),
                ),
              ),
          ],
        ),
        AsyncError(:final error) => Center(
          child: TextButton(
            key: const Key('retry-trash'),
            onPressed: () => ref.invalidate(taskTrashProvider(project.id)),
            child: Text('${taskErrorMessage(mapTrashError(error))} Retry'),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref, Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(taskListProvider(project.id).notifier).restore(task);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${task.displayId} restored')));
    } on TaskException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
    }
  }
}

/// A failed trash read as a [TaskException] (anything else is "other").
TaskException mapTrashError(Object error) =>
    error is TaskException ? error : const TaskException(TaskFailure.other);
