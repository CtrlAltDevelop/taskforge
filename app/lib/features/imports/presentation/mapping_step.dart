import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Our priorities, for the priority table.
Map<String, String> _priorities(AppLocalizations l) => {
  'urgent': l.grpCImpPriUrgent,
  'high': l.grpCImpPriHigh,
  'normal': l.grpCImpPriNormal,
  'low': l.grpCImpPriLow,
  'none': l.grpCImpPriNone,
};

/// The fields a CSV column can fill (the server's names).
Map<String, String> csvFieldLabels(AppLocalizations l) => {
  'title': l.grpCImpFTitle,
  'description': l.grpCImpFDescription,
  'status': l.grpCStatus,
  'priority': l.grpCImpFPriority,
  'assignee': l.grpCImpFAssignee,
  'reporter': l.grpCImpFReporter,
  'created': l.grpCImpFCreated,
  'updated': l.grpCImpFUpdated,
  'start': l.grpCImpFStart,
  'due': l.grpCImpFDue,
  'labels': l.grpCImpFLabels,
  'sprint': l.grpCImpFSprint,
  'parent': l.grpCImpFParent,
  'id': l.grpCImpFId,
  'key': l.grpCImpFKey,
  'points': l.grpCImpFPoints,
  'estimate': l.grpCImpFEstimate,
  'comment': l.grpCComment,
  'type': l.grpCImpFType,
};

/// Where it goes and how each part of the file maps, with everything proposed
/// from the file: the person only changes what is wrong.
class MappingStep extends ConsumerWidget {
  const MappingStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final proposal = wizard.proposal;
    if (proposal == null) return const SizedBox.shrink();
    final analysis = proposal.analysis;
    final mapping = wizard.mapping;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          analysis.subtasks > 0
              ? context.l10n.grpCImpSummarySub(
                  analysis.issues,
                  analysis.subtasks,
                  analysis.comments,
                  analysis.links,
                  wizard.job?.filename ?? context.l10n.grpCImpTheFile,
                )
              : context.l10n.grpCImpSummary(
                  analysis.issues,
                  analysis.comments,
                  analysis.links,
                  wizard.job?.filename ?? context.l10n.grpCImpTheFile,
                ),
          key: const Key('import-summary'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: TfSpace.md),
        _Source(wizard: wizard, notifier: notifier),
        if (proposal.members.length > 1) _Members(proposal: proposal),
        const Divider(height: 32),
        _Target(mapping: mapping, onChanged: notifier.edit),
        if (wizard.isCsv && analysis.columns.isNotEmpty) ...[
          const Divider(height: 32),
          _Columns(
            columns: analysis.columns,
            mapping: mapping,
            onChanged: notifier.edit,
          ),
        ],
        if (analysis.statuses.isNotEmpty) ...[
          const Divider(height: 32),
          _Statuses(
            counts: analysis.statuses,
            mapping: mapping,
            onChanged: notifier.edit,
          ),
        ],
        if (analysis.priorities.isNotEmpty) ...[
          const Divider(height: 32),
          _Table(
            title: context.l10n.grpCImpPriorities,
            rows: [
              for (final e in analysis.priorities.entries)
                _Row(
                  keyName: 'map-priority-${e.key}',
                  label: '${e.key} (${e.value})',
                  value: mapping.priorities[e.key] ?? 'none',
                  options: _priorities(context.l10n),
                  onChanged: (v) => notifier.edit(
                    mapping.copyWith(
                      priorities: {...mapping.priorities, e.key: v},
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (analysis.people.isNotEmpty) ...[
          const Divider(height: 32),
          _People(
            people: analysis.people,
            mapping: mapping,
            onChanged: notifier.edit,
          ),
        ],
        if (analysis.labels > 0) ...[
          const Divider(height: 32),
          TfToggleTile(
            key: const Key('map-labels'),
            value: mapping.labels,
            onChanged: (v) => notifier.edit(mapping.copyWith(labels: v)),
            title: context.l10n.grpCImpKeepLabels(analysis.labels),
            subtitle: context.l10n.grpCImpKeepLabelsSub,
          ),
        ],
        if (analysis.sprints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: TfSpace.sm),
            child: Text(
              context.l10n.grpCImpSprintsCreated(analysis.sprints.join(', ')),
              key: const Key('map-sprints'),
            ),
          ),
        const SizedBox(height: TfSpace.lg),
        Row(
          children: [
            TfButton(
              key: const Key('map-back'),
              label: context.l10n.grpCBack,
              variant: TfButtonVariant.ghost,
              onPressed: wizard.busy ? null : notifier.back,
            ),
            const Spacer(),
            TfButton(
              key: const Key('map-next'),
              label: context.l10n.grpCImpReview,
              variant: TfButtonVariant.primary,
              onPressed: wizard.busy ? null : notifier.review,
            ),
          ],
        ),
      ],
    );
  }
}

class _Source extends StatelessWidget {
  const _Source({required this.wizard, required this.notifier});

  final ImportWizardState wizard;
  final ImportWizard notifier;

  @override
  Widget build(BuildContext context) {
    final current = wizard.detected;
    return Row(
      children: [
        Text(context.l10n.grpCImpReadAs),
        const SizedBox(width: TfSpace.md),
        TfSelectField<ImportSource>(
          key: const Key('import-source'),
          options: {
            for (final s in ImportSource.values) s: s.labelIn(context.l10n),
          },
          value: current,
          onChanged: wizard.busy
              ? null
              : (s) {
                  if (s != current) notifier.changeSource(s);
                },
        ),
      ],
    );
  }
}

class _Members extends ConsumerWidget {
  const _Members({required this.proposal});

  final ImportProposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.only(top: TfSpace.sm),
    child: Row(
      children: [
        Text(context.l10n.grpCImpZipFile),
        const SizedBox(width: TfSpace.md),
        Flexible(
          child: TfSelectField(
            key: const Key('import-member'),
            options: {for (final m in proposal.members) m: m},
            value: null,
            onChanged: (m) {
              if (m != null) {
                ref.read(importWizardProvider.notifier).chooseMember(m);
              }
            },
            hint: context.l10n.grpCImpChooseOne,
            expand: true,
          ),
        ),
      ],
    ),
  );
}

class _Target extends ConsumerWidget {
  const _Target({required this.mapping, required this.onChanged});

  final ImportMapping mapping;
  final void Function(ImportMapping) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects =
        (ref.watch(projectsProvider(false)).value?.projects ?? const [])
            .where((p) => !p.isArchived)
            .toList();
    final existing = !mapping.intoNewProject;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.grpCImpInto,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        RadioGroup<bool>(
          groupValue: existing,
          onChanged: (v) {
            if (v == true && projects.isNotEmpty) {
              onChanged(mapping.copyWith(projectId: projects.first.id));
            } else {
              onChanged(mapping.copyWith(projectId: ''));
            }
          },
          child: Column(
            children: [
              TfRadioTile<bool>(
                key: const Key('map-target-new'),
                value: false,
                title: context.l10n.grpCImpNewProject,
              ),
              if (projects.isNotEmpty)
                TfRadioTile<bool>(
                  key: const Key('map-target-existing'),
                  value: true,
                  title: context.l10n.grpCImpExistingProject,
                ),
            ],
          ),
        ),
        const SizedBox(height: TfSpace.md),
        if (existing)
          TfSelectField(
            key: const Key('map-project'),
            options: {for (final p in projects) p.id: '${p.name} (${p.key})'},
            value: projects.any((p) => p.id == mapping.projectId)
                ? mapping.projectId
                : null,
            onChanged: (id) {
              onChanged(mapping.copyWith(projectId: id));
            },
          )
        else
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('map-new-name'),
                  initialValue: mapping.newName,
                  decoration: InputDecoration(
                    labelText: context.l10n.grpCImpProjectName,
                  ),
                  onChanged: (v) => onChanged(mapping.copyWith(newName: v)),
                ),
              ),
              const SizedBox(width: TfSpace.md),
              SizedBox(
                width: 120,
                child: TextFormField(
                  key: const Key('map-new-key'),
                  initialValue: mapping.newKey,
                  decoration: InputDecoration(
                    labelText: context.l10n.grpCImpFKey,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (v) => onChanged(mapping.copyWith(newKey: v)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Columns extends StatelessWidget {
  const _Columns({
    required this.columns,
    required this.mapping,
    required this.onChanged,
  });

  final List<String> columns;
  final ImportMapping mapping;
  final void Function(ImportMapping) onChanged;

  @override
  Widget build(BuildContext context) => _Table(
    title: context.l10n.grpCImpColumns,
    rows: [
      for (final e in csvFieldLabels(context.l10n).entries)
        _Row(
          keyName: 'map-col-${e.key}',
          label: e.value,
          value: columns.contains(mapping.columns[e.key])
              ? mapping.columns[e.key]!
              : '',
          options: {
            '': context.l10n.grpCImpNotInFile,
            for (final c in columns.toSet()) c: c,
          },
          onChanged: (v) => onChanged(
            mapping.copyWith(columns: {...mapping.columns, e.key: v}),
          ),
        ),
    ],
  );
}

class _Statuses extends ConsumerWidget {
  const _Statuses({
    required this.counts,
    required this.mapping,
    required this.onChanged,
  });

  final Map<String, int> counts;
  final ImportMapping mapping;
  final void Function(ImportMapping) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = mapping.intoNewProject
        ? const <WorkflowStatus>[]
        : (ref.watch(workflowProvider(mapping.projectId)).value?.statuses ??
              const []);
    return _Table(
      title: context.l10n.grpCImpStatuses,
      rows: [
        for (final e in counts.entries)
          _Row(
            keyName: 'map-status-${e.key}',
            label: '${e.key} (${e.value})',
            value: _statusValue(mapping.statuses[e.key], statuses),
            options: {
              'new': context.l10n.grpCImpSameName,
              for (final s in statuses) 'id:${s.id}': s.name,
            },
            onChanged: (v) => onChanged(
              mapping.copyWith(statuses: {...mapping.statuses, e.key: v}),
            ),
          ),
      ],
    );
  }

  static String _statusValue(String? chosen, List<WorkflowStatus> statuses) {
    if (chosen == null || chosen == 'new') return 'new';
    return statuses.any((s) => 'id:${s.id}' == chosen) ? chosen : 'new';
  }
}

class _People extends ConsumerWidget {
  const _People({
    required this.people,
    required this.mapping,
    required this.onChanged,
  });

  final Map<String, String> people;
  final ImportMapping mapping;
  final void Function(ImportMapping) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final options = {
      'placeholder': context.l10n.grpCImpNotMember,
      'skip': context.l10n.grpCImpUnassigned,
      for (final m in members)
        m.userId: m.displayName.isEmpty ? m.email : m.displayName,
    };
    return _Table(
      title: context.l10n.grpCImpPeople,
      rows: [
        for (final e in people.entries.take(200))
          _Row(
            keyName: 'map-user-${e.key}',
            label: e.value == e.key ? e.key : '${e.value} (${e.key})',
            value: options.containsKey(mapping.users[e.key])
                ? mapping.users[e.key]!
                : 'placeholder',
            options: options,
            onChanged: (v) => onChanged(
              mapping.copyWith(users: {...mapping.users, e.key: v}),
            ),
          ),
        if (people.length > 200) _Note(context.l10n.grpCImpFirst200),
      ],
    );
  }
}

class _Note extends _Row {
  const _Note(String text)
    : super(
        keyName: 'map-note',
        label: text,
        value: '',
        options: const {},
        onChanged: _ignore,
      );

  static void _ignore(String _) {}
}

class _Row {
  const _Row({
    required this.keyName,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String keyName;
  final String label;
  final String value;
  final Map<String, String> options;
  final void Function(String) onChanged;
}

class _Table extends StatelessWidget {
  const _Table({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: TfSpace.xs),
      for (final row in rows)
        if (row is _Note)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
            child: Text(row.label),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.xxs),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(row.label)),
                const SizedBox(width: TfSpace.md),
                Expanded(
                  flex: 3,
                  child: DropdownButton<String>(
                    key: Key(row.keyName),
                    isExpanded: true,
                    value: row.options.containsKey(row.value)
                        ? row.value
                        : null,
                    items: [
                      for (final o in row.options.entries)
                        DropdownMenuItem(
                          value: o.key,
                          child: Text(o.value, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) row.onChanged(v);
                    },
                  ),
                ),
              ],
            ),
          ),
    ],
  );
}
