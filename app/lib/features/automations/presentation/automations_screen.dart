import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/automations/presentation/action_cards.dart';
import 'package:taskforge/features/automations/presentation/dry_run_dialog.dart';
import 'package:taskforge/features/automations/presentation/rule_builder.dart';
import 'package:taskforge/features/automations/presentation/runs_panel.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

/// A project's rules and their run history.
class AutomationsScreen extends ConsumerStatefulWidget {
  const AutomationsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<AutomationsScreen> createState() => _AutomationsScreenState();
}

class _AutomationsScreenState extends ConsumerState<AutomationsScreen> {
  var _history = false;
  Automation? _filter;

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _try(Future<Object?> Function() call) async {
    try {
      await call();
    } on AutomationException catch (e) {
      if (mounted) _say(automationErrorMessage(e));
    }
  }

  Future<void> _delete(Automation rule) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Delete "${rule.name}"?'),
        content: const Text(
          'The rule stops for good. Its run history is deleted too.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _try(() => ref.read(automationActionsProvider).delete(rule));
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId));
    final catalog = ref.watch(projectCatalogProvider(true));
    return ShellScaffold(
      appBar: AppBar(
        title: Text(
          'Automations${project == null ? '' : ' · ${project.name}'}',
        ),
      ),
      body: switch (project) {
        null when catalog.hasValue => const Center(
          child: Text('Project not found.', key: Key('automations-missing')),
        ),
        null => const Center(child: CircularProgressIndicator()),
        _ => _body(context),
      },
    );
  }

  Widget _body(BuildContext context) {
    final canManage = ref
        .watch(permissionSetProvider)
        .can(Perm.automationManage);
    final rules = ref.watch(automationsProvider(widget.projectId));
    final count = rules.value?.length ?? 0;
    final full = count >= maxRulesPerProject;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<bool>(
                key: const Key('automations-tabs'),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('Rules')),
                  ButtonSegment(value: true, label: Text('Run history')),
                ],
                selected: {_history},
                onSelectionChanged: (s) => setState(() => _history = s.first),
              ),
              if (canManage && !_history)
                FilledButton.icon(
                  key: const Key('new-rule'),
                  icon: const Icon(Icons.add),
                  label: const Text('New automation'),
                  onPressed: full
                      ? null
                      : () => showRuleBuilder(
                          context,
                          projectId: widget.projectId,
                        ),
                ),
              if (!canManage)
                const Chip(
                  key: Key('read-only'),
                  avatar: Icon(Icons.lock_outline, size: 16),
                  label: Text('Read only'),
                ),
              if (full && !_history)
                Text(
                  'Limit of $maxRulesPerProject rules reached.',
                  key: const Key('rule-limit'),
                ),
            ],
          ),
        ),
        if (_history && _filter != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                key: const Key('history-filter'),
                label: Text('Rule: ${_filter!.name}'),
                onDeleted: () => setState(() => _filter = null),
              ),
            ),
          ),
        Expanded(
          child: _history
              ? RunsPanel(
                  projectId: widget.projectId,
                  ruleId: _filter?.id ?? '',
                )
              : _rules(context, rules, canManage),
        ),
      ],
    );
  }

  Widget _rules(
    BuildContext context,
    AsyncValue<List<Automation>> rules,
    bool canManage,
  ) => switch (rules) {
    AsyncData(:final value) when value.isEmpty => const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No automations yet. A rule says: when something happens, and '
          'if it matches, then do these things.',
          key: Key('automations-empty'),
          textAlign: TextAlign.center,
        ),
      ),
    ),
    AsyncData(:final value) => ListView(
      key: const Key('automations-list'),
      children: [
        for (final r in value)
          RuleTile(
            rule: r,
            canManage: canManage,
            onToggle: (on) =>
                _try(() => ref.read(automationActionsProvider).toggle(r, on)),
            onOpen: () => showRuleBuilder(
              context,
              projectId: widget.projectId,
              rule: r,
              readOnly: !canManage,
            ),
            onDryRun: () => showDryRun(context, r),
            onHistory: () => setState(() {
              _filter = r;
              _history = true;
            }),
            onDelete: () => _delete(r),
          ),
      ],
    ),
    AsyncError(:final error) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            automationErrorMessage(error),
            key: const Key('automations-error'),
          ),
          TextButton(
            onPressed: () => ref.invalidate(automationsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
    _ => const Center(child: CircularProgressIndicator()),
  };
}

/// One rule in the list.
class RuleTile extends ConsumerWidget {
  const RuleTile({
    super.key,
    required this.rule,
    required this.canManage,
    required this.onToggle,
    required this.onOpen,
    required this.onDryRun,
    required this.onHistory,
    required this.onDelete,
  });

  final Automation rule;
  final bool canManage;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;
  final VoidCallback onDryRun;
  final VoidCallback onHistory;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookups = ref.watch(lookupsProvider(rule.projectId));
    final last = RunStatus.tryParse(rule.lastRunStatus);
    return Card(
      key: Key('rule-${rule.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rule.wasSwitchedOffByServer)
              DisabledBanner(reason: rule.disabledReason),
            InkWell(
              key: Key('open-${rule.id}'),
              onTap: onOpen,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'When ${describeTrigger(rule.trigger, lookups)}'
                          ' · ${rule.actions.length} '
                          '${rule.actions.length == 1 ? 'action' : 'actions'}',
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    key: Key('toggle-${rule.id}'),
                    value: rule.enabled,
                    onChanged: canManage ? onToggle : null,
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (rule.lastRunStatus.isEmpty)
                  const Text('Never run', key: Key('never-run'))
                else
                  KeyedSubtree(
                    key: Key('last-${rule.id}'),
                    child: RunStatusChip(status: last, raw: rule.lastRunStatus),
                  ),
                if (rule.lastRunAt.isNotEmpty) Text(rule.lastRunAt),
                TextButton(
                  key: Key('history-${rule.id}'),
                  onPressed: onHistory,
                  child: const Text('History'),
                ),
                if (canManage) ...[
                  TextButton(
                    key: Key('dry-${rule.id}'),
                    onPressed: onDryRun,
                    child: const Text('Dry run'),
                  ),
                  IconButton(
                    key: Key('delete-${rule.id}'),
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A short phrase for the trigger.
String describeTrigger(Trigger t, Lookups l) => switch (t.type) {
  TriggerType.statusChanged =>
    t.toStatus.isEmpty
        ? 'a status changes'
        : 'a task moves to ${l.status(t.toStatus)}',
  TriggerType.fieldChanged =>
    '${watchableFields[t.field] ?? l.fields[t.field] ?? t.field} changes',
  TriggerType.assigned =>
    t.userId.isEmpty
        ? 'someone is assigned'
        : '${l.user(t.userId)} is assigned',
  TriggerType.dueDateReached =>
    t.daysBefore == 0
        ? 'a due date is reached'
        : '${t.daysBefore} days before a due date',
  _ => t.type.label.toLowerCase(),
};
