import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';

String _memberName(WidgetRef ref, String userId, String someone) {
  for (final m in ref.watch(membersProvider).value ?? const []) {
    if (m.userId == userId) return m.label;
  }
  return someone;
}

/// A quick read-only look at blocks (a revision's body).
class BlockPreview extends StatelessWidget {
  const BlockPreview({super.key, required this.blocks});

  final List<DocBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (blocks.isEmpty) return Text(context.l10n.grpBEmptyPage);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks)
          switch (b.type) {
            BlockType.divider => const Divider(),
            BlockType.image => Text(context.l10n.grpBImageBlock(b.alt)),
            BlockType.taskCard => Text(context.l10n.grpBTaskCardBlock),
            BlockType.heading => Text(
              b.plain,
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            BlockType.bullet => Text(
              '•  '
              '${b.plain}',
            ),
            BlockType.numbered => Text(
              '-  '
              '${b.plain}',
            ),
            BlockType.checklist => Text(
              '${b.checked ? '[x]' : '[ ]'}  ${b.plain}',
            ),
            BlockType.code => Text(
              b.plain,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            _ when !b.isKnown => Text(
              '['
              '${b.type}'
              ']',
            ),
            _ => Text(b.plain),
          },
      ],
    );
  }
}

/// The history of a page: pick a revision to look at, restore it.
class RevisionsPanel extends ConsumerStatefulWidget {
  const RevisionsPanel({super.key, required this.docId, required this.canEdit});

  final String docId;
  final bool canEdit;

  @override
  ConsumerState<RevisionsPanel> createState() => _RevisionsPanelState();
}

class _RevisionsPanelState extends ConsumerState<RevisionsPanel> {
  int? _picked;
  String? _error;
  var _busy = false;

  Future<void> _restore(int id) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(docSessionProvider(widget.docId).notifier)
          .restoreRevision(id);
      if (mounted) Navigator.of(context).pop();
    } on DocException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = docErrorMessage(e, context.l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    return Drawer(
      key: const Key('revisions-drawer'),
      width: 380,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                title: Text(context.l10n.grpBHistory),
                trailing: picked == null
                    ? null
                    : TextButton(
                        key: const Key('revision-back'),
                        onPressed: () => setState(() => _picked = null),
                        child: Text(context.l10n.grpBAllRevisions),
                      ),
              ),
            ),
            const Divider(height: 1),
            Expanded(child: picked == null ? _list() : _preview(picked)),
          ],
        ),
      ),
    );
  }

  Widget _list() {
    final revisions = ref.watch(docRevisionsProvider(widget.docId));
    return switch (revisions) {
      AsyncData(:final value) when value.isEmpty => Center(
        child: Text(
          context.l10n.grpBNoRevisions,
          key: const Key('no-revisions'),
        ),
      ),
      AsyncData(:final value) => ListView(
        children: [
          for (final r in value)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: Key('revision-${r.id}'),
                dense: true,
                title: Text(
                  r.title.isEmpty
                      ? context.l10n.grpBVersionN(r.version)
                      : r.title,
                ),
                subtitle: Text(
                  '${_memberName(ref, r.authorId, context.l10n.grpBSomeone)} · ${r.savedAt.isEmpty ? r.at : r.savedAt}',
                ),
                trailing: Text(context.l10n.grpBVersionShort(r.version)),
                onTap: () => setState(() => _picked = r.id),
              ),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(docRevisionsProvider(widget.docId)),
          child: Text(context.l10n.grpBRevisionsLoadFailed),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _preview(int id) {
    final body = ref.watch(
      docRevisionProvider((doc: widget.docId, revision: id)),
    );
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            key: const Key('revision-preview'),
            child: switch (body) {
              AsyncData(:final value) => BlockPreview(blocks: value),
              AsyncError() => Text(context.l10n.grpBRevisionLoadFailed),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _error!,
              key: const Key('revision-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (widget.canEdit)
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              key: const Key('revision-restore'),
              icon: const Icon(Icons.restore),
              label: Text(context.l10n.grpBRestoreVersion),
              onPressed: _busy || !body.hasValue ? null : () => _restore(id),
            ),
          ),
      ],
    );
  }
}

/// Pages that mention this one.
class BacklinksPanel extends ConsumerWidget {
  const BacklinksPanel({super.key, required this.docId, required this.onOpen});

  final String docId;
  final void Function(String id) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(docBacklinksProvider(docId)).value ?? const [];
    return ExpansionTile(
      key: const Key('backlinks-panel'),
      title: Text(context.l10n.grpBLinkedFrom(links.length)),
      children: [
        if (links.isEmpty)
          ListTile(dense: true, title: Text(context.l10n.grpBNoBacklinks)),
        for (final d in links)
          ListTile(
            key: Key('backlink-${d.id}'),
            dense: true,
            leading: Text(d.icon.isEmpty ? '📄' : d.icon),
            title: Text(d.labelIn(context.l10n)),
            onTap: () => onOpen(d.id),
          ),
      ],
    );
  }
}

/// Shows the Markdown of a page, to copy or save.
Future<void> exportMarkdown(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final out = await ref.read(docsActionsProvider).export(id);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('export-dialog'),
        title: Text(context.l10n.grpBMarkdownTitle(out.title)),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: SelectableText(
              out.markdown,
              key: const Key('export-text'),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('export-copy'),
            onPressed: () async {
              final copied = context.l10n.grpBMarkdownCopied;
              await Clipboard.setData(ClipboardData(text: out.markdown));
              messenger.showSnackBar(SnackBar(content: Text(copied)));
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.grpBCopy),
          ),
          TextButton(
            key: const Key('export-save'),
            onPressed: () async {
              final name = out.title.trim().isEmpty ? 'page' : out.title.trim();
              await FilePicker.saveFile(
                fileName: '$name.md',
                bytes: Uint8List.fromList(utf8.encode(out.markdown)),
                mimeType: 'text/markdown',
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.grpBSaveAsFile),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.grpBClose),
          ),
        ],
      ),
    );
  } on DocException catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(docErrorMessage(e, context.l10n))),
    );
  }
}
