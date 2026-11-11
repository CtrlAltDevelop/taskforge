import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/sprints/domain/sprints.dart';

/// One task of the backlog or a sprint: a checkbox for multi-select, a handle
/// to drag it to the other pane, and the points (tap to edit).
class PlanningTaskRow extends StatelessWidget {
  const PlanningTaskRow({
    super.key,
    required this.task,
    required this.selected,
    required this.onToggle,
    this.canDrag = false,
    this.onPoints,
  });

  final SprintTask task;
  final bool selected;
  final ValueChanged<bool> onToggle;
  final bool canDrag;

  /// Null when the caller may not edit points.
  final VoidCallback? onPoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = task.points;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 4, right: 8),
      leading: canDrag
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  key: Key('select-${task.id}'),
                  value: selected,
                  onChanged: (v) => onToggle(v ?? false),
                ),
                Draggable<SprintTask>(
                  key: Key('drag-${task.id}'),
                  data: task,
                  feedback: Material(
                    elevation: 4,
                    child: SizedBox(
                      width: 260,
                      child: ListTile(
                        dense: true,
                        title: Text(task.title, maxLines: 1),
                        subtitle: Text(task.key),
                      ),
                    ),
                  ),
                  childWhenDragging: const Opacity(
                    opacity: 0.3,
                    child: Icon(Icons.drag_indicator),
                  ),
                  child: const Tooltip(
                    message: 'Drag to the other list',
                    child: Icon(Icons.drag_indicator),
                  ),
                ),
              ],
            )
          : null,
      title: Text(
        task.title,
        overflow: TextOverflow.ellipsis,
        style: task.isDone
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(
        [
          task.key,
          if (task.statusName.isNotEmpty) task.statusName,
          if (task.late) 'added after start',
        ].join(' · '),
        key: task.late ? Key('late-${task.id}') : null,
        style: task.late
            ? TextStyle(color: theme.colorScheme.error)
            : theme.textTheme.bodySmall,
      ),
      trailing: ActionChip(
        key: Key('points-${task.id}'),
        label: Text(points == null ? '—' : pointsText(points)),
        tooltip: 'Story points',
        onPressed: onPoints,
      ),
    );
  }
}

/// Wraps [child] as the place tasks are dropped; highlights while hovering.
class DropPane extends StatelessWidget {
  const DropPane({
    super.key,
    required this.accepts,
    required this.onDrop,
    required this.child,
  });

  final bool Function(SprintTask task) accepts;
  final ValueChanged<SprintTask> onDrop;
  final Widget child;

  @override
  Widget build(BuildContext context) => DragTarget<SprintTask>(
    onWillAcceptWithDetails: (d) => accepts(d.data),
    onAcceptWithDetails: (d) => onDrop(d.data),
    builder: (context, hovering, _) => DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: hovering.isNotEmpty
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: child,
    ),
  );
}

/// The load of a sprint against its capacity, in points or hours.
class CapacityBar extends StatelessWidget {
  const CapacityBar({
    super.key,
    required this.capacity,
    required this.hours,
    required this.onHours,
    this.onEdit,
  });

  final Capacity capacity;
  final bool hours;
  final ValueChanged<bool> onHours;

  /// Null when the caller may not change the capacity.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = hours ? 'h' : ' pts';
    final load = pointsText(double.parse(capacity.load.toStringAsFixed(1)));
    final cap = capacity.capacity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  capacity.known
                      ? 'Load $load$unit of ${pointsText(cap!)}$unit'
                      : 'Load $load$unit (no capacity set)',
                  key: const Key('capacity-text'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: capacity.over ? theme.colorScheme.error : null,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  key: const Key('capacity-edit'),
                  tooltip: 'Set capacity',
                  icon: const Icon(Icons.tune, size: 18),
                  onPressed: onEdit,
                ),
              SegmentedButton<bool>(
                key: const Key('capacity-unit'),
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: const [
                  ButtonSegment(value: false, label: Text('Points')),
                  ButtonSegment(value: true, label: Text('Hours')),
                ],
                selected: {hours},
                onSelectionChanged: (s) => onHours(s.first),
              ),
            ],
          ),
          LinearProgressIndicator(
            key: const Key('capacity-bar'),
            value: capacity.fraction,
            color: capacity.over ? theme.colorScheme.error : null,
            minHeight: 8,
          ),
          if (capacity.over)
            Text(
              'Over capacity by '
              '${pointsText(double.parse((-capacity.remaining).toStringAsFixed(1)))}'
              '$unit',
              key: const Key('capacity-over'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }
}

/// A list of tasks with a header and an empty state; used by both panes.
class TaskListPane extends ConsumerWidget {
  const TaskListPane({
    super.key,
    required this.title,
    required this.tasks,
    required this.emptyText,
    required this.rowBuilder,
    this.actions = const [],
    this.header,
  });

  final String title;
  final AsyncValue<List<SprintTask>> tasks;
  final String emptyText;
  final Widget Function(SprintTask task) rowBuilder;
  final List<Widget> actions;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final list = tasks.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  list == null ? title : '$title (${list.length})',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              ...actions,
            ],
          ),
        ),
        ?header,
        Expanded(
          child: switch (tasks) {
            AsyncData(:final value) when value.isEmpty => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(emptyText, textAlign: TextAlign.center),
              ),
            ),
            AsyncData(:final value) => ListView(
              children: [for (final t in value) rowBuilder(t)],
            ),
            AsyncError(:final error) => Center(
              child: Text(sprintErrorMessage(error)),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}
