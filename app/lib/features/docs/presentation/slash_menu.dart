import 'package:flutter/material.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// One entry of the `/` menu.
class SlashItem {
  const SlashItem(
    this.id,
    this.label,
    this.icon,
    this.type, {
    this.attrs = const {},
    this.words = '',
  });

  final String id;
  final String label;
  final IconData icon;
  final String type;
  final Map<String, Object?> attrs;

  /// Other words that find it.
  final String words;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (id) {
    'text' => l.grpMSlashText,
    'h1' => l.grpMSlashH1,
    'h2' => l.grpMSlashH2,
    'h3' => l.grpMSlashH3,
    'bullet' => l.grpMSlashBullet,
    'numbered' => l.grpMSlashNumbered,
    'todo' => l.grpMSlashTodo,
    'quote' => l.grpMSlashQuote,
    'code' => l.grpMSlashCode,
    'table' => l.grpMSlashTable,
    'divider' => l.grpMSlashDivider,
    'image' => l.grpMSlashImage,
    'callout' => l.grpMSlashCallout,
    'task' => l.grpMSlashTask,
    _ => label,
  };

  /// Matches the id, the English label, the other words and, when [l] is
  /// given, the label in that language.
  bool matches(String query, [AppLocalizations? l]) {
    final q = query.toLowerCase();
    return q.isEmpty ||
        id.contains(q) ||
        label.toLowerCase().contains(q) ||
        words.contains(q) ||
        (l != null && labelIn(l).toLowerCase().contains(q));
  }
}

const slashItems = [
  SlashItem(
    'text',
    'Text',
    Icons.notes,
    BlockType.paragraph,
    words: 'paragraph',
  ),
  SlashItem(
    'h1',
    'Heading 1',
    Icons.title,
    BlockType.heading,
    attrs: {'level': 1},
    words: 'heading',
  ),
  SlashItem(
    'h2',
    'Heading 2',
    Icons.title,
    BlockType.heading,
    attrs: {'level': 2},
    words: 'heading',
  ),
  SlashItem(
    'h3',
    'Heading 3',
    Icons.title,
    BlockType.heading,
    attrs: {'level': 3},
    words: 'heading',
  ),
  SlashItem(
    'bullet',
    'Bulleted list',
    Icons.format_list_bulleted,
    BlockType.bullet,
    words: 'list',
  ),
  SlashItem(
    'numbered',
    'Numbered list',
    Icons.format_list_numbered,
    BlockType.numbered,
    words: 'list',
  ),
  SlashItem(
    'todo',
    'Checklist',
    Icons.checklist,
    BlockType.checklist,
    words: 'check task list',
  ),
  SlashItem('quote', 'Quote', Icons.format_quote, BlockType.quote),
  SlashItem('code', 'Code', Icons.code, BlockType.code),
  SlashItem('table', 'Table', Icons.table_chart_outlined, BlockType.table),
  SlashItem(
    'divider',
    'Divider',
    Icons.horizontal_rule,
    BlockType.divider,
    words: 'line',
  ),
  SlashItem(
    'image',
    'Image',
    Icons.image_outlined,
    BlockType.image,
    words: 'picture',
  ),
  SlashItem(
    'callout',
    'Callout',
    Icons.info_outline,
    BlockType.callout,
    words: 'note',
  ),
  SlashItem(
    'task',
    'Task card',
    Icons.task_alt,
    BlockType.taskCard,
    words: 'embed task',
  ),
];

/// The `/` menu under a block, narrowed by what was typed after the slash.
class SlashMenu extends StatelessWidget {
  const SlashMenu({super.key, required this.query, required this.onPick});

  final String query;
  final void Function(SlashItem item) onPick;

  static List<SlashItem> filter(String query, [AppLocalizations? l]) => [
    for (final i in slashItems)
      if (i.matches(query, l)) i,
  ];

  @override
  Widget build(BuildContext context) {
    final items = filter(query, context.l10n);
    return Material(
      key: const Key('slash-menu'),
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260, maxWidth: 320),
        child: items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Text(context.l10n.grpJNoMatchingBlocks),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final i in items)
                    ListTile(
                      key: Key('slash-${i.id}'),
                      dense: true,
                      leading: Icon(i.icon, size: 20),
                      title: Text(i.labelIn(context.l10n)),
                      onTap: () => onPick(i),
                    ),
                ],
              ),
      ),
    );
  }
}

/// The `[[` menu: pages whose title fits what was typed.
class PagePicker extends StatelessWidget {
  const PagePicker({
    super.key,
    required this.query,
    required this.pages,
    required this.onPick,
  });

  final String query;
  final List<DocNode> pages;
  final void Function(DocNode page) onPick;

  static List<DocNode> filter(List<DocNode> pages, String query) => [
    for (final p in pages)
      if (!p.archived && p.label.toLowerCase().contains(query.toLowerCase())) p,
  ].take(8).toList();

  @override
  Widget build(BuildContext context) {
    final items = filter(pages, query);
    return Material(
      key: const Key('page-picker'),
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260, maxWidth: 320),
        child: items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Text(context.l10n.grpJNoMatchingPages),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final p in items)
                    ListTile(
                      key: Key('pick-page-${p.id}'),
                      dense: true,
                      leading: Text(p.icon.isEmpty ? '📄' : p.icon),
                      title: Text(
                        p.labelIn(context.l10n),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onPick(p),
                    ),
                ],
              ),
      ),
    );
  }
}
