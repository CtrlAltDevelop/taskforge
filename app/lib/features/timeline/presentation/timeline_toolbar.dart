import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';

const _zoomLabels = {
  TimelineZoom.day: 'Day',
  TimelineZoom.week: 'Week',
  TimelineZoom.month: 'Month',
  TimelineZoom.quarter: 'Quarter',
};

const _groups = {
  groupNone: 'Task tree',
  groupAssignee: 'By assignee',
  groupStatus: 'By status',
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
            tooltip: 'Earlier',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => anchor.shift(zoom, -1),
          ),
          TextButton(
            key: const Key('timeline-today'),
            onPressed: anchor.today,
            child: const Text('Today'),
          ),
          IconButton(
            key: const Key('timeline-next'),
            tooltip: 'Later',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => anchor.shift(zoom, 1),
          ),
          SegmentedButton<TimelineZoom>(
            key: const Key('timeline-zoom'),
            showSelectedIcon: false,
            segments: [
              for (final z in TimelineZoom.values)
                ButtonSegment(value: z, label: Text(_zoomLabels[z]!)),
            ],
            selected: {zoom},
            onSelectionChanged: (v) =>
                layoutNotifier.update((l) => l.copyWith(zoom: v.first.name)),
          ),
          DropdownButton<String>(
            key: const Key('timeline-group'),
            value: layout.groupBy,
            items: [
              for (final e in _groups.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) =>
                layoutNotifier.update((l) => l.copyWith(groupBy: v ?? '')),
          ),
          FilterChip(
            key: const Key('timeline-critical'),
            label: const Text('Critical path'),
            selected: layout.criticalPath,
            onSelected: (v) =>
                layoutNotifier.update((l) => l.copyWith(criticalPath: v)),
          ),
          FilterChip(
            key: const Key('timeline-hide-done'),
            label: const Text('Hide done'),
            selected: layout.hideDone,
            onSelected: (v) =>
                layoutNotifier.update((l) => l.copyWith(hideDone: v)),
          ),
          IconButton(
            key: const Key('timeline-list-mode'),
            tooltip: listMode ? 'Show the chart' : 'Show as a list',
            icon: Icon(listMode ? Icons.stacked_bar_chart : Icons.list),
            onPressed: () => onListMode(!listMode),
          ),
          if (!listMode)
            IconButton(
              key: const Key('timeline-export'),
              tooltip: 'Export as an image',
              icon: const Icon(Icons.image_outlined),
              onPressed: onExport,
            ),
          if (onWorkingDays != null)
            IconButton(
              key: const Key('timeline-working-days'),
              tooltip: 'Working days',
              icon: const Icon(Icons.event_busy_outlined),
              onPressed: onWorkingDays,
            ),
        ],
      ),
    );
  }
}
