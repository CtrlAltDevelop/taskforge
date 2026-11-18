import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/page/tf_danger_zone.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

class DangerZone extends ConsumerWidget {
  const DangerZone({super.key, required this.workspace});

  final Workspace workspace;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    // Captured before any await: the screen may be gone once this workspace is.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final notifier = ref.read(workspacesProvider.notifier);
    final confirmed = await showTfTypedConfirm(
      context,
      title: l10n.grpJDeleteWorkspaceQ,
      phrase: workspace.name,
      promptLabel: l10n.grpJTypeNameToConfirm(workspace.name),
      confirmLabel: l10n.grpJDelete,
      cancelLabel: l10n.cancel,
      fieldKey: const Key('confirm-name'),
      confirmKey: const Key('confirm-delete'),
    );
    if (!confirmed) return;
    try {
      await notifier.delete(workspace, workspace.name);
    } on WorkspaceException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(workspaceErrorMessage(e, l10n))),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.grpJWorkspaceDeleted(workspace.name)),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: l10n.grpJUndo,
          onPressed: () async {
            try {
              await notifier.restore(workspace.id);
            } on WorkspaceException catch (e) {
              messenger.showSnackBar(
                SnackBar(content: Text(workspaceErrorMessage(e, l10n))),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => TfDangerZone(
    title: context.l10n.grpJDangerZone,
    description: context.l10n.grpJDangerZoneBody,
    actions: [
      TfDangerAction(
        label: context.l10n.grpJDeleteWorkspace,
        buttonKey: const Key('delete-workspace'),
        onPressed: () => _delete(context, ref),
      ),
    ],
  );
}
