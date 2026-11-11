import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';

String _memberName(WidgetRef ref, String userId) {
  for (final m in ref.watch(membersProvider).value ?? const []) {
    if (m.userId == userId) return m.label;
  }
  return userId.isEmpty ? 'Someone' : 'Someone';
}

/// A quick read-only look at blocks (a revision's body).
class BlockPreview extends StatelessWidget {
  const BlockPreview({super.key, required this.blocks});

  final List<DocBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (blocks.isEmpty) return const Text('(empty page)');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks)
          switch (b.type) {
            BlockType.divider => const Divider(),
            BlockType.image => Text('[Image ${b.alt}]'),
            BlockType.taskCard => const Text('[Task card]'),
            BlockType.heading => Text(
              b.plain,
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            BlockType.bullet => Text('•  ${b.plain}'),
            BlockType.numbered => Text('-  ${b.plain}'),
            BlockType.checklist => Text(
              '${b.checked ? '[x]' : '[ ]'}  ${b.plain}',
            ),
            BlockType.code => Text(
              b.plain,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            _ when !b.isKnown => Text('[${b.type}]'),
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
          _error = docErrorMessage(e);
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
            ListTile(
              title: const Text('History'),
              trailing: picked == null
                  ? null
                  : TextButton(
                      key: const Key('revision-back'),
                      onPressed: () => setState(() => _picked = null),
                      child: const Text('All revisions'),
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
      AsyncData(:final value) when value.isEmpty => const Center(
        child: Text('No revisions yet.', key: Key('no-revisions')),
      ),
      AsyncData(:final value) => ListView(
        children: [
          for (final r in value)
            ListTile(
              key: Key('revision-${r.id}'),
              dense: true,
              title: Text(r.title.isEmpty ? 'Version ${r.version}' : r.title),
              subtitle: Text(
                '${_memberName(ref, r.authorId)} · ${r.savedAt.isEmpty ? r.at : r.savedAt}',
              ),
              trailing: Text('v${r.version}'),
              onTap: () => setState(() => _picked = r.id),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(docRevisionsProvider(widget.docId)),
          child: const Text('Could not load history. Retry'),
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
              AsyncError() => const Text('Could not load this revision.'),
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
              label: const Text('Restore this version'),
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
      title: Text('Linked from (${links.length})'),
      children: [
        if (links.isEmpty)
          const ListTile(
            dense: true,
            title: Text('No page mentions this one.'),
          ),
        for (final d in links)
          ListTile(
            key: Key('backlink-${d.id}'),
            dense: true,
            leading: Text(d.icon.isEmpty ? '📄' : d.icon),
            title: Text(d.label),
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
        title: Text('Markdown: ${out.title}'),
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
              await Clipboard.setData(ClipboardData(text: out.markdown));
              messenger.showSnackBar(
                const SnackBar(content: Text('Markdown copied.')),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Copy'),
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
            child: const Text('Save as file'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  } on DocException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(docErrorMessage(e))));
  }
}
