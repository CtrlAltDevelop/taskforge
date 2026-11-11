import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

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
    super.dispose();
  }

  Future<void> _pick(TextEditingController c) async {
    final now = parseDay(c.text) ?? _today;
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => c.text = dayText(d));
  }

  Future<void> _save() async {
    final start = parseDay(_start.text);
    final end = parseDay(_end.text);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give the sprint a name.');
      return;
    }
    if (start == null || end == null) {
      setState(() => _error = 'Dates are written YYYY-MM-DD.');
      return;
    }
    if (end.isBefore(start)) {
      setState(() => _error = 'The sprint cannot end before it starts.');
      return;
    }
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
            )
          : await actions.edit(
              existing,
              name: _name.text.trim(),
              goal: _goal.text.trim(),
              start: start,
              end: end,
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
        _error = sprintErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    if (saved != null) {
      return AlertDialog(
        title: const Text('Sprint saved'),
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
            child: const Text('Done'),
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
      title: Text(widget.sprint == null ? 'New sprint' : 'Edit sprint'),
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
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                key: const Key('sprint-goal'),
                controller: _goal,
                decoration: const InputDecoration(labelText: 'Goal'),
              ),
              TextField(
                key: const Key('sprint-start'),
                controller: _start,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Start (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    tooltip: 'Pick start date',
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
                  labelText: 'End (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    tooltip: 'Pick end date',
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pick(_end),
                  ),
                ),
              ),
              if (clash.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'These dates overlap ${clash.map((s) => s.name).join(', ')}.',
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('sprint-save'),
          onPressed: _busy ? null : _save,
          child: const Text('Save'),
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
      title: Text('Complete ${s.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${s.doneTasks} done, $open unfinished',
            key: const Key('complete-counts'),
          ),
          if (open > 0) ...[
            const SizedBox(height: 8),
            const Text('What happens to the unfinished tasks?'),
            RadioGroup<String>(
              groupValue: _carry,
              onChanged: (v) => setState(() => _carry = v ?? _carry),
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: const Key('carry-next'),
                    value: 'next',
                    enabled: widget.planned.isNotEmpty,
                    title: const Text('Move to the next sprint'),
                    subtitle: widget.planned.isEmpty
                        ? const Text('No planned sprint to move them to')
                        : null,
                  ),
                  const RadioListTile<String>(
                    key: Key('carry-backlog'),
                    value: 'backlog',
                    title: Text('Back to the backlog'),
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('complete-confirm'),
          onPressed: () => Navigator.of(context).pop<CarryChoice>((
            carryOver: open == 0 ? 'backlog' : _carry,
            nextSprintId: open > 0 && _carry == 'next' ? _next : '',
          )),
          child: const Text('Complete sprint'),
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
        setState(() => _error = 'Use a number, or leave empty to clear.');
        return;
      }
    }
    Navigator.of(context).pop(t);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Points for ${widget.task.key}'),
    content: TextField(
      key: const Key('points-field'),
      controller: _c,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Story points', errorText: _error),
      onSubmitted: (_) => _ok(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('points-save'),
        onPressed: _ok,
        child: const Text('Save'),
      ),
    ],
  );
}

/// Asks for the sprint's capacity; returns the text ('' clears it).
class CapacityDialog extends StatefulWidget {
  const CapacityDialog({super.key, required this.unit, this.value});

  final String unit;
  final double? value;

  @override
  State<CapacityDialog> createState() => _CapacityState();
}

class _CapacityState extends State<CapacityDialog> {
  late final _c = TextEditingController(
    text: widget.value == null ? '' : pointsText(widget.value!),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Capacity in ${widget.unit}'),
    content: TextField(
      key: const Key('capacity-field'),
      controller: _c,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('capacity-save'),
        onPressed: () => Navigator.of(context).pop(_c.text.trim()),
        child: const Text('Save'),
      ),
    ],
  );
}
