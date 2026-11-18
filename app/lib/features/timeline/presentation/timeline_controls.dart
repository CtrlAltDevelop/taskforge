import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/tasks/presentation/work/toolbar_parts.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

Map<TimelineZoom, String> _zoomLabels(AppLocalizations l) => {
  TimelineZoom.day: l.grpIDay,
  TimelineZoom.week: l.grpIWeek,
  TimelineZoom.month: l.grpIMonth,
  TimelineZoom.quarter: l.grpIQuarter,
};

Map<String, String> _groups(AppLocalizations l) => {
  groupNone: l.grpITaskTree,
  groupAssignee: l.grpIByAssignee,
  groupStatus: l.grpIByStatus,
};

/// The timeline's "Group": the task tree, by assignee or by status.
class TimelineGroupMenu extends ConsumerWidget {
  const TimelineGroupMenu({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = _groups(context.l10n);
    final layout = ref.watch(timelineLayoutProvider(projectId)).layout;
    final notifier = ref.read(timelineLayoutProvider(projectId).notifier);
    return ToolbarMenu(
      key: const Key('timeline-group'),
      icon: TfIcons.rows,
      label: groups[layout.groupBy] ?? groups[groupNone]!,
      items: [
        for (final e in groups.entries)
          TfMenuItem(
            label: e.value,
            selected: layout.groupBy == e.key,
            onSelected: () =>
                notifier.update((l) => l.copyWith(groupBy: e.key)),
          ),
      ],
    );
  }
}

/// The timeline's own controls: moving through time, zoom, the critical path,
/// finished tasks, list or chart, export and (for those who may) the working
/// days.
List<Widget> timelineSpecificControls(
  BuildContext context,
  WidgetRef ref,
  String projectId, {
  required bool listMode,
  required ValueChanged<bool> onListMode,
  required VoidCallback onExport,
  VoidCallback? onWorkingDays,
}) {
  final l10n = context.l10n;
  final layout = ref.watch(timelineLayoutProvider(projectId)).layout;
  final notifier = ref.read(timelineLayoutProvider(projectId).notifier);
  final anchor = ref.read(timelineAnchorProvider(projectId).notifier);
  final zoom = zoomOf(layout);
  return [
    ToolbarIcon(
      key: const Key('timeline-prev'),
      icon: TfIcons.chevronStart,
      tooltip: l10n.grpIEarlier,
      onPressed: () => anchor.shift(zoom, -1),
    ),
    TfButton(
      key: const Key('timeline-today'),
      label: l10n.grpIToday,
      size: TfButtonSize.small,
      onPressed: anchor.today,
    ),
    ToolbarIcon(
      key: const Key('timeline-next'),
      icon: TfIcons.chevronEnd,
      tooltip: l10n.grpILater,
      onPressed: () => anchor.shift(zoom, 1),
    ),
    TfSegmented<TimelineZoom>(
      key: const Key('timeline-zoom'),
      scrollable: false,
      options: _zoomLabels(l10n),
      value: zoom,
      onChanged: (z) => notifier.update((l) => l.copyWith(zoom: z.name)),
    ),
    ToolbarToggle(
      key: const Key('timeline-critical'),
      label: l10n.grpICriticalPath,
      on: layout.criticalPath,
      onChanged: (v) => notifier.update((l) => l.copyWith(criticalPath: v)),
    ),
    ToolbarToggle(
      key: const Key('timeline-hide-done'),
      label: l10n.grpIHideDone,
      on: layout.hideDone,
      onChanged: (v) => notifier.update((l) => l.copyWith(hideDone: v)),
    ),
    ToolbarIcon(
      key: const Key('timeline-list-mode'),
      icon: listMode ? TfIcons.timeline : TfIcons.list,
      tooltip: listMode ? l10n.grpIShowChart : l10n.grpIShowList,
      onPressed: () => onListMode(!listMode),
    ),
    if (!listMode)
      ToolbarIcon(
        key: const Key('timeline-export'),
        icon: TfIcons.image,
        tooltip: l10n.grpIExportImage,
        onPressed: onExport,
      ),
    if (onWorkingDays != null)
      ToolbarIcon(
        key: const Key('timeline-working-days'),
        icon: TfIcons.calendarX,
        tooltip: l10n.grpIWorkingDays,
        onPressed: onWorkingDays,
      ),
  ];
}
