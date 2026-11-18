import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/tasks/presentation/work/toolbar_parts.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// The saved layouts of a project: use a shared one, reset, share the one in
/// use, and (for those who may) delete a shared one.
class LayoutsMenu extends ConsumerWidget {
  const LayoutsMenu({
    super.key,
    required this.projectId,
    required this.canShare,
  });

  final String projectId;
  final bool canShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(listLayoutProvider(projectId));
    final notifier = ref.read(listLayoutProvider(projectId).notifier);
    return ToolbarMenu(
      key: const Key('layouts-menu'),
      icon: TfIcons.bookmark,
      label: l10n.grpDLayouts,
      items: [
        for (final v in state.shared)
          TfMenuItem(
            key: Key('shared-${v.id}'),
            icon: TfIcons.users,
            label: v.name,
            onSelected: () => notifier.useShared(v),
          ),
        TfMenuItem(
          key: const Key('layout-reset'),
          label: l10n.grpDResetLayout,
          onSelected: () => notifier.set(const ListLayout()),
        ),
        if (canShare)
          TfMenuItem(
            key: const Key('layout-share'),
            label: l10n.grpDShareLayoutMenu,
            onSelected: () => shareLayout(context, notifier),
          ),
        if (canShare)
          for (final v in state.shared)
            TfMenuItem(
              key: Key('shared-delete-${v.id}'),
              icon: TfIcons.trash,
              danger: true,
              label: l10n.grpDDeleteShared(v.name),
              onSelected: () => deleteLayout(context, notifier, v),
            ),
      ],
    );
  }
}

/// Asks for a name, then shares the layout in use under it.
Future<void> shareLayout(
  BuildContext context,
  ListLayoutNotifier notifier,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final name = await showDialog<String>(
    context: context,
    builder: (_) => const _NameDialog(),
  );
  if (name == null) return;
  try {
    await notifier.shareCurrent(name);
    messenger.showSnackBar(SnackBar(content: Text(l10n.grpDSharedNamed(name))));
  } on ViewException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(viewErrorMessage(e, l10n))));
  }
}

/// Asks to be sure, then removes a shared layout for everyone.
Future<void> deleteLayout(
  BuildContext context,
  ListLayoutNotifier notifier,
  SavedView view,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final sure = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.grpDDeleteSharedTitle(view.name)),
      content: Text(l10n.grpDDeleteSharedBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog, false),
          child: Text(l10n.grpDCancel),
        ),
        FilledButton(
          key: const Key('layout-delete-confirm'),
          onPressed: () => Navigator.pop(dialog, true),
          child: Text(l10n.grpDDelete),
        ),
      ],
    ),
  );
  if (sure != true) return;
  try {
    await notifier.deleteShared(view);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.grpDDeletedNamed(view.name))),
    );
  } on ViewException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(viewErrorMessage(e, l10n))));
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpDShareLayoutTitle),
    content: TextField(
      key: const Key('layout-name'),
      controller: _controller,
      autofocus: true,
      maxLength: 60,
      decoration: InputDecoration(labelText: context.l10n.grpDName),
      onSubmitted: (_) => _done(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpDCancel),
      ),
      FilledButton(
        key: const Key('layout-share-confirm'),
        onPressed: _done,
        child: Text(context.l10n.grpDShare),
      ),
    ],
  );
}
