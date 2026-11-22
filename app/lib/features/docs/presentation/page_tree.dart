import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

const newPageTitle = 'Untitled';

bool get _touchFirst =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// The left tree of pages: open, nest, drag to reorder or move, archive.
class PageTree extends ConsumerStatefulWidget {
  const PageTree({
    super.key,
    required this.project,
    required this.selectedId,
    required this.canEdit,
    required this.onOpen,
  });

  /// '' for the workspace's pages.
  final String project;
  final String? selectedId;
  final bool canEdit;
  final void Function(String id) onOpen;

  @override
  ConsumerState<PageTree> createState() => _PageTreeState();
}

class _PageTreeState extends ConsumerState<PageTree> {
  final _collapsed = <String>{};

  void _say(Object error) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(docErrorMessage(error, context.l10n))),
    );

  Future<void> _run(Future<void> Function() call) async {
    try {
      await call();
    } on DocException catch (e) {
      if (mounted) _say(e);
    }
  }

  Future<void> _create(String parentId) async {
    try {
      final page = await ref
          .read(docsActionsProvider)
          .create(
            projectId: widget.project,
            parentId: parentId,
            title: newPageTitle,
          );
      if (!mounted) return;
      setState(() => _collapsed.remove(parentId));
      widget.onOpen(page.node.id);
    } on DocException catch (e) {
      if (mounted) _say(e);
    }
  }

  Future<void> _drop(
    DocTreeView tree,
    String dragged,
    String target,
    DropZone zone,
  ) async {
    final at = tree.dropAt(dragged, target, zone);
    if (at == null) return;
    await _run(
      () => ref
          .read(docsActionsProvider)
          .move(dragged, parent: at.parent, index: at.index),
    );
  }

  Future<void> _moveTo(DocTreeView tree, DocNode doc) async {
    final blocked = tree.subtree(doc.id);
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        key: const Key('move-to-dialog'),
        title: Text(context.l10n.grpBMoveUnder(doc.labelIn(context.l10n))),
        children: [
          SimpleDialogOption(
            key: const Key('move-to-top'),
            onPressed: () => Navigator.pop(context, ''),
            child: Text(context.l10n.grpBTopLevel),
          ),
          for (final d in tree.docs)
            if (!blocked.contains(d.id))
              SimpleDialogOption(
                key: Key('move-to-${d.id}'),
                onPressed: () => Navigator.pop(context, d.id),
                child: Text(d.labelIn(context.l10n)),
              ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    final kids = tree.children(choice).where((d) => d.id != doc.id);
    await _run(
      () => ref
          .read(docsActionsProvider)
          .move(doc.id, parent: choice, index: kids.length),
    );
  }

  Future<void> _menu(DocTreeView tree, DocNode doc, String action) async {
    switch (action) {
      case 'child':
        await _create(doc.id);
      case 'up' || 'down':
        final at = tree.nudge(doc.id, action == 'up' ? -1 : 1);
        if (at == null) return;
        await _run(
          () => ref
              .read(docsActionsProvider)
              .move(doc.id, parent: at.parent, index: at.index),
        );
      case 'move':
        await _moveTo(tree, doc);
      case 'restore':
        await _run(() async {
          await ref.read(docsActionsProvider).restore(doc.id);
        });
      case 'archive':
        await _run(() async {
          await ref.read(docsActionsProvider).archive(doc.id);
          if (widget.selectedId == doc.id ||
              tree.subtree(doc.id).contains(widget.selectedId)) {
            if (mounted) widget.onOpen('');
          }
        });
    }
  }

  Widget _row(DocTreeView tree, DocNode doc, int depth) {
    final selected = doc.id == widget.selectedId;
    final hasKids = tree.hasChildren(doc.id);
    final open = !_collapsed.contains(doc.id);
    final tile = Container(
      key: Key('page-row-${doc.id}'),
      color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: InkWell(
        onTap: () => widget.onOpen(doc.id),
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 4.0 + depth * 16, end: 0),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: hasKids
                    ? IconButton(
                        key: Key('toggle-${doc.id}'),
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        tooltip: open
                            ? context.l10n.grpBCollapse
                            : context.l10n.grpBExpand,
                        icon: TfIcon(
                          open ? TfIcons.chevronDown : TfIcons.chevronEnd,
                        ),
                        onPressed: () => setState(() {
                          open
                              ? _collapsed.add(doc.id)
                              : _collapsed.remove(doc.id);
                        }),
                      )
                    : null,
              ),
              Text(doc.icon.isEmpty ? '📄' : doc.icon),
              const SizedBox(width: TfSpace.sm),
              Expanded(
                child: Text(
                  doc.labelIn(context.l10n),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : null,
                    fontStyle: doc.archived ? FontStyle.italic : null,
                    color: doc.archived
                        ? Theme.of(context).colorScheme.outline
                        : null,
                  ),
                ),
              ),
              if (doc.restricted)
                TfIcon(
                  TfIcons.lock,
                  key: Key('restricted-${doc.id}'),
                  size: 14,
                  semanticLabel: context.l10n.grpBRestricted,
                ),
              if (widget.canEdit)
                PopupMenuButton<String>(
                  key: Key('page-menu-${doc.id}'),
                  tooltip: context.l10n.grpBPageOptions,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  onSelected: (a) => _menu(tree, doc, a),
                  itemBuilder: (ctx) => doc.archived
                      ? [
                          PopupMenuItem(
                            value: 'restore',
                            child: Text(ctx.l10n.grpBRestore),
                          ),
                        ]
                      : [
                          PopupMenuItem(
                            value: 'child',
                            child: Text(ctx.l10n.grpBNewSubpage),
                          ),
                          PopupMenuItem(
                            value: 'up',
                            child: Text(ctx.l10n.grpBMoveUp),
                          ),
                          PopupMenuItem(
                            value: 'down',
                            child: Text(ctx.l10n.grpBMoveDown),
                          ),
                          PopupMenuItem(
                            value: 'move',
                            child: Text(ctx.l10n.grpBMoveTo),
                          ),
                          PopupMenuItem(
                            value: 'archive',
                            child: Text(ctx.l10n.grpBArchive),
                          ),
                        ],
                ),
            ],
          ),
        ),
      ),
    );
    if (!widget.canEdit) return tile;
    final drag = LongPressDraggable<String>(
      data: doc.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(TfSpace.sm),
          child: Text(doc.labelIn(context.l10n)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      child: tile,
    );
    final draggable = _touchFirst
        ? drag
        : Draggable<String>(
            data: doc.id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(TfSpace.sm),
                child: Text(doc.labelIn(context.l10n)),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.4, child: tile),
            child: tile,
          );
    return Builder(
      builder: (context) => DragTarget<String>(
        onWillAcceptWithDetails: (d) => d.data != doc.id,
        onAcceptWithDetails: (d) {
          final box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(d.offset);
          final f = box.size.height == 0 ? 0.5 : local.dy / box.size.height;
          final zone = f < 0.25
              ? DropZone.before
              : f > 0.75
              ? DropZone.after
              : DropZone.into;
          _drop(tree, d.data, doc.id, zone);
        },
        builder: (_, candidates, _) => DecoratedBox(
          decoration: BoxDecoration(
            border: candidates.isEmpty
                ? null
                : Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: draggable,
        ),
      ),
    );
  }

  List<Widget> _rows(DocTreeView tree, String parent, int depth) => [
    for (final d in tree.children(parent)) ...[
      _row(tree, d, depth),
      if (!_collapsed.contains(d.id)) ..._rows(tree, d.id, depth + 1),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final tree = ref.watch(docTreeProvider(widget.project));
    final showArchived = ref.watch(docShowArchivedProvider);
    return Column(
      key: const Key('page-tree'),
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            TfSpace.lg,
            TfSpace.sm,
            TfSpace.sm,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.grpBPages,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TfIconButton(
                key: const Key('show-archived'),
                icon: TfIcons.archive,
                tooltip: showArchived
                    ? context.l10n.grpBHideArchived
                    : context.l10n.grpBShowArchived,
                onPressed: () => ref
                    .read(docShowArchivedProvider.notifier)
                    .set(!showArchived),
                selected: showArchived,
              ),
              if (widget.canEdit)
                TfIconButton(
                  key: const Key('new-page'),
                  icon: TfIcons.plus,
                  tooltip: context.l10n.grpBNewPage,
                  onPressed: () => _create(''),
                ),
            ],
          ),
        ),
        Expanded(
          child: switch (tree) {
            AsyncData(:final value) when value.isEmpty => TfEmpty(
              key: const Key('tree-empty'),
              compact: true,
              illustration: TfIllustrationKind.docs,
              title: context.l10n.grpBNoPagesYet,
            ),
            AsyncData(:final value) => ListView(
              children: _rows(DocTreeView(value), '', 0),
            ),
            AsyncError() => TfError(
              compact: true,
              message: context.l10n.grpBPagesLoadFailed,
              retryKey: const Key('retry-tree'),
              onRetry: () => ref.invalidate(docTreeProvider),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}
