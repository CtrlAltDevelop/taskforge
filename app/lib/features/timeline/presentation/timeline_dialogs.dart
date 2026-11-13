import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/core/i18n/weekday_names.dart';

/// What the person chose for a move that would push dependents.
enum ShiftChoice { shift, keep, cancel }

/// Lists the dependents a move pushes and asks: shift them too, or keep them
/// where they are (and show the conflict). Dismissing counts as cancel.
Future<ShiftChoice> askShift(BuildContext context, ShiftPlan plan) async {
  final choice = await showDialog<ShiftChoice>(
    context: context,
    builder: (ctx) => AlertDialog(
      key: const Key('shift-dialog'),
      title: Text(
        ctx.l10n.grpIMovingPushes(plan.task.displayId, plan.shifts.length),
      ),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final s in plan.shifts)
              ListTile(
                dense: true,
                title: Text(
                  '${s.task.displayId}  ${s.task.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  ctx.l10n.grpIRangeShift(
                    _range(s.task.startDate, s.task.dueDate),
                    _range(s.newStart, s.newDue),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('shift-cancel'),
          onPressed: () => Navigator.pop(context, ShiftChoice.cancel),
          child: Text(ctx.l10n.grpICancel),
        ),
        TextButton(
          key: const Key('shift-keep'),
          onPressed: () => Navigator.pop(context, ShiftChoice.keep),
          child: Text(ctx.l10n.grpIKeepThem),
        ),
        FilledButton(
          key: const Key('shift-apply'),
          onPressed: () => Navigator.pop(context, ShiftChoice.shift),
          child: Text(ctx.l10n.grpIShiftDependents),
        ),
      ],
    ),
  );
  return choice ?? ShiftChoice.cancel;
}

String _range(String start, String due) => start.isNotEmpty && due.isNotEmpty
    ? '$start – $due'
    : (due.isEmpty ? start : due);

List<String> _weekdayNames(AppLocalizations l) => l.weekdayShortNames;

/// Edits the working weekdays and holidays; null when cancelled.
Future<WorkingDays?> editWorkingDays(
  BuildContext context,
  WorkingDays current,
) => showDialog<WorkingDays>(
  context: context,
  builder: (_) => _WorkingDaysDialog(current),
);

class _WorkingDaysDialog extends StatefulWidget {
  const _WorkingDaysDialog(this.current);

  final WorkingDays current;

  @override
  State<_WorkingDaysDialog> createState() => _WorkingDaysDialogState();
}

class _WorkingDaysDialogState extends State<_WorkingDaysDialog> {
  late final Set<int> _days = {...widget.current.days};
  late final _holidays = TextEditingController(
    text: widget.current.holidays.join(', '),
  );

  @override
  void dispose() {
    _holidays.dispose();
    super.dispose();
  }

  List<String> get _holidayList => [
    for (final h in _holidays.text.split(RegExp(r'[,\s]+')))
      if (h.isNotEmpty) h,
  ];

  @override
  Widget build(BuildContext context) => AlertDialog(
    key: const Key('working-days-dialog'),
    title: Text(context.l10n.grpIWorkingDays),
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.grpIWorkingDaysHint),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < 7; i++)
                FilterChip(
                  key: Key('working-day-$i'),
                  label: Text(_weekdayNames(context.l10n)[i]),
                  selected: _days.contains(i),
                  onSelected: (on) =>
                      setState(() => on ? _days.add(i) : _days.remove(i)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('holidays-field'),
            controller: _holidays,
            decoration: InputDecoration(
              labelText: context.l10n.grpIHolidays,
              helperText: context.l10n.grpIHolidaysHint,
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpICancel),
      ),
      FilledButton(
        key: const Key('working-days-save'),
        onPressed: () => Navigator.pop(
          context,
          WorkingDays(days: [..._days]..sort(), holidays: _holidayList),
        ),
        child: Text(context.l10n.grpISave),
      ),
    ],
  );
}
