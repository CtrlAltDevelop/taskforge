import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _weekdays = {
  0: 'Locale default',
  1: 'Monday',
  6: 'Saturday',
  7: 'Sunday',
};

String rangeTitle(CalendarMode mode, Day anchor, Day first, Day last) =>
    switch (mode) {
      CalendarMode.month => '${_months[anchor.month - 1]} ${anchor.year}',
      CalendarMode.week => '${formatDay(first)} – ${formatDay(last)}',
      CalendarMode.day => formatDay(anchor),
    };

/// Previous / next / today, the title, the mode, what bars are coloured by,
/// the first weekday and whether finished tasks show.
class CalendarToolbar extends ConsumerWidget {
  const CalendarToolbar({
    super.key,
    required this.projectId,
    required this.compact,
    required this.onTray,
    this.workspaceWide = false,
  });

  final String projectId;

  /// A phone: only the arrows, today and the tray.
  final bool compact;

  /// The calendar of every project (it can also colour by project).
  final bool workspaceWide;

  /// Opens the tray as a sheet (null when it is a sidebar already).
  final VoidCallback? onTray;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarLayoutProvider(projectId));
    final layout = state.layout;
    final mode = shownMode(layout, compact: compact);
    final anchor = ref.watch(calendarAnchorProvider(projectId));
    final weekStart = ref.watch(weekStartProvider(projectId));
    final range = visibleRange(mode, anchor, weekStart);
    final notifier = ref.read(calendarLayoutProvider(projectId).notifier);
    final cursor = ref.read(calendarAnchorProvider(projectId).notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        key: const Key('calendar-toolbar'),
        children: [
          IconButton(
            key: const Key('cal-prev'),
            tooltip: 'Previous',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => cursor.shift(mode, -1),
          ),
          IconButton(
            key: const Key('cal-next'),
            tooltip: 'Next',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => cursor.shift(mode, 1),
          ),
          TextButton(
            key: const Key('cal-today'),
            onPressed: cursor.today,
            child: const Text('Today'),
          ),
          if (onTray != null)
            IconButton(
              key: const Key('cal-tray-button'),
              onPressed: onTray,
              tooltip: 'Unscheduled',
              icon: const Icon(Icons.inbox_outlined),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              rangeTitle(mode, anchor, range.first, range.last),
              key: const Key('cal-title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (!compact) ...[
            SegmentedButton<CalendarMode>(
              key: const Key('cal-mode'),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: CalendarMode.month, label: Text('Month')),
                ButtonSegment(value: CalendarMode.week, label: Text('Week')),
                ButtonSegment(value: CalendarMode.day, label: Text('Day')),
              ],
              selected: {mode},
              onSelectionChanged: (v) =>
                  notifier.update((l) => l.copyWith(mode: v.first.name)),
            ),
            PopupMenuButton<String>(
              key: const Key('cal-color-menu'),
              tooltip: 'Colour by',
              onSelected: (v) => notifier.update((l) => l.copyWith(colorBy: v)),
              itemBuilder: (_) => [
                for (final c in [
                  if (workspaceWide) 'project',
                  'status',
                  'priority',
                ])
                  CheckedPopupMenuItem(
                    key: Key('cal-color-$c'),
                    value: c,
                    checked: layout.colorBy == c,
                    child: Text(
                      c == 'status' ? 'Colour by status' : 'Colour by priority',
                    ),
                  ),
              ],
              child: const _Chip(icon: Icons.palette_outlined, label: 'Colour'),
            ),
            PopupMenuButton<int>(
              key: const Key('cal-week-menu'),
              tooltip: 'Week starts on',
              onSelected: (v) =>
                  notifier.update((l) => l.copyWith(weekStart: v)),
              itemBuilder: (_) => [
                for (final e in _weekdays.entries)
                  CheckedPopupMenuItem(
                    key: Key('cal-week-${e.key}'),
                    value: e.key,
                    checked: layout.weekStart == e.key,
                    child: Text(e.value),
                  ),
              ],
              child: const _Chip(icon: Icons.view_week_outlined, label: 'Week'),
            ),
          ],
          FilterChip(
            key: const Key('cal-hide-done'),
            label: const Text('Hide done'),
            selected: layout.hideDone,
            onSelected: (v) => notifier.update((l) => l.copyWith(hideDone: v)),
          ),
          IconButton(
            key: const Key('cal-refresh'),
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(calendarProvider(projectId).notifier).refresh(),
          ),
          if (state.saveFailed)
            const Tooltip(
              message:
                  'Your calendar layout could not be saved. It will be tried '
                  'again on your next change.',
              child: Icon(
                Icons.warning_amber,
                key: Key('cal-layout-not-saved'),
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    // The menu button around it is the one tab stop.
    child: ExcludeFocus(
      child: Chip(avatar: Icon(icon, size: 18), label: Text(label)),
    ),
  );
}
