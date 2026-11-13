import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/core/i18n/weekday_names.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Asks until when to hide a notification: a preset or a date and time of the
/// person's choosing. Null when they back out.
Future<DateTime?> pickSnooze(BuildContext context, DateTime now) async {
  final choice = await showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, p) in snoozePresets(now, l10n: sheet.l10n).indexed)
            ListTile(
              key: Key('snooze-preset-$i'),
              leading: const Icon(Icons.snooze),
              title: Text(p.label),
              subtitle: Text(sheet.localDigits(_describe(p.at, sheet.l10n))),
              onTap: () => Navigator.of(sheet).pop(p.at),
            ),
          ListTile(
            key: const Key('snooze-custom'),
            leading: const Icon(Icons.edit_calendar_outlined),
            title: Text(sheet.l10n.grpHPickDateTime),
            onTap: () async {
              final custom = await _pickDateTime(sheet, now);
              if (sheet.mounted) Navigator.of(sheet).pop(custom);
            },
          ),
        ],
      ),
    ),
  );
  return choice;
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime now) async {
  final day = await showAppDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
  );
  if (day == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
  );
  if (time == null) return null;
  final at = DateTime(day.year, day.month, day.day, time.hour, time.minute);
  return at.isAfter(now) ? at : null;
}

String _describe(DateTime at, AppLocalizations l) {
  String two(int n) => n.toString().padLeft(2, '0');
  final days = l.weekdayShortNames;
  return '${days[at.weekday - 1]} ${two(at.hour)}:${two(at.minute)}';
}
