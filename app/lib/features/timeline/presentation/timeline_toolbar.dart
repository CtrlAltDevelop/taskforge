import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/directional_icon.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
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

/// Zoom, grouping, the critical path, finished tasks, moving through time,
/// export and (for those who may) the working days.
class TimelineToolbar extends ConsumerWidget {
  const TimelineToolbar({
    super.key,
    required this.projectId,
    required this.listMode,
    required this.onListMode,
    required this.onExport,
    this.onWorkingDays,
  });

  final String projectId;
  final bool listMode;
  final ValueChanged<bool> onListMode;
  final VoidCallback onExport;

  /// Null when the person may not change the workspace's working days.
  final VoidCallback? onWorkingDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(timelineLayoutProvider(projectId)).layout;
    final layoutNotifier = ref.read(timelineLayoutProvider(projectId).notifier);
    final anchor = ref.read(timelineAnchorProvider(projectId).notifier);
    final zoom = zoomOf(layout);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            key: const Key('timeline-prev'),
            tooltip: context.l10n.grpIEarlier,
            icon: const DirectionalIcon(Icons.chevron_left),
            onPressed: () => anchor.shift(zoom, -1),
          ),
          TextButton(
            key: const Key('timeline-today'),
            onPressed: anchor.today,
            child: Text(context.l10n.grpIToday),
          ),
          IconButton(
            key: const Key('timeline-next'),
            tooltip: context.l10n.grpILater,
            icon: const DirectionalIcon(Icons.chevron_right),
            onPressed: () => anchor.shift(zoom, 1),
          ),
          SegmentedButton<TimelineZoom>(
            key: const Key('timeline-zoom'),
            showSelectedIcon: false,
            segments: [
              for (final z in TimelineZoom.values)
                ButtonSegment(
                  value: z,
                  label: Text(_zoomLabels(context.l10n)[z]!),
                ),
            ],
            selected: {zoom},
            onSelectionChanged: (v) =>
                layoutNotifier.update((l) => l.copyWith(zoom: v.first.name)),
          ),
          DropdownButton<String>(
            key: const Key('timeline-group'),
            value: layout.groupBy,
            items: [
              for (final e in _groups(context.l10n).entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) =>
                layoutNotifier.update((l) => l.copyWith(groupBy: v ?? '')),
          ),
          FilterChip(
            key: const Key('timeline-critical'),
            label: Text(context.l10n.grpICriticalPath),
            selected: layout.criticalPath,
            onSelected: (v) =>
                layoutNotifier.update((l) => l.copyWith(criticalPath: v)),
          ),
          FilterChip(
            key: const Key('timeline-hide-done'),
            label: Text(context.l10n.grpIHideDone),
            selected: layout.hideDone,
            onSelected: (v) =>
                layoutNotifier.update((l) => l.copyWith(hideDone: v)),
          ),
          IconButton(
            key: const Key('timeline-list-mode'),
            tooltip: listMode
                ? context.l10n.grpIShowChart
                : context.l10n.grpIShowList,
            icon: Icon(listMode ? Icons.stacked_bar_chart : Icons.list),
            onPressed: () => onListMode(!listMode),
          ),
          if (!listMode)
            IconButton(
              key: const Key('timeline-export'),
              tooltip: context.l10n.grpIExportImage,
              icon: const Icon(Icons.image_outlined),
              onPressed: onExport,
            ),
          if (onWorkingDays != null)
            IconButton(
              key: const Key('timeline-working-days'),
              tooltip: context.l10n.grpIWorkingDays,
              icon: const Icon(Icons.event_busy_outlined),
              onPressed: onWorkingDays,
            ),
        ],
      ),
    );
  }
}
