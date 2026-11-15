import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/directional_icon.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';

String _monthName(BuildContext context, int month) {
  final l = context.l10n;
  return switch (month) {
    1 => l.grpEMonth1,
    2 => l.grpEMonth2,
    3 => l.grpEMonth3,
    4 => l.grpEMonth4,
    5 => l.grpEMonth5,
    6 => l.grpEMonth6,
    7 => l.grpEMonth7,
    8 => l.grpEMonth8,
    9 => l.grpEMonth9,
    10 => l.grpEMonth10,
    11 => l.grpEMonth11,
    _ => l.grpEMonth12,
  };
}

String _weekdayName(BuildContext context, int day) {
  final l = context.l10n;
  return switch (day) {
    0 => l.grpEWeekLocale,
    1 => l.grpEMonday,
    6 => l.grpESaturday,
    _ => l.grpESunday,
  };
}

const _weekdayKeys = [0, 1, 6, 7];

String rangeTitle(
  BuildContext context,
  CalendarMode mode,
  Day anchor,
  Day first,
  Day last,
) => switch (mode) {
  CalendarMode.month when context.localePrefs.isJalali => () {
    final j = jalaliOf(anchor);
    return context.localDigits(
      '${jalaliMonthName(context.l10n, j.month)} ${j.year}',
    );
  }(),
  CalendarMode.month => '${_monthName(context, anchor.month)} ${anchor.year}',
  CalendarMode.week => '${context.localIso(first)} – ${context.localIso(last)}',
  CalendarMode.day => context.localIso(anchor),
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
    final range = visibleRange(
      mode,
      anchor,
      weekStart,
      jalali: ref.watch(calendarJalaliProvider),
    );
    final notifier = ref.read(calendarLayoutProvider(projectId).notifier);
    final cursor = ref.read(calendarAnchorProvider(projectId).notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        key: const Key('calendar-toolbar'),
        children: [
          IconButton(
            key: const Key('cal-prev'),
            tooltip: context.l10n.grpEPrevious,
            icon: const DirectionalIcon(Icons.chevron_left),
            onPressed: () => cursor.shift(mode, -1),
          ),
          IconButton(
            key: const Key('cal-next'),
            tooltip: context.l10n.grpENext,
            icon: const DirectionalIcon(Icons.chevron_right),
            onPressed: () => cursor.shift(mode, 1),
          ),
          TextButton(
            key: const Key('cal-today'),
            onPressed: cursor.today,
            child: Text(context.l10n.grpEToday),
          ),
          if (onTray != null)
            IconButton(
              key: const Key('cal-tray-button'),
              onPressed: onTray,
              tooltip: context.l10n.grpEUnscheduled,
              icon: const Icon(Icons.inbox_outlined),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              rangeTitle(context, mode, anchor, range.first, range.last),
              key: const Key('cal-title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (!compact) ...[
            SegmentedButton<CalendarMode>(
              key: const Key('cal-mode'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: CalendarMode.month,
                  label: Text(context.l10n.grpEMonth),
                ),
                ButtonSegment(
                  value: CalendarMode.week,
                  label: Text(context.l10n.grpEWeek),
                ),
                ButtonSegment(
                  value: CalendarMode.day,
                  label: Text(context.l10n.grpEDay),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (v) =>
                  notifier.update((l) => l.copyWith(mode: v.first.name)),
            ),
            PopupMenuButton<String>(
              key: const Key('cal-color-menu'),
              tooltip: context.l10n.grpEColourBy,
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
                    child: Text(switch (c) {
                      'project' => context.l10n.grpEColourByProject,
                      'status' => context.l10n.grpEColourByStatus,
                      _ => context.l10n.grpEColourByPriority,
                    }),
                  ),
              ],
              child: _Chip(
                icon: Icons.palette_outlined,
                label: context.l10n.grpEColourChip,
              ),
            ),
            PopupMenuButton<int>(
              key: const Key('cal-week-menu'),
              tooltip: context.l10n.grpEWeekStartsOn,
              onSelected: (v) =>
                  notifier.update((l) => l.copyWith(weekStart: v)),
              itemBuilder: (_) => [
                for (final d in _weekdayKeys)
                  CheckedPopupMenuItem(
                    key: Key('cal-week-$d'),
                    value: d,
                    checked: layout.weekStart == d,
                    child: Text(_weekdayName(context, d)),
                  ),
              ],
              child: _Chip(
                icon: Icons.view_week_outlined,
                label: context.l10n.grpEWeek,
              ),
            ),
          ],
          FilterChip(
            key: const Key('cal-hide-done'),
            label: Text(context.l10n.grpEHideDone),
            selected: layout.hideDone,
            onSelected: (v) => notifier.update((l) => l.copyWith(hideDone: v)),
          ),
          IconButton(
            key: const Key('cal-refresh'),
            tooltip: context.l10n.grpERefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(calendarProvider(projectId).notifier).refresh(),
          ),
          if (state.saveFailed)
            Tooltip(
              message: context.l10n.grpELayoutNotSaved,
              child: const Icon(
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
