import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/work/toolbar_parts.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// Sort: one entry per column that can be sorted, the arrow shows the way.
class ListSortMenu extends ConsumerWidget {
  const ListSortMenu({
    super.key,
    required this.projectId,
    required this.lookups,
  });

  final String projectId;
  final ListLookups lookups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final layout = ref.watch(listLayoutProvider(projectId)).layout;
    final notifier = ref.read(listLayoutProvider(projectId).notifier);
    String name(String key) =>
        key == 'title' ? l10n.grpDTitle : lookups.columnLabel(key, l10n);
    String arrow(String key) {
      final i = layout.sort.indexWhere((s) => s.key == key);
      return i < 0 ? '' : (layout.sort[i].desc ? '  ↓' : '  ↑');
    }

    return ToolbarMenu(
      key: const Key('sort-menu'),
      icon: TfIcons.sort,
      active: layout.sort.isNotEmpty,
      label: layout.sort.isEmpty
          ? l10n.grpDSort
          : l10n.grpDSortBy(layout.sort.map((s) => name(s.key)).join(', ')),
      items: [
        TfMenuItem(
          label: l10n.grpDNoSort,
          onSelected: () => notifier.update((l) => l.copyWith(sort: const [])),
        ),
        for (final key in ['title', ...layout.columns])
          if (lookups.sortable(key))
            TfMenuItem(
              key: Key('sort-$key'),
              label: '${name(key)}${arrow(key)}',
              onSelected: () => notifier.update((l) => l.sortedBy(key)),
            ),
      ],
    );
  }
}

/// Group: none, or one of the fields a list can be grouped by.
class ListGroupMenu extends ConsumerWidget {
  const ListGroupMenu({
    super.key,
    required this.projectId,
    required this.lookups,
  });

  final String projectId;
  final ListLookups lookups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final layout = ref.watch(listLayoutProvider(projectId)).layout;
    final notifier = ref.read(listLayoutProvider(projectId).notifier);
    final choices = lookups.groupChoicesFor(l10n);
    final current = choices.where((g) => g.key == layout.groupBy).firstOrNull;
    return ToolbarMenu(
      key: const Key('group-menu'),
      icon: TfIcons.rows,
      active: layout.groupBy.isNotEmpty,
      label: layout.groupBy.isEmpty
          ? l10n.grpDGroup
          : l10n.grpDGroupBy(current?.label ?? ''),
      items: [
        TfMenuItem(
          key: const Key('group-by-none'),
          label: l10n.grpDNoGrouping,
          selected: layout.groupBy.isEmpty,
          onSelected: () => notifier.update((l) => l.groupedBy('')),
        ),
        for (final g in choices)
          TfMenuItem(
            key: Key('group-by-${g.key}'),
            label: g.label,
            selected: layout.groupBy == g.key,
            onSelected: () => notifier.update((l) => l.groupedBy(g.key)),
          ),
      ],
    );
  }
}

/// Fields: which columns show, and a reset of columns and their widths.
class ListFieldsMenu extends ConsumerWidget {
  const ListFieldsMenu({
    super.key,
    required this.projectId,
    required this.lookups,
  });

  final String projectId;
  final ListLookups lookups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final layout = ref.watch(listLayoutProvider(projectId)).layout;
    final notifier = ref.read(listLayoutProvider(projectId).notifier);
    return ToolbarMenu(
      key: const Key('columns-menu'),
      icon: TfIcons.columns,
      label: l10n.grpDColumns,
      items: [
        for (final key in [
          ...builtInColumns.keys,
          for (final f in lookups.fields) '$fieldColumnPrefix${f.id}',
        ])
          TfMenuItem(
            key: Key('column-$key'),
            label: lookups.columnLabel(key, l10n),
            selected: layout.columns.contains(key),
            onSelected: () => notifier.update(
              (l) => l.withColumn(key, shown: !l.columns.contains(key)),
            ),
          ),
        TfMenuItem(
          key: const Key('columns-reset'),
          label: l10n.wvResetColumns,
          onSelected: () => notifier.update(
            (l) => l.copyWith(columns: defaultColumns, widths: const {}),
          ),
        ),
      ],
    );
  }
}
