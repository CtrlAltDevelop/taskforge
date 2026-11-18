import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/core/ui/theme_extension.dart';

/// What is wrong with the workflow being edited, in words, or that it is ready.
class ValidationPanel extends StatelessWidget {
  const ValidationPanel({super.key, required this.problems});

  final List<WorkflowProblem> problems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (problems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
        child: TfPanel(
          key: const Key('validation-ok'),
          padding: EdgeInsets.zero,
          child: TfRow(
            title: context.l10n.grpINoProblems,
            subtitle: context.l10n.grpIEveryTaskValid,
            leading: TfIcon(
              TfIcons.success,
              color: context.tf.colors.success.fg,
            ),
          ),
        ),
      );
    }
    return Card(
      key: const Key('validation-panel'),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.grpIProblemsToFix(problems.length),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final p in problems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TfIcon(
                      TfIcons.error,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p.message, key: Key('listed-${p.code}')),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
