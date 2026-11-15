import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/weekday_names.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show currentUserIdProvider;
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workload/application/workload_providers.dart';
import 'package:taskforge/features/workload/domain/workload.dart';
import 'package:taskforge/features/workload/presentation/workload_screen.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Asks for hours per day and working days, saves them, and says so on a
/// refusal. Returns true when something was saved.
Future<bool> editCapacity(
  BuildContext context,
  WidgetRef ref,
  String userId,
  String name,
  Capacity current,
) async {
  final result = await showDialog<(double, List<int>)>(
    context: context,
    builder: (_) => _CapacityDialog(name: name, current: current),
  );
  final ws = ref.read(workspaceScopeProvider);
  if (result == null || ws == null) return false;
  try {
    await ref
        .read(workloadClientProvider)
        .setCapacity(ws, userId, result.$1, result.$2);
    ref.invalidate(capacitiesProvider);
    return true;
  } on Object catch (e) {
    if (context.mounted) sayWorkload(context, workloadMessage(context, e));
    return false;
  }
}

class _CapacityDialog extends StatefulWidget {
  const _CapacityDialog({required this.name, required this.current});

  final String name;
  final Capacity current;

  @override
  State<_CapacityDialog> createState() => _CapacityDialogState();
}

class _CapacityDialogState extends State<_CapacityDialog> {
  late final _hours = TextEditingController(
    text: hoursText(widget.current.secondsPerDay),
  );
  late final Set<int> _days = {...widget.current.workingDays};
  String? _error;

  @override
  void dispose() {
    _hours.dispose();
    super.dispose();
  }

  void _save() {
    final hours = double.tryParse(_hours.text.trim().replaceAll(',', '.'));
    if (hours == null || hours < 0 || hours > 24) {
      setState(() => _error = context.l10n.wlHoursInvalid);
      return;
    }
    Navigator.pop(context, (hours, _days.toList()..sort()));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final names = t.weekdayShortNames;
    return AlertDialog(
      title: Text(t.wlCapacityOf(widget.name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('capacity-hours'),
              controller: _hours,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: t.wlHoursPerDay,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            Text(t.wlWorkingDays),
            Wrap(
              spacing: 6,
              children: [
                for (var d = 0; d < 7; d++)
                  FilterChip(
                    key: Key('capacity-day-$d'),
                    label: Text(names[d]),
                    selected: _days.contains(d),
                    onSelected: (on) =>
                        setState(() => on ? _days.add(d) : _days.remove(d)),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          key: const Key('capacity-save'),
          onPressed: _save,
          child: Text(t.save),
        ),
      ],
    );
  }
}

/// Capacity per person, time off and holidays.
class WorkloadSettingsScreen extends ConsumerWidget {
  const WorkloadSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TfAppBar(
          title: Text(t.wlSettings),
          bottom: TabBar(
            tabs: [
              Tab(text: t.wlTabCapacity),
              Tab(text: t.wlTabTimeOff),
              Tab(text: t.wlTabHolidays),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_CapacityTab(), _TimeOffTab(), _HolidaysTab()],
        ),
      ),
    );
  }
}

class _CapacityTab extends ConsumerWidget {
  const _CapacityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final caps = ref.watch(capacitiesProvider);
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final manage = ref.watch(permissionSetProvider).can(Perm.workloadManage);
    return caps.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(workloadMessage(context, e))),
      data: (list) => ListView(
        children: [
          for (final c in list)
            ListTile(
              key: Key('capacity-${c.userId}'),
              title: Text(
                members.where((m) => m.userId == c.userId).firstOrNull?.label ??
                    c.userId,
              ),
              subtitle: Text(
                c.isSet
                    ? t.wlCapacitySummary(
                        context.localDigits(hoursText(c.secondsPerDay)),
                        context.localDigits('${c.workingDays.length}'),
                      )
                    : t.wlNoCapacity,
              ),
              trailing: manage
                  ? IconButton(
                      tooltip: t.wlSetCapacity,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => editCapacity(
                        context,
                        ref,
                        c.userId,
                        members
                                .where((m) => m.userId == c.userId)
                                .firstOrNull
                                ?.label ??
                            c.userId,
                        c,
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _TimeOffTab extends ConsumerWidget {
  const _TimeOffTab();

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    TimeOff? existing,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    final me = ref.read(currentUserIdProvider);
    final manage = ref.read(permissionSetProvider).can(Perm.workloadManage);
    final members = ref.read(membersProvider).value ?? const <Member>[];
    final draft = await showDialog<_TimeOffDraft>(
      context: context,
      builder: (_) => _TimeOffDialog(
        existing: existing,
        me: me,
        members: manage ? members : const [],
      ),
    );
    if (draft == null || ws == null) return;
    try {
      await ref
          .read(workloadClientProvider)
          .saveTimeOff(
            ws,
            id: existing?.id ?? '',
            userId: draft.userId,
            start: draft.start,
            end: draft.end,
            kind: draft.kind,
            note: draft.note,
          );
    } on Object catch (e) {
      if (context.mounted) sayWorkload(context, workloadMessage(context, e));
    }
    ref.invalidate(timeOffProvider);
    ref.invalidate(workloadProvider);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TimeOff row) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      await ref.read(workloadClientProvider).deleteTimeOff(ws, row.id);
    } on Object catch (e) {
      if (context.mounted) sayWorkload(context, workloadMessage(context, e));
    }
    ref.invalidate(timeOffProvider);
    ref.invalidate(workloadProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final rows = ref.watch(timeOffProvider);
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final me = ref.watch(currentUserIdProvider);
    final manage = ref.watch(permissionSetProvider).can(Perm.workloadManage);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-time-off'),
        onPressed: () => _add(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(t.wlAddTimeOff),
      ),
      body: rows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(workloadMessage(context, e))),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.wlNoTimeOff))
            : ListView(
                children: [
                  for (final r in list)
                    ListTile(
                      title: Text(
                        '${members.where((m) => m.userId == r.userId).firstOrNull?.label ?? r.userId}'
                        ' · ${_kindLabel(t, r.kind)}',
                      ),
                      subtitle: Text(
                        '${context.localDate(r.start)} – ${context.localDate(r.end)}'
                        '${r.note.isEmpty ? '' : '\n${r.note}'}',
                      ),
                      onTap: manage || r.userId == me
                          ? () => _add(context, ref, r)
                          : null,
                      trailing: manage || r.userId == me
                          ? IconButton(
                              tooltip: t.wlDelete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(context, ref, r),
                            )
                          : null,
                    ),
                ],
              ),
      ),
    );
  }
}

String _kindLabel(AppLocalizations t, TimeOffKind kind) => switch (kind) {
  TimeOffKind.vacation => t.wlKindVacation,
  TimeOffKind.sick => t.wlKindSick,
  TimeOffKind.personal => t.wlKindPersonal,
  TimeOffKind.other => t.wlKindOther,
};

class _TimeOffDraft {
  const _TimeOffDraft(this.userId, this.start, this.end, this.kind, this.note);

  final String userId;
  final DateTime start;
  final DateTime end;
  final TimeOffKind kind;
  final String note;
}

class _TimeOffDialog extends StatefulWidget {
  const _TimeOffDialog({
    required this.existing,
    required this.me,
    required this.members,
  });

  final TimeOff? existing;
  final String me;
  final List<Member> members;

  @override
  State<_TimeOffDialog> createState() => _TimeOffDialogState();
}

class _TimeOffDialogState extends State<_TimeOffDialog> {
  late String _user = widget.existing?.userId ?? widget.me;
  late DateTime _start = widget.existing?.start ?? dateOnly(DateTime.now());
  late DateTime _end = widget.existing?.end ?? dateOnly(DateTime.now());
  late TimeOffKind _kind = widget.existing?.kind ?? TimeOffKind.vacation;
  late final _note = TextEditingController(text: widget.existing?.note ?? '');

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final range = await showAppDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: DateTime(_start.year, _start.month, _start.day),
        end: DateTime(_end.year, _end.month, _end.day),
      ),
    );
    if (range == null) return;
    setState(() {
      _start = dateOnly(range.start);
      _end = dateOnly(range.end);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AlertDialog(
      title: Text(t.wlAddTimeOff),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.members.isNotEmpty && widget.existing == null)
              DropdownButtonFormField<String>(
                initialValue: _user,
                decoration: InputDecoration(labelText: t.wlPerson),
                items: [
                  for (final m in widget.members)
                    DropdownMenuItem(value: m.userId, child: Text(m.label)),
                ],
                onChanged: (v) => setState(() => _user = v ?? _user),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('time-off-dates'),
              icon: const Icon(Icons.date_range),
              label: Text(
                '${context.localDate(_start)} – ${context.localDate(_end)}',
              ),
              onPressed: _pick,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TimeOffKind>(
              initialValue: _kind,
              decoration: InputDecoration(labelText: t.wlKind),
              items: [
                for (final k in TimeOffKind.values)
                  DropdownMenuItem(value: k, child: Text(_kindLabel(t, k))),
              ],
              onChanged: (v) => setState(() => _kind = v ?? _kind),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: InputDecoration(labelText: t.wlNote),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          key: const Key('time-off-save'),
          onPressed: () => Navigator.pop(
            context,
            _TimeOffDraft(_user, _start, _end, _kind, _note.text),
          ),
          child: Text(t.save),
        ),
      ],
    );
  }
}

class _HolidaysTab extends ConsumerWidget {
  const _HolidaysTab();

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Holiday? existing,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    final draft = await showDialog<(DateTime, String)>(
      context: context,
      builder: (_) => _HolidayDialog(existing: existing),
    );
    if (draft == null || ws == null) return;
    try {
      await ref
          .read(workloadClientProvider)
          .saveHoliday(
            ws,
            id: existing?.id ?? '',
            date: draft.$1,
            name: draft.$2,
          );
    } on Object catch (e) {
      if (context.mounted) sayWorkload(context, workloadMessage(context, e));
    }
    ref.invalidate(holidaysProvider);
    ref.invalidate(workloadProvider);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Holiday h) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      await ref.read(workloadClientProvider).deleteHoliday(ws, h.id);
    } on Object catch (e) {
      if (context.mounted) sayWorkload(context, workloadMessage(context, e));
    }
    ref.invalidate(holidaysProvider);
    ref.invalidate(workloadProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final rows = ref.watch(holidaysProvider);
    final manage = ref.watch(permissionSetProvider).can(Perm.workloadManage);
    return Scaffold(
      floatingActionButton: manage
          ? FloatingActionButton.extended(
              key: const Key('add-holiday'),
              onPressed: () => _edit(context, ref, null),
              icon: const Icon(Icons.add),
              label: Text(t.wlAddHoliday),
            )
          : null,
      body: rows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(workloadMessage(context, e))),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.wlNoHolidays))
            : ListView(
                children: [
                  for (final h in list)
                    ListTile(
                      title: Text(h.name),
                      subtitle: Text(context.localDate(h.date, long: true)),
                      onTap: manage ? () => _edit(context, ref, h) : null,
                      trailing: manage
                          ? IconButton(
                              tooltip: t.wlDelete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(context, ref, h),
                            )
                          : null,
                    ),
                ],
              ),
      ),
    );
  }
}

class _HolidayDialog extends StatefulWidget {
  const _HolidayDialog({required this.existing});

  final Holiday? existing;

  @override
  State<_HolidayDialog> createState() => _HolidayDialogState();
}

class _HolidayDialogState extends State<_HolidayDialog> {
  late DateTime _date = widget.existing?.date ?? dateOnly(DateTime.now());
  late final _name = TextEditingController(text: widget.existing?.name ?? '');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final day = await showAppDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (day != null) setState(() => _date = dateOnly(day));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AlertDialog(
      title: Text(t.wlAddHoliday),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('holiday-name'),
            controller: _name,
            maxLength: 120,
            decoration: InputDecoration(labelText: t.wlHolidayName),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.event),
            label: Text(context.localDate(_date)),
            onPressed: _pick,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          key: const Key('holiday-save'),
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            Navigator.pop(context, (_date, _name.text));
          },
          child: Text(t.save),
        ),
      ],
    );
  }
}
