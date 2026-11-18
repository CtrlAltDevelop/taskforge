import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

/// A code block: plain monospace text and a language.
class CodeBlockView extends StatefulWidget {
  const CodeBlockView({
    super.key,
    required this.block,
    required this.focusNode,
    required this.readOnly,
    required this.onChanged,
    required this.onBackspaceStart,
  });

  final DocBlock block;
  final FocusNode focusNode;
  final bool readOnly;
  final void Function(DocBlock block) onChanged;
  final VoidCallback onBackspaceStart;

  @override
  State<CodeBlockView> createState() => _CodeBlockViewState();
}

class _CodeBlockViewState extends State<CodeBlockView> {
  late final _text = TextEditingController(text: widget.block.codeText);
  late final _lang = TextEditingController(text: widget.block.language);

  @override
  void didUpdateWidget(CodeBlockView old) {
    super.didUpdateWidget(old);
    if (_text.text != widget.block.codeText) {
      _text.text = widget.block.codeText;
    }
    if (_lang.text != widget.block.language) {
      _lang.text = widget.block.language;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _lang.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: TfRadius.control,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: TextField(
              key: Key('lang-${widget.block.id}'),
              controller: _lang,
              readOnly: widget.readOnly,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: context.l10n.grpJCodeLanguageHint,
              ),
              onChanged: (v) =>
                  widget.onChanged(widget.block.withAttrs({'language': v})),
            ),
          ),
          TextField(
            key: Key('field-${widget.block.id}'),
            controller: _text,
            focusNode: widget.focusNode,
            readOnly: widget.readOnly,
            maxLines: null,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
            onChanged: (v) => widget.onChanged(widget.block.withCodeText(v)),
          ),
        ],
      ),
    );
  }
}

/// A table: a grid of small text fields with add and remove for rows and
/// columns.
class TableBlockView extends StatelessWidget {
  const TableBlockView({
    super.key,
    required this.block,
    required this.readOnly,
    required this.onChanged,
  });

  final DocBlock block;
  final bool readOnly;
  final void Function(DocBlock block) onChanged;

  @override
  Widget build(BuildContext context) {
    final rows = block.rows;
    final columns = rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);
    final scheme = Theme.of(context).colorScheme;

    void set(int r, int c, String text) {
      final next = [
        for (var i = 0; i < rows.length; i++)
          [
            for (var j = 0; j < rows[i].length; j++)
              if (i == r && j == c) rows[i][j].withText(text) else rows[i][j],
          ],
      ];
      onChanged(block.withRows(next));
    }

    List<List<Rich>> padded() => [
      for (final r in rows)
        [...r, for (var j = r.length; j < columns; j++) Rich.empty],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          key: Key('table-${block.id}'),
          border: TableBorder.all(color: scheme.outlineVariant),
          defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
          children: [
            for (var r = 0; r < rows.length; r++)
              TableRow(
                decoration: block.header && r == 0
                    ? BoxDecoration(color: scheme.surfaceContainerHighest)
                    : null,
                children: [
                  for (var c = 0; c < columns; c++)
                    _CellField(
                      key: ValueKey('${block.id}-$r-$c'),
                      fieldKey: Key('cell-${block.id}-$r-$c'),
                      text: c < rows[r].length ? rows[r][c].text : '',
                      readOnly: readOnly,
                      bold: block.header && r == 0,
                      onChanged: (t) => set(r, c, t),
                    ),
                ],
              ),
          ],
        ),
        if (!readOnly)
          Wrap(
            children: [
              TextButton.icon(
                key: Key('table-add-row-${block.id}'),
                icon: const TfIcon(TfIcons.plus, size: 16),
                label: Text(context.l10n.grpJTableRow),
                onPressed: () => onChanged(
                  block.withRows([
                    ...padded(),
                    [for (var j = 0; j < columns; j++) Rich.empty],
                  ]),
                ),
              ),
              TextButton.icon(
                key: Key('table-add-column-${block.id}'),
                icon: const TfIcon(TfIcons.plus, size: 16),
                label: Text(context.l10n.grpJTableColumn),
                onPressed: columns >= 20
                    ? null
                    : () => onChanged(
                        block.withRows([
                          for (final r in padded()) [...r, Rich.empty],
                        ]),
                      ),
              ),
              TextButton.icon(
                key: Key('table-remove-row-${block.id}'),
                icon: const TfIcon(TfIcons.minus, size: 16),
                label: Text(context.l10n.grpJTableRow),
                onPressed: rows.length <= 1
                    ? null
                    : () => onChanged(
                        block.withRows(padded().sublist(0, rows.length - 1)),
                      ),
              ),
              TextButton.icon(
                key: Key('table-remove-column-${block.id}'),
                icon: const TfIcon(TfIcons.minus, size: 16),
                label: Text(context.l10n.grpJTableColumn),
                onPressed: columns <= 1
                    ? null
                    : () => onChanged(
                        block.withRows([
                          for (final r in padded()) r.sublist(0, columns - 1),
                        ]),
                      ),
              ),
            ],
          ),
      ],
    );
  }
}

class _CellField extends StatefulWidget {
  const _CellField({
    super.key,
    required this.fieldKey,
    required this.text,
    required this.readOnly,
    required this.bold,
    required this.onChanged,
  });

  final Key fieldKey;
  final String text;
  final bool readOnly;
  final bool bold;
  final void Function(String text) onChanged;

  @override
  State<_CellField> createState() => _CellFieldState();
}

class _CellFieldState extends State<_CellField> {
  late final _c = TextEditingController(text: widget.text);

  @override
  void didUpdateWidget(_CellField old) {
    super.didUpdateWidget(old);
    if (_c.text != widget.text) _c.text = widget.text;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: TextField(
      key: widget.fieldKey,
      controller: _c,
      readOnly: widget.readOnly,
      maxLines: null,
      style: TextStyle(fontWeight: widget.bold ? FontWeight.bold : null),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
      ),
      onChanged: widget.onChanged,
    ),
  );
}

class DividerBlockView extends StatelessWidget {
  const DividerBlockView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(key: Key('divider-block'), height: 24);
}

/// An image by address, with a button to change it.
class ImageBlockView extends StatelessWidget {
  const ImageBlockView({
    super.key,
    required this.block,
    required this.readOnly,
    required this.onEdit,
  });

  final DocBlock block;
  final bool readOnly;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final src = block.src;
    final width = (block.attrs['width'] as num?)?.toDouble();
    final empty = src.isEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: empty
              ? Text(
                  context.l10n.grpJNoImageAddress,
                  key: const Key('image-empty'),
                )
              : Image.network(
                  src,
                  width: width,
                  semanticLabel: block.alt,
                  errorBuilder: (_, _, _) => Container(
                    key: const Key('image-broken'),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      block.alt.isEmpty
                          ? context.l10n.grpJImageLoadFailed
                          : block.alt,
                    ),
                  ),
                ),
        ),
        if (!readOnly)
          IconButton(
            key: Key('edit-image-${block.id}'),
            tooltip: context.l10n.grpJEditImage,
            icon: const TfIcon(TfIcons.edit, size: 18),
            onPressed: onEdit,
          ),
      ],
    );
  }
}

/// A task embedded in the page: live status, or "no access".
class TaskCardView extends StatelessWidget {
  const TaskCardView({
    super.key,
    required this.block,
    required this.card,
    required this.onOpen,
  });

  final DocBlock block;

  /// Null while the card is still being read.
  final TaskCardInfo? card;
  final void Function(TaskCardInfo card) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = card;
    if (c == null) {
      return Card(
        key: const Key('task-card-loading'),
        child: ListTile(dense: true, title: Text(context.l10n.grpJLoadingTask)),
      );
    }
    if (c.hidden) {
      return Card(
        key: Key('task-card-hidden-${c.taskId}'),
        color: theme.colorScheme.surfaceContainerHighest,
        child: ListTile(
          dense: true,
          leading: const TfIcon(TfIcons.lock),
          title: Text(context.l10n.grpJNoAccessTask),
        ),
      );
    }
    return Card(
      key: Key('task-card-${c.taskId}'),
      child: ListTile(
        dense: true,
        leading: TfIcon(
          c.statusCategory == 'done' ? TfIcons.success : TfIcons.circle,
          color: c.statusCategory == 'done' ? Colors.green : null,
        ),
        title: Text('${c.key}  ${c.title}', overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [c.statusName, if (c.priority.isNotEmpty) c.priority].join(' · '),
          key: Key('task-card-status-${c.taskId}'),
        ),
        onTap: () => onOpen(c),
      ),
    );
  }
}

/// A block of a kind this version does not know: kept whole, shown as a
/// placeholder.
class UnknownBlockView extends StatelessWidget {
  const UnknownBlockView({super.key, required this.block});

  final DocBlock block;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('unknown-${block.id}'),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: TfRadius.control,
    ),
    child: Row(
      children: [
        const TfIcon(TfIcons.puzzle, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(context.l10n.grpJUnknownBlock(block.type))),
      ],
    ),
  );
}
