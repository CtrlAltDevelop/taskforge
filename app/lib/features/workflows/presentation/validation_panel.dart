import 'package:flutter/material.dart';

import 'package:taskforge/features/workflows/domain/workflow.dart';

/// What is wrong with the workflow being edited, in words, or that it is ready.
class ValidationPanel extends StatelessWidget {
  const ValidationPanel({super.key, required this.problems});

  final List<WorkflowProblem> problems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (problems.isEmpty) {
      return Card(
        key: const Key('validation-ok'),
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('No problems'),
          subtitle: const Text('Every task keeps a valid status.'),
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
              problems.length == 1
                  ? '1 problem to fix before saving'
                  : '${problems.length} problems to fix before saving',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final p in problems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
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
