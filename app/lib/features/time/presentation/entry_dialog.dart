import 'package:flutter/material.dart';

import 'package:taskforge/features/time/domain/time.dart';

/// What the dialog gives back. When editing, [startedAt] and [durationSec] are
/// null unless the person changed them, so saving a note never rewrites the
/// time the timer measured; for a new entry they are always set.
typedef EntryInput = ({
  DateTime? startedAt,
  int? durationSec,
  String note,
  bool billable,
});

/// Asks for a manual entry, or the changes to [existing]. [day] fixes the
/// date (the timesheet cell); otherwise it is chosen. Returns null when
/// cancelled.
Future<EntryInput?> askEntry(
  BuildContext context, {
  TimeEntry? existing,
  DateTime? day,
  DateTime Function()? now,
}) => showDialog<EntryInput>(
  context: context,
  builder: (_) => _EntryDialog(existing: existing, day: day, now: now),
);

class _EntryDialog extends StatefulWidget {
  const _EntryDialog({this.existing, this.day, this.now});

  final TimeEntry? existing;
  final DateTime? day;
  final DateTime Function()? now;

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  // A running entry has no duration to edit yet.
  late final _duration = TextEditingController(
    text: widget.existing == null || widget.existing!.running
        ? ''
        : durationText(widget.existing!.durationSec),
  );
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  late var _billable = widget.existing?.billable ?? false;
  late DateTime _date = _initialDate();
  String? _problem;

  DateTime get _now => (widget.now ?? DateTime.now)();

  DateTime _initialDate() {
    final e = widget.existing;
    final d = widget.day ?? e?.startedAt.toLocal() ?? _now;
    return DateTime(d.year, d.month, d.day);
  }

  @override
  void dispose() {
    _duration.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: _now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final existing = widget.existing;
    final editingRunning = existing != null && existing.running;
    final seconds = editingRunning ? null : parseDuration(_duration.text);
    if (!editingRunning && seconds == null) {
      setState(() => _problem = 'Enter a time like 1h 30m, 90m or 1:30.');
      return;
    }
    DateTime? started;
    int? length;
    if (existing == null) {
      length = seconds;
      started = _startFor(seconds!);
    } else if (!editingRunning) {
      // Only what changed: minutes shown are not the seconds measured.
      if (seconds != existing.durationSec ~/ 60 * 60) length = seconds;
      final was = existing.startedAt.toLocal();
      if (_date != DateTime(was.year, was.month, was.day)) {
        started = DateTime(
          _date.year,
          _date.month,
          _date.day,
          was.hour,
          was.minute,
        );
      }
    }
    Navigator.of(context).pop((
      startedAt: started,
      durationSec: length,
      note: _note.text.trim(),
      billable: _billable,
    ));
  }

  /// A new entry starts at 09:00 that day, or earlier if that would end in
  /// the future (today, before nine).
  DateTime _startFor(int seconds) {
    final nine = DateTime(_date.year, _date.month, _date.day, 9);
    final now = _now;
    return nine.add(Duration(seconds: seconds)).isAfter(now)
        ? now.subtract(Duration(seconds: seconds))
        : nine;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'Add time' : 'Edit time'),
    content: SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.existing?.running != true)
            TextField(
              key: const Key('entry-duration'),
              controller: _duration,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Time spent',
                hintText: '1h 30m',
                errorText: _problem,
              ),
              onSubmitted: (_) => _save(),
            ),
          if (widget.day == null && widget.existing?.running != true)
            ListTile(
              key: const Key('entry-date'),
              contentPadding: EdgeInsets.zero,
              title: Text(isoDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
          TextField(
            key: const Key('entry-note'),
            controller: _note,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          SwitchListTile(
            key: const Key('entry-billable'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Billable'),
            value: _billable,
            onChanged: (v) => setState(() => _billable = v),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('entry-save'),
        onPressed: _save,
        child: const Text('Save'),
      ),
    ],
  );
}

/// Asks for a task's estimate; 0 clears. Null when cancelled.
Future<int?> askEstimate(BuildContext context, int currentSec) =>
    showDialog<int>(
      context: context,
      builder: (_) => _EstimateDialog(currentSec),
    );

class _EstimateDialog extends StatefulWidget {
  const _EstimateDialog(this.currentSec);

  final int currentSec;

  @override
  State<_EstimateDialog> createState() => _EstimateDialogState();
}

class _EstimateDialogState extends State<_EstimateDialog> {
  late final _text = TextEditingController(
    text: widget.currentSec > 0 ? durationText(widget.currentSec) : '',
  );
  String? _problem;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    if (_text.text.trim().isEmpty) {
      Navigator.of(context).pop(0);
      return;
    }
    final seconds = parseDuration(_text.text);
    if (seconds == null) {
      setState(() => _problem = 'Enter a time like 1h 30m, 90m or 1:30.');
      return;
    }
    Navigator.of(context).pop(seconds);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Estimate'),
    content: TextField(
      key: const Key('estimate-field'),
      controller: _text,
      autofocus: true,
      decoration: InputDecoration(
        labelText: 'Estimated time',
        hintText: 'Empty for none',
        errorText: _problem,
      ),
      onSubmitted: (_) => _save(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('estimate-save'),
        onPressed: _save,
        child: const Text('Save'),
      ),
    ],
  );
}

/// Asks before deleting logged time. True when confirmed.
Future<bool> confirmDelete(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this time?'),
        content: const Text('The logged time is removed for good.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
    false;
