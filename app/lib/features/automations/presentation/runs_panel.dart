import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';

Color statusColor(BuildContext context, RunStatus? s) {
  final scheme = Theme.of(context).colorScheme;
  return switch (s) {
    RunStatus.succeeded => Colors.green.shade700,
    RunStatus.failed => scheme.error,
    RunStatus.skippedCondition => scheme.outline,
    RunStatus.skippedLoop || RunStatus.skippedRate => Colors.orange.shade800,
    null => scheme.outline,
  };
}

/// A coloured chip with the status in words.
class RunStatusChip extends StatelessWidget {
  const RunStatusChip({super.key, required this.status, this.raw = ''});

  final RunStatus? status;
  final String raw;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(status?.label ?? (raw.isEmpty ? 'Unknown' : raw)),
    visualDensity: VisualDensity.compact,
    side: BorderSide(color: statusColor(context, status)),
    labelStyle: TextStyle(color: statusColor(context, status)),
  );
}

/// What each step did, in order.
class StepsView extends StatelessWidget {
  const StepsView({super.key, required this.steps, this.lookups});

  final List<RunStep> steps;
  final String? lookups;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, s) in steps.indexed)
          Padding(
            key: Key('step-$i'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}. ${s.label} (${s.status.replaceAll('_', ' ')})',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: s.isFailure ? scheme.error : null,
                  ),
                ),
                for (final c in s.changes)
                  Text(
                    '${c.field}: ${c.from.isEmpty ? '(empty)' : c.from}'
                    ' -> ${c.to.isEmpty ? '(empty)' : c.to}',
                    key: Key('change-${c.field}'),
                  ),
                if (s.detail.isNotEmpty) Text(s.detail),
                if (s.error.isNotEmpty)
                  Text(s.error, style: TextStyle(color: scheme.error)),
              ],
            ),
          ),
      ],
    );
  }
}

/// The run history of a project, or of one rule.
class RunsPanel extends ConsumerWidget {
  const RunsPanel({super.key, required this.projectId, this.ruleId = ''});

  final String projectId;
  final String ruleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(
      automationRunsProvider((project: projectId, rule: ruleId)),
    );
    return switch (runs) {
      AsyncData(:final value) when value.isEmpty => const Center(
        child: Text('Nothing has run yet.', key: Key('runs-empty')),
      ),
      AsyncData(:final value) => ListView(
        key: const Key('runs-list'),
        children: [for (final r in value) RunTile(run: r)],
      ),
      AsyncError(:final error) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(automationErrorMessage(error), key: const Key('runs-error')),
            TextButton(
              onPressed: () => ref.invalidate(automationRunsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// One run: status, task, and on expansion the steps, the error and, for a run
/// that did nothing, why.
class RunTile extends StatelessWidget {
  const RunTile({super.key, required this.run});

  final AutomationRun run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = run.status;
    return ExpansionTile(
      key: Key('run-${run.id}'),
      title: Text(run.automationName),
      subtitle: Text(
        [
          if (run.taskKey.isNotEmpty) run.taskKey,
          run.startedAt,
        ].where((e) => e.isNotEmpty).join(' · '),
      ),
      trailing: RunStatusChip(status: status, raw: run.rawStatus),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        if (status != null &&
            status != RunStatus.succeeded &&
            status != RunStatus.failed)
          Text(status.meaning, key: Key('meaning-${run.id}')),
        if (run.didNotRun || run.explanation.isNotEmpty)
          Container(
            key: Key('why-${run.id}'),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Why didn't this run? "
              '${run.explanation.isEmpty ? status?.meaning ?? '' : run.explanation}',
            ),
          ),
        if (run.error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              run.error,
              key: Key('error-${run.id}'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        if (run.depth > 0) Text('Chain depth ${run.depth}'),
        StepsView(steps: run.steps),
      ],
    );
  }
}
