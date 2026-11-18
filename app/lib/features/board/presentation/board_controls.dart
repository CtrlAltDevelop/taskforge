import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/work/toolbar_parts.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// What the columns come from (the board's "Group").
class BoardColumnsMenu extends ConsumerWidget {
  const BoardColumnsMenu({
    super.key,
    required this.projectId,
    required this.lookups,
  });

  final String projectId;
  final ListLookups lookups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final layout = ref.watch(boardLayoutProvider(projectId)).layout;
    final notifier = ref.read(boardLayoutProvider(projectId).notifier);
    final choices = lookups.groupChoicesFor(l10n);
    return ToolbarMenu(
      key: const Key('board-group-menu'),
      icon: TfIcons.columns,
      label: l10n.grpFColumnsChip(
        choices.where((g) => g.key == layout.groupBy).firstOrNull?.label ??
            l10n.grpFStatus,
      ),
      items: [
        for (final g in choices)
          TfMenuItem(
            key: Key('board-group-${g.key}'),
            label: g.label,
            selected: layout.groupBy == g.key,
            onSelected: () =>
                notifier.update((l) => l.copyWith(groupBy: g.key)),
          ),
      ],
    );
  }
}

/// What a card shows (the board's "Fields").
class BoardFieldsMenu extends ConsumerWidget {
  const BoardFieldsMenu({
    super.key,
    required this.projectId,
    required this.lookups,
  });

  final String projectId;
  final ListLookups lookups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final layout = ref.watch(boardLayoutProvider(projectId)).layout;
    final notifier = ref.read(boardLayoutProvider(projectId).notifier);
    return ToolbarMenu(
      key: const Key('board-fields-menu'),
      icon: TfIcons.tune,
      label: l10n.grpFCardFields,
      items: [
        for (final key in [
          ...builtInCardFields.keys,
          for (final f in lookups.fields) '$fieldColumnPrefix${f.id}',
        ])
          TfMenuItem(
            key: Key('card-field-$key'),
            label:
                builtInCardFieldLabelIn(l10n, key) ??
                lookups.columnLabel(key, l10n),
            selected: layout.cardFields.contains(key),
            onSelected: () => notifier.update(
              (l) => l.withCardField(key, shown: !l.cardFields.contains(key)),
            ),
          ),
      ],
    );
  }
}

/// The board's own controls: swimlanes, the current sprint, refresh and the
/// mark for a layout that could not be saved.
List<Widget> boardSpecificControls(
  BuildContext context,
  WidgetRef ref,
  String projectId, {
  required bool sprintFilter,
}) {
  final l10n = context.l10n;
  final state = ref.watch(boardLayoutProvider(projectId));
  final notifier = ref.read(boardLayoutProvider(projectId).notifier);
  return [
    ToolbarMenu(
      key: const Key('board-lane-menu'),
      icon: TfIcons.rows,
      active: state.layout.swimlane.isNotEmpty,
      label: state.layout.swimlane.isEmpty
          ? l10n.grpFSwimlanes
          : l10n.grpFLanesAssignee,
      items: [
        TfMenuItem(
          key: const Key('board-lane-none'),
          label: l10n.grpFNoSwimlanes,
          selected: state.layout.swimlane.isEmpty,
          onSelected: () => notifier.update((l) => l.copyWith(swimlane: '')),
        ),
        TfMenuItem(
          key: const Key('board-lane-assignee'),
          label: l10n.grpFByAssignee,
          selected: state.layout.swimlane == 'assignee',
          onSelected: () =>
              notifier.update((l) => l.copyWith(swimlane: 'assignee')),
        ),
      ],
    ),
    if (sprintFilter)
      // A Material FilterChip: board_sprint_filter_test reads its `selected`.
      FilterChip(
        key: const Key('board-sprint-filter'),
        avatar: const TfIcon(TfIcons.clock),
        label: Text(l10n.grpFCurrentSprint),
        selected: ref.watch(boardCurrentSprintProvider(projectId)),
        onSelected: (on) => ref
            .read(boardCurrentSprintProvider(projectId).notifier)
            .set(on: on),
      ),
    ToolbarIcon(
      key: const Key('board-refresh'),
      icon: TfIcons.refresh,
      tooltip: l10n.grpFRefresh,
      onPressed: () => ref.read(boardProvider(projectId).notifier).refresh(),
    ),
    if (state.saveFailed)
      SaveFailedMark(
        message: l10n.grpFBoardLayoutNotSaved,
        markKey: const Key('board-layout-not-saved'),
      ),
  ];
}
