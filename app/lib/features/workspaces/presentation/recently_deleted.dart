import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

/// Deleted workspaces still restorable (7 days). Renders nothing when there are none.
class RecentlyDeleted extends ConsumerWidget {
  const RecentlyDeleted({super.key});

  Future<void> _restore(BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(workspacesProvider.notifier).restore(id);
    } on WorkspaceException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(workspaceErrorMessage(e, l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleted = ref.watch(deletedWorkspacesProvider).value ?? const [];
    if (deleted.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.grpJRecentlyDeleted,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final w in deleted)
            ListTile(
              key: Key('deleted-${w.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(w.name),
              trailing: OutlinedButton(
                key: Key('restore-${w.id}'),
                onPressed: () => _restore(context, ref, w.id),
                child: Text(context.l10n.grpJRestore),
              ),
            ),
        ],
      ),
    );
  }
}
