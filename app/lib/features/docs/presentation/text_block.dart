import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/doc_ops.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/docs/presentation/rich_controller.dart';
import 'package:taskforge/features/docs/presentation/slash_menu.dart';

/// Asks for a link address; null means leave it.
typedef LinkAsker = Future<String?> Function(
  BuildContext context,
  String current,
);

/// A block whose body is rich text: paragraph, heading, list item, quote,
/// callout.
class TextBlockView extends StatefulWidget {
  const TextBlockView({
    super.key,
    required this.block,
    required this.focusNode,
    required this.readOnly,
    required this.pages,
    required this.currentDocId,
    required this.onChanged,
    required this.onSplit,
    required this.onBackspaceStart,
    required this.onTurn,
    required this.onMoveFocus,
    required this.onOpenDoc,
    required this.askLink,
    this.onPasteTask,
    this.number = 1,
    this.focusOffset,
  });

  final DocBlock block;
  final FocusNode focusNode;
  final bool readOnly;
  final List<DocNode> pages;
  final String currentDocId;
  final int number;

  /// When set, the field takes the focus with the cursor here.
  final int? focusOffset;
  final void Function(DocBlock block) onChanged;
  final void Function(Rich before, Rich after) onSplit;
  final VoidCallback onBackspaceStart;
  final void Function(String type, Map<String, Object?> attrs) onTurn;
  final void Function(int delta) onMoveFocus;
  final void Function(String docId) onOpenDoc;
  final LinkAsker askLink;

  /// A task link was pasted as the whole text of this block: make it a card.
  final void Function(String taskId)? onPasteTask;

  @override
  State<TextBlockView> createState() => _TextBlockViewState();
}

class _TextBlockViewState extends State<TextBlockView> {
  late final MarkedTextController _c;
  final _anchor = LayerLink();
  final _overlay = OverlayPortalController();

  DocBlock get _block => widget.block;

  @override
  void initState() {
    super.initState();
    _c = MarkedTextController(_block.rich)..addListener(_redraw);
    widget.focusNode.addListener(_redraw);
    _focusIfAsked();
  }

  @override
  void didUpdateWidget(TextBlockView old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      old.focusNode.removeListener(_redraw);
      widget.focusNode.addListener(_redraw);
    }
    // Changed from outside (a merge, a restore): show the new text.
    if (!sameJson(_block.json['content'], _c.rich.toInlines())) {
      _c.rich = _block.rich;
    }
    if (widget.focusOffset != null && widget.focusOffset != old.focusOffset) {
      _focusIfAsked();
    }
  }

  void _focusIfAsked() {
    final at = widget.focusOffset;
    if (at == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.focusNode.requestFocus();
      _c.selection = TextSelection.collapsed(
        offset: at.clamp(0, _c.text.length),
      );
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_redraw);
    _c.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  int? _newBreak(Rich rich) {
    for (var i = 0; i < rich.length; i++) {
      if (rich.text[i] == '\n' && rich.attrs[i].atom == null) return i;
    }
    return null;
  }

  String? get _slashQuery {
    if (_block.type != BlockType.paragraph || widget.readOnly) return null;
    final t = _c.text;
    if (!widget.focusNode.hasFocus || !t.startsWith('/') || t.contains(' ')) {
      return null;
    }
    return t.substring(1);
  }

  ({int start, String query})? get _mentionQuery {
    if (widget.readOnly || !widget.focusNode.hasFocus) return null;
    final caret = _c.selection.baseOffset;
    if (caret < 2 || caret > _c.text.length) return null;
    final m = RegExp(r'\[\[([^\[\]\n]*)$')
        .firstMatch(_c.text.substring(0, caret));
    return m == null ? null : (start: m.start, query: m.group(1)!);
  }

  void _changed(String _) {
    final rich = _c.rich;
    final newline = _newBreak(rich);
    if (newline != null) {
      final slash = _slashQuery;
      if (slash != null) {
        final items = SlashMenu.filter(slash.replaceAll('\n', ''));
        // Take the break back out, then do what the menu would.
        _c.rich = rich.replaceRange(newline, newline + 1, '');
        if (items.isNotEmpty) {
          widget.onTurn(items.first.type, items.first.attrs);
        }
        return;
      }
      widget.onSplit(
        rich.slice(0, newline),
        rich.slice(newline + 1, rich.length),
      );
      return;
    }
    if (_block.type == BlockType.paragraph && _pastedTask(rich.text)) return;
    if (_block.type == BlockType.paragraph) {
      final s = markdownShortcut(rich.text);
      if (s != null) {
        widget.onTurn(s.type, s.attrs);
        return;
      }
    }
    widget.onChanged(_block.withRich(rich));
  }

  /// Many characters arrived at once and they are one task link: a paste.
  bool _pastedTask(String text) {
    final handler = widget.onPasteTask;
    if (handler == null || text.length - _block.plain.length < 8) return false;
    final id = taskIdFromText(text);
    if (id == null || text.trim().length > 300) return false;
    final rest = text.replaceFirst(
      RegExp(r'https?://\S+|' + id, caseSensitive: false),
      '',
    );
    if (rest.trim().isNotEmpty) return false;
    handler(id);
    return true;
  }

  void _toggle(String mark) {
    final s = _c.selection;
    if (!s.isValid || s.isCollapsed) return;
    final next = _c.rich.toggleMark(s.start, s.end, mark);
    _c.restyle(next);
    widget.onChanged(_block.withRich(next));
  }

  Future<void> _link() async {
    final s = _c.selection;
    if (!s.isValid || s.isCollapsed) return;
    final current = _c.rich.attrs[s.start].link ?? '';
    final href = await widget.askLink(context, current);
    if (href == null || !mounted) return;
    final next = _c.rich.setLink(s.start, s.end, href);
    _c.restyle(next);
    widget.onChanged(_block.withRich(next));
  }

  void _pickMention(DocNode page, int start) {
    final caret = _c.selection.baseOffset;
    final atom = Atom.mention(page.id, page.label);
    final rich = _c.rich;
    final inserted = Rich(
      atom.text,
      List.filled(atom.text.length, Attr(const [], atom)),
    );
    final next =
        Rich(rich.text.substring(0, start), rich.attrs.sublist(0, start)) +
        inserted +
        Rich(' ${rich.text.substring(caret)}', [
          Attr.plain,
          ...rich.attrs.sublist(caret),
        ]);
    _c.rich = next;
    _c.selection = TextSelection.collapsed(
      offset: start + atom.text.length + 1,
    );
    widget.onChanged(_block.withRich(next));
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (widget.readOnly || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final s = _c.selection;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace &&
        s.isCollapsed &&
        s.baseOffset == 0) {
      widget.onBackspaceStart();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp &&
        s.isCollapsed &&
        s.baseOffset == 0) {
      widget.onMoveFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown &&
        s.isCollapsed &&
        s.baseOffset == _c.text.length) {
      widget.onMoveFocus(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab && _block.type != BlockType.paragraph) {
      final shift = HardwareKeyboard.instance.isShiftPressed;
      final next = (_block.indent + (shift ? -1 : 1)).clamp(0, 5);
      widget.onChanged(_block.withAttrs({'indent': next}));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  TextStyle? _style(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return switch (_block.type) {
      BlockType.heading => switch (_block.level) {
        1 => t.headlineMedium,
        2 => t.titleLarge,
        _ => t.titleMedium,
      }?.copyWith(fontWeight: FontWeight.bold),
      BlockType.quote => t.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
      _ => t.bodyLarge,
    };
  }

  Widget _prefix(BuildContext context) => switch (_block.type) {
    BlockType.bullet => const Padding(
      padding: EdgeInsetsDirectional.only(end: 8, top: 2),
      child: Text('•'),
    ),
    BlockType.numbered => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8, top: 2),
      child: Text('${widget.number}.', key: Key('number-${_block.id}')),
    ),
    BlockType.checklist => SizedBox(
      width: 32,
      height: 28,
      child: Checkbox(
        key: Key('check-${_block.id}'),
        value: _block.checked,
        onChanged: widget.readOnly
            ? null
            : (v) =>
                  widget.onChanged(_block.withAttrs({'checked': v ?? false})),
      ),
    ),
    _ => const SizedBox.shrink(),
  };

  Widget _toolbar() => Material(
    key: const Key('floating-toolbar'),
    elevation: 3,
    borderRadius: BorderRadius.circular(8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (id, icon, tip, mark) in [
          ('bold', Icons.format_bold, context.l10n.grpJBold, boldMark),
          ('italic', Icons.format_italic, context.l10n.grpJItalic, italicMark),
          (
            'strike',
            Icons.strikethrough_s,
            context.l10n.grpJStrikethrough,
            strikeMark,
          ),
          ('code', Icons.code, context.l10n.grpJCode, codeMark),
        ])
          IconButton(
            key: Key('tb-$id'),
            tooltip: tip,
            icon: Icon(icon, size: 18),
            onPressed: () => _toggle(mark),
          ),
        IconButton(
          key: const Key('tb-link'),
          tooltip: context.l10n.grpJLink,
          icon: const Icon(Icons.link, size: 18),
          onPressed: _link,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sel = _c.selection;
    final showBar =
        !widget.readOnly &&
        widget.focusNode.hasFocus &&
        sel.isValid &&
        !sel.isCollapsed;
    final slash = _slashQuery;
    final mention = _mentionQuery;
    final isCallout = _block.type == BlockType.callout;
    final mentions = {
      for (final a in _c.rich.attrs)
        if (a.atom?.docId != null) a.atom!.docId!: a.atom!.text,
    };

    Widget field = Focus(
      onKeyEvent: _key,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
              _toggle(boldMark),
          const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () =>
              _toggle(boldMark),
          const SingleActivator(LogicalKeyboardKey.keyI, control: true): () =>
              _toggle(italicMark),
          const SingleActivator(LogicalKeyboardKey.keyI, meta: true): () =>
              _toggle(italicMark),
        },
        child: TextField(
          key: Key('field-${_block.id}'),
          controller: _c,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          maxLines: null,
          style: _style(context),
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          onChanged: _changed,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: widget.readOnly
                ? null
                : _block.type == BlockType.paragraph
                ? context.l10n.grpJHintParagraph
                : _block.type == BlockType.heading
                ? context.l10n.grpJHintHeading(_block.level)
                : null,
          ),
        ),
      ),
    );
    if (_block.type == BlockType.quote) {
      field = Container(
        padding: const EdgeInsetsDirectional.only(start: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.colorScheme.outline, width: 3),
          ),
        ),
        child: field,
      );
    }
    var row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _prefix(context),
        Expanded(child: field),
      ],
    );
    if (isCallout) {
      final tone = _toneColor(theme.colorScheme, _block.tone);
      row = Row(
        children: [
          IconButton(
            key: Key('callout-tone-${_block.id}'),
            tooltip: context.l10n.grpJChangeTone(_block.tone),
            icon: Icon(_toneIcon(_block.tone), color: tone),
            onPressed: widget.readOnly
                ? null
                : () {
                    final next =
                        calloutTones[(calloutTones.indexOf(_block.tone) + 1) %
                            calloutTones.length];
                    widget.onChanged(_block.withAttrs({'tone': next}));
                  },
          ),
          Expanded(child: field),
        ],
      );
      row = Row(
        children: [
          Expanded(
            child: Container(
              key: Key('callout-${_block.id}'),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: row,
            ),
          ),
        ],
      );
    }
    final pages = [
      for (final p in widget.pages)
        if (p.id != widget.currentDocId) p,
    ];
    final floating = showBar || slash != null || mention != null;
    if (floating != _overlay.isShowing) {
      // Shown or hidden once this frame is built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || floating == _overlay.isShowing) return;
        floating ? _overlay.show() : _overlay.hide();
      });
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(start: _block.indent * 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlayPortal(
            controller: _overlay,
            overlayChildBuilder: (_) => Stack(
              children: [
                if (showBar)
                  CompositedTransformFollower(
                    link: _anchor,
                    showWhenUnlinked: false,
                    targetAnchor: Alignment.topLeft,
                    followerAnchor: Alignment.bottomLeft,
                    child: _toolbar(),
                  ),
                if (slash != null || mention != null)
                  CompositedTransformFollower(
                    link: _anchor,
                    showWhenUnlinked: false,
                    targetAnchor: Alignment.bottomLeft,
                    child: slash != null
                        ? SlashMenu(
                            query: slash,
                            onPick: (i) => widget.onTurn(i.type, i.attrs),
                          )
                        : PagePicker(
                            query: mention!.query,
                            pages: pages,
                            onPick: (p) => _pickMention(p, mention.start),
                          ),
                  ),
              ],
            ),
            child: CompositedTransformTarget(link: _anchor, child: row),
          ),
          if (mentions.isNotEmpty)
            Wrap(
              spacing: 6,
              children: [
                for (final e in mentions.entries)
                  ActionChip(
                    key: Key('mention-${e.key}'),
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.description_outlined, size: 14),
                    label: Text(e.value),
                    onPressed: () => widget.onOpenDoc(e.key),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

Color _toneColor(ColorScheme s, String tone) => switch (tone) {
  'warning' => Colors.orange,
  'success' => Colors.green,
  'danger' => s.error,
  _ => s.primary,
};

IconData _toneIcon(String tone) => switch (tone) {
  'warning' => Icons.warning_amber,
  'success' => Icons.check_circle_outline,
  'danger' => Icons.error_outline,
  _ => Icons.info_outline,
};
