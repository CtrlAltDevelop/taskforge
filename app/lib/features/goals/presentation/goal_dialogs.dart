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
    builder: (c) => AlertDialog(
      title: Text(c.l10n.goalsFolderName),
      content: TextField(
        key: const Key('folder-name'),
        controller: controller,
        autofocus: true,
        maxLength: 80,
        decoration: InputDecoration(labelText: c.l10n.goalsFolderName),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(c).pop(),
          child: Text(c.l10n.grpCCancel),
        ),
        FilledButton(
          key: const Key('save-folder'),
          onPressed: () => Navigator.of(c).pop(controller.text.trim()),
          child: Text(c.l10n.goalsSave),
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
    return AlertDialog(
      title: Text(editing ? t.goalsEdit : t.goalsNew),
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
              const SizedBox(height: 12),
              TextField(
                key: const Key('goal-description'),
                controller: _description,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(labelText: t.goalsDescription),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('goal-period'),
                onPressed: _pickPeriod,
                icon: const TfIcon(TfIcons.calendarRange),
                label: Text(
                  t.goalsPeriod(
                    context.localDate(_start),
                    context.localDate(_end),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('goal-owner'),
                initialValue: widget.members.any((m) => m.userId == _owner)
                    ? _owner
                    : null,
                decoration: InputDecoration(labelText: t.goalsOwner),
                items: [
                  for (final m in widget.members)
                    DropdownMenuItem(value: m.userId, child: Text(m.label)),
                ],
                onChanged: (v) => setState(() => _owner = v ?? _owner),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('goal-parent'),
                initialValue: parents.any((g) => g.id == _parent)
                    ? _parent
                    : '',
                decoration: InputDecoration(labelText: t.goalsParent),
                items: [
                  DropdownMenuItem(value: '', child: Text(t.goalsNone)),
                  for (final g in parents)
                    DropdownMenuItem(value: g.id, child: Text(g.name)),
                ],
                onChanged: (v) => setState(() => _parent = v ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('goal-folder'),
                initialValue: widget.catalog.folders.any((f) => f.id == _folder)
                    ? _folder
                    : '',
                decoration: InputDecoration(labelText: t.goalsFolder),
                items: [
                  DropdownMenuItem(value: '', child: Text(t.goalsNoFolder)),
                  for (final f in widget.catalog.folders)
                    DropdownMenuItem(value: f.id, child: Text(f.name)),
                ],
                onChanged: (v) => setState(() => _folder = v ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('goal-weight'),
                initialValue: goalWeights.contains(_weight) ? _weight : '1',
                decoration: InputDecoration(labelText: t.goalsWeight),
                items: [
                  for (final w in goalWeights)
                    DropdownMenuItem(value: w, child: Text(w)),
                ],
                onChanged: (v) => setState(() => _weight = v ?? '1'),
              ),
              const SizedBox(height: 12),
              if (editing)
                DropdownButtonFormField<String>(
                  key: const Key('goal-status'),
                  initialValue: _override,
                  decoration: InputDecoration(labelText: t.goalsStatusLabel),
                  items: [
                    DropdownMenuItem(value: '', child: Text(t.goalsStatusAuto)),
                    for (final s in GoalStatus.values)
                      DropdownMenuItem(
                        value: s.wire,
                        child: Text(goalStatusLabel(t, s)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _override = v ?? ''),
                ),
              const SizedBox(height: 12),
              SwitchListTile(
                key: const Key('goal-private'),
                contentPadding: EdgeInsets.zero,
                title: Text(t.goalsPrivate),
                subtitle: Text(t.goalsPrivateHint),
                value: _private,
                onChanged: (v) => setState(() => _private = v),
              ),
              Text(
                t.goalsContributors,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Wrap(
                spacing: 6,
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.grpCCancel),
        ),
        FilledButton(
          key: const Key('save-goal'),
          onPressed: _save,
          child: Text(t.goalsSave),
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
    padding: const EdgeInsets.only(bottom: 12),
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
    return AlertDialog(
      title: Text(editing ? t.goalsEditKr : t.goalsAddKr),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<KrType>(
                key: const Key('kr-type'),
                initialValue: _type,
                decoration: InputDecoration(labelText: t.goalsKrType),
                items: [
                  for (final k in KrType.values)
                    DropdownMenuItem(value: k, child: Text(_typeLabel(k))),
                ],
                onChanged: editing
                    ? null
                    : (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              if (_type == KrType.number) ...[
                _number('kr-start', _start, t.goalsKrStart),
                _number('kr-target', _target, t.goalsKrTarget),
                if (!editing) _number('kr-current', _current, t.goalsKrCurrent),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
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
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(t.goalsKrPicked(widget.kr!.taskIds.length)),
                  ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('kr-weight'),
                initialValue: goalWeights.contains(_weight) ? _weight : '1',
                decoration: InputDecoration(labelText: t.goalsWeight),
                items: [
                  for (final w in goalWeights)
                    DropdownMenuItem(value: w, child: Text(w)),
                ],
                onChanged: (v) => setState(() => _weight = v ?? '1'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.grpCCancel),
        ),
        FilledButton(
          key: const Key('save-kr'),
          onPressed: _save,
          child: Text(t.goalsSave),
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
    return AlertDialog(
      title: Text(t.goalsCheckInTitle(kr.name)),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kr.type == KrType.boolean)
                SwitchListTile(
                  key: const Key('checkin-done'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.goalsCheckInDone),
                  value: _done,
                  onChanged: (v) => setState(() => _done = v),
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
              const SizedBox(height: 12),
              TextField(
                key: const Key('checkin-note'),
                controller: _note,
                maxLines: 2,
                maxLength: 2000,
                decoration: InputDecoration(labelText: t.goalsCheckInNote),
              ),
              const SizedBox(height: 12),
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
                  padding: EdgeInsets.all(12),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.grpCCancel),
        ),
        FilledButton(
          key: const Key('save-checkin'),
          onPressed: _busy ? null : _save,
          child: Text(t.goalsCheckIn),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t.goalsCheckInEmpty),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Sparkline(points: [for (final r in rows.reversed) r.progress]),
        const SizedBox(height: 8),
        for (final r in rows.take(12))
          ListTile(
            key: Key('checkin-${r.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              t.goalsCheckInChange(
                trimNumber(r.previousValue),
                trimNumber(r.value),
              ),
            ),
            subtitle: Text(
              [
                r.userId.isEmpty
                    ? t.goalsCheckInSystem
                    : (names[r.userId] ?? ''),
                if (r.at != null) context.localDate(r.at!),
                if (r.note.isNotEmpty) r.note,
              ].where((s) => s.isNotEmpty).join(' · '),
            ),
          ),
      ],
    );
  }
}
