import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/doc_ops.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/docs/presentation/doc_dialogs.dart';
import 'package:taskforge/features/docs/presentation/other_blocks.dart';
import 'package:taskforge/features/docs/presentation/slash_menu.dart';
import 'package:taskforge/features/docs/presentation/text_block.dart';

/// The page body: a column of blocks, edited in place. The blocks (server
/// JSON) stay the source of truth: every change gives the parent a new list.
class BlockEditor extends ConsumerStatefulWidget {
  const BlockEditor({
    super.key,
    required this.docId,
    required this.blocks,
    required this.readOnly,
    required this.pages,
    required this.seedCards,
    required this.onChanged,
  });

  final String docId;
  final List<DocBlock> blocks;
  final bool readOnly;
  final List<DocNode> pages;

  /// Cards the page came with, shown until the live ones are read.
  final List<TaskCardInfo> seedCards;
  final void Function(List<DocBlock> blocks) onChanged;

  @override
  ConsumerState<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends ConsumerState<BlockEditor> {
  final _nodes = <String, FocusNode>{};
  ({String id, int offset})? _focus;

  List<DocBlock> get _blocks => widget.blocks;

  FocusNode _node(String id) => _nodes.putIfAbsent(id, FocusNode.new);

  @override
  void didUpdateWidget(BlockEditor old) {
    super.didUpdateWidget(old);
    final ids = {for (final b in _blocks) b.id};
    for (final id in _nodes.keys.where((k) => !ids.contains(k)).toList()) {
      final node = _nodes.remove(id);
      // Disposed after the frame: a field may still be listening to it.
      WidgetsBinding.instance.addPostFrameCallback((_) => node?.dispose());
    }
  }

  @override
  void dispose() {
    for (final n in _nodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  void _emit(List<DocBlock> blocks, {String? focus, int offset = 0}) {
    if (focus != null) {
      setState(() => _focus = (id: focus, offset: offset));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _focus = null);
      });
    }
    widget.onChanged(blocks);
  }

  void _replace(DocBlock block) => _emit(replaceBlock(_blocks, block));

  void _split(String id, Rich before, Rich after) {
    final r = splitBlock(_blocks, id, before, after);
    _emit(r.blocks, focus: r.focus);
  }

  void _backspace(String id) {
    final r = mergeUp(_blocks, id);
    if (r != null) _emit(r.blocks, focus: r.focus, offset: r.offset);
  }

  void _moveFocus(String id, int delta) {
    final at = _blocks.indexWhere((b) => b.id == id) + delta;
    if (at < 0 || at >= _blocks.length) return;
    final target = _blocks[at];
    if (!target.hasRichText && target.type != BlockType.code) return;
    _node(target.id).requestFocus();
  }

  /// The block turned into [type], emptied of the text that asked for it.
  Future<void> _turn(
    DocBlock block,
    String type,
    Map<String, Object?> attrs,
  ) async {
    var next = block.hasRichText ? block.withRich(Rich.empty) : block;
    if (type == BlockType.taskCard) {
      final taskId = await pickTask(context);
      if (!mounted) return;
      if (taskId == null) {
        _emit(replaceBlock(_blocks, next), focus: block.id);
        return;
      }
      next = next.turnInto(type).withAttrs({'task_id': taskId});
    } else if (type == BlockType.image) {
      final edit = await editImage(context, null);
      if (!mounted) return;
      if (edit == null) {
        _emit(replaceBlock(_blocks, next), focus: block.id);
        return;
      }
      next = next.turnInto(type).withAttrs(edit);
    } else {
      next = next.turnInto(type, attrs: attrs);
    }
    var list = replaceBlock(_blocks, next);
    final isLast = list.last.id == next.id;
    final plainBlock = next.hasRichText || next.type == BlockType.code;
    if (!plainBlock && isLast) {
      final tail = DocBlock.create(BlockType.paragraph);
      list = [...list, tail];
      _emit(list, focus: tail.id);
    } else {
      _emit(list, focus: next.id);
    }
  }

  /// A task link was pasted into [block]: the block becomes the task's card.
  void _pasteTask(DocBlock block, String taskId) {
    final card = block.withRich(Rich.empty).turnInto(BlockType.taskCard);
    var list = replaceBlock(_blocks, card.withAttrs({'task_id': taskId}));
    if (list.last.id == block.id) {
      final tail = DocBlock.create(BlockType.paragraph);
      list = [...list, tail];
      _emit(list, focus: tail.id);
    } else {
      _emit(list);
    }
  }

  void _menu(DocBlock b, String action) {
    final i = _blocks.indexWhere((x) => x.id == b.id);
    switch (action) {
      case 'up':
        _emit(moveBlock(_blocks, b.id, -1));
      case 'down':
        _emit(moveBlock(_blocks, b.id, 1));
      case 'delete':
        _emit(removeBlock(_blocks, b.id));
      case 'below':
        final n = DocBlock.create(BlockType.paragraph);
        _emit(insertAfter(_blocks, b.id, n), focus: n.id);
      default:
        if (action.startsWith('turn:')) {
          final item = slashItems.firstWhere(
            (s) => s.id == action.substring(5),
          );
          if (item.type == BlockType.taskCard ||
              item.type == BlockType.image ||
              i < 0) {
            _turn(b, item.type, item.attrs);
          } else {
            _emit(
              replaceBlock(_blocks, b.turnInto(item.type, attrs: item.attrs)),
              focus: b.id,
            );
          }
        }
    }
  }

  Widget _menuButton(DocBlock b) => PopupMenuButton<String>(
    key: Key('block-menu-${b.id}'),
    tooltip: context.l10n.grpJBlockOptions,
    iconSize: 18,
    padding: EdgeInsets.zero,
    icon: const Icon(Icons.drag_indicator, size: 18),
    onSelected: (a) => _menu(b, a),
    itemBuilder: (_) => [
      PopupMenuItem(value: 'up', child: Text(context.l10n.grpJMoveUp)),
      PopupMenuItem(value: 'down', child: Text(context.l10n.grpJMoveDown)),
      PopupMenuItem(
        value: 'below',
        child: Text(context.l10n.grpJAddBlockBelow),
      ),
      PopupMenuItem(value: 'delete', child: Text(context.l10n.grpJDelete)),
      const PopupMenuDivider(),
      for (final s in slashItems)
        PopupMenuItem(
          value: 'turn:${s.id}',
          child: Text(context.l10n.grpJTurnInto(s.labelIn(context.l10n))),
        ),
    ],
  );

  Widget _view(
    DocBlock b,
    Map<String, int> numbers,
    Map<String, TaskCardInfo> cards,
  ) {
    final focus = _focus;
    final offset = focus != null && focus.id == b.id ? focus.offset : null;
    switch (b.type) {
      case BlockType.divider:
        return const DividerBlockView();
      case BlockType.code:
        return CodeBlockView(
          block: b,
          focusNode: _node(b.id),
          readOnly: widget.readOnly,
          onChanged: _replace,
          onBackspaceStart: () => _backspace(b.id),
        );
      case BlockType.table:
        return TableBlockView(
          block: b,
          readOnly: widget.readOnly,
          onChanged: _replace,
        );
      case BlockType.image:
        return ImageBlockView(
          block: b,
          readOnly: widget.readOnly,
          onEdit: () async {
            final edit = await editImage(context, b);
            if (edit != null && mounted) _replace(b.withAttrs(edit));
          },
        );
      case BlockType.taskCard:
        return TaskCardView(
          block: b,
          card: cards[b.taskId],
          onOpen: (c) =>
              context.go('/projects/${c.projectId}?task=${c.taskId}'),
        );
      case BlockType.paragraph ||
          BlockType.heading ||
          BlockType.bullet ||
          BlockType.numbered ||
          BlockType.checklist ||
          BlockType.quote ||
          BlockType.callout:
        return TextBlockView(
          block: b,
          number: numbers[b.id] ?? 1,
          focusNode: _node(b.id),
          focusOffset: offset,
          readOnly: widget.readOnly,
          pages: widget.pages,
          currentDocId: widget.docId,
          onChanged: _replace,
          onSplit: (before, after) => _split(b.id, before, after),
          onBackspaceStart: () => _backspace(b.id),
          onTurn: (type, attrs) => _turn(b, type, attrs),
          onMoveFocus: (d) => _moveFocus(b.id, d),
          onOpenDoc: (id) => context.go('/docs/$id'),
          askLink: askLink,
          onPasteTask: (taskId) => _pasteTask(b, taskId),
        );
      default:
        return UnknownBlockView(block: b);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ids = taskCardIds(_blocks);
    final live = ids.isEmpty
        ? null
        : ref.watch(docCardsProvider(([...ids]..sort()).join(','))).value;
    final cards = {for (final c in widget.seedCards) c.taskId: c, ...?live};
    final numbers = numbering(_blocks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_blocks.isEmpty && !widget.readOnly)
          InkWell(
            key: const Key('empty-page'),
            onTap: () {
              final b = DocBlock.create(BlockType.paragraph);
              _emit([b], focus: b.id);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(context.l10n.grpJClickToWrite),
            ),
          ),
        for (final b in _blocks)
          Padding(
            key: ValueKey('row-${b.id}'),
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: widget.readOnly ? null : _menuButton(b),
                ),
                Expanded(child: _view(b, numbers, cards)),
              ],
            ),
          ),
        if (!widget.readOnly && _blocks.isNotEmpty)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('add-block'),
              icon: const Icon(Icons.add, size: 16),
              label: Text(context.l10n.grpJAddBlock),
              onPressed: () {
                final b = DocBlock.create(BlockType.paragraph);
                _emit([..._blocks, b], focus: b.id);
              },
            ),
          ),
      ],
    );
  }
}
