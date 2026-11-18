import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/automations/presentation/action_cards.dart';
import 'package:taskforge/features/automations/presentation/dry_run_dialog.dart';
import 'package:taskforge/features/automations/presentation/rule_builder.dart';
import 'package:taskforge/features/automations/presentation/runs_panel.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

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
      if (mounted) _say(automationErrorMessage(e, context.l10n));
    }
  }

  Future<void> _delete(Automation rule) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.l10n.grpCAutoDeleteTitle(rule.name)),
        content: Text(c.l10n.grpCAutoDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(c.l10n.grpCCancel),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(c.l10n.grpCDelete),
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
    return Scaffold(
      appBar: TfAppBar(
        title: Text(
          project == null
              ? context.l10n.grpCAutoTitle
              : context.l10n.grpCAutoTitleProject(project.name),
        ),
      ),
      body: switch (project) {
        null when catalog.hasValue => TfEmpty(
          key: const Key('automations-missing'),
          illustration: TfIllustrationKind.notFound,
          title: context.l10n.grpCAutoMissing,
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
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(context.l10n.grpCAutoRules),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(context.l10n.grpCAutoRunHistory),
                  ),
                ],
                selected: {_history},
                onSelectionChanged: (s) => setState(() => _history = s.first),
              ),
              if (canManage && !_history)
                FilledButton.icon(
                  key: const Key('new-rule'),
                  icon: const TfIcon(TfIcons.plus, size: 24),
                  label: Text(context.l10n.grpCAutoNew),
                  onPressed: full
                      ? null
                      : () => showRuleBuilder(
                          context,
                          projectId: widget.projectId,
                        ),
                ),
              if (!canManage)
                Chip(
                  key: const Key('read-only'),
                  avatar: const TfIcon(TfIcons.lock, size: 16),
                  label: Text(context.l10n.grpCAutoReadOnly),
                ),
              if (full && !_history)
                Text(
                  context.l10n.grpCAutoLimit(maxRulesPerProject),
                  key: const Key('rule-limit'),
                ),
            ],
          ),
        ),
        if (_history && _filter != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: InputChip(
                key: const Key('history-filter'),
                label: Text(context.l10n.grpCAutoRuleFilter(_filter!.name)),
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
    AsyncData(:final value) when value.isEmpty => TfEmpty(
      key: const Key('automations-empty'),
      title: context.l10n.grpCAutoEmpty,
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
    AsyncError(:final error) => TfError(
      key: const Key('automations-error'),
      message: automationErrorMessage(error, context.l10n),
      details: '$error',
      onRetry: () => ref.invalidate(automationsProvider),
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
                          context.l10n.grpCAutoWhen(
                            describeTrigger(
                              rule.trigger,
                              lookups,
                              context.l10n,
                            ),
                            rule.actions.length,
                          ),
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
                  Text(
                    context.l10n.grpCAutoNeverRun,
                    key: const Key('never-run'),
                  )
                else
                  KeyedSubtree(
                    key: Key('last-${rule.id}'),
                    child: RunStatusChip(status: last, raw: rule.lastRunStatus),
                  ),
                if (rule.lastRunAt.isNotEmpty) Text(rule.lastRunAt),
                TextButton(
                  key: Key('history-${rule.id}'),
                  onPressed: onHistory,
                  child: Text(context.l10n.grpCAutoHistory),
                ),
                if (canManage) ...[
                  TextButton(
                    key: Key('dry-${rule.id}'),
                    onPressed: onDryRun,
                    child: Text(context.l10n.grpCAutoDryRun),
                  ),
                  IconButton(
                    key: Key('delete-${rule.id}'),
                    tooltip: context.l10n.grpCDelete,
                    icon: const TfIcon(TfIcons.trash, size: 24),
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
///
/// [loc] is the language to describe it in; English when left out.
String describeTrigger(Trigger t, Lookups l, [AppLocalizations? loc]) {
  final s = loc ?? lookupAppLocalizations(const Locale('en'));
  return switch (t.type) {
    TriggerType.statusChanged =>
      t.toStatus.isEmpty
          ? s.grpCAutoStatusChanges
          : s.grpCAutoMovesTo(l.status(t.toStatus, s)),
    TriggerType.fieldChanged => s.grpCAutoFieldChanges(
      watchableFields[t.field] ?? l.fields[t.field] ?? t.field,
    ),
    TriggerType.assigned =>
      t.userId.isEmpty
          ? s.grpCAutoSomeoneAssigned
          : s.grpCAutoUserAssigned(l.user(t.userId, s)),
    TriggerType.dueDateReached =>
      t.daysBefore == 0
          ? s.grpCAutoDueReached
          : s.grpCAutoDaysBefore(t.daysBefore),
    _ => t.type.labelIn(s).toLowerCase(),
  };
}
