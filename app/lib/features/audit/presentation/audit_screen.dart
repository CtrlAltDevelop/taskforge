import 'package:taskforge/core/ui/tf_app_bar.dart';

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/audit/application/audit_providers.dart';
import 'package:taskforge/features/audit/domain/activity_lines.dart';
import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/features/audit/domain/describe.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

/// The areas a person can narrow the log to (an action prefix each).
const auditAreas = <(String, String)>[
  ('All', ''),
  ('Tasks', 'task.'),
  ('Comments', 'comment.'),
  ('Files', 'attachment.'),
  ('Projects', 'project.'),
  ('Members', 'member.'),
  ('Roles', 'role.'),
  ('Invitations', 'invitation.'),
  ('Sign-in', 'auth.'),
];

String _areaLabel(BuildContext context, String prefix, String fallback) =>
    switch (prefix) {
      '' => context.l10n.grpBAuditAll,
      'task.' => context.l10n.grpBAuditTasks,
      'comment.' => context.l10n.grpBComments,
      'attachment.' => context.l10n.grpBAuditFiles,
      'project.' => context.l10n.grpBAuditProjects,
      'member.' => context.l10n.grpBAuditMembers,
      'role.' => context.l10n.grpBAuditRoles,
      'invitation.' => context.l10n.grpBAuditInvitations,
      'auth.' => context.l10n.grpBAuditSignIn,
      _ => fallback,
    };

/// Who changed what, workspace-wide: filter chips, a row per change, a
/// before/after view, and CSV export. For people holding `audit.view`.
class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  var _filters = const AuditFilters();
  var _exporting = false;

  void _set(AuditFilters next) => setState(() => _filters = next);

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showAppDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (range == null || !mounted) return;
    // `until` is exclusive on the server: the day after the last one picked.
    _set(
      _filters.copyWith(
        since: range.start,
        until: range.end.add(const Duration(days: 1)),
      ),
    );
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final csv = await ref.read(auditExportProvider)(_filters);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => _ExportDialog(csv: csv, messenger: messenger),
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(auditErrorMessage(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionSetProvider).can(Perm.auditView);
    return Scaffold(
      appBar: TfAppBar(
        leading: IconButton(
          key: const Key('back-home'),
          tooltip: context.l10n.grpBBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.l10n.grpBAuditTitle),
        actions: [
          if (allowed)
            IconButton(
              key: const Key('audit-export'),
              tooltip: context.l10n.grpBExportCsv,
              icon: const Icon(Icons.download),
              onPressed: _exporting ? null : _export,
            ),
        ],
      ),
      body: allowed
          ? _Body(filters: _filters, onFilters: _set, onPickDates: _pickDates)
          : Center(
              child: Text(
                context.l10n.grpBAuditDenied,
                key: const Key('audit-denied'),
              ),
            ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.filters,
    required this.onFilters,
    required this.onPickDates,
  });

  final AuditFilters filters;
  final ValueChanged<AuditFilters> onFilters;
  final VoidCallback onPickDates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(auditListProvider(filters));
    final notifier = ref.read(auditListProvider(filters).notifier);
    final now = ref.watch(auditNowProvider)();
    return ListView(
      key: const Key('audit-list'),
      padding: const EdgeInsets.all(16),
      children: [
        _Filters(
          filters: filters,
          onFilters: onFilters,
          onPickDates: onPickDates,
        ),
        const SizedBox(height: 8),
        if (state.loading)
          const Center(child: CircularProgressIndicator())
        else if (state.error != null && state.entries.isEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  auditErrorMessage(state.error!, context.l10n),
                  key: const Key('audit-error'),
                ),
              ),
              TextButton(
                key: const Key('audit-retry'),
                onPressed: notifier.refresh,
                child: Text(context.l10n.grpBRetry),
              ),
            ],
          )
        else if (state.entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.l10n.grpBAuditEmpty,
              key: const Key('audit-empty'),
            ),
          )
        else ...[
          for (final e in state.entries)
            _Row(entry: e, labels: state.labels, now: now),
          if (state.error != null)
            Text(
              auditErrorMessage(state.error!, context.l10n),
              key: const Key('audit-error'),
            ),
          if (state.hasMore)
            TextButton(
              key: const Key('audit-more'),
              onPressed: state.loadingMore ? null : notifier.more,
              child: Text(
                state.loadingMore
                    ? context.l10n.grpBLoading
                    : context.l10n.grpBShowOlder,
              ),
            ),
        ],
      ],
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({
    required this.filters,
    required this.onFilters,
    required this.onPickDates,
  });

  final AuditFilters filters;
  final ValueChanged<AuditFilters> onFilters;
  final VoidCallback onPickDates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider).value ?? const [];
    final projects =
        ref.watch(projectCatalogProvider(true)).value?.projects ?? const [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (label, prefix) in auditAreas)
          ChoiceChip(
            key: Key('area-${prefix.isEmpty ? 'all' : prefix}'),
            label: Text(_areaLabel(context, prefix, label)),
            selected: filters.action == prefix,
            onSelected: (_) => onFilters(filters.copyWith(action: prefix)),
          ),
        DropdownButton<String>(
          key: const Key('filter-person'),
          value: members.any((m) => m.userId == filters.actor)
              ? filters.actor
              : '',
          hint: Text(context.l10n.grpBAnyone),
          items: [
            DropdownMenuItem(value: '', child: Text(context.l10n.grpBAnyone)),
            for (final m in members)
              DropdownMenuItem(value: m.userId, child: Text(m.displayName)),
          ],
          onChanged: (v) => onFilters(filters.copyWith(actor: v ?? '')),
        ),
        DropdownButton<String>(
          key: const Key('filter-project'),
          value: projects.any((p) => p.id == filters.projectId)
              ? filters.projectId
              : '',
          items: [
            DropdownMenuItem(
              value: '',
              child: Text(context.l10n.grpBAnyProject),
            ),
            for (final p in projects)
              DropdownMenuItem(value: p.id, child: Text(p.name)),
          ],
          onChanged: (v) => onFilters(filters.copyWith(projectId: v ?? '')),
        ),
        OutlinedButton.icon(
          key: const Key('filter-dates'),
          icon: const Icon(Icons.date_range),
          label: Text(
            filters.since == null
                ? context.l10n.grpBAnyTime
                : _range(context, filters),
          ),
          onPressed: onPickDates,
        ),
        if (!filters.isEmpty)
          TextButton(
            key: const Key('filters-clear'),
            onPressed: () => onFilters(const AuditFilters()),
            child: Text(context.l10n.grpBClearFilters),
          ),
      ],
    );
  }

  static String _range(BuildContext context, AuditFilters f) {
    final last = f.until?.subtract(const Duration(days: 1)) ?? f.since!;
    return '${context.localIso(f.since!)} – ${context.localIso(last)}';
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, required this.labels, required this.now});

  final AuditEntry entry;
  final Map<String, String> labels;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      key: Key('audit-row-${entry.id}'),
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${entry.whoIn(context.l10n)} · ${describeEntry(entry, labels, context.l10n)}',
      ),
      subtitle: Text(
        '${entry.targetType} · ${entry.action} · ${relativeTime(now, entry.at, context.l10n, context.localePrefs)}',
      ),
      trailing: entry.batchId.isEmpty
          ? null
          : Tooltip(
              message: context.l10n.grpBBulkChange,
              child: const Icon(Icons.layers, size: 16),
            ),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => DiffDialog(entry: entry, labels: labels),
      ),
    ),
  );
}

/// Before and after of every field an entry changed, and where it came from.
class DiffDialog extends StatelessWidget {
  const DiffDialog({super.key, required this.entry, required this.labels});

  final AuditEntry entry;
  final Map<String, String> labels;

  String _name(BuildContext context, String field, Object? v) {
    if (v == null || v == '') return '—';
    if (v is List) return v.map((e) => _name(context, field, e)).join(', ');
    if (v is Map && v.containsKey('size')) {
      return context.l10n.grpBCharacters('${v['size']}');
    }
    if (field.endsWith('_id') || field == 'assignees') {
      return labels[v.toString()] ?? v.toString();
    }
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final changes = fieldChanges(entry);
    return AlertDialog(
      key: const Key('diff-dialog'),
      title: Text(entry.action),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${entry.whoIn(context.l10n)} · ${entry.at.toLocal()}'),
              if (entry.ip.isNotEmpty || entry.userAgent.isNotEmpty)
                Text('${entry.ip} ${entry.userAgent}'.trim()),
              const Divider(),
              if (changes.isEmpty) Text(context.l10n.grpBNoFieldChanges),
              for (final c in changes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: c.hasBefore
                      ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${fieldLabel(c.name, context.l10n)}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: _name(context, c.name, c.before),
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const TextSpan(text: '  →  '),
                              TextSpan(text: _name(context, c.name, c.after)),
                            ],
                          ),
                          key: Key('diff-${c.name}'),
                        )
                      : Text(
                          '${fieldLabel(c.name, context.l10n)}: ${_name(context, c.name, c.after)}',
                          key: Key('diff-${c.name}'),
                        ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.grpBClose),
        ),
      ],
    );
  }
}

class _ExportDialog extends StatelessWidget {
  const _ExportDialog({required this.csv, required this.messenger});

  final String csv;
  final ScaffoldMessengerState messenger;

  /// Only this many lines are drawn: a big export must not freeze the screen.
  /// Copy and Save always carry all of it.
  static const previewLines = 40;

  @override
  Widget build(BuildContext context) {
    final lines = const LineSplitter().convert(csv);
    final shown = lines.take(previewLines).join('\n');
    return _dialog(context, shown, lines.length);
  }

  Widget _dialog(BuildContext context, String shown, int total) => AlertDialog(
    key: const Key('audit-export-dialog'),
    title: Text(context.l10n.grpBAuditExportTitle),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (total > previewLines)
              Text(
                context.l10n.grpBAuditExportNote(previewLines, total),
                key: const Key('audit-export-note'),
              ),
            SelectableText(
              shown,
              key: const Key('audit-export-text'),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        key: const Key('audit-export-copy'),
        onPressed: () async {
          final copied = context.l10n.grpBCsvCopied;
          await Clipboard.setData(ClipboardData(text: csv));
          messenger.showSnackBar(SnackBar(content: Text(copied)));
          if (context.mounted) Navigator.pop(context);
        },
        child: Text(context.l10n.grpBCopy),
      ),
      TextButton(
        key: const Key('audit-export-save'),
        onPressed: () async {
          await FilePicker.saveFile(
            fileName: 'audit-log.csv',
            bytes: Uint8List.fromList(utf8.encode(csv)),
            mimeType: 'text/csv',
          );
          if (context.mounted) Navigator.pop(context);
        },
        child: Text(context.l10n.grpBSaveAsFile),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpBClose),
      ),
    ],
  );
}
