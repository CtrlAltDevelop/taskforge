import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/weekday_names.dart';
import 'package:taskforge/core/i18n/directional_icon.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show currentUserIdProvider;
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/features/time/presentation/entry_dialog.dart';

/// A week of the caller's time: a row per task, a column per day, totals on
/// both edges. Tapping a cell opens that task's entries for the day.
class TimesheetScreen extends ConsumerStatefulWidget {
  const TimesheetScreen({super.key, this.today});

  /// "Today" for choosing the first week (tests say).
  final DateTime? today;

  @override
  ConsumerState<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends ConsumerState<TimesheetScreen> {
  late var _week = weekStartOf(widget.today ?? DateTime.now());

  /// Whose week is shown: empty for the caller.
  var _user = '';

  void _move(int weeks) => setState(() => _week = addDays(_week, 7 * weeks));

  @override
  Widget build(BuildContext context) {
    final sheet = ref.watch(timesheetProvider((week: _week, user: _user)));
    final permissions = ref.watch(permissionSetProvider);
    final me = ref.watch(currentUserIdProvider);
    final last = addDays(_week, 6);
    return ShellScaffold(
      appBar: TfAppBar(title: Text(context.l10n.grpATimesheetTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  key: const Key('week-previous'),
                  tooltip: context.l10n.grpAPreviousWeek,
                  icon: const DirectionalIcon(Icons.chevron_left),
                  onPressed: () => _move(-1),
                ),
                Text(
                  '${context.localIso(_week)} – ${context.localIso(last)}',
                  key: const Key('week-label'),
                ),
                IconButton(
                  key: const Key('week-next'),
                  tooltip: context.l10n.grpANextWeek,
                  icon: const DirectionalIcon(Icons.chevron_right),
                  onPressed: () => _move(1),
                ),
                if (permissions.can(Perm.timeEditOthers))
                  _PersonPicker(
                    value: _user.isEmpty ? me : _user,
                    onChanged: (id) =>
                        setState(() => _user = id == me ? '' : id),
                  ),
                TextButton(
                  key: const Key('week-this'),
                  onPressed: () => setState(
                    () => _week = weekStartOf(widget.today ?? DateTime.now()),
                  ),
                  child: Text(context.l10n.grpAThisWeek),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (sheet) {
              AsyncData(:final value) => ListView(
                children: [
                  _Grid(sheet: value, week: _week, mine: _user.isEmpty),
                  _Totals(week: _week),
                ],
              ),
              AsyncError(:final error) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(timeErrorMessage(error, context.l10n)),
                    TextButton(
                      key: const Key('timesheet-retry'),
                      onPressed: () => ref.invalidate(
                        timesheetProvider((week: _week, user: _user)),
                      ),
                      child: Text(context.l10n.grpARetry),
                    ),
                  ],
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({required this.sheet, required this.week, required this.mine});

  final Timesheet sheet;
  final DateTime week;

  /// Cells open for editing only on your own sheet.
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sheet.rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          key: const Key('timesheet-empty'),
          child: Text(context.l10n.grpATimesheetEmpty),
        ),
      );
    }
    final canLog = mine && ref.watch(permissionSetProvider).can(Perm.timeLog);
    String cell(int s) => s == 0 ? '' : durationText(s);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text(context.l10n.grpATask)),
          for (var i = 0; i < 7; i++)
            DataColumn(
              numeric: true,
              label: Text(
                context.localDigits(
                  '${context.l10n.weekdayShortNames[i]} ${addDays(week, i).day}',
                ),
              ),
            ),
          DataColumn(numeric: true, label: Text(context.l10n.grpATotal)),
        ],
        rows: [
          for (final r in sheet.rows)
            DataRow(
              key: ValueKey('row-${r.taskId}'),
              cells: [
                DataCell(
                  Text('${r.key} ${r.title}'),
                  onTap: () =>
                      context.go('/projects/${r.projectId}?task=${r.taskId}'),
                ),
                for (var i = 0; i < 7; i++)
                  DataCell(
                    Text(cell(r.seconds[i])),
                    onTap: canLog
                        ? () => _openCell(context, ref, r, addDays(week, i))
                        : null,
                  ),
                DataCell(Text(durationText(r.total))),
              ],
            ),
          DataRow(
            key: const ValueKey('row-total'),
            cells: [
              DataCell(Text(context.l10n.grpATotal)),
              for (var i = 0; i < 7; i++)
                DataCell(Text(cell(sheet.dayTotals[i]))),
              DataCell(
                Text(durationText(sheet.total), key: const Key('sheet-total')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openCell(
    BuildContext context,
    WidgetRef ref,
    SheetRow row,
    DateTime day,
  ) => showDialog<void>(
    context: context,
    builder: (_) => _CellDialog(row: row, day: day),
  );
}

/// One task's entries for one day, to change, delete or add to.
class _CellDialog extends ConsumerWidget {
  const _CellDialog({required this.row, required this.day});

  final SheetRow row;
  final DateTime day;

  /// Runs a change and says so when it fails (the dialog stays open).
  Future<void> _run(BuildContext context, Future<void> Function() act) async {
    try {
      await act();
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(timeErrorMessage(e, context.l10n))),
        );
    }
  }

  bool _onDay(TimeEntry e) {
    final d = e.startedAt.toLocal();
    return d.year == day.year && d.month == day.month && d.day == day.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    final task = (project: row.projectId, task: row.taskId);
    final entries =
        (ref.watch(timeEntriesProvider(task)).value ?? const <TimeEntry>[])
            .where((e) => e.userId == me && _onDay(e))
            .toList();
    final actions = ref.read(timeActionsProvider);
    return AlertDialog(
      key: const Key('cell-dialog'),
      title: Text('${row.key} · ${context.localIso(day)}'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in entries)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  key: Key('cell-entry-${e.id}'),
                  dense: true,
                  title: Text(
                    e.running
                        ? context.l10n.grpARunning
                        : durationText(e.durationSec),
                  ),
                  subtitle: e.note.isEmpty ? null : Text(e.note),
                  trailing: e.running
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: Key('cell-edit-${e.id}'),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: context.l10n.grpAEdit,
                              onPressed: () async {
                                final input = await askEntry(
                                  context,
                                  existing: e,
                                );
                                if (input == null || !context.mounted) return;
                                await _run(
                                  context,
                                  () => actions.edit(
                                    e.id,
                                    startedAt: input.startedAt,
                                    durationSec: input.durationSec,
                                    note: input.note,
                                    billable: input.billable,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              key: Key('cell-delete-${e.id}'),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: context.l10n.grpADelete,
                              onPressed: () async {
                                if (!await confirmDelete(context)) return;
                                if (!context.mounted) return;
                                await _run(context, () => actions.remove(e.id));
                              },
                            ),
                          ],
                        ),
                ),
              ),
            TextButton.icon(
              key: const Key('cell-add'),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.grpAAddTime),
              onPressed: () async {
                final input = await askEntry(context, day: day);
                if (input == null) return;
                if (!context.mounted) return;
                await _run(
                  context,
                  () => actions.add(
                    row.projectId,
                    row.taskId,
                    startedAt: input.startedAt!,
                    durationSec: input.durationSec!,
                    note: input.note,
                    billable: input.billable,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpAClose),
        ),
      ],
    );
  }
}

/// Whose week to show: the caller or another active member.
class _PersonPicker extends ConsumerWidget {
  const _PersonPicker({required this.value, required this.onChanged});

  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider).value ?? const [];
    final me = ref.watch(currentUserIdProvider);
    if (members.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: DropdownButton<String>(
          key: const Key('sheet-person'),
          isExpanded: true,
          value: members.any((m) => m.userId == value) ? value : me,
          items: [
            for (final m in members)
              DropdownMenuItem(
                value: m.userId,
                child: Text(
                  m.userId == me
                      ? context.l10n.grpAYou
                      : (m.displayName.isEmpty ? m.email : m.displayName),
                ),
              ),
          ],
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ),
    );
  }
}

/// Per-person time in one project for the shown week.
class _Totals extends ConsumerStatefulWidget {
  const _Totals({required this.week});

  final DateTime week;

  @override
  ConsumerState<_Totals> createState() => _TotalsState();
}

class _TotalsState extends ConsumerState<_Totals> {
  String? _project;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(projectCatalogProvider(false));
    final projects = [
      for (final p in catalog.value?.projects ?? const [])
        if (p.enabledFeatures.contains(timeFeature)) p,
    ];
    if (projects.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final chosen = _project;
    final totals = chosen == null
        ? null
        : ref.watch(
            projectTotalsProvider((project: chosen, week: widget.week)),
          );
    return Padding(
      key: const Key('project-totals'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.grpAProjectTotals,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            key: const Key('totals-project'),
            isExpanded: true,
            hint: Text(context.l10n.grpAChooseProject),
            value: chosen,
            items: [
              for (final p in projects)
                DropdownMenuItem(
                  value: p.id,
                  child: Text(
                    '${p.key} ${p.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (id) => setState(() => _project = id),
          ),
          const SizedBox(height: 12),
          if (totals != null)
            switch (totals) {
              AsyncData(:final value) when value.isEmpty => Text(
                context.l10n.grpATotalsEmpty,
                key: const Key('totals-empty'),
              ),
              AsyncData(:final value) => Column(
                children: [
                  for (final t in value)
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        key: Key('total-${t.userId}'),
                        dense: true,
                        title: Text(t.name),
                        trailing: Text(
                          durationText(t.seconds) +
                              (t.billable > 0
                                  ? context.l10n.grpABillableAmount(
                                      durationText(t.billable),
                                    )
                                  : ''),
                        ),
                      ),
                    ),
                ],
              ),
              AsyncError(:final error) => Text(
                timeErrorMessage(error, context.l10n),
              ),
              _ => const LinearProgressIndicator(),
            },
        ],
      ),
    );
  }
}
