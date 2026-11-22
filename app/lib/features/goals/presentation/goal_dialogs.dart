import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/goals/application/goals_providers.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/features/goals/presentation/goal_widgets.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// Asks for a folder name; null when cancelled.
Future<String?> showFolderDialog(BuildContext context, {String initial = ''}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (c) => TfDialogFrame(
      title: c.l10n.goalsFolderName,
      content: TextField(
        key: const Key('folder-name'),
        controller: controller,
        autofocus: true,
        maxLength: 80,
        decoration: InputDecoration(labelText: c.l10n.goalsFolderName),
      ),
      actions: [
        TfButton(
          label: c.l10n.grpCCancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(c).pop(),
        ),
        TfButton(
          key: const Key('save-folder'),
          label: c.l10n.goalsSave,
          variant: TfButtonVariant.primary,
          onPressed: () => Navigator.of(c).pop(controller.text.trim()),
        ),
      ],
    ),
  );
}

/// The goal form: create (no [goal]) or edit.
Future<GoalDraft?> showGoalDialog(
  BuildContext context, {
  required GoalCatalog catalog,
  required List<Member> members,
  required String me,
  Goal? goal,
  String parentId = '',
}) => showDialog<GoalDraft>(
  context: context,
  builder: (_) => _GoalDialog(
    catalog: catalog,
    members: members,
    me: me,
    goal: goal,
    parentId: parentId,
  ),
);

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({
    required this.catalog,
    required this.members,
    required this.me,
    required this.goal,
    required this.parentId,
  });

  final GoalCatalog catalog;
  final List<Member> members;
  final String me;
  final Goal? goal;
  final String parentId;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final _name = TextEditingController(text: widget.goal?.name ?? '');
  late final _description = TextEditingController(
    text: widget.goal?.description ?? '',
  );
  late DateTime _start;
  late DateTime _end;
  late String _owner;
  late String _parent;
  late String _folder;
  late bool _private;
  late String _weight;
  late String _override;
  late Set<String> _contributors;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    final (qs, qe) = quarterOf(DateTime.now());
    _start = g?.start ?? qs;
    _end = g?.end ?? qe;
    _owner = g?.ownerId ?? widget.me;
    _parent = g?.parentId ?? widget.parentId;
    _folder = g?.folderId ?? '';
    _private = g?.private ?? false;
    _weight = trimNumber(g?.weight ?? '1');
    _override = g?.statusOverride ?? '';
    _contributors = {...?g?.contributorIds};
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickPeriod() async {
    final picked = await showAppDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _start, end: _end),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
    }
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      GoalDraft(
        name: name,
        description: _description.text.trim(),
        periodStart: isoDay(_start),
        periodEnd: isoDay(_end),
        ownerId: _owner,
        parentId: _parent,
        folderId: _folder,
        private: _private,
        weight: _weight,
        statusOverride: _override,
        contributorIds: _contributors.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final editing = widget.goal != null;
    final parents = [
      for (final g in widget.catalog.goals)
        if (g.id != widget.goal?.id) g,
    ];
    return TfDialogFrame(
      title: editing ? t.goalsEdit : t.goalsNew,
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('goal-name'),
                controller: _name,
                autofocus: true,
                maxLength: 160,
                decoration: InputDecoration(labelText: t.goalsName),
              ),
              const SizedBox(height: TfSpace.md),
              TextField(
                key: const Key('goal-description'),
                controller: _description,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(labelText: t.goalsDescription),
              ),
              const SizedBox(height: TfSpace.md),
              TfButton(
                key: const Key('goal-period'),
                label: t.goalsPeriod(
                  context.localDate(_start),
                  context.localDate(_end),
                ),
                icon: TfIcons.calendarRange,
                onPressed: _pickPeriod,
              ),
              const SizedBox(height: TfSpace.md),
              TfSelectField(
                key: const Key('goal-owner'),
                options: {for (final m in widget.members) m.userId: m.label},
                value: widget.members.any((m) => m.userId == _owner)
                    ? _owner
                    : null,
                onChanged: (v) => setState(() => _owner = v),
                label: t.goalsOwner,
                expand: true,
              ),
              const SizedBox(height: TfSpace.md),
              TfSelectField(
                key: const Key('goal-parent'),
                options: {
                  '': t.goalsNone,
                  for (final g in parents) g.id: g.name,
                },
                value: parents.any((g) => g.id == _parent) ? _parent : '',
                onChanged: (v) => setState(() => _parent = v),
                label: t.goalsParent,
                expand: true,
              ),
              const SizedBox(height: TfSpace.md),
              TfSelectField(
                key: const Key('goal-folder'),
                options: {
                  '': t.goalsNoFolder,
                  for (final f in widget.catalog.folders) f.id: f.name,
                },
                value: widget.catalog.folders.any((f) => f.id == _folder)
                    ? _folder
                    : '',
                onChanged: (v) => setState(() => _folder = v),
                label: t.goalsFolder,
                expand: true,
              ),
              const SizedBox(height: TfSpace.md),
              TfSelectField(
                key: const Key('goal-weight'),
                options: {for (final w in goalWeights) w: w},
                value: goalWeights.contains(_weight) ? _weight : '1',
                onChanged: (v) => setState(() => _weight = v),
                label: t.goalsWeight,
                expand: true,
              ),
              const SizedBox(height: TfSpace.md),
              if (editing)
                TfSelectField(
                  key: const Key('goal-status'),
                  options: {
                    '': t.goalsStatusAuto,
                    for (final s in GoalStatus.values)
                      s.wire: goalStatusLabel(t, s),
                  },
                  value: _override,
                  onChanged: (v) => setState(() => _override = v),
                  label: t.goalsStatusLabel,
                  expand: true,
                ),
              const SizedBox(height: TfSpace.md),
              TfToggleTile(
                key: const Key('goal-private'),
                value: _private,
                onChanged: (v) => setState(() => _private = v),
                title: t.goalsPrivate,
                subtitle: t.goalsPrivateHint,
              ),
              Text(
                t.goalsContributors,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Wrap(
                spacing: TfSpace.xs,
                children: [
                  for (final m in widget.members)
                    if (m.userId != _owner)
                      FilterChip(
                        key: Key('contributor-${m.userId}'),
                        label: Text(m.label),
                        selected: _contributors.contains(m.userId),
                        onSelected: (on) => setState(() {
                          on
                              ? _contributors.add(m.userId)
                              : _contributors.remove(m.userId);
                        }),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TfButton(
          label: t.grpCCancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TfButton(
          key: const Key('save-goal'),
          label: t.goalsSave,
          variant: TfButtonVariant.primary,
          onPressed: _save,
        ),
      ],
    );
  }
}

/// The key result form: create (no [kr]) or edit. A type cannot change.
Future<KrDraft?> showKrDialog(BuildContext context, {KeyResult? kr}) =>
    showDialog<KrDraft>(
      context: context,
      builder: (_) => _KrDialog(kr: kr),
    );

class _KrDialog extends StatefulWidget {
  const _KrDialog({required this.kr});

  final KeyResult? kr;

  @override
  State<_KrDialog> createState() => _KrDialogState();
}

class _KrDialogState extends State<_KrDialog> {
  late final _name = TextEditingController(text: widget.kr?.name ?? '');
  late final _start = TextEditingController(
    text: trimNumber(widget.kr?.startValue ?? '0'),
  );
  late final _target = TextEditingController(
    text: trimNumber(widget.kr?.targetValue ?? '100'),
  );
  late final _current = TextEditingController(
    text: trimNumber(widget.kr?.currentValue ?? '0'),
  );
  late final _filter = TextEditingController(text: widget.kr?.filterText ?? '');
  late KrType _type = widget.kr?.type ?? KrType.number;
  late String _weight = trimNumber(widget.kr?.weight ?? '1');

  @override
  void dispose() {
    for (final c in [_name, _start, _target, _current, _filter]) {
      c.dispose();
    }
    super.dispose();
  }

  String _typeLabel(KrType type) {
    final t = context.l10n;
    return switch (type) {
      KrType.number => t.goalsKrNumber,
      KrType.percentage => t.goalsKrPercentage,
      KrType.boolean => t.goalsKrBoolean,
      KrType.linked => t.goalsKrLinked,
    };
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      KrDraft(
        name: name,
        type: _type,
        startValue: _start.text.trim(),
        targetValue: _target.text.trim(),
        currentValue: _current.text.trim(),
        weight: _weight,
        filterText: _filter.text.trim(),
        taskIds: widget.kr?.taskIds ?? const [],
      ),
    );
  }

  Widget _number(String key, TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: TfSpace.md),
    child: TextField(
      key: Key(key),
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(labelText: label),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final editing = widget.kr != null;
    return TfDialogFrame(
      title: editing ? t.goalsEditKr : t.goalsAddKr,
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('kr-name'),
                controller: _name,
                autofocus: true,
                maxLength: 160,
                decoration: InputDecoration(labelText: t.goalsKrName),
              ),
              const SizedBox(height: TfSpace.md),
              TfSelectField<KrType>(
                key: const Key('kr-type'),
                options: {for (final k in KrType.values) k: _typeLabel(k)},
                value: _type,
                onChanged: editing ? null : (v) => setState(() => _type = v),
                label: t.goalsKrType,
                expand: true,
              ),
              const SizedBox(height: TfSpace.md),
              if (_type == KrType.number) ...[
                _number('kr-start', _start, t.goalsKrStart),
                _number('kr-target', _target, t.goalsKrTarget),
                if (!editing) _number('kr-current', _current, t.goalsKrCurrent),
                Padding(
                  padding: const EdgeInsets.only(bottom: TfSpace.xs),
                  child: Text(
                    t.goalsKrDirectionHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              if (_type == KrType.linked) ...[
                TextField(
                  key: const Key('kr-filter'),
                  controller: _filter,
                  decoration: InputDecoration(
                    labelText: t.goalsKrFilter,
                    helperText: t.goalsKrFilterHint,
                    helperMaxLines: 3,
                  ),
                ),
                if (editing && widget.kr!.taskIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: TfSpace.sm),
                    child: Text(t.goalsKrPicked(widget.kr!.taskIds.length)),
                  ),
              ],
              const SizedBox(height: TfSpace.md),
              TfSelectField(
                key: const Key('kr-weight'),
                options: {for (final w in goalWeights) w: w},
                value: goalWeights.contains(_weight) ? _weight : '1',
                onChanged: (v) => setState(() => _weight = v),
                label: t.goalsWeight,
                expand: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TfButton(
          label: t.grpCCancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TfButton(
          key: const Key('save-kr'),
          label: t.goalsSave,
          variant: TfButtonVariant.primary,
          onPressed: _save,
        ),
      ],
    );
  }
}

/// The check-in dialog with the key result's history as a sparkline. Returns
/// the goal as the server now has it, or null when cancelled.
Future<Goal?> showCheckInDialog(
  BuildContext context, {
  required KeyResult kr,
  required Map<String, String> names,
}) => showDialog<Goal>(
  context: context,
  builder: (_) => _CheckInDialog(kr: kr, names: names),
);

class _CheckInDialog extends ConsumerStatefulWidget {
  const _CheckInDialog({required this.kr, required this.names});

  final KeyResult kr;
  final Map<String, String> names;

  @override
  ConsumerState<_CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends ConsumerState<_CheckInDialog> {
  late final _value = TextEditingController(
    text: trimNumber(widget.kr.currentValue),
  );
  final _note = TextEditingController();
  late bool _done = double.tryParse(widget.kr.currentValue) == 1;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final value = switch (widget.kr.type) {
      KrType.boolean => _done ? '1' : '0',
      KrType.linked => '0',
      _ => _value.text.trim(),
    };
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final goal = await ref
          .read(goalsClientProvider)
          .addCheckIn(ws, widget.kr.id, value, _note.text);
      ref.invalidate(checkInsProvider(widget.kr.id));
      if (mounted) Navigator.of(context).pop(goal);
    } on GoalsException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = goalsErrorMessage(e, context.l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final history = ref.watch(checkInsProvider(widget.kr.id));
    final kr = widget.kr;
    return TfDialogFrame(
      title: t.goalsCheckInTitle(kr.name),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kr.type == KrType.boolean)
                TfToggle(
                  key: const Key('checkin-done'),
                  value: _done,
                  onChanged: (v) => setState(() => _done = v),
                  label: t.goalsCheckInDone,
                )
              else if (kr.type == KrType.linked)
                Text(t.goalsCheckInLinkedHint)
              else
                TextField(
                  key: const Key('checkin-value'),
                  controller: _value,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: InputDecoration(labelText: t.goalsCheckInValue),
                ),
              const SizedBox(height: TfSpace.md),
              TextField(
                key: const Key('checkin-note'),
                controller: _note,
                maxLines: 2,
                maxLength: 2000,
                decoration: InputDecoration(labelText: t.goalsCheckInNote),
              ),
              const SizedBox(height: TfSpace.md),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const Divider(),
              Text(
                t.goalsCheckInHistory,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              history.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(TfSpace.md),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => TfError(
                  compact: true,
                  message: goalsErrorMessage(e, t),
                  details: '$e',
                ),
                data: (rows) => _History(rows: rows, names: widget.names),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TfButton(
          label: t.grpCCancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TfButton(
          key: const Key('save-checkin'),
          label: t.goalsCheckIn,
          variant: TfButtonVariant.primary,
          onPressed: _busy ? null : _save,
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.rows, required this.names});

  final List<CheckIn> rows;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: TfSpace.sm),
        child: Text(t.goalsCheckInEmpty),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Sparkline(points: [for (final r in rows.reversed) r.progress]),
        const SizedBox(height: TfSpace.sm),
        for (final r in rows.take(12))
          TfRow(
            key: Key('checkin-${r.id}'),
            title: t.goalsCheckInChange(
              trimNumber(r.previousValue),
              trimNumber(r.value),
            ),
            subtitle: [
              r.userId.isEmpty ? t.goalsCheckInSystem : (names[r.userId] ?? ''),
              if (r.at != null) context.localDate(r.at!),
              if (r.note.isNotEmpty) r.note,
            ].where((s) => s.isNotEmpty).join(' · '),
          ),
      ],
    );
  }
}
