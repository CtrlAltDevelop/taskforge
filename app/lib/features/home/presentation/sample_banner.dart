import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// Deletes the person's sample tasks (they go to the trash; the project
/// stays) and refreshes everything that showed them. Returns whether it worked.
Future<bool> deleteSampleTasks(BuildContext context, WidgetRef ref) async {
  final ws = ref.read(workspaceScopeProvider);
  if (ws == null) return false;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l = context.l10n;
  final project = ref.read(onboardingProvider).value?.sampleProjectId ?? '';
  try {
    await ref.read(onboardingClientProvider).deleteSamples(ws);
  } on Object {
    messenger?.showSnackBar(SnackBar(content: Text(l.sampleDeleteFailed)));
    return false;
  }
  ref.invalidate(onboardingProvider);
  ref.invalidate(homeSummaryProvider);
  ref.invalidate(homeAssignedProvider);
  if (project.isNotEmpty) ref.invalidate(taskListProvider(project));
  messenger?.showSnackBar(SnackBar(content: Text(l.sampleDeleted)));
  return true;
}

/// "This project has sample tasks": one click removes them. Shows while the
/// workspace still has any; [projectId] limits it to the sample project's own
/// page.
class SampleBanner extends ConsumerWidget {
  const SampleBanner({super.key, this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider).value;
    if (state == null || state.sampleCount == 0) return const SizedBox.shrink();
    if (projectId != null && projectId != state.sampleProjectId) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: TfSpace.md),
      child: TfBanner(
        key: const Key('sample-banner'),
        message: l.sampleBanner,
        actionLabel: l.sampleDelete,
        actionKey: const Key('delete-samples'),
        onAction: () => deleteSampleTasks(context, ref),
      ),
    );
  }
}
