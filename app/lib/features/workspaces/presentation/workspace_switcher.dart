import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

/// Width from which the switcher is a dropdown rather than a bottom sheet.
const desktopBreakpoint = 1024.0;

/// App-bar title: the current workspace's name, tapping it lists all of them.
class WorkspaceSwitcher extends ConsumerWidget {
  const WorkspaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentWorkspaceProvider);
    final all = ref.watch(workspacesProvider).value ?? const <Workspace>[];
    if (current == null) return const Text('TaskForge');
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(current.name, overflow: TextOverflow.ellipsis)),
        const Icon(Icons.arrow_drop_down),
      ],
    );
    void select(String id) =>
        ref.read(selectedWorkspaceIdProvider.notifier).select(id);

    if (MediaQuery.sizeOf(context).width >= desktopBreakpoint) {
      return PopupMenuButton<String>(
        key: const Key('workspace-switcher'),
        tooltip: 'Switch workspace',
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
          const PopupMenuItem(
            key: Key('new-workspace'),
            value: _newId,
            child: Text('Create workspace'),
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
                title: const Text('Create workspace'),
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
