import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/recurrence/application/recurrence_providers.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/recurrence/presentation/repeat_editor.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

/// The "Repeat" chip of a task, and what its series is doing: the rule in
/// words, which instance this is, the next dates, and a paused notice.
class RepeatSection extends ConsumerWidget {
  const RepeatSection({super.key, required this.task, required this.canEdit});

  final Task task;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = (project: task.projectId, task: task.id);
    final series = ref.watch(repeatProvider(target));
    final found = series.value;
    final scheme = Theme.of(context).colorScheme;
    if (series.hasError && found == null) {
      // Not "does not repeat": offering to start a repeat here could replace
      // the one that exists.
      return Row(
        key: const Key('repeat-read-error'),
        children: [
          const Flexible(child: Text('Could not read how this repeats.')),
          TextButton(
            key: const Key('repeat-retry'),
            onPressed: () => ref.invalidate(repeatProvider(target)),
            child: const Text('Retry'),
          ),
        ],
      );
    }
    if (series.isLoading && found == null) return const SizedBox.shrink();
    if (found == null) {
      // Unknown yet or not repeating: offer to start one.
      if (!canEdit) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: ActionChip(
          key: const Key('repeat-chip'),
          avatar: const Icon(Icons.repeat, size: 18),
          label: const Text('Repeat'),
          onPressed: () => showRepeatEditor(context, task: task),
        ),
      );
    }
    return Column(
      key: const Key('repeat-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ActionChip(
              key: const Key('repeat-chip'),
              avatar: Icon(
                found.paused ? Icons.pause_circle_outline : Icons.repeat,
                size: 18,
              ),
              label: Text(found.summary),
              onPressed: canEdit
                  ? () => showRepeatEditor(context, task: task, series: found)
                  : null,
            ),
            Chip(
              key: const Key('series-badge'),
              visualDensity: VisualDensity.compact,
              label: Text(
                found.index == 0 ? 'First of a series' : 'Repeating task',
              ),
            ),
            Text(
              '${found.instanceCount} '
              '${found.instanceCount == 1 ? 'task' : 'tasks'} in this series',
              key: const Key('series-count'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        if (found.paused)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              found.pauseReason.isEmpty
                  ? 'Paused: no new tasks are made.'
                  : 'Paused by the system: ${found.pauseReason}',
              key: const Key('repeat-paused'),
              style: TextStyle(color: scheme.error),
            ),
          )
        else if (found.nextDates.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Next: ${found.nextDates.join(', ')}',
              key: const Key('repeat-next'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else if (found.mode == RepeatKind.afterCompletion)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'The next one is made when this is completed.',
              key: const Key('repeat-waits'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// Asked before a task that is the template of a repeating series is deleted:
/// true to go on (the series was stopped, or is left running), false to cancel.
Future<bool> confirmDeleteTemplate(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  final target = (project: task.projectId, task: task.id);
  RepeatSeries? series;
  try {
    series = await ref.read(repeatProvider(target).future);
  } on Object {
    return true; // cannot tell: do not stand in the way of the delete
  }
  if (series == null || !series.isTemplate || !context.mounted) return true;
  final choice = await showDialog<String>(
    context: context,
    builder: (dialog) => AlertDialog(
      key: const Key('delete-template-dialog'),
      title: const Text('This task repeats'),
      content: Text(
        'It is the template of "${series!.summary}". Deleting it can '
        'stop the series, or the series can keep making new tasks.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('keep-repeating'),
          onPressed: () => Navigator.pop(dialog, 'keep'),
          child: const Text('Delete, keep repeating'),
        ),
        FilledButton(
          key: const Key('stop-series'),
          onPressed: () => Navigator.pop(dialog, 'stop'),
          child: const Text('Delete and stop'),
        ),
      ],
    ),
  );
  if (choice == null) return false;
  if (choice == 'stop') {
    try {
      await ref.read(repeatActionsProvider).clear(target);
    } on RepeatException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(repeatErrorMessage(e))));
      }
      return false;
    }
  }
  return true;
}
