import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/recurrence/application/recurrence_providers.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/core/i18n/weekday_names.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

Future<void> showRepeatEditor(
  BuildContext context, {
  required Task task,
  RepeatSeries? series,
}) => showDialog<void>(
  context: context,
  builder: (_) => RepeatEditor(task: task, series: series),
);

/// Sets, changes, pauses or stops how a task repeats. The sentence and the next
/// five dates under the form come from the server (the dates it will make).
class RepeatEditor extends ConsumerStatefulWidget {
  const RepeatEditor({super.key, required this.task, this.series});

  final Task task;
  final RepeatSeries? series;

  @override
  ConsumerState<RepeatEditor> createState() => _RepeatEditorState();
}

class _RepeatEditorState extends ConsumerState<RepeatEditor> {
  late RepeatDraft _draft;
  String? _error;
  var _busy = false;

  RepeatTarget get _target =>
      (project: widget.task.projectId, task: widget.task.id);

  @override
  void initState() {
    super.initState();
    _draft = widget.series?.draft ?? _fresh();
  }

  RepeatDraft _fresh() => RepeatDraft(
    weekdays: {_weekdayOf(widget.task.dueDate)},
    monthDay: _dayOf(widget.task.dueDate),
  );

  static int _weekdayOf(String iso) =>
      ((DateTime.tryParse(iso) ?? DateTime.now()).weekday - 1) % 7;

  static int _dayOf(String iso) =>
      (DateTime.tryParse(iso) ?? DateTime.now()).day;

  /// Where the server counts from: the series' own start and its latest
  /// instance when it already runs, so the preview is what the clock makes.
  PreviewKey get _anchor {
    final series = widget.series;
    if (series == null) {
      return (draft: _draft, startsOn: widget.task.dueDate, after: '');
    }
    final next = DateTime.tryParse(series.nextDueOn);
    final after = next == null
        ? widget.task.dueDate
        : next
              .subtract(const Duration(days: 1))
              .toIso8601String()
              .substring(0, 10);
    return (
      draft: _draft,
      startsOn: series.startsOn.isEmpty ? widget.task.dueDate : series.startsOn,
      after: after,
    );
  }

  void _edit(RepeatDraft next) => setState(() {
    _draft = next;
    _error = null;
  });

  Future<void> _run(Future<void> Function() call, {bool close = true}) async {
    setState(() => _busy = true);
    try {
      await call();
      if (mounted && close) Navigator.pop(context);
    } on RepeatException catch (e) {
      if (mounted) setState(() => _error = repeatErrorMessage(e, context.l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() {
    final problem = _draft.problem;
    if (problem != null) {
      setState(() => _error = problem);
      return Future.value();
    }
    return _run(() => ref.read(repeatActionsProvider).set(_target, _draft));
  }

  Future<void> _applyToFuture() => _run(() async {
    final changed = await ref.read(repeatActionsProvider).updateFuture(_target);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changed == 0
              ? context.l10n.grpDRepeatNothingToUpdate
              : context.l10n.grpDRepeatUpdatedLater(changed),
        ),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final series = widget.series;
    final unsupported = series != null && series.draft == null;
    final preview = unsupported
        ? const AsyncData<RepeatPreview?>(null)
        : ref.watch(repeatPreviewProvider(_anchor));
    return AlertDialog(
      key: const Key('repeat-editor'),
      title: Text(context.l10n.grpDRepeat),
      content: unsupported
          ? Text(
              context.l10n.grpDRepeatUnsupported(series.summary),
              key: const Key('repeat-unsupported'),
            )
          : SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<RepeatKind>(
                      key: const Key('repeat-mode'),
                      segments: [
                        for (final m in RepeatKind.values)
                          ButtonSegment(
                            value: m,
                            label: Text(m.labelIn(context.l10n)),
                          ),
                      ],
                      selected: {_draft.mode},
                      onSelectionChanged: (s) =>
                          _edit(_draft.copyWith(mode: s.first)),
                    ),
                    const SizedBox(height: 12),
                    _EveryRow(draft: _draft, onChanged: _edit),
                    if (_draft.mode == RepeatKind.schedule) ...[
                      if (_draft.freq == RepeatFreq.weekly)
                        _Weekdays(draft: _draft, onChanged: _edit),
                      if (_draft.freq == RepeatFreq.monthly)
                        _Monthly(draft: _draft, onChanged: _edit),
                    ],
                    const SizedBox(height: 8),
                    _EndRow(draft: _draft, onChanged: _edit),
                    SwitchListTile(
                      key: const Key('repeat-skip-weekends'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.grpDSkipWeekends),
                      value: _draft.skipWeekends,
                      onChanged: (v) => _edit(_draft.copyWith(skipWeekends: v)),
                    ),
                    if (_draft.mode == RepeatKind.schedule)
                      _Timing(draft: _draft, onChanged: _edit),
                    const Divider(),
                    _PreviewBox(preview: preview, problem: _draft.problem),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          key: const Key('repeat-error'),
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
        if (series != null) ...[
          TextButton(
            key: const Key('repeat-stop'),
            onPressed: _busy
                ? null
                : () => _run(
                    () => ref.read(repeatActionsProvider).clear(_target),
                  ),
            child: Text(context.l10n.grpDStopRepeating),
          ),
          TextButton(
            key: const Key('repeat-pause'),
            onPressed: _busy
                ? null
                : () => _run(
                    () => ref
                        .read(repeatActionsProvider)
                        .pause(_target, paused: !series.paused),
                  ),
            child: Text(
              series.paused ? context.l10n.grpDResume : context.l10n.grpDPause,
            ),
          ),
          TextButton(
            key: const Key('repeat-future'),
            onPressed: _busy ? null : _applyToFuture,
            child: Text(context.l10n.grpDUseForFuture),
          ),
        ],
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(context.l10n.grpDCancel),
        ),
        if (!unsupported)
          FilledButton(
            key: const Key('repeat-save'),
            onPressed: _busy ? null : _save,
            child: Text(context.l10n.grpDSave),
          ),
      ],
    );
  }
}

class _EveryRow extends StatelessWidget {
  const _EveryRow({required this.draft, required this.onChanged});

  final RepeatDraft draft;
  final void Function(RepeatDraft) onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(context.l10n.grpDEvery),
      const SizedBox(width: 8),
      SizedBox(
        width: 64,
        child: TextFormField(
          key: const Key('repeat-interval'),
          initialValue: '${draft.interval}',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null) onChanged(draft.copyWith(interval: n));
          },
        ),
      ),
      const SizedBox(width: 8),
      DropdownButton<RepeatFreq>(
        key: const Key('repeat-freq'),
        value: draft.freq,
        items: [
          for (final f in RepeatFreq.values)
            DropdownMenuItem(
              value: f,
              child: Text(f.unitIn(context.l10n, plural: draft.interval != 1)),
            ),
        ],
        onChanged: (f) {
          if (f != null) onChanged(draft.copyWith(freq: f));
        },
      ),
    ],
  );
}

class _Weekdays extends StatelessWidget {
  const _Weekdays({required this.draft, required this.onChanged});

  final RepeatDraft draft;
  final void Function(RepeatDraft) onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    children: [
      for (var d = 0; d < 7; d++)
        FilterChip(
          key: Key('repeat-day-$d'),
          label: Text(context.l10n.weekdayShortNames[d]),
          selected: draft.weekdays.contains(d),
          onSelected: (on) => onChanged(
            draft.copyWith(
              weekdays: on
                  ? {...draft.weekdays, d}
                  : draft.weekdays.where((x) => x != d).toSet(),
            ),
          ),
        ),
    ],
  );
}

class _Monthly extends StatelessWidget {
  const _Monthly({required this.draft, required this.onChanged});

  final RepeatDraft draft;
  final void Function(RepeatDraft) onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RadioGroup<MonthlyBy>(
        groupValue: draft.monthlyBy,
        onChanged: (v) {
          if (v != null) onChanged(draft.copyWith(monthlyBy: v));
        },
        child: Column(
          children: [
            RadioListTile<MonthlyBy>(
              key: const Key('repeat-by-day'),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.grpDRepeatByDay),
              value: MonthlyBy.dayOfMonth,
            ),
            RadioListTile<MonthlyBy>(
              key: const Key('repeat-by-weekday'),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.grpDRepeatByWeekday),
              value: MonthlyBy.nthWeekday,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (draft.monthlyBy == MonthlyBy.dayOfMonth)
        DropdownButton<int>(
          key: const Key('repeat-month-day'),
          value: draft.monthDay,
          items: [
            for (var d = 1; d <= 31; d++)
              DropdownMenuItem(
                value: d,
                child: Text(context.l10n.grpDDayNumber(d)),
              ),
          ],
          onChanged: (d) {
            if (d != null) onChanged(draft.copyWith(monthDay: d));
          },
        )
      else
        Row(
          children: [
            DropdownButton<int>(
              key: const Key('repeat-nth'),
              value: draft.nth,
              items: [
                DropdownMenuItem(value: 1, child: Text(context.l10n.grpDNth1)),
                DropdownMenuItem(value: 2, child: Text(context.l10n.grpDNth2)),
                DropdownMenuItem(value: 3, child: Text(context.l10n.grpDNth3)),
                DropdownMenuItem(value: 4, child: Text(context.l10n.grpDNth4)),
                DropdownMenuItem(
                  value: -1,
                  child: Text(context.l10n.grpDNthLast),
                ),
              ],
              onChanged: (n) {
                if (n != null) onChanged(draft.copyWith(nth: n));
              },
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              key: const Key('repeat-nth-day'),
              value: draft.nthWeekday,
              items: [
                for (var d = 0; d < 7; d++)
                  DropdownMenuItem(
                    value: d,
                    child: Text(context.l10n.weekdayShortNames[d]),
                  ),
              ],
              onChanged: (d) {
                if (d != null) onChanged(draft.copyWith(nthWeekday: d));
              },
            ),
          ],
        ),
    ],
  );
}

class _EndRow extends StatelessWidget {
  const _EndRow({required this.draft, required this.onChanged});

  final RepeatDraft draft;
  final void Function(RepeatDraft) onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context: context,
      initialDate: DateTime.tryParse(draft.until) ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    final iso =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    onChanged(draft.copyWith(until: iso));
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(context.l10n.grpDEnds),
      const SizedBox(width: 12),
      DropdownButton<RepeatEnd>(
        key: const Key('repeat-end'),
        value: draft.end,
        items: [
          DropdownMenuItem(
            value: RepeatEnd.never,
            child: Text(context.l10n.grpDEndNever),
          ),
          DropdownMenuItem(
            value: RepeatEnd.count,
            child: Text(context.l10n.grpDEndAfter),
          ),
          DropdownMenuItem(
            value: RepeatEnd.until,
            child: Text(context.l10n.grpDEndOn),
          ),
        ],
        onChanged: (e) {
          if (e != null) onChanged(draft.copyWith(end: e));
        },
      ),
      const SizedBox(width: 8),
      if (draft.end == RepeatEnd.count) ...[
        SizedBox(
          width: 64,
          child: TextFormField(
            key: const Key('repeat-count'),
            initialValue: '${draft.count}',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null) onChanged(draft.copyWith(count: n));
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(context.l10n.grpDTasksWord),
      ],
      if (draft.end == RepeatEnd.until)
        TextButton(
          key: const Key('repeat-until'),
          onPressed: () => _pick(context),
          child: Text(
            draft.until.isEmpty ? context.l10n.grpDPickDate : draft.until,
          ),
        ),
    ],
  );
}

class _Timing extends StatelessWidget {
  const _Timing({required this.draft, required this.onChanged});

  final RepeatDraft draft;
  final void Function(RepeatDraft) onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(context.l10n.grpDMakeIt),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: TextFormField(
              key: const Key('repeat-lead'),
              initialValue: '${draft.leadDays}',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null) onChanged(draft.copyWith(leadDays: n));
              },
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(context.l10n.grpDDaysAhead)),
        ],
      ),
      ListTile(
        key: const Key('repeat-time'),
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.schedule),
        title: Text(
          context.l10n.grpDRepeatAt(context.localDigits(draft.atTime)),
        ),
        onTap: () async {
          final parts = draft.atTime.split(':');
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: int.tryParse(parts.first) ?? 9,
              minute: int.tryParse(parts.last) ?? 0,
            ),
          );
          if (picked == null) return;
          String two(int n) => n.toString().padLeft(2, '0');
          onChanged(
            draft.copyWith(atTime: '${two(picked.hour)}:${two(picked.minute)}'),
          );
        },
      ),
      const SizedBox(height: 4),
      DropdownButton<String>(
        key: const Key('repeat-zone'),
        isExpanded: true,
        value: repeatZones.contains(draft.zone) ? draft.zone : null,
        hint: Text(draft.zone),
        items: [
          for (final z in repeatZones)
            DropdownMenuItem(value: z, child: Text(z)),
        ],
        onChanged: (z) {
          if (z != null) onChanged(draft.copyWith(zone: z));
        },
      ),
    ],
  );
}

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({required this.preview, required this.problem});

  final AsyncValue<RepeatPreview?> preview;
  final String? problem;

  @override
  Widget build(BuildContext context) {
    if (problem != null) {
      return Text(problem!, key: const Key('repeat-problem'));
    }
    return preview.when(
      loading: () => const LinearProgressIndicator(key: Key('repeat-loading')),
      error: (e, _) => TfError(
        key: const Key('repeat-preview-error'),
        compact: true,
        message: repeatErrorMessage(e, context.l10n),
        details: '$e',
      ),
      data: (p) => p == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.summary,
                  key: const Key('repeat-summary'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  p.dates.isEmpty
                      ? context.l10n.grpDNoFurtherDates
                      : context.l10n.grpDNextDates(p.dates.join(', ')),
                  key: const Key('repeat-preview'),
                ),
              ],
            ),
    );
  }
}
