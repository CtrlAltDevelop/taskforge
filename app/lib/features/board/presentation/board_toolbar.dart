import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// What the columns come from, the swimlanes, what a card shows, and refresh.
class BoardToolbar extends ConsumerWidget {
  const BoardToolbar({
    super.key,
    required this.projectId,
    required this.lookups,
  });

  final String projectId;
  final ListLookups lookups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(boardLayoutProvider(projectId));
    final layout = state.layout;
    final notifier = ref.read(boardLayoutProvider(projectId).notifier);
    final choices = lookups.groupChoices;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        key: const Key('board-toolbar'),
        children: [
          PopupMenuButton<String>(
            key: const Key('board-group-menu'),
            tooltip: 'Columns by',
            onSelected: (key) =>
                notifier.update((l) => l.copyWith(groupBy: key)),
            itemBuilder: (_) => [
              for (final g in choices)
                CheckedPopupMenuItem(
                  key: Key('board-group-${g.key}'),
                  value: g.key,
                  checked: layout.groupBy == g.key,
                  child: Text(g.label),
                ),
            ],
            child: _Chip(
              icon: Icons.view_column_outlined,
              label:
                  'Columns: ${choices.where((g) => g.key == layout.groupBy).firstOrNull?.label ?? 'Status'}',
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('board-lane-menu'),
            tooltip: 'Swimlanes',
            onSelected: (key) =>
                notifier.update((l) => l.copyWith(swimlane: key)),
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                key: const Key('board-lane-none'),
                value: '',
                checked: layout.swimlane.isEmpty,
                child: const Text('No swimlanes'),
              ),
              CheckedPopupMenuItem(
                key: const Key('board-lane-assignee'),
                value: 'assignee',
                checked: layout.swimlane == 'assignee',
                child: const Text('By assignee'),
              ),
            ],
            child: _Chip(
              icon: Icons.table_rows_outlined,
              label: layout.swimlane.isEmpty ? 'Swimlanes' : 'Lanes: assignee',
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('board-fields-menu'),
            tooltip: 'Card fields',
            onSelected: (key) => notifier.update(
              (l) => l.withCardField(key, shown: !l.cardFields.contains(key)),
            ),
            itemBuilder: (_) => [
              for (final key in [
                ...builtInCardFields.keys,
                for (final f in lookups.fields) '$fieldColumnPrefix${f.id}',
              ])
                CheckedPopupMenuItem(
                  key: Key('card-field-$key'),
                  value: key,
                  checked: layout.cardFields.contains(key),
                  child: Text(
                    builtInCardFields[key] ?? lookups.columnLabel(key),
                  ),
                ),
            ],
            child: const _Chip(icon: Icons.tune, label: 'Card fields'),
          ),
          IconButton(
            key: const Key('board-refresh'),
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(boardProvider(projectId).notifier).refresh(),
          ),
          if (state.saveFailed)
            const Tooltip(
              message:
                  'Your board layout could not be saved. It will be tried '
                  'again on your next change.',
              child: Icon(
                Icons.warning_amber,
                key: Key('board-layout-not-saved'),
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    // The menu button around it is the one tab stop.
    child: ExcludeFocus(
      child: Chip(avatar: Icon(icon, size: 18), label: Text(label)),
    ),
  );
}
