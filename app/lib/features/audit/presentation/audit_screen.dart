import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
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
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

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
        leading: TfIconButton(
          key: const Key('back-home'),
          icon: TfIcons.arrowStart,
          tooltip: context.l10n.grpBBack,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.l10n.grpBAuditTitle),
        actions: [
          if (allowed)
            TfIconButton(
              key: const Key('audit-export'),
              icon: TfIcons.download,
              tooltip: context.l10n.grpBExportCsv,
              onPressed: _exporting ? null : _export,
            ),
        ],
      ),
      body: allowed
          ? _Body(filters: _filters, onFilters: _set, onPickDates: _pickDates)
          : TfEmpty(
              key: const Key('audit-denied'),
              illustration: TfIllustrationKind.noAccess,
              title: context.l10n.grpBAuditDenied,
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
    final entries = state.entries;
    final showRows =
        !state.loading &&
        !(state.error != null && entries.isEmpty) &&
        entries.isNotEmpty;
    // The rows, then what sits under them (an error, "show older"); or the one
    // widget that stands in for them (spinner, error, empty).
    final lead = <Widget>[
      if (state.loading)
        const Center(child: CircularProgressIndicator())
      else if (state.error != null && entries.isEmpty)
        TfError(
          key: const Key('audit-error'),
          compact: true,
          message: auditErrorMessage(state.error!, context.l10n),
          details: '${state.error}',
          retryKey: const Key('audit-retry'),
          onRetry: notifier.refresh,
        )
      else if (entries.isEmpty)
        TfEmpty(
          key: const Key('audit-empty'),
          compact: true,
          illustration: TfIllustrationKind.docs,
          title: context.l10n.grpBAuditEmpty,
        ),
    ];
    final foot = <Widget>[
      if (showRows && state.error != null)
        Text(
          auditErrorMessage(state.error!, context.l10n),
          key: const Key('audit-error'),
        ),
      if (showRows && state.hasMore)
        TfButton(
          key: const Key('audit-more'),
          label: state.loadingMore
              ? context.l10n.grpBLoading
              : context.l10n.grpBShowOlder,
          variant: TfButtonVariant.ghost,
          onPressed: state.loadingMore ? null : notifier.more,
        ),
    ];
    final rows = showRows ? entries.length : 0;
    return TfPage.builder(
      key: const Key('audit-list'),
      maxWidth: TfPageWidth.wide,
      pinned: _Filters(
        filters: filters,
        onFilters: onFilters,
        onPickDates: onPickDates,
      ),
      itemCount: lead.length + rows + foot.length,
      itemBuilder: (context, i) {
        if (i < lead.length) return lead[i];
        i -= lead.length;
        if (i < rows) {
          return _Row(entry: entries[i], labels: state.labels, now: now);
        }
        return foot[i - rows];
      },
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
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: TfSpace.sm,
        runSpacing: TfSpace.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (label, prefix) in auditAreas)
            TfChip(
              key: Key('area-${prefix.isEmpty ? 'all' : prefix}'),
              label: _areaLabel(context, prefix, label),
              selected: filters.action == prefix,
              onTap: () => onFilters(filters.copyWith(action: prefix)),
            ),
          TfSelectField(
            key: const Key('filter-person'),
            options: {
              '': context.l10n.grpBAnyone,
              for (final m in members) m.userId: m.displayName,
            },
            value: members.any((m) => m.userId == filters.actor)
                ? filters.actor
                : '',
            onChanged: (v) => onFilters(filters.copyWith(actor: v)),
            hint: context.l10n.grpBAnyone,
          ),
          TfSelectField(
            key: const Key('filter-project'),
            options: {
              '': context.l10n.grpBAnyProject,
              for (final p in projects) p.id: p.name,
            },
            value: projects.any((p) => p.id == filters.projectId)
                ? filters.projectId
                : '',
            onChanged: (v) => onFilters(filters.copyWith(projectId: v)),
          ),
          TfButton(
            key: const Key('filter-dates'),
            label: filters.since == null
                ? context.l10n.grpBAnyTime
                : _range(context, filters),
            icon: TfIcons.calendarRange,
            onPressed: onPickDates,
          ),
          if (!filters.isEmpty)
            TfButton(
              key: const Key('filters-clear'),
              label: context.l10n.grpBClearFilters,
              variant: TfButtonVariant.ghost,
              onPressed: () => onFilters(const AuditFilters()),
            ),
        ],
      ),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
    child: TfPanel(
      padding: EdgeInsets.zero,
      child: TfRow(
        key: Key('audit-row-${entry.id}'),
        title:
            '${entry.whoIn(context.l10n)} · ${describeEntry(entry, labels, context.l10n)}',
        subtitle:
            '${entry.targetType} · ${entry.action} · ${relativeTime(now, entry.at, context.l10n, context.localePrefs)}',
        trailing: entry.batchId.isEmpty
            ? null
            : Tooltip(
                message: context.l10n.grpBBulkChange,
                child: const TfIcon(TfIcons.layers, size: 16),
              ),
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => DiffDialog(entry: entry, labels: labels),
        ),
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
    return TfDialogFrame(
      key: const Key('diff-dialog'),
      title: entry.action,
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
                  padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
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
        TfButton(
          label: context.l10n.grpBClose,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
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

  Widget _dialog(BuildContext context, String shown, int total) =>
      TfDialogFrame(
        key: const Key('audit-export-dialog'),
        title: context.l10n.grpBAuditExportTitle,
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
          TfButton(
            key: const Key('audit-export-copy'),
            label: context.l10n.grpBCopy,
            variant: TfButtonVariant.ghost,
            onPressed: () async {
              final copied = context.l10n.grpBCsvCopied;
              await Clipboard.setData(ClipboardData(text: csv));
              messenger.showSnackBar(SnackBar(content: Text(copied)));
              if (context.mounted) Navigator.pop(context);
            },
          ),
          TfButton(
            key: const Key('audit-export-save'),
            label: context.l10n.grpBSaveAsFile,
            variant: TfButtonVariant.ghost,
            onPressed: () async {
              await FilePicker.saveFile(
                fileName: 'audit-log.csv',
                bytes: Uint8List.fromList(utf8.encode(csv)),
                mimeType: 'text/csv',
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
          TfButton(
            label: context.l10n.grpBClose,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
}
