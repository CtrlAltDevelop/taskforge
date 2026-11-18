import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';

/// The eye on a task: watching it means hearing about its comments and status
/// changes.
class WatchButton extends ConsumerWidget {
  const WatchButton({super.key, required this.projectId, required this.taskId});

  final String projectId;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ref0 = (project: projectId, task: taskId);
    final state = ref.watch(watchProvider(ref0));
    final watching = state.value?.watching ?? false;
    final tip = watching
        ? context.l10n.grp1StopWatchingTask
        : context.l10n.grp1WatchTask;
    return IconButton(
      key: const Key('watch-toggle'),
      tooltip: tip,
      isSelected: watching,
      icon: const TfIcon(TfIcons.eye),
      selectedIcon: const TfIcon(TfIcons.eye),
      onPressed: state.value == null
          ? null
          : () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              try {
                await ref.read(watchProvider(ref0).notifier).toggle();
              } on Object catch (e) {
                if (!context.mounted) return;
                messenger
                  ?..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(inboxErrorMessage(e, context.l10n))),
                  );
              }
            },
    );
  }
}
