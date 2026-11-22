import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

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
  final TfIconData icon;
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
    TfIcons.alignLeft,
    BlockType.paragraph,
    words: 'paragraph',
  ),
  SlashItem(
    'h1',
    'Heading 1',
    TfIcons.heading,
    BlockType.heading,
    attrs: {'level': 1},
    words: 'heading',
  ),
  SlashItem(
    'h2',
    'Heading 2',
    TfIcons.heading,
    BlockType.heading,
    attrs: {'level': 2},
    words: 'heading',
  ),
  SlashItem(
    'h3',
    'Heading 3',
    TfIcons.heading,
    BlockType.heading,
    attrs: {'level': 3},
    words: 'heading',
  ),
  SlashItem(
    'bullet',
    'Bulleted list',
    TfIcons.list,
    BlockType.bullet,
    words: 'list',
  ),
  SlashItem(
    'numbered',
    'Numbered list',
    TfIcons.listOrdered,
    BlockType.numbered,
    words: 'list',
  ),
  SlashItem(
    'todo',
    'Checklist',
    TfIcons.listChecks,
    BlockType.checklist,
    words: 'check task list',
  ),
  SlashItem('quote', 'Quote', TfIcons.quote, BlockType.quote),
  SlashItem('code', 'Code', TfIcons.code, BlockType.code),
  SlashItem('table', 'Table', TfIcons.table, BlockType.table),
  SlashItem(
    'divider',
    'Divider',
    TfIcons.minus,
    BlockType.divider,
    words: 'line',
  ),
  SlashItem('image', 'Image', TfIcons.image, BlockType.image, words: 'picture'),
  SlashItem(
    'callout',
    'Callout',
    TfIcons.info,
    BlockType.callout,
    words: 'note',
  ),
  SlashItem(
    'task',
    'Task card',
    TfIcons.success,
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
      borderRadius: TfRadius.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260, maxWidth: 320),
        child: items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(TfSpace.md),
                child: Text(context.l10n.grpJNoMatchingBlocks),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final i in items)
                    TfRow(
                      key: Key('slash-${i.id}'),
                      title: i.labelIn(context.l10n),
                      leading: TfIcon(i.icon, size: 20),
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
      borderRadius: TfRadius.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260, maxWidth: 320),
        child: items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(TfSpace.md),
                child: Text(context.l10n.grpJNoMatchingPages),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final p in items)
                    TfTile(
                      key: Key('pick-page-${p.id}'),
                      title: Text(
                        p.labelIn(context.l10n),
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Text(p.icon.isEmpty ? '📄' : p.icon),
                      onTap: () => onPick(p),
                    ),
                ],
              ),
      ),
    );
  }
}
