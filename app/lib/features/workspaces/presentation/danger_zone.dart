import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
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
    final typed = await showDialog<String>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(name: workspace.name),
    );
    if (typed == null) return;
    try {
      await notifier.delete(workspace, typed);
    } on WorkspaceException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(workspaceErrorMessage(e))));
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
                SnackBar(content: Text(workspaceErrorMessage(e))),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.grpJDangerZone,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.grpJDangerZoneBody),
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('delete-workspace'),
            style: OutlinedButton.styleFrom(foregroundColor: color),
            onPressed: () => _delete(context, ref),
            child: Text(context.l10n.grpJDeleteWorkspace),
          ),
        ],
      ),
    );
  }
}

class _ConfirmDeleteDialog extends StatefulWidget {
  const _ConfirmDeleteDialog({required this.name});

  final String name;

  @override
  State<_ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<_ConfirmDeleteDialog> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.grpJDeleteWorkspaceQ),
      content: TextField(
        key: const Key('confirm-name'),
        controller: _typed,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: context.l10n.grpJTypeNameToConfirm(widget.name),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          key: const Key('confirm-delete'),
          onPressed: _typed.text == widget.name
              ? () => Navigator.pop(context, _typed.text)
              : null,
          child: Text(context.l10n.grpJDelete),
        ),
      ],
    );
  }
}
