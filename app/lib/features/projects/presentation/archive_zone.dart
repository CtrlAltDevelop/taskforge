import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/application/project_access.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';

/// Archive or restore, for those holding `project.archive`.
class ArchiveZone extends ConsumerWidget {
  const ArchiveZone({super.key, required this.project});

  final Project project;

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(dialog.l10n.grpHArchiveTitle(project.name)),
        content: Text(dialog.l10n.grpHArchiveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(dialog.l10n.grpHCancel),
          ),
          FilledButton(
            key: const Key('confirm-archive'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(dialog.l10n.grpHArchive),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await runProjectAction(
      context,
      () => ref.read(projectsControllerProvider).archive(project),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.error;
    if (!canManageProject(
      ref.watch(permissionSetProvider),
      Perm.projectArchive,
    )) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.grpHDangerZone,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          if (project.isArchived)
            OutlinedButton(
              key: const Key('restore-project'),
              onPressed: () => runProjectAction(
                context,
                () => ref.read(projectsControllerProvider).restore(project),
              ),
              child: Text(context.l10n.grpHRestoreProject),
            )
          else
            OutlinedButton(
              key: const Key('archive-project'),
              style: OutlinedButton.styleFrom(foregroundColor: color),
              onPressed: () => _archive(context, ref),
              child: Text(context.l10n.grpHArchiveProject),
            ),
        ],
      ),
    );
  }
}
