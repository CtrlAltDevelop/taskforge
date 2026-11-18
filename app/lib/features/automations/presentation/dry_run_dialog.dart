import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/automations/presentation/runs_panel.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// Tries [rule] on a chosen task without changing anything.
Future<void> showDryRun(BuildContext context, Automation rule) =>
    showDialog<void>(
      context: context,
      builder: (_) => DryRunDialog(rule: rule),
    );

class DryRunDialog extends ConsumerStatefulWidget {
  const DryRunDialog({super.key, required this.rule});

  final Automation rule;

  @override
  ConsumerState<DryRunDialog> createState() => _DryRunDialogState();
}

class _DryRunDialogState extends ConsumerState<DryRunDialog> {
  String? _task;
  DryRunResult? _result;
  String? _error;
  var _busy = false;

  Future<void> _run() async {
    final id = _task;
    if (id == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final r = await ref
          .read(automationActionsProvider)
          .dryRun(widget.rule, id);
      if (mounted) setState(() => _result = r);
    } on AutomationException catch (e) {
      if (mounted) {
        setState(() => _error = automationErrorMessage(e, context.l10n));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(dryRunTasksProvider(widget.rule.projectId));
    final scheme = Theme.of(context).colorScheme;
    final result = _result;
    return AlertDialog(
      title: Text(context.l10n.grpGDryRunTitle(widget.rule.name)),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.grpGDryRunIntro),
              const SizedBox(height: 12),
              switch (tasks) {
                AsyncData(:final value) => DropdownButtonFormField<String>(
                  key: const Key('dry-task'),
                  initialValue: _task,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.grpGTask,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final t in value)
                      DropdownMenuItem(
                        value: t.id,
                        child: Text(
                          '${t.displayId} ${t.title}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() {
                    _task = v;
                    _result = null;
                  }),
                ),
                AsyncError() => TfError(
                  compact: true,
                  message: context.l10n.grpGTasksLoadFailed,
                  onRetry: () => ref.invalidate(
                    dryRunTasksProvider(widget.rule.projectId),
                  ),
                ),
                _ => const LinearProgressIndicator(),
              },
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    key: const Key('dry-error'),
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              if (result != null) ...[
                const Divider(height: 24),
                Text(
                  result.wouldRun
                      ? context.l10n.grpGWouldRun
                      : context.l10n.grpGWouldNotRun,
                  key: const Key('dry-verdict'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (result.explanation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      result.explanation,
                      key: const Key('dry-explanation'),
                    ),
                  ),
                if (result.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      result.error,
                      key: const Key('dry-result-error'),
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                const SizedBox(height: 8),
                StepsView(steps: result.steps),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpGClose),
        ),
        FilledButton(
          key: const Key('dry-run'),
          onPressed: _task == null || _busy ? null : _run,
          child: Text(context.l10n.grpGRun),
        ),
      ],
    );
  }
}
