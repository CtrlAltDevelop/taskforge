import 'package:flutter/material.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/calendar/presentation/calendar_ghosts.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

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
      return Center(
        child: Text(
          'Nothing on ${formatDay(day)}.',
          key: const Key('day-empty'),
        ),
      );
    }
    return ListView(
      key: const Key('day-tasks'),
      children: [
        for (final task in onDay)
          ListTile(
            key: Key('agenda-${task.id}'),
            leading: CircleAvatar(radius: 6, backgroundColor: colorOf(task)),
            title: Text(task.title),
            subtitle: Text(_span(task)),
            onTap: () => onOpen(task),
            trailing: canMove
                ? IconButton(
                    key: Key('reschedule-${task.id}'),
                    tooltip: 'Reschedule…',
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: () => onReschedule(task),
                  )
                : null,
          ),
        for (final ghost in ghostsToday) GhostTile(ghost: ghost),
      ],
    );
  }

  static String _at(Task task) {
    final time = dueTimeLocal(task);
    return time.isEmpty ? '' : ' $time';
  }

  static String _span(Task task) {
    final s = spanOf(task);
    if (s == null) return task.displayId;
    return s.first == s.last
        ? '${task.displayId} · ${formatDay(s.first)}${_at(task)}'
        : '${task.displayId} · ${formatDay(s.first)} → ${formatDay(s.last)}${_at(task)}';
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
  });

  final List<RepeatGhost> ghosts;
  final Day first;
  final int weeks;
  final int month;
  final List<Task> tasks;
  final Day today;
  final Day selected;
  final void Function(Day) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var w = 0; w < weeks; w++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(child: _cell(scheme, addDays(first, 7 * w + c))),
            ],
          ),
      ],
    );
  }

  Widget _cell(ColorScheme scheme, Day d) {
    final isSelected = d == selected;
    final has = tasksOn(tasks, d).isNotEmpty;
    final hasGhost = !has && ghostsOn(ghosts, d).isNotEmpty;
    return InkWell(
      key: Key('dot-${formatDay(d)}'),
      onTap: () => onSelect(d),
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : null,
          border: d == today ? Border.all(color: scheme.primary) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${d.day}',
              style: TextStyle(color: d.month == month ? null : scheme.outline),
            ),
            if (has)
              Container(
                key: Key('has-tasks-${formatDay(d)}'),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            else if (hasGhost)
              Container(
                key: Key('has-ghost-${formatDay(d)}'),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
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
