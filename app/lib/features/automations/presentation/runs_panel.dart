import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

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

/// The run history of a project, or of one rule: the newest page, and older
/// ones on "Load more" (the page after the last run shown, by its start time).
class RunsPanel extends ConsumerStatefulWidget {
  const RunsPanel({super.key, required this.projectId, this.ruleId = ''});

  final String projectId;
  final String ruleId;

  @override
  ConsumerState<RunsPanel> createState() => _RunsPanelState();
}

class _RunsPanelState extends ConsumerState<RunsPanel> {
  var _older = const <AutomationRun>[];
  var _exhausted = false;
  var _loading = false;
  Object? _moreError;

  RunsKey get _key => (project: widget.projectId, rule: widget.ruleId);

  Future<void> _loadMore(List<AutomationRun> newest) async {
    final shown = [...newest, ..._older];
    if (shown.isEmpty || _loading) return;
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    setState(() {
      _loading = true;
      _moreError = null;
    });
    try {
      final page = await ref
          .read(automationsClientProvider)
          .runs(
            ws,
            widget.projectId,
            automationId: widget.ruleId,
            before: '${shown.last.startedAt}#${shown.last.id}',
            limit: runPageSize,
          );
      if (!mounted) return;
      final have = {for (final r in shown) r.id};
      setState(() {
        _older = [
          ..._older,
          for (final r in page)
            if (!have.contains(r.id)) r,
        ];
        _exhausted = page.length < runPageSize;
        _loading = false;
      });
    } on AutomationException catch (e) {
      if (!mounted) return;
      setState(() {
        _moreError = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A fresh read of the newest page (a change elsewhere) starts over.
    ref.listen(automationRunsProvider(_key), (prev, next) {
      if (next is AsyncData && prev?.value != next.value) {
        setState(() {
          _older = const [];
          _exhausted = false;
          _moreError = null;
        });
      }
    });
    final runs = ref.watch(automationRunsProvider(_key));
    return switch (runs) {
      AsyncData(:final value) when value.isEmpty => const Center(
        child: Text('Nothing has run yet.', key: Key('runs-empty')),
      ),
      AsyncData(:final value) => ListView(
        key: const Key('runs-list'),
        children: [
          for (final r in [...value, ..._older]) RunTile(run: r),
          if (_moreError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                automationErrorMessage(_moreError!),
                key: const Key('runs-more-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (value.length >= runPageSize && !_exhausted)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        key: const Key('runs-load-more'),
                        onPressed: () => _loadMore(value),
                        child: const Text('Load more'),
                      ),
              ),
            ),
        ],
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
