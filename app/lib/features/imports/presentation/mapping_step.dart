import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// Our priorities, for the priority table.
const _priorities = {
  'urgent': 'Urgent',
  'high': 'High',
  'normal': 'Normal',
  'low': 'Low',
  'none': 'None',
};

/// The fields a CSV column can fill (the server's names).
const csvFieldLabels = {
  'title': 'Title *',
  'description': 'Description',
  'status': 'Status',
  'priority': 'Priority',
  'assignee': 'Assignee',
  'reporter': 'Reporter',
  'created': 'Created',
  'updated': 'Updated',
  'start': 'Start date',
  'due': 'Due date',
  'labels': 'Labels',
  'sprint': 'Sprint',
  'parent': 'Parent (id)',
  'id': 'Id',
  'key': 'Key',
  'points': 'Story points',
  'estimate': 'Estimate',
  'comment': 'Comment',
  'type': 'Type',
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
          '${analysis.issues} tasks'
          '${analysis.subtasks > 0 ? ' (${analysis.subtasks} sub-tasks)' : ''}, '
          '${analysis.comments} comments, ${analysis.links} links found in '
          '${wizard.job?.filename ?? 'the file'}.',
          key: const Key('import-summary'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
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
            title: 'Priorities',
            rows: [
              for (final e in analysis.priorities.entries)
                _Row(
                  keyName: 'map-priority-${e.key}',
                  label: '${e.key} (${e.value})',
                  value: mapping.priorities[e.key] ?? 'none',
                  options: _priorities,
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
          SwitchListTile(
            key: const Key('map-labels'),
            contentPadding: EdgeInsets.zero,
            title: Text('Keep ${analysis.labels} labels'),
            subtitle: const Text('As a "Labels" field on every task.'),
            value: mapping.labels,
            onChanged: (v) => notifier.edit(mapping.copyWith(labels: v)),
          ),
        ],
        if (analysis.sprints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Sprints that will be created: ${analysis.sprints.join(', ')}',
              key: const Key('map-sprints'),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              key: const Key('map-back'),
              onPressed: wizard.busy ? null : notifier.back,
              child: const Text('Back'),
            ),
            const Spacer(),
            FilledButton(
              key: const Key('map-next'),
              onPressed: wizard.busy ? null : notifier.review,
              child: const Text('Review'),
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
        const Text('Read as'),
        const SizedBox(width: 12),
        DropdownButton<ImportSource>(
          key: const Key('import-source'),
          value: current,
          items: [
            for (final s in ImportSource.values)
              DropdownMenuItem(value: s, child: Text(s.label)),
          ],
          onChanged: wizard.busy
              ? null
              : (s) {
                  if (s != null && s != current) notifier.changeSource(s);
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
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        const Text('File inside the zip'),
        const SizedBox(width: 12),
        Flexible(
          child: DropdownButton<String>(
            key: const Key('import-member'),
            isExpanded: true,
            hint: const Text('Choose one'),
            items: [
              for (final m in proposal.members)
                DropdownMenuItem(value: m, child: Text(m)),
            ],
            onChanged: (m) {
              if (m != null) {
                ref.read(importWizardProvider.notifier).chooseMember(m);
              }
            },
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
        Text('Import into', style: Theme.of(context).textTheme.titleSmall),
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
              RadioListTile<bool>(
                key: const Key('map-target-new'),
                contentPadding: EdgeInsets.zero,
                title: const Text('A new project'),
                value: false,
              ),
              if (projects.isNotEmpty)
                RadioListTile<bool>(
                  key: const Key('map-target-existing'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('An existing project'),
                  value: true,
                ),
            ],
          ),
        ),
        if (existing)
          DropdownButton<String>(
            key: const Key('map-project'),
            value: projects.any((p) => p.id == mapping.projectId)
                ? mapping.projectId
                : null,
            items: [
              for (final p in projects)
                DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.name} (${p.key})'),
                ),
            ],
            onChanged: (id) {
              if (id != null) onChanged(mapping.copyWith(projectId: id));
            },
          )
        else
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('map-new-name'),
                  initialValue: mapping.newName,
                  decoration: const InputDecoration(labelText: 'Project name'),
                  onChanged: (v) => onChanged(mapping.copyWith(newName: v)),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextFormField(
                  key: const Key('map-new-key'),
                  initialValue: mapping.newKey,
                  decoration: const InputDecoration(labelText: 'Key'),
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
    title: 'Columns',
    rows: [
      for (final e in csvFieldLabels.entries)
        _Row(
          keyName: 'map-col-${e.key}',
          label: e.value,
          value: columns.contains(mapping.columns[e.key])
              ? mapping.columns[e.key]!
              : '',
          options: {
            '': '(not in the file)',
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
      title: 'Statuses',
      rows: [
        for (final e in counts.entries)
          _Row(
            keyName: 'map-status-${e.key}',
            label: '${e.key} (${e.value})',
            value: _statusValue(mapping.statuses[e.key], statuses),
            options: {
              'new': 'Same name (create if missing)',
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
      'placeholder': 'Not a member yet (assign when they join)',
      'skip': 'Leave unassigned',
      for (final m in members)
        m.userId: m.displayName.isEmpty ? m.email : m.displayName,
    };
    return _Table(
      title: 'People',
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
        if (people.length > 200)
          const _Note(
            'Only the first 200 people are listed; the rest wait as placeholders.',
          ),
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
      const SizedBox(height: 4),
      for (final row in rows)
        if (row is _Note)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(row.label),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(row.label)),
                const SizedBox(width: 12),
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
