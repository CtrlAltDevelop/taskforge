import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// "5 Nov → 9 Nov", "due 5 Nov" or "from 5 Nov": what a bar says, in words.
String datesText(Task t, [AppLocalizations? l10n]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (t.startDate.isNotEmpty && t.dueDate.isNotEmpty) {
    return l.grpIDateRange(t.startDate, t.dueDate);
  }
  if (t.dueDate.isNotEmpty) return l.grpIDueOn(t.dueDate);
  if (t.startDate.isNotEmpty) return l.grpIFromDate(t.startDate);
  return l.grpINoDates;
}

/// How long the bar is, in days (a milestone has none).
String lengthText(Task t, [AppLocalizations? l10n]) {
  final s = spanOf(t);
  if (s == null || isMilestone(t)) return '';
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  return l.grpIDaysCount(daysBetween(s.first, s.last) + 1);
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
      return Center(
        child: Text(
          context.l10n.grpINothingScheduled,
          key: const Key('timeline-empty'),
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
              datesText(task, context.l10n),
              if (lengthText(task, context.l10n).isNotEmpty)
                lengthText(task, context.l10n),
              if (isCritical) context.l10n.grpIOnCriticalPath,
              if (task.isBlocked) context.l10n.grpIBlocked,
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
