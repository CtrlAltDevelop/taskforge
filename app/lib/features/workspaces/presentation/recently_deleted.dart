import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
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
      padding: const EdgeInsets.only(top: TfSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TfSectionHeader(title: context.l10n.grpJRecentlyDeleted),
          for (final w in deleted)
            Padding(
              padding: const EdgeInsets.only(bottom: TfSpace.xs),
              child: TfPanel(
                padding: EdgeInsets.zero,
                child: TfRow(
                  key: Key('deleted-${w.id}'),
                  title: w.name,
                  trailing: TfButton(
                    key: Key('restore-${w.id}'),
                    label: context.l10n.grpJRestore,
                    onPressed: () => _restore(context, ref, w.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
