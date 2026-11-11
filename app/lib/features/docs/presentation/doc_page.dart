import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/data/docs_client.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/docs/presentation/block_editor.dart';
import 'package:taskforge/features/docs/presentation/doc_dialogs.dart';
import 'package:taskforge/features/docs/presentation/doc_panels.dart';
import 'package:taskforge/features/members/application/members_providers.dart';

/// What the save indicator says.
String saveLabel(SaveState s) => switch (s) {
  SaveState.saved => 'Saved',
  SaveState.dirty => 'Unsaved changes',
  SaveState.saving => 'Saving...',
  SaveState.error => 'Could not save',
  SaveState.conflict => 'Conflict: choose what to keep',
};

/// One open page: title, text, and everything around it.
class DocPageView extends ConsumerStatefulWidget {
  const DocPageView({
    super.key,
    required this.docId,
    required this.project,
    this.onOpenTree,
  });

  final String docId;
  final String project;

  /// Phone layout: opens the tree drawer.
  final VoidCallback? onOpenTree;

  @override
  ConsumerState<DocPageView> createState() => _DocPageViewState();
}

class _DocPageViewState extends ConsumerState<DocPageView> {
  final _title = TextEditingController();
  final _titleFocus = FocusNode();
  Timer? _beat;
  late final DocsActions _actions;
  late final DocsClient _client;
  late final String _ws;
  var _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _actions = ref.read(docsActionsProvider);
    _client = ref.read(docsClientProvider);
    _ws = ref.read(workspaceScopeProvider) ?? '';
    _beat = Timer.periodic(docPresenceEvery, (_) => _heartbeat());
  }

  @override
  void didUpdateWidget(DocPageView old) {
    super.didUpdateWidget(old);
    if (old.docId != widget.docId) {
      unawaited(
        _client
            .presence(_ws, old.docId, 'left')
            .then((_) {}, onError: (Object _) {}),
      );
      unawaited(_heartbeat());
    }
  }

  Future<void> _heartbeat() async {
    final s = ref.read(docSessionProvider(widget.docId));
    if (s.loading || s.error != null) return;
    final editing = s.save == SaveState.dirty || s.save == SaveState.saving;
    try {
      final roster = await _actions.presence(
        widget.docId,
        editing ? 'editing' : 'viewing',
      );
      if (mounted) {
        ref.read(docSessionProvider(widget.docId).notifier).setEditing(roster);
      }
    } on DocException {
      // A missed heartbeat only hides the hint.
    }
  }

  @override
  void dispose() {
    _beat?.cancel();
    unawaited(
      _client
          .presence(_ws, widget.docId, 'left')
          .then((_) {}, onError: (Object _) {}),
    );
    _title.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _openConflict() {
    if (_dialogOpen) return;
    _dialogOpen = true;
    showDialog<void>(
      context: context,
      builder: (_) => ConflictDialog(docId: widget.docId),
    ).whenComplete(() => _dialogOpen = false);
  }

  String _name(String id) {
    for (final m in ref.read(membersProvider).value ?? const []) {
      if (m.userId == id) return m.label;
    }
    return 'Someone';
  }

  Widget _banner(String key, String text, {Widget? action, Color? color}) =>
      Container(
        key: Key(key),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            ?action,
          ],
        ),
      );

  Widget _crumbs(List<DocNode> trail) => Wrap(
    key: const Key('breadcrumb'),
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      TextButton(
        key: const Key('crumb-root'),
        onPressed: () => context.go(
          widget.project.isEmpty ? '/docs' : '/docs?project=${widget.project}',
        ),
        child: const Text('Docs'),
      ),
      for (final d in trail) ...[
        const Icon(Icons.chevron_right, size: 16),
        TextButton(
          key: Key('crumb-${d.id}'),
          onPressed: d.id == widget.docId
              ? null
              : () => context.go(
                  '/docs/${d.id}${widget.project.isEmpty ? '' : '?project=${widget.project}'}',
                ),
          child: Text(d.label),
        ),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final id = widget.docId;
    ref.listen(docSessionProvider(id).select((s) => s.loading), (prev, next) {
      if (prev == true && !next) unawaited(_heartbeat());
    });
    ref.listen(docSessionProvider(id).select((s) => s.conflict), (prev, next) {
      if (prev == null && next != null) _openConflict();
    });
    final s = ref.watch(docSessionProvider(id));
    final notifier = ref.read(docSessionProvider(id).notifier);
    final me = ref.watch(currentUserIdProvider);
    final tree = DocTreeView(
      ref.watch(docTreeProvider(widget.project)).value ?? const [],
    );

    if (s.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = s.error;
    if (error != null) {
      final missing = error.failure == DocFailure.notFound;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              missing
                  ? 'This page does not exist, or you cannot open it.'
                  : docErrorMessage(error),
              key: Key(missing ? 'doc-not-found' : 'doc-error'),
            ),
            const SizedBox(height: 8),
            if (missing)
              TextButton(
                key: const Key('back-to-docs'),
                onPressed: () => context.go('/docs'),
                child: const Text('Back to all pages'),
              )
            else
              TextButton(
                key: const Key('retry-doc'),
                onPressed: notifier.load,
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    final page = s.page!;
    if (!_titleFocus.hasFocus && _title.text != s.title) _title.text = s.title;
    final canEdit = s.canEdit;
    final others = [
      for (final e in s.editing)
        if (e.editing && e.userId != me) _name(e.userId),
    ];
    final trail = tree.trail(id);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
            notifier.saveNow(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () =>
            notifier.saveNow(),
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.archived)
                  _banner(
                    'archived-banner',
                    'This page is archived. It is read-only.',
                    action: page.canEdit
                        ? TextButton(
                            key: const Key('restore-page'),
                            onPressed: () async {
                              try {
                                await _actions.restore(id);
                              } on DocException catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(docErrorMessage(e))),
                                  );
                                }
                              }
                            },
                            child: const Text('Restore'),
                          )
                        : null,
                  ),
                if (s.conflict != null)
                  _banner(
                    'conflict-banner',
                    'Someone else changed this page. Your changes are not saved yet.',
                    color: Theme.of(context).colorScheme.errorContainer,
                    action: TextButton(
                      key: const Key('open-conflict'),
                      onPressed: _openConflict,
                      child: const Text('Resolve'),
                    ),
                  ),
                if (s.remoteChanged && s.conflict == null)
                  _banner(
                    'remote-banner',
                    'A newer version was saved by someone else. '
                        'It will be merged when you save.',
                  ),
                if (others.isNotEmpty)
                  Padding(
                    key: const Key('editing-hint'),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          others.length == 1
                              ? '${others.first} is editing'
                              : '${others.join(', ')} are editing',
                        ),
                      ],
                    ),
                  ),
                _crumbs(trail),
                Row(
                  children: [
                    if (widget.onOpenTree != null)
                      IconButton(
                        key: const Key('open-page-tree'),
                        tooltip: 'Pages',
                        icon: const Icon(Icons.account_tree_outlined),
                        onPressed: widget.onOpenTree,
                      ),
                    Expanded(
                      child: TextField(
                        key: const Key('doc-title'),
                        controller: _title,
                        focusNode: _titleFocus,
                        readOnly: !canEdit,
                        style: Theme.of(context).textTheme.headlineMedium,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Untitled',
                        ),
                        onChanged: (v) => notifier.edit(title: v),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      key: const Key('save-state'),
                      saveLabel(s.save),
                      style: TextStyle(
                        color:
                            s.save == SaveState.error ||
                                s.save == SaveState.conflict
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                    if (s.save == SaveState.error)
                      TextButton(
                        key: const Key('retry-save'),
                        onPressed: notifier.saveNow,
                        child: const Text('Retry'),
                      ),
                    if (!page.canEdit && !s.archived)
                      const Chip(
                        key: Key('read-only-badge'),
                        label: Text('Read only'),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (page.node.restricted)
                      const Chip(
                        key: Key('restricted-badge'),
                        avatar: Icon(Icons.lock_outline, size: 14),
                        label: Text('Restricted'),
                        visualDensity: VisualDensity.compact,
                      ),
                    IconButton(
                      key: const Key('open-revisions'),
                      tooltip: 'History',
                      icon: const Icon(Icons.history),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                    IconButton(
                      key: const Key('open-share'),
                      tooltip: 'Access',
                      icon: const Icon(Icons.lock_person_outlined),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => ShareDialog(docId: id),
                      ),
                    ),
                    IconButton(
                      key: const Key('export-md'),
                      tooltip: 'Export Markdown',
                      icon: const Icon(Icons.ios_share),
                      onPressed: () => exportMarkdown(context, ref, id),
                    ),
                  ],
                ),
                if (s.saveError != null && s.save == SaveState.error)
                  Text(
                    docErrorMessage(s.saveError!),
                    key: const Key('save-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const Divider(),
                BlockEditor(
                  docId: id,
                  blocks: s.blocks,
                  readOnly: !canEdit,
                  pages: tree.docs,
                  seedCards: page.cards,
                  onChanged: (b) => notifier.edit(blocks: b),
                ),
                const SizedBox(height: 24),
                BacklinksPanel(
                  docId: id,
                  onOpen: (d) => context.go('/docs/$d'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
