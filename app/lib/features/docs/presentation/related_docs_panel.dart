import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

/// The "Related docs" of a task: pages that embed it or were linked to it.
class RelatedDocsPanel extends ConsumerWidget {
  const RelatedDocsPanel({
    super.key,
    required this.projectId,
    required this.taskId,
    required this.canEdit,
  });

  final String projectId;
  final String taskId;
  final bool canEdit;

  DocTaskKey get _key => (project: projectId, task: taskId);

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final workspace = ref.read(docTreeProvider('').future);
    final project = ref.read(docTreeProvider(projectId).future);
    final all = [...await workspace, ...await project];
    if (!context.mounted) return;
    final pick = await showDialog<DocNode>(
      context: context,
      builder: (context) => SimpleDialog(
        key: const Key('related-pick-dialog'),
        title: Text(context.l10n.grpJLinkAPage),
        children: [
          if (all.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.grpJNoPagesYetLong),
            ),
          for (final d in all)
            SimpleDialogOption(
              key: Key('related-pick-${d.id}'),
              onPressed: () => Navigator.pop(context, d),
              child: Text(d.labelIn(context.l10n)),
            ),
        ],
      ),
    );
    if (pick == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(docsActionsProvider).link(projectId, taskId, pick.id);
      ref.invalidate(relatedDocsProvider(_key));
    } on DocException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(docErrorMessage(e, l10n))));
    }
  }

  Future<void> _unlink(BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(docsActionsProvider).unlink(projectId, taskId, id);
      ref.invalidate(relatedDocsProvider(_key));
    } on DocException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(docErrorMessage(e, l10n))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(relatedDocsProvider(_key)).value ?? const [];
    final theme = Theme.of(context);
    return Column(
      key: const Key('related-docs'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.grpJRelatedDocs,
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            if (canEdit)
              TfIconButton(
                key: const Key('add-related-doc'),
                icon: TfIcons.filePlus,
                tooltip: context.l10n.grpJLinkAPage,
                onPressed: () => _add(context, ref),
              ),
          ],
        ),
        if (docs.isEmpty)
          Text(context.l10n.grpJNoPagesYet, style: theme.textTheme.bodySmall),
        for (final r in docs)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
            child: TfPanel(
              padding: EdgeInsets.zero,
              child: TfRow(
                key: Key('related-doc-${r.doc.id}'),
                title: r.doc.labelIn(context.l10n),
                subtitle: r.kind == 'link'
                    ? context.l10n.grpJLinked
                    : context.l10n.grpJEmbedded,
                leading: Text(r.doc.icon.isEmpty ? '📄' : r.doc.icon),
                trailing: canEdit && r.kind == 'link'
                    ? TfIconButton(
                        key: Key('unlink-doc-${r.doc.id}'),
                        icon: TfIcons.unlink,
                        tooltip: context.l10n.grpJUnlink,
                        onPressed: () => _unlink(context, ref, r.doc.id),
                      )
                    : null,
                onTap: () => context.go(
                  '/docs/${r.doc.id}${r.doc.projectId.isEmpty ? '' : '?project=${r.doc.projectId}'}',
                ),
              ),
            ),
          ),
      ],
    );
  }
}
