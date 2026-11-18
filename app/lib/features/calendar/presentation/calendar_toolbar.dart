import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/presentation/work/toolbar_parts.dart';

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

/// The calendar's own controls for the shared view toolbar: previous / next /
/// today, the title, Month/Week/Day, what bars are coloured by, the first
/// weekday, whether finished tasks show, and refresh. (A phone gets only the
/// arrows, today and the tray.)
List<Widget> calendarSpecificControls(
  BuildContext context,
  WidgetRef ref,
  String projectId, {
  required bool compact,
  required VoidCallback? onTray,
  bool workspaceWide = false,
}) {
  final l10n = context.l10n;
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
  return [
    ToolbarIcon(
      key: const Key('cal-prev'),
      icon: TfIcons.chevronStart,
      tooltip: l10n.grpEPrevious,
      onPressed: () => cursor.shift(mode, -1),
    ),
    ToolbarIcon(
      key: const Key('cal-next'),
      icon: TfIcons.chevronEnd,
      tooltip: l10n.grpENext,
      onPressed: () => cursor.shift(mode, 1),
    ),
    TfButton(
      key: const Key('cal-today'),
      label: l10n.grpEToday,
      size: TfButtonSize.small,
      onPressed: cursor.today,
    ),
    if (onTray != null)
      ToolbarIcon(
        key: const Key('cal-tray-button'),
        icon: TfIcons.inbox,
        tooltip: l10n.grpEUnscheduled,
        onPressed: onTray,
      ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: TfSpace.sm),
      child: Text(
        rangeTitle(context, mode, anchor, range.first, range.last),
        key: const Key('cal-title'),
        style: context.tf.typography.lead.copyWith(
          color: context.tf.colors.text,
        ),
      ),
    ),
    if (!compact) ...[
      TfSegmented<CalendarMode>(
        key: const Key('cal-mode'),
        scrollable: false,
        options: {
          CalendarMode.month: l10n.grpEMonth,
          CalendarMode.week: l10n.grpEWeek,
          CalendarMode.day: l10n.grpEDay,
        },
        value: mode,
        onChanged: (m) => notifier.update((l) => l.copyWith(mode: m.name)),
      ),
      ToolbarMenu(
        key: const Key('cal-color-menu'),
        icon: TfIcons.palette,
        label: l10n.grpEColourChip,
        items: [
          for (final c in [if (workspaceWide) 'project', 'status', 'priority'])
            TfMenuItem(
              key: Key('cal-color-$c'),
              label: switch (c) {
                'project' => l10n.grpEColourByProject,
                'status' => l10n.grpEColourByStatus,
                _ => l10n.grpEColourByPriority,
              },
              selected: layout.colorBy == c,
              onSelected: () => notifier.update((l) => l.copyWith(colorBy: c)),
            ),
        ],
      ),
      ToolbarMenu(
        key: const Key('cal-week-menu'),
        icon: TfIcons.calendarRange,
        label: l10n.grpEWeek,
        items: [
          for (final d in _weekdayKeys)
            TfMenuItem(
              key: Key('cal-week-$d'),
              label: _weekdayName(context, d),
              selected: layout.weekStart == d,
              onSelected: () =>
                  notifier.update((l) => l.copyWith(weekStart: d)),
            ),
        ],
      ),
    ],
    ToolbarToggle(
      key: const Key('cal-hide-done'),
      label: l10n.grpEHideDone,
      on: layout.hideDone,
      onChanged: (v) => notifier.update((l) => l.copyWith(hideDone: v)),
    ),
    ToolbarIcon(
      key: const Key('cal-refresh'),
      icon: TfIcons.refresh,
      tooltip: l10n.grpERefresh,
      onPressed: () => ref.read(calendarProvider(projectId).notifier).refresh(),
    ),
    if (state.saveFailed)
      SaveFailedMark(
        message: l10n.grpELayoutNotSaved,
        markKey: const Key('cal-layout-not-saved'),
      ),
  ];
}
