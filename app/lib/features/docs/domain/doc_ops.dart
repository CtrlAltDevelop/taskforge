import 'package:taskforge/features/docs/domain/doc_blocks.dart';

/// Editing a list of blocks. Every function gives a new list.

List<DocBlock> replaceBlock(List<DocBlock> blocks, DocBlock block) => [
  for (final b in blocks)
    if (b.id == block.id) block else b,
];

List<DocBlock> insertAfter(List<DocBlock> blocks, String? id, DocBlock block) {
  final at = id == null ? -1 : blocks.indexWhere((b) => b.id == id);
  return [...blocks.sublist(0, at + 1), block, ...blocks.sublist(at + 1)];
}

List<DocBlock> removeBlock(List<DocBlock> blocks, String id) => [
  for (final b in blocks)
    if (b.id != id) b,
];

/// [id] moved by [delta] places (clamped to the ends).
List<DocBlock> moveBlock(List<DocBlock> blocks, String id, int delta) {
  final at = blocks.indexWhere((b) => b.id == id);
  if (at < 0) return blocks;
  final to = (at + delta).clamp(0, blocks.length - 1);
  if (to == at) return blocks;
  final out = [...blocks];
  final b = out.removeAt(at);
  out.insert(to, b);
  return out;
}

/// What Enter does at the end of [before]: the block keeps [before], a new
/// one gets [after]. A list item stays a list item; a heading, quote or
/// callout continues as a paragraph; Enter in an empty list item ends the
/// list instead.
({List<DocBlock> blocks, String focus}) splitBlock(
  List<DocBlock> blocks,
  String id,
  Rich before,
  Rich after,
) {
  final block = blocks.firstWhere((b) => b.id == id);
  final isList = const {
    BlockType.bullet,
    BlockType.numbered,
    BlockType.checklist,
  }.contains(block.type);
  if (isList && before.isEmpty && after.isEmpty) {
    final plain = block.turnInto(BlockType.paragraph);
    return (blocks: replaceBlock(blocks, plain), focus: id);
  }
  final kind = isList ? block.type : BlockType.paragraph;
  var next = DocBlock.create(kind).withRich(after);
  if (isList) next = next.withAttrs({'indent': block.indent});
  final kept = block.withRich(before);
  return (
    blocks: insertAfter(replaceBlock(blocks, kept), id, next),
    focus: next.id,
  );
}

/// What Backspace at the start of a block does: anything but a paragraph
/// becomes one; a paragraph joins the text block above it. Null when there is
/// nothing to do.
({List<DocBlock> blocks, String focus, int offset})? mergeUp(
  List<DocBlock> blocks,
  String id,
) {
  final at = blocks.indexWhere((b) => b.id == id);
  if (at < 0) return null;
  final block = blocks[at];
  if (block.type != BlockType.paragraph && block.hasRichText) {
    return (
      blocks: replaceBlock(blocks, block.turnInto(BlockType.paragraph)),
      focus: id,
      offset: 0,
    );
  }
  if (at == 0 || !block.hasRichText) return null;
  final above = blocks[at - 1];
  if (!above.hasRichText) {
    // An empty paragraph under a divider, image or card removes itself.
    if (block.rich.isEmpty) {
      return (blocks: removeBlock(blocks, id), focus: above.id, offset: 0);
    }
    return null;
  }
  final joined = above.rich;
  return (
    blocks: removeBlock(
      replaceBlock(blocks, above.withRich(joined + block.rich)),
      id,
    ),
    focus: above.id,
    offset: joined.length,
  );
}

/// The number each numbered item shows: runs of numbered items count from
/// one, deeper items count on their own.
Map<String, int> numbering(List<DocBlock> blocks) {
  final out = <String, int>{};
  final counts = <int, int>{};
  for (final b in blocks) {
    if (b.type != BlockType.numbered) {
      counts.clear();
      continue;
    }
    counts.removeWhere((indent, _) => indent > b.indent);
    final n = (counts[b.indent] ?? 0) + 1;
    counts[b.indent] = n;
    out[b.id] = n;
  }
  return out;
}

/// A block type typed as Markdown at the start of a paragraph (`# `, `- `,
/// `1. `, `[] `, `> `, three backticks, `---`), or null.
({String type, Map<String, Object?> attrs})? markdownShortcut(String text) {
  final heading = RegExp(r'^(#{1,3}) $').firstMatch(text);
  if (heading != null) {
    return (
      type: BlockType.heading,
      attrs: {'level': heading.group(1)!.length},
    );
  }
  return switch (text) {
    '- ' || '* ' => (type: BlockType.bullet, attrs: const {}),
    '1. ' => (type: BlockType.numbered, attrs: const {}),
    '[] ' || '[ ] ' => (type: BlockType.checklist, attrs: const {}),
    '> ' => (type: BlockType.quote, attrs: const {}),
    '```' => (type: BlockType.code, attrs: const {}),
    '---' => (type: BlockType.divider, attrs: const {}),
    _ => null,
  };
}

/// The id of a task in pasted text: a `?task=<id>` link or the bare id.
String? taskIdFromText(String text) {
  final id = RegExp(
    r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
  ).firstMatch(text.trim());
  return id?.group(0)?.toLowerCase();
}
