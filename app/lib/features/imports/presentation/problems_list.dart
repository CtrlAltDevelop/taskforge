import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// Rows that could not be read, and warnings, most useful first (errors
/// before warnings), capped; [total] is how many there are in all.
class ProblemsList extends StatelessWidget {
  const ProblemsList({super.key, required this.problems, required this.total});

  final List<ImportProblem> problems;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (problems.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final sorted = [...problems]
      ..sort(
        (a, b) => a.isError == b.isError
            ? 0
            : a.isError
            ? -1
            : 1,
      );
    final shown = sorted.take(maxProblemsShown).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        key: const Key('problems-tile'),
        tilePadding: EdgeInsets.zero,
        title: Text(context.l10n.grpGNotesAboutFile(total)),
        children: [
          for (final p in shown)
            ListTile(
              dense: true,
              leading: Icon(
                p.isError ? TfIcons.error.glyph : TfIcons.warning.glyph,
                color: p.isError ? scheme.error : scheme.tertiary,
              ),
              title: Text(p.message),
              subtitle: p.line > 0
                  ? Text(context.l10n.grpGRowNumber(p.line))
                  : null,
            ),
          if (total > shown.length)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(context.l10n.grpGAndMore(total - shown.length)),
            ),
        ],
      ),
    );
  }
}

/// The error report of a finished (or stopped) import, read when opened.
class ImportProblems extends ConsumerWidget {
  const ImportProblems({super.key, required this.jobId, required this.count});

  final String jobId;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (count == 0) return const SizedBox.shrink();
    final detail = ref.watch(importDetailProvider(jobId));
    return detail.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => TfError(
        compact: true,
        message: context.l10n.grpGNotesReadFailed,
        details: '$e',
        onRetry: () => ref.invalidate(importDetailProvider(jobId)),
      ),
      data: (d) => ProblemsList(problems: d.problems, total: count),
    );
  }
}
