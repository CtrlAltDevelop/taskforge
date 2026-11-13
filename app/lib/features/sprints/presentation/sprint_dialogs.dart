import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

const _badCapacity = -1.0;

/// A capacity typed in a box: null when empty, [_badCapacity] when it is not
/// a non-negative number.
double? _capacity(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final value = double.tryParse(text);
  return value == null || value < 0 ? _badCapacity : value;
}

/// Create ([sprint] null) or edit a sprint. Overlap with other sprints is
/// shown while typing and again from the server's warnings after saving.
class SprintFormDialog extends ConsumerStatefulWidget {
  const SprintFormDialog({
    super.key,
    required this.projectId,
    required this.others,
    this.sprint,
    this.today,
  });

  final String projectId;
  final List<Sprint> others;
  final Sprint? sprint;
  final DateTime? today;

  @override
  ConsumerState<SprintFormDialog> createState() => _SprintFormState();
}

class _SprintFormState extends ConsumerState<SprintFormDialog> {
  late final _name = TextEditingController(text: widget.sprint?.name ?? '');
  late final _goal = TextEditingController(text: widget.sprint?.goal ?? '');
  late final _start = TextEditingController(
    text: dayText(widget.sprint?.startDate ?? _today),
  );
  late final _end = TextEditingController(
    text: dayText(
      widget.sprint?.endDate ?? _today.add(const Duration(days: 13)),
    ),
  );
  late final _capacityPoints = TextEditingController(
    text: widget.sprint?.capacityPoints == null
        ? ''
        : decimalText(widget.sprint!.capacityPoints!),
  );
  late final _capacityHours = TextEditingController(
    text: widget.sprint?.capacitySec == null
        ? ''
        : decimalText(widget.sprint!.capacitySec! / 3600),
  );
  var _busy = false;
  String? _error;
  List<String>? _saved; // warnings after a save that went through

  DateTime get _today => widget.today ?? ref.read(sprintTodayProvider)();

  @override
  void dispose() {
    _name.dispose();
    _goal.dispose();
    _start.dispose();
    _end.dispose();
    _capacityPoints.dispose();
    _capacityHours.dispose();
    super.dispose();
  }

  Future<void> _pick(TextEditingController c) async {
    final now = parseDay(c.text) ?? _today;
    final d = await showAppDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => c.text = dayText(d));
  }

  Future<void> _save() async {
    final l = context.l10n;
    final start = parseDay(_start.text);
    final end = parseDay(_end.text);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l.grpASprintNameRequired);
      return;
    }
    if (start == null || end == null) {
      setState(() => _error = l.grpASprintDatesFormat);
      return;
    }
    if (end.isBefore(start)) {
      setState(() => _error = l.grpASprintEndBeforeStart);
      return;
    }
    final points = _capacity(_capacityPoints.text);
    final hours = _capacity(_capacityHours.text);
    if (points == _badCapacity || hours == _badCapacity) {
      setState(() => _error = l.grpASprintCapacityNumber);
      return;
    }
    final capacityPoints = points == null ? '' : decimalText(points);
    final capacitySec = hours == null ? 0 : (hours * 3600).round();
    setState(() {
      _busy = true;
      _error = null;
    });
    final actions = ref.read(sprintActionsProvider);
    try {
      final existing = widget.sprint;
      final answer = existing == null
          ? await actions.create(
              widget.projectId,
              name: _name.text.trim(),
              goal: _goal.text.trim(),
              start: start,
              end: end,
              capacityPoints: capacityPoints,
              capacitySec: capacitySec,
            )
          : await actions.edit(
              existing,
              name: _name.text.trim(),
              goal: _goal.text.trim(),
              start: start,
              end: end,
              capacityPoints: capacityPoints,
              capacitySec: capacitySec,
            );
      if (!mounted) return;
      if (answer.warnings.isEmpty) {
        Navigator.of(context).pop(answer.sprint);
      } else {
        setState(() {
          _busy = false;
          _saved = answer.warnings;
        });
      }
    } on SprintException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = sprintErrorMessage(e, context.l10n);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    if (saved != null) {
      return AlertDialog(
        title: Text(context.l10n.grpASprintSaved),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final w in saved) Text(w, key: const Key('sprint-warning')),
          ],
        ),
        actions: [
          FilledButton(
            key: const Key('sprint-done'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.grpADone),
          ),
        ],
      );
    }
    final start = parseDay(_start.text);
    final end = parseDay(_end.text);
    final clash = start == null || end == null
        ? const <Sprint>[]
        : overlapping(
            widget.others,
            start,
            end,
            exceptId: widget.sprint?.id ?? '',
          );
    return AlertDialog(
      title: Text(
        widget.sprint == null
            ? context.l10n.grpANewSprint
            : context.l10n.grpAEditSprint,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('sprint-name'),
                controller: _name,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.grpASprintName,
                ),
              ),
              TextField(
                key: const Key('sprint-goal'),
                controller: _goal,
                decoration: InputDecoration(
                  labelText: context.l10n.grpASprintGoal,
                ),
              ),
              TextField(
                key: const Key('sprint-start'),
                controller: _start,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: context.l10n.grpASprintStartLabel,
                  suffixIcon: IconButton(
                    tooltip: context.l10n.grpAPickStartDate,
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pick(_start),
                  ),
                ),
              ),
              TextField(
                key: const Key('sprint-end'),
                controller: _end,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: context.l10n.grpASprintEndLabel,
                  suffixIcon: IconButton(
                    tooltip: context.l10n.grpAPickEndDate,
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pick(_end),
                  ),
                ),
              ),
              TextField(
                key: const Key('sprint-capacity-points'),
                controller: _capacityPoints,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.grpACapacityPointsOptional,
                ),
              ),
              TextField(
                key: const Key('sprint-capacity-hours'),
                controller: _capacityHours,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.grpACapacityHoursOptional,
                ),
              ),
              if (clash.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.grpASprintOverlap(
                      clash.map((s) => s.name).join(', '),
                    ),
                    key: const Key('sprint-overlap'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    key: const Key('sprint-form-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpACancel),
        ),
        FilledButton(
          key: const Key('sprint-save'),
          onPressed: _busy ? null : _save,
          child: Text(context.l10n.grpASave),
        ),
      ],
    );
  }
}

/// What to do with the unfinished tasks when a sprint is completed.
typedef CarryChoice = ({String carryOver, String nextSprintId});

class CompleteSprintDialog extends StatefulWidget {
  const CompleteSprintDialog({
    super.key,
    required this.sprint,
    required this.planned,
  });

  final Sprint sprint;

  /// Planned sprints that could take the unfinished tasks.
  final List<Sprint> planned;

  @override
  State<CompleteSprintDialog> createState() => _CompleteState();
}

class _CompleteState extends State<CompleteSprintDialog> {
  late var _carry = widget.planned.isEmpty ? 'backlog' : 'next';
  late String _next = widget.planned.isEmpty ? '' : widget.planned.first.id;

  @override
  Widget build(BuildContext context) {
    final s = widget.sprint;
    final open = s.openTasks;
    return AlertDialog(
      title: Text(context.l10n.grpACompleteTitle(s.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.grpACompleteCounts(s.doneTasks, open),
            key: const Key('complete-counts'),
          ),
          if (open > 0) ...[
            const SizedBox(height: 8),
            Text(context.l10n.grpACompleteWhatHappens),
            RadioGroup<String>(
              groupValue: _carry,
              onChanged: (v) => setState(() => _carry = v ?? _carry),
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: const Key('carry-next'),
                    value: 'next',
                    enabled: widget.planned.isNotEmpty,
                    title: Text(context.l10n.grpACompleteMoveNext),
                    subtitle: widget.planned.isEmpty
                        ? Text(context.l10n.grpACompleteNoPlanned)
                        : null,
                  ),
                  RadioListTile<String>(
                    key: const Key('carry-backlog'),
                    value: 'backlog',
                    title: Text(context.l10n.grpACompleteBackToBacklog),
                  ),
                ],
              ),
            ),
            if (_carry == 'next' && widget.planned.length > 1)
              DropdownButton<String>(
                key: const Key('carry-next-sprint'),
                value: _next,
                isExpanded: true,
                items: [
                  for (final p in widget.planned)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => setState(() => _next = v ?? _next),
              ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpACancel),
        ),
        FilledButton(
          key: const Key('complete-confirm'),
          onPressed: () => Navigator.of(context).pop<CarryChoice>((
            carryOver: open == 0 ? 'backlog' : _carry,
            nextSprintId: open > 0 && _carry == 'next' ? _next : '',
          )),
          child: Text(context.l10n.grpACompleteSprint),
        ),
      ],
    );
  }
}

/// Asks for a task's story points; returns the text ('' clears).
class PointsDialog extends StatefulWidget {
  const PointsDialog({super.key, required this.task});

  final SprintTask task;

  @override
  State<PointsDialog> createState() => _PointsState();
}

class _PointsState extends State<PointsDialog> {
  late final _c = TextEditingController(
    text: widget.task.points == null ? '' : pointsText(widget.task.points!),
  );
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _ok() {
    final t = _c.text.trim();
    if (t.isNotEmpty) {
      final v = double.tryParse(t);
      if (v == null || v < 0) {
        setState(() => _error = context.l10n.grpAPointsInvalid);
        return;
      }
    }
    Navigator.of(context).pop(t);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpAPointsFor(widget.task.key)),
    content: TextField(
      key: const Key('points-field'),
      controller: _c,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: context.l10n.grpAStoryPoints,
        errorText: _error,
      ),
      onSubmitted: (_) => _ok(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.grpACancel),
      ),
      FilledButton(
        key: const Key('points-save'),
        onPressed: _ok,
        child: Text(context.l10n.grpASave),
      ),
    ],
  );
}

/// Asks for the sprint's capacity; returns the text ('' clears it).
class CapacityDialog extends StatefulWidget {
  const CapacityDialog({super.key, required this.hours, this.value});

  final bool hours;
  final double? value;

  @override
  State<CapacityDialog> createState() => _CapacityState();
}

class _CapacityState extends State<CapacityDialog> {
  late final _c = TextEditingController(
    text: widget.value == null ? '' : decimalText(widget.value!),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.hours
          ? context.l10n.grpACapacityInHours
          : context.l10n.grpACapacityInPoints,
    ),
    content: TextField(
      key: const Key('capacity-field'),
      controller: _c,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.grpACancel),
      ),
      FilledButton(
        key: const Key('capacity-save'),
        onPressed: () => Navigator.of(context).pop(_c.text.trim()),
        child: Text(context.l10n.grpASave),
      ),
    ],
  );
}
