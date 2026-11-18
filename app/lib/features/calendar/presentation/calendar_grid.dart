import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/weekday_names.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/calendar/presentation/calendar_drag.dart';
import 'package:taskforge/features/calendar/presentation/calendar_ghosts.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

const _headerHeight = 24.0;
const _laneHeight = 24.0;
const _moreHeight = 22.0;

/// Weeks as rows of seven days with each task a bar across the days it covers.
/// Tasks drag to another day (keeping their length) or by an edge (resize).
class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.first,
    required this.weeks,
    required this.weekStart,
    required this.tasks,
    required this.today,
    required this.colorOf,
    required this.onOpen,
    required this.onDrop,
    required this.onMore,
    this.maxLanes = 3,
    this.month,
    this.jalali = false,
    this.canMove = false,
    this.longPress = false,
    this.openTaskId,
    this.ghosts = const [],
  });

  /// The first day of the first week shown, and how many weeks.
  final Day first;
  final int weeks;
  final int weekStart;
  final List<Task> tasks;
  final Day today;

  /// Days of other months are dimmed (null: none are). With [jalali] this is a
  /// Jalali month number and the day numbers are Jalali too.
  final int? month;
  final bool jalali;
  final int maxLanes;
  final bool canMove;

  /// Touch: a bar is picked up with a long press, so a plain drag scrolls.
  final bool longPress;
  final String? openTaskId;

  /// Dates a repeating task will still make, shown faded.
  final List<RepeatGhost> ghosts;
  final Color Function(Task) colorOf;
  final void Function(Task) onOpen;
  final void Function(CalDrag drag, Day target) onDrop;
  final void Function(Day) onMore;

  @override
  Widget build(BuildContext context) {
    final dayNames = context.l10n.weekdayShortNames;
    final names = [
      for (var i = 0; i < 7; i++) dayNames[(weekStart - 1 + i) % 7],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final name in names)
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: context.tf.typography.label.copyWith(
                      color: context.tf.colors.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            key: const Key('cal-scroll'),
            child: Column(
              children: [
                for (var w = 0; w < weeks; w++) ...[
                  _WeekRow(
                    key: Key('week-${formatDay(addDays(first, 7 * w))}'),
                    weekFirst: addDays(first, 7 * w),
                    grid: this,
                  ),
                  GhostRow(weekFirst: addDays(first, 7 * w), ghosts: ghosts),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({super.key, required this.weekFirst, required this.grid});

  final Day weekFirst;
  final CalendarGrid grid;

  @override
  Widget build(BuildContext context) {
    final row = layoutWeek(grid.tasks, weekFirst, maxLanes: grid.maxLanes);
    final lanes = row.segments.fold<int>(
      0,
      (n, s) => s.lane >= n ? s.lane + 1 : n,
    );
    final height =
        _headerHeight + (lanes < 2 ? 2 : lanes) * _laneHeight + _moreHeight;
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, box) {
          final colWidth = box.maxWidth / 7;
          return Stack(
            children: [
              Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: _DayCell(
                        day: addDays(weekFirst, c),
                        hidden: row.hidden[c],
                        grid: grid,
                      ),
                    ),
                ],
              ),
              for (final s in row.segments)
                PositionedDirectional(
                  start: s.startCol * colWidth + 1,
                  top: _headerHeight + s.lane * _laneHeight,
                  width: (s.endCol - s.startCol + 1) * colWidth - 2,
                  height: _laneHeight - 2,
                  child: _Bar(
                    key: Key('bar-${s.task.id}-${formatDay(weekFirst)}'),
                    segment: s,
                    weekFirst: weekFirst,
                    colWidth: colWidth,
                    grid: grid,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.hidden, required this.grid});

  final Day day;
  final int hidden;
  final CalendarGrid grid;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final isToday = day == grid.today;
    final shown = grid.jalali ? jalaliOf(day) : null;
    final number = shown?.day ?? day.day;
    final dim = grid.month != null && (shown?.month ?? day.month) != grid.month;
    return DragTarget<CalDrag>(
      key: Key('day-${formatDay(day)}'),
      onWillAcceptWithDetails: (_) => grid.canMove,
      onAcceptWithDetails: (d) => grid.onDrop(d.data, day),
      builder: (context, hovering, _) => Container(
        decoration: BoxDecoration(
          color: hovering.isNotEmpty
              ? c.accent.withValues(alpha: 0.12)
              : isToday
              ? c.selected
              : null,
          border: BorderDirectional(
            start: BorderSide(color: c.border, width: tfHairline),
            top: BorderSide(color: c.border, width: tfHairline),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 0, 0),
              child: isToday
                  ? Container(
                      key: const Key('today-marker'),
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        context.localDigits('$number'),
                        style: tf.typography.caption.copyWith(
                          color: c.onAccent,
                        ),
                      ),
                    )
                  : Text(
                      context.localDigits('$number'),
                      style: tf.typography.caption.copyWith(
                        color: dim ? c.textSubtle : c.text,
                      ),
                    ),
            ),
            const Spacer(),
            if (hidden > 0)
              InkWell(
                key: Key('more-${formatDay(day)}'),
                onTap: () => grid.onMore(day),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    context.l10n.grpFPlusMore(hidden),
                    style: tf.typography.caption.copyWith(color: c.textMuted),
                  ),
                ),
              )
            else
              const SizedBox(height: _moreHeight - 4),
          ],
        ),
      ),
    );
  }
}

/// A task's bar text: its due time (the viewer's clock) before the title, on
/// the bar that ends the task.
String _label(Task task) {
  final time = dueTimeLocal(task);
  return time.isEmpty ? task.title : '$time ${task.title}';
}

/// One task's bar in one week: dragged to move (the day it was picked up on
/// is remembered), with a handle on each end that really is an end of it.
class _Bar extends StatelessWidget {
  const _Bar({
    super.key,
    required this.segment,
    required this.weekFirst,
    required this.colWidth,
    required this.grid,
  });

  final BarSegment segment;
  final Day weekFirst;
  final double colWidth;
  final CalendarGrid grid;

  @override
  Widget build(BuildContext context) {
    final task = segment.task;
    final color = grid.colorOf(task);
    final selected = task.id == grid.openTaskId;
    final shape = BorderRadiusDirectional.horizontal(
      start: Radius.circular(segment.continuesBefore ? 0 : TfRadius.sm),
      end: Radius.circular(segment.continuesAfter ? 0 : TfRadius.sm),
    ).resolve(Directionality.of(context));
    final body = Material(
      color: color,
      borderRadius: shape,
      child: InkWell(
        key: Key('chip-${task.id}-${formatDay(weekFirst)}'),
        borderRadius: shape,
        onTap: () => grid.onOpen(task),
        child: Container(
          decoration: selected
              ? BoxDecoration(
                  borderRadius: shape,
                  border: Border.all(width: 2, color: context.tf.colors.text),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            _label(task),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.tf.typography.caption.copyWith(
              color:
                  ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
    if (!grid.canMove) return body;
    final drag = CalDrag(task);
    Widget handle(BarEdge edge) => Draggable<CalDrag>(
      data: CalDrag(task, edge: edge),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: const Material(
        child: Padding(padding: EdgeInsets.all(4), child: Text('↔')),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Container(
          key: Key('resize-${edge.name}-${task.id}-${formatDay(weekFirst)}'),
          width: 8,
          color: Colors.black26,
        ),
      ),
    );
    return Stack(
      children: [
        Listener(
          onPointerDown: (e) {
            final cols = segment.endCol - segment.startCol;
            final visual = (e.localPosition.dx / colWidth).floor().clamp(
              0,
              cols,
            );
            // Right to left, the bar's first day is at its right end.
            final col = Directionality.of(context) == TextDirection.rtl
                ? cols - visual
                : visual;
            drag.grabbed = addDays(weekFirst, segment.startCol + col);
          },
          child: calDraggable(
            longPress: grid.longPress,
            data: drag,
            feedback: Material(
              color: color,
              borderRadius: TfRadius.control,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(task.title),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.35, child: body),
            child: body,
          ),
        ),
        if (!segment.continuesBefore)
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: handle(BarEdge.start),
          ),
        if (!segment.continuesAfter)
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: handle(BarEdge.end),
          ),
      ],
    );
  }
}
