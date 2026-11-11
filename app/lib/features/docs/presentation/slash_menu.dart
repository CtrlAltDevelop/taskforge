import 'package:flutter/material.dart';

import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

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

  bool matches(String query) {
    final q = query.toLowerCase();
    return q.isEmpty ||
        id.contains(q) ||
        label.toLowerCase().contains(q) ||
        words.contains(q);
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

  static List<SlashItem> filter(String query) => [
    for (final i in slashItems)
      if (i.matches(query)) i,
  ];

  @override
  Widget build(BuildContext context) {
    final items = filter(query);
    return Material(
      key: const Key('slash-menu'),
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260, maxWidth: 320),
        child: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No matching blocks'),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final i in items)
                    ListTile(
                      key: Key('slash-${i.id}'),
                      dense: true,
                      leading: Icon(i.icon, size: 20),
                      title: Text(i.label),
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
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No matching pages'),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final p in items)
                    ListTile(
                      key: Key('pick-page-${p.id}'),
                      dense: true,
                      leading: Text(p.icon.isEmpty ? '📄' : p.icon),
                      title: Text(p.label, overflow: TextOverflow.ellipsis),
                      onTap: () => onPick(p),
                    ),
                ],
              ),
      ),
    );
  }
}
