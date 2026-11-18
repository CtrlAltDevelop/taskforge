import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';

/// Asks for a new name and saves it; nothing happens on cancel.
Future<void> renameProject(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _RenameDialog(initial: project.name),
  );
  if (name == null || name == project.name || !context.mounted) return;
  await runProjectAction(
    context,
    () => ref.read(projectsControllerProvider).update(project, name: name),
  );
}

/// Asks, then archives [project] (it leaves the sidebar).
Future<void> archiveProject(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final l = context.l10n;
  final ok = await showTfDialog<bool>(
    context,
    title: l.grpHArchiveTitle(project.name),
    body: Text(l.grpHArchiveBody),
    actions: [
      Builder(
        builder: (c) => TfButton(
          label: l.cancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(c).pop(false),
        ),
      ),
      Builder(
        builder: (c) => TfButton(
          key: const Key('confirm-archive'),
          label: l.grpHArchive,
          variant: TfButtonVariant.danger,
          onPressed: () => Navigator.of(c).pop(true),
        ),
      ),
    ],
  );
  if (ok != true || !context.mounted) return;
  await runProjectAction(
    context,
    () => ref.read(projectsControllerProvider).archive(project),
  );
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final error = validateProjectName(_name.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.shellRenameProject),
      content: TfTextField(
        key: const Key('rename-project-field'),
        controller: _name,
        label: l.grpHName,
        errorText: _error,
        autofocus: true,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TfButton(
          label: l.cancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TfButton(
          key: const Key('rename-project-save'),
          label: l.save,
          variant: TfButtonVariant.primary,
          onPressed: _save,
        ),
      ],
    );
  }
}
