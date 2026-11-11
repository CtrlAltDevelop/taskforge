import 'package:flutter/material.dart';

import 'package:taskforge/features/inbox/domain/inbox.dart';

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
          for (final (i, p) in snoozePresets(now).indexed)
            ListTile(
              key: Key('snooze-preset-$i'),
              leading: const Icon(Icons.snooze),
              title: Text(p.label),
              subtitle: Text(_describe(p.at)),
              onTap: () => Navigator.of(sheet).pop(p.at),
            ),
          ListTile(
            key: const Key('snooze-custom'),
            leading: const Icon(Icons.edit_calendar_outlined),
            title: const Text('Pick date and time'),
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
  final day = await showDatePicker(
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

String _describe(DateTime at) {
  String two(int n) => n.toString().padLeft(2, '0');
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[at.weekday - 1]} ${two(at.hour)}:${two(at.minute)}';
}
