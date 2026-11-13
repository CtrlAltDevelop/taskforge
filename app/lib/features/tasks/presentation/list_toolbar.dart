import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Sort, group, columns, layouts and refresh for the list. On a phone this is
/// the only way to sort and group (there are no column headers).
class ListToolbar extends ConsumerWidget {
  const ListToolbar({
    super.key,
    required this.projectId,
    required this.lookups,
    required this.canShare,
  });

  final String projectId;
  final ListLookups lookups;

  /// May save layouts for the whole project (`project.update`).
  final bool canShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(listLayoutProvider(projectId));
    final layout = state.layout;
    final notifier = ref.read(listLayoutProvider(projectId).notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        key: const Key('list-toolbar'),
        children: [
          PopupMenuButton<String>(
            key: const Key('sort-menu'),
            tooltip: l10n.grpDSort,
            onSelected: (key) => key.isEmpty
                ? notifier.update((l) => l.copyWith(sort: const []))
                : notifier.update((l) => l.sortedBy(key)),
            itemBuilder: (_) => [
              PopupMenuItem(value: '', child: Text(l10n.grpDNoSort)),
              for (final key in ['title', ...layout.columns])
                if (lookups.sortable(key))
                  PopupMenuItem(
                    key: Key('sort-$key'),
                    value: key,
                    child: Text(
                      '${key == 'title' ? l10n.grpDTitle : lookups.columnLabel(key, l10n)}'
                      '${_arrow(layout, key)}',
                    ),
                  ),
            ],
            child: _Chip(
              icon: Icons.sort,
              label: layout.sort.isEmpty
                  ? l10n.grpDSort
                  : l10n.grpDSortBy(
                      layout.sort
                          .map(
                            (s) => _name(lookups, s.key, l10n.grpDTitle, l10n),
                          )
                          .join(', '),
                    ),
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('group-menu'),
            tooltip: l10n.grpDGroup,
            onSelected: (key) => notifier.update((l) => l.groupedBy(key)),
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                key: const Key('group-by-none'),
                value: '',
                checked: layout.groupBy.isEmpty,
                child: Text(l10n.grpDNoGrouping),
              ),
              for (final g in lookups.groupChoicesFor(context.l10n))
                CheckedPopupMenuItem(
                  key: Key('group-by-${g.key}'),
                  value: g.key,
                  checked: layout.groupBy == g.key,
                  child: Text(g.label),
                ),
            ],
            child: _Chip(
              icon: Icons.view_agenda_outlined,
              label: layout.groupBy.isEmpty
                  ? l10n.grpDGroup
                  : l10n.grpDGroupBy(_groupName(lookups, layout.groupBy)),
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('columns-menu'),
            tooltip: l10n.grpDColumns,
            onSelected: (key) => notifier.update(
              (l) => l.withColumn(key, shown: !l.columns.contains(key)),
            ),
            itemBuilder: (_) => [
              for (final key in [
                ...builtInColumns.keys,
                for (final f in lookups.fields) '$fieldColumnPrefix${f.id}',
              ])
                CheckedPopupMenuItem(
                  key: Key('column-$key'),
                  value: key,
                  checked: layout.columns.contains(key),
                  child: Text(lookups.columnLabel(key, context.l10n)),
                ),
            ],
            child: _Chip(
              icon: Icons.view_column_outlined,
              label: l10n.grpDColumns,
            ),
          ),
          _LayoutsMenu(projectId: projectId, state: state, canShare: canShare),
          IconButton(
            key: const Key('refresh-tasks'),
            tooltip: l10n.grpDRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(taskListProvider(projectId).notifier).refresh(),
          ),
          if (state.saveFailed)
            Tooltip(
              message: l10n.grpDLayoutNotSaved,
              child: const Icon(
                Icons.warning_amber,
                key: Key('layout-not-saved'),
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  static String _arrow(ListLayout layout, String key) {
    final i = layout.sort.indexWhere((s) => s.key == key);
    if (i < 0) return '';
    return layout.sort[i].desc ? '  ↓' : '  ↑';
  }

  static String _name(
    ListLookups lookups,
    String key,
    String titleLabel, [
    AppLocalizations? l10n,
  ]) => key == 'title' ? titleLabel : lookups.columnLabel(key, l10n);

  static String _groupName(ListLookups lookups, String key) =>
      lookups.groupChoices.where((g) => g.key == key).firstOrNull?.label ?? '';
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    // The menu button around it is the one tab stop; a chip would add a second
    // that does nothing.
    child: ExcludeFocus(
      child: Chip(avatar: Icon(icon, size: 18), label: Text(label)),
    ),
  );
}

enum _LayoutAction { reset, shareNew }

/// The choice to remove a shared layout for everyone.
class _DeleteShared {
  const _DeleteShared(this.view);

  final SavedView view;
}

class _LayoutsMenu extends ConsumerWidget {
  const _LayoutsMenu({
    required this.projectId,
    required this.state,
    required this.canShare,
  });

  final String projectId;
  final LayoutState state;
  final bool canShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(listLayoutProvider(projectId).notifier);
    return PopupMenuButton<Object>(
      key: const Key('layouts-menu'),
      tooltip: l10n.grpDLayouts,
      onSelected: (choice) async {
        switch (choice) {
          case _LayoutAction.reset:
            notifier.set(const ListLayout());
          case _LayoutAction.shareNew:
            await _share(context, notifier);
          case SavedView view:
            notifier.useShared(view);
          case _DeleteShared(:final view):
            await _delete(context, notifier, view);
        }
      },
      itemBuilder: (_) => [
        for (final v in state.shared)
          PopupMenuItem<Object>(
            key: Key('shared-${v.id}'),
            value: v,
            child: Row(
              children: [
                const Icon(Icons.group_outlined, size: 18),
                const SizedBox(width: 8),
                Text(v.name),
              ],
            ),
          ),
        if (state.shared.isNotEmpty) const PopupMenuDivider(),
        PopupMenuItem<Object>(
          key: const Key('layout-reset'),
          value: _LayoutAction.reset,
          child: Text(l10n.grpDResetLayout),
        ),
        if (canShare)
          PopupMenuItem<Object>(
            key: const Key('layout-share'),
            value: _LayoutAction.shareNew,
            child: Text(l10n.grpDShareLayoutMenu),
          ),
        if (canShare)
          for (final v in state.shared)
            PopupMenuItem<Object>(
              key: Key('shared-delete-${v.id}'),
              value: _DeleteShared(v),
              child: Text(l10n.grpDDeleteShared(v.name)),
            ),
      ],
      child: _Chip(icon: Icons.bookmarks_outlined, label: l10n.grpDLayouts),
    );
  }

  Future<void> _delete(
    BuildContext context,
    ListLayoutNotifier notifier,
    SavedView view,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.grpDDeleteSharedTitle(view.name)),
        content: Text(l10n.grpDDeleteSharedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.grpDCancel),
          ),
          FilledButton(
            key: const Key('layout-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
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
      messenger.showSnackBar(
        SnackBar(content: Text(viewErrorMessage(e, l10n))),
      );
    }
  }

  Future<void> _share(BuildContext context, ListLayoutNotifier notifier) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(),
    );
    if (name == null) return;
    try {
      await notifier.shareCurrent(name);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.grpDSharedNamed(name))),
      );
    } on ViewException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(viewErrorMessage(e, l10n))),
      );
    }
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
