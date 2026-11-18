import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

/// Width from which the switcher is a dropdown rather than a bottom sheet.
const desktopBreakpoint = ScreenSize.expandedFrom;

/// App-bar title: the current workspace's name, tapping it lists all of them.
class WorkspaceSwitcher extends ConsumerWidget {
  const WorkspaceSwitcher({super.key, this.compact = false});

  /// Only the workspace's avatar (the sidebar's icon strip).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentWorkspaceProvider);
    final all = ref.watch(workspacesProvider).value ?? const <Workspace>[];
    if (current == null) return Text(context.l10n.appTitle);
    // Unread somewhere else: a dot on the switcher says there is more to see.
    final elsewhere =
        (ref.watch(unreadTotalProvider).value ?? 0) -
        (ref.watch(unreadCountProvider).value ?? 0);
    final label = compact
        ? Badge(
            key: const Key('switcher-badge'),
            isLabelVisible: elsewhere > 0,
            label: Text('$elsewhere'),
            child: Tooltip(
              message: current.name,
              child: TfAvatar(name: current.name, size: 28),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(current.name, overflow: TextOverflow.ellipsis),
              ),
              Badge(
                key: const Key('switcher-badge'),
                isLabelVisible: elsewhere > 0,
                label: Text('$elsewhere'),
                child: const Icon(Icons.arrow_drop_down),
              ),
            ],
          );
    void select(String id) =>
        ref.read(selectedWorkspaceIdProvider.notifier).select(id);

    if (MediaQuery.sizeOf(context).width >= desktopBreakpoint) {
      return PopupMenuButton<String>(
        key: const Key('workspace-switcher'),
        tooltip: context.l10n.grpJSwitchWorkspace,
        onSelected: (id) =>
            id == _newId ? context.push('/workspaces/new') : select(id),
        itemBuilder: (_) => [
          for (final w in all)
            CheckedPopupMenuItem(
              key: Key('switch-${w.id}'),
              value: w.id,
              checked: w.id == current.id,
              child: Text(w.name),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(
            key: const Key('new-workspace'),
            value: _newId,
            child: Text(context.l10n.grpJCreateWorkspace),
          ),
        ],
        child: label,
      );
    }
    return InkWell(
      key: const Key('workspace-switcher'),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (sheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final w in all)
                ListTile(
                  key: Key('switch-${w.id}'),
                  title: Text(w.name),
                  trailing: w.id == current.id ? const Icon(Icons.check) : null,
                  onTap: () {
                    select(w.id);
                    Navigator.of(sheet).pop();
                  },
                ),
              ListTile(
                key: const Key('new-workspace'),
                leading: const Icon(Icons.add),
                title: Text(context.l10n.grpJCreateWorkspace),
                onTap: () {
                  Navigator.of(sheet).pop();
                  context.push('/workspaces/new');
                },
              ),
            ],
          ),
        ),
      ),
      child: label,
    );
  }
}

const _newId = '\u0000new';
