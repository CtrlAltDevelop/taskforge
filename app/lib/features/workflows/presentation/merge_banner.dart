import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

/// Shown after someone else saved first and the editor merged their work with
/// the draft: everything that was taken, kept or given up, in words. Saving is
/// off until the person says they have read it, so nothing changes silently.
class MergeBanner extends StatelessWidget {
  const MergeBanner({
    super.key,
    required this.notes,
    required this.onKeep,
    required this.onReload,
  });

  final List<String> notes;

  /// "I have read this; keep my draft with these changes."
  final VoidCallback onKeep;

  /// "Throw my draft away and start from what was saved."
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('merge-banner'),
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.grpIMergeTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(context.l10n.grpIMergeBody),
            const SizedBox(height: 8),
            for (final (i, note) in notes.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(note, key: Key('merge-note-$i'))),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: const Key('merge-acknowledge'),
                  onPressed: onKeep,
                  child: Text(context.l10n.grpIMergeKeep),
                ),
                OutlinedButton(
                  key: const Key('merge-reload'),
                  onPressed: onReload,
                  child: Text(context.l10n.grpIMergeReload),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
