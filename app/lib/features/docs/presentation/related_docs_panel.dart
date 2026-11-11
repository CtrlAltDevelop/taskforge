import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        title: const Text('Link a page'),
        children: [
          if (all.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('There are no pages yet.'),
            ),
          for (final d in all)
            SimpleDialogOption(
              key: Key('related-pick-${d.id}'),
              onPressed: () => Navigator.pop(context, d),
              child: Text(d.label),
            ),
        ],
      ),
    );
    if (pick == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(docsActionsProvider).link(projectId, taskId, pick.id);
      ref.invalidate(relatedDocsProvider(_key));
    } on DocException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(docErrorMessage(e))));
    }
  }

  Future<void> _unlink(BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(docsActionsProvider).unlink(projectId, taskId, id);
      ref.invalidate(relatedDocsProvider(_key));
    } on DocException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(docErrorMessage(e))));
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
            Text('Related docs', style: theme.textTheme.titleSmall),
            const Spacer(),
            if (canEdit)
              IconButton(
                key: const Key('add-related-doc'),
                tooltip: 'Link a page',
                icon: const Icon(Icons.post_add),
                onPressed: () => _add(context, ref),
              ),
          ],
        ),
        if (docs.isEmpty)
          Text('No pages yet.', style: theme.textTheme.bodySmall),
        for (final r in docs)
          ListTile(
            key: Key('related-doc-${r.doc.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Text(r.doc.icon.isEmpty ? '📄' : r.doc.icon),
            title: Text(r.doc.label),
            subtitle: Text(r.kind == 'link' ? 'Linked' : 'Embedded'),
            trailing: canEdit && r.kind == 'link'
                ? IconButton(
                    key: Key('unlink-doc-${r.doc.id}'),
                    tooltip: 'Unlink',
                    icon: const Icon(Icons.link_off, size: 18),
                    onPressed: () => _unlink(context, ref, r.doc.id),
                  )
                : null,
            onTap: () => context.go(
              '/docs/${r.doc.id}${r.doc.projectId.isEmpty ? '' : '?project=${r.doc.projectId}'}',
            ),
          ),
      ],
    );
  }
}
