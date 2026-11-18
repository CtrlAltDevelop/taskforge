import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/calendar/presentation/calendar_ghosts.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// The tasks of one day as a list, each with a button that asks for a new date
/// (the phone's way to reschedule, and the keyboard's).
class DayTasks extends StatelessWidget {
  const DayTasks({
    super.key,
    required this.day,
    required this.tasks,
    required this.colorOf,
    required this.canMove,
    required this.onOpen,
    required this.onReschedule,
    this.ghosts = const [],
  });

  final Day day;
  final List<RepeatGhost> ghosts;
  final List<Task> tasks;
  final Color Function(Task) colorOf;
  final bool canMove;
  final void Function(Task) onOpen;
  final void Function(Task) onReschedule;

  @override
  Widget build(BuildContext context) {
    final onDay = tasksOn(tasks, day);
    final ghostsToday = ghostsOn(ghosts, day);
    if (onDay.isEmpty && ghostsToday.isEmpty) {
      return TfEmpty(
        key: const Key('day-empty'),
        illustration: TfIllustrationKind.calendar,
        title: context.l10n.grpFNothingOn(context.localIso(day)),
      );
    }
    return ListView(
      key: const Key('day-tasks'),
      children: [
        for (final task in onDay)
          WorkCard(
            child: ListTile(
              key: Key('agenda-${task.id}'),
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorOf(task),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(task.title),
              subtitle: Text(_span(context, task)),
              onTap: () => onOpen(task),
              trailing: canMove
                  ? IconButton(
                      key: Key('reschedule-${task.id}'),
                      tooltip: context.l10n.grpFReschedule,
                      icon: TfIcon(TfIcons.calendarEdit),
                      onPressed: () => onReschedule(task),
                    )
                  : null,
            ),
          ),
        for (final ghost in ghostsToday) GhostTile(ghost: ghost),
      ],
    );
  }

  static String _at(Task task) {
    final time = dueTimeLocal(task);
    return time.isEmpty ? '' : ' $time';
  }

  static String _span(BuildContext context, Task task) {
    final s = spanOf(task);
    if (s == null) return task.displayId;
    return s.first == s.last
        ? '${task.displayId} · ${context.localIso(s.first)}${_at(task)}'
        : '${task.displayId} · ${context.localIso(s.first)} → ${context.localIso(s.last)}${_at(task)}';
  }
}

/// A month as weeks of small day buttons with a dot under a day that has tasks,
/// and the chosen day filled in.
class MonthDots extends StatelessWidget {
  const MonthDots({
    super.key,
    required this.first,
    required this.weeks,
    required this.month,
    required this.tasks,
    required this.today,
    required this.selected,
    required this.onSelect,
    this.ghosts = const [],
    this.jalali = false,
  });

  final List<RepeatGhost> ghosts;

  /// [month] and the day numbers are Jalali.
  final bool jalali;
  final Day first;
  final int weeks;
  final int month;
  final List<Task> tasks;
  final Day today;
  final Day selected;
  final void Function(Day) onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    return Column(
      children: [
        for (var w = 0; w < weeks; w++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(child: _cell(context, c, addDays(first, 7 * w + col))),
            ],
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, TfColors c, Day d) {
    final isSelected = d == selected;
    final shown = jalali ? jalaliOf(d) : null;
    final has = tasksOn(tasks, d).isNotEmpty;
    final hasGhost = !has && ghostsOn(ghosts, d).isNotEmpty;
    return InkWell(
      key: Key('dot-${formatDay(d)}'),
      onTap: () => onSelect(d),
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? c.selected : null,
          border: d == today ? Border.all(color: c.accent) : null,
          borderRadius: TfRadius.panel,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.localDigits('${shown?.day ?? d.day}'),
              style: TextStyle(
                color: (shown?.month ?? d.month) == month
                    ? c.text
                    : c.textSubtle,
              ),
            ),
            if (has)
              Container(
                key: Key('has-tasks-${formatDay(d)}'),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: c.accent,
                  shape: BoxShape.circle,
                ),
              )
            else if (hasGhost)
              Container(
                key: Key('has-ghost-${formatDay(d)}'),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  border: Border.all(color: c.textSubtle),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
