import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/workload/domain/workload.dart';

/// What a drag carries: a task, and the person and column it was taken from.
@immutable
class DraggedTask {
  const DraggedTask(this.taskId, this.fromUser, this.fromColumn);

  final String taskId;
  final String fromUser;
  final DateTime fromColumn;
}

/// The columns of the grid: first day, last day.
List<(DateTime, DateTime)> columnsOf(WorkloadZoom zoom, WorkloadData data) {
  final out = <(DateTime, DateTime)>[];
  var start = data.start;
  while (!start.isAfter(data.end) && out.length < 400) {
    final next = nextColumn(zoom, start);
    out.add((start, addDays(next, -1)));
    start = next;
  }
  return out;
}

/// Load against capacity: under half, within, a little over, far over.
enum LoadLevel { none, under, ok, over, severe }

LoadLevel levelOf(int load, int capacity, {required bool capacitySet}) {
  if (load <= 0) return LoadLevel.none;
  if (!capacitySet) return LoadLevel.ok;
  if (capacity <= 0) return LoadLevel.severe;
  final ratio = load / capacity;
  if (ratio > 1.25) return LoadLevel.severe;
  if (ratio > 1) return LoadLevel.over;
  return ratio < 0.5 ? LoadLevel.under : LoadLevel.ok;
}

Color levelColor(ThemeData theme, LoadLevel level) => switch (level) {
  LoadLevel.severe => theme.colorScheme.error,
  LoadLevel.over => Colors.amber.shade700,
  LoadLevel.under => theme.colorScheme.primary.withValues(alpha: 0.45),
  LoadLevel.ok || LoadLevel.none => theme.colorScheme.primary,
};

const cellHeight = 64.0;
const _minSegment = 10.0;

/// One person in one column: stacked bars of the tasks that load it, a
/// tooltip that lists them, and (when [onDrop] is set) a drop target and drag
/// sources.
class LoadCell extends StatelessWidget {
  const LoadCell({
    super.key,
    required this.person,
    required this.data,
    required this.column,
    required this.zoom,
    this.onDrop,
  });

  final PersonLoad person;
  final WorkloadData data;
  final (DateTime, DateTime) column;
  final WorkloadZoom zoom;
  final void Function(DraggedTask task, String toUser, DateTime toColumn)?
  onDrop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cal = WorkCalendar(
      capacity: person.capacity,
      holidays: data.holidays,
      timeOff: person.timeOff,
    );
    final perTask = <String, int>{};
    var capacity = 0;
    for (var d = column.$1; !d.isAfter(column.$2); d = addDays(d, 1)) {
      capacity += cal.capacityOn(d);
      for (final c in person.days[d] ?? const <Contribution>[]) {
        perTask.update(
          c.taskId,
          (v) => v + c.seconds,
          ifAbsent: () => c.seconds,
        );
      }
    }
    final load = perTask.values.fold(0, (s, v) => s + v);
    final level = levelOf(load, capacity, capacitySet: person.capacity.isSet);
    final off = zoom == WorkloadZoom.day && capacity == 0;
    final cell = Container(
      height: cellHeight,
      decoration: BoxDecoration(
        color: off
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : null,
        border: BorderDirectional(
          end: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Tooltip(
        richMessage: _tooltip(context, perTask, load, capacity),
        waitDuration: const Duration(milliseconds: 250),
        child: load == 0
            ? null
            : _Bars(
                perTask: perTask,
                load: load,
                capacity: capacity,
                level: level,
                data: data,
                person: person,
                column: column,
                draggable: onDrop != null,
              ),
      ),
    );
    final drop = onDrop;
    if (drop == null) return cell;
    return DragTarget<DraggedTask>(
      onWillAcceptWithDetails: (d) =>
          d.data.fromUser != person.userId || d.data.fromColumn != column.$1,
      onAcceptWithDetails: (d) => drop(d.data, person.userId, column.$1),
      builder: (context, candidates, _) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: candidates.isEmpty
              ? null
              : Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        child: cell,
      ),
    );
  }

  InlineSpan _tooltip(
    BuildContext context,
    Map<String, int> perTask,
    int load,
    int capacity,
  ) {
    final t = context.l10n;
    final lines = <String>[
      t.wlCellTotal(
        context.localDigits(hoursText(load)),
        context.localDigits(hoursText(capacity)),
      ),
      for (final e in perTask.entries)
        '${data.tasks[e.key]?.displayId ?? ''} '
            '${data.tasks[e.key]?.title ?? ''}: '
            '${context.localDigits(hoursText(e.value))} ${t.wlHoursUnit}',
    ];
    if (perTask.isEmpty) {
      lines.add(t.wlCellEmpty);
    }
    return TextSpan(text: lines.join('\n'));
  }
}

class _Bars extends StatelessWidget {
  const _Bars({
    required this.perTask,
    required this.load,
    required this.capacity,
    required this.level,
    required this.data,
    required this.person,
    required this.column,
    required this.draggable,
  });

  final Map<String, int> perTask;
  final int load;
  final int capacity;
  final LoadLevel level;
  final WorkloadData data;
  final PersonLoad person;
  final (DateTime, DateTime) column;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = levelColor(theme, level);
    final scale = (load > capacity ? load : capacity).toDouble();
    final entries = perTask.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final shades = [for (var i = 0; i < entries.length; i++) i];
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: base.withValues(alpha: 0.08))),
        Positioned(
          left: 4,
          right: 4,
          bottom: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final i in shades)
                _Segment(
                  height: ((entries[i].value / scale) * (cellHeight - 8)).clamp(
                    _minSegment,
                    cellHeight - 8,
                  ),
                  color: base.withValues(alpha: i.isEven ? 0.95 : 0.7),
                  dragged: draggable
                      ? DraggedTask(entries[i].key, person.userId, column.$1)
                      : null,
                  title: data.tasks[entries[i].key]?.displayId ?? '',
                ),
            ],
          ),
        ),
        PositionedDirectional(
          start: 4,
          top: 1,
          child: Text(
            context.localDigits(hoursText(load)),
            style: theme.textTheme.labelSmall?.copyWith(
              color: level == LoadLevel.over || level == LoadLevel.severe
                  ? base
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

bool get _touch =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class _Segment extends StatelessWidget {
  const _Segment({
    required this.height,
    required this.color,
    required this.title,
    this.dragged,
  });

  final double height;
  final Color color;
  final String title;
  final DraggedTask? dragged;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      height: height,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
    final drag = dragged;
    if (drag == null) return bar;
    final feedback = Material(
      color: Colors.transparent,
      child: Chip(label: Text(title)),
    );
    return _touch
        ? LongPressDraggable<DraggedTask>(
            data: drag,
            feedback: feedback,
            childWhenDragging: Opacity(opacity: 0.3, child: bar),
            child: bar,
          )
        : Draggable<DraggedTask>(
            data: drag,
            feedback: feedback,
            childWhenDragging: Opacity(opacity: 0.3, child: bar),
            child: MouseRegion(cursor: SystemMouseCursors.grab, child: bar),
          );
  }
}
