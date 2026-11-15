import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/jalali.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/locale_providers.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// A date picker in the calendar the person chose.
///
/// Gregorian uses Flutter's own picker; Jalali uses [_JalaliPickerDialog].
/// Either way the answer is a date-only Gregorian [DateTime], so nothing that
/// stores or compares dates needs to know a Jalali calendar exists.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  final prefs = ProviderScope.containerOf(context).read(localePrefsProvider);
  if (!prefs.isJalali) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
    );
  }
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  var initial = _dateOnly(initialDate);
  if (initial.isBefore(first)) initial = first;
  if (initial.isAfter(last)) initial = last;
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _JalaliPickerDialog(
      initial: initial,
      first: first,
      last: last,
      prefs: prefs,
      title: helpText,
    ),
  );
}

/// A date range picker in the calendar the person chose.
///
/// Gregorian uses Flutter's own range picker. Jalali asks for the first day
/// and then the last (which cannot be earlier than the first), each in the
/// Jalali dialog. The answer is a date-only Gregorian range either way.
Future<DateTimeRange?> showAppDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) async {
  final prefs = ProviderScope.containerOf(context).read(localePrefsProvider);
  if (!prefs.isJalali) {
    return showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
    );
  }
  final l10n = context.l10n;
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  final start = await showAppDatePicker(
    context: context,
    initialDate: initialDateRange?.start ?? last,
    firstDate: first,
    lastDate: last,
    helpText: l10n.grpAPickStartDate,
  );
  if (start == null || !context.mounted) return null;
  final end = await showAppDatePicker(
    context: context,
    initialDate:
        initialDateRange != null && !initialDateRange.end.isBefore(start)
        ? initialDateRange.end
        : start,
    firstDate: start,
    lastDate: last,
    helpText: l10n.grpAPickEndDate,
  );
  if (end == null) return null;
  return DateTimeRange(start: start, end: end);
}

class _JalaliPickerDialog extends StatefulWidget {
  const _JalaliPickerDialog({
    required this.initial,
    required this.first,
    required this.last,
    required this.prefs,
    this.title,
  });

  final DateTime initial;
  final DateTime first;
  final DateTime last;
  final LocalePrefs prefs;
  final String? title;

  @override
  State<_JalaliPickerDialog> createState() => _JalaliPickerDialogState();
}

class _JalaliPickerDialogState extends State<_JalaliPickerDialog> {
  late DateTime _selected = widget.initial;
  late JalaliDate _month = JalaliDate.fromGregorian(widget.initial)
      .copyWith(day: 1);

  bool _allowed(DateTime d) =>
      !d.isBefore(widget.first) && !d.isAfter(widget.last);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prefs = widget.prefs;
    final theme = Theme.of(context);
    final weekdays = MaterialLocalizations.of(context).narrowWeekdays;
    final start = prefs.weekStartDay; // 1 Monday ... 7 Sunday
    final length = jalaliMonthLength(_month.year, _month.month);
    // How many cells to leave empty before day 1.
    final offset = (_month.weekday - start + 7) % 7;
    final selectedJalali = JalaliDate.fromGregorian(_selected);

    return AlertDialog(
      title: Text(widget.title ?? l10n.pickDateTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('jalali-prev'),
                  tooltip: l10n.previousMonth,
                  // Directional: the arrow flips with the text direction.
                  icon: const BackButtonIcon(),
                  onPressed: () =>
                      setState(() => _month = _month.addMonths(-1)),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      prefs.digits(
                        '${jalaliMonthName(l10n, _month.month)} ${_month.year}',
                      ),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('jalali-next'),
                  tooltip: l10n.nextMonth,
                  icon: Transform.flip(
                    flipX: Directionality.of(context) == TextDirection.rtl,
                    child: const Icon(Icons.chevron_right),
                  ),
                  onPressed: () => setState(() => _month = _month.addMonths(1)),
                ),
              ],
            ),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    // narrowWeekdays starts on Sunday (index 0); ISO Sunday is 7.
                    child: Center(child: Text(weekdays[(start + i) % 7])),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (var row = 0; row * 7 < offset + length; row++)
              Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: _cell(
                        row * 7 + col - offset + 1,
                        length,
                        selectedJalali,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text(l10n.pickDateOk),
        ),
      ],
    );
  }

  Widget _cell(int day, int length, JalaliDate selected) {
    if (day < 1 || day > length) return const SizedBox(height: 40);
    final date = JalaliDate(_month.year, _month.month, day).toGregorian();
    final allowed = _allowed(date);
    final isSelected = selected == JalaliDate(_month.year, _month.month, day);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        key: Key('jalali-day-$day'),
        customBorder: const CircleBorder(),
        onTap: allowed ? () => setState(() => _selected = date) : null,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(color: colors.primary, shape: BoxShape.circle)
              : null,
          child: Text(
            widget.prefs.digits('$day'),
            style: TextStyle(
              color: isSelected
                  ? colors.onPrimary
                  : allowed
                  ? null
                  : colors.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
      ),
    );
  }
}
