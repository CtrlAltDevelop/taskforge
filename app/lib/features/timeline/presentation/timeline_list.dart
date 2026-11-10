import 'package:flutter/material.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';

/// "5 Nov → 9 Nov", "due 5 Nov" or "from 5 Nov": what a bar says, in words.
String datesText(Task t) {
  if (t.startDate.isNotEmpty && t.dueDate.isNotEmpty) {
    return '${t.startDate} → ${t.dueDate}';
  }
  if (t.dueDate.isNotEmpty) return 'due ${t.dueDate}';
  if (t.startDate.isNotEmpty) return 'from ${t.startDate}';
  return 'no dates';
}

/// How long the bar is, in days (a milestone has none).
String lengthText(Task t) {
  final s = spanOf(t);
  if (s == null || isMilestone(t)) return '';
  final days = daysBetween(s.first, s.last) + 1;
  return days == 1 ? '1 day' : '$days days';
}

/// The timeline as a plain list: for a screen reader (the canvas has no
/// per-bar semantics), for a narrow screen and for anyone who prefers it.
class TimelineList extends StatelessWidget {
  const TimelineList({
    super.key,
    required this.rows,
    required this.critical,
    required this.onOpen,
  });

  final List<TimelineRow> rows;
  final Set<String> critical;
  final void Function(Task) onOpen;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'Nothing is scheduled in this range.',
          key: Key('timeline-empty'),
        ),
      );
    }
    return ListView.builder(
      key: const Key('timeline-list'),
      itemCount: rows.length,
      itemExtent: 56,
      itemBuilder: (context, i) {
        final row = rows[i];
        final task = row.task;
        if (task == null) {
          return ListTile(
            dense: true,
            title: Text(
              row.header!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          );
        }
        final isCritical = critical.contains(task.id);
        return ListTile(
          key: Key('timeline-row-${task.id}'),
          contentPadding: EdgeInsetsDirectional.only(
            start: 16.0 + 16 * row.depth,
            end: 16,
          ),
          title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            [
              task.displayId,
              datesText(task),
              if (lengthText(task).isNotEmpty) lengthText(task),
              if (isCritical) 'on the critical path',
              if (task.isBlocked) 'blocked',
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onOpen(task),
        );
      },
    );
  }
}
