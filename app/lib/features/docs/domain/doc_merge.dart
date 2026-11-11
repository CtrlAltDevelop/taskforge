import 'package:flutter/foundation.dart';

import 'package:taskforge/features/docs/domain/doc_blocks.dart';

/// A block both sides changed (or one changed and the other removed).
@immutable
class BlockConflict {
  const BlockConflict({required this.id, this.mine, this.theirs});

  final String id;

  /// Null when I removed it.
  final DocBlock? mine;

  /// Null when they removed it.
  final DocBlock? theirs;
}

@immutable
class MergeResult {
  const MergeResult(this.blocks, this.conflicts);

  final List<DocBlock> blocks;
  final List<BlockConflict> conflicts;

  bool get clean => conflicts.isEmpty;
}

/// A three-way merge by block id. [base] is what both started from, [mine]
/// the edited body, [theirs] the server's. Blocks changed on one side only
/// take that change; blocks changed on both are conflicts, kept as mine unless
/// listed in [takeTheirs].
MergeResult mergeBlocks(
  List<DocBlock> base,
  List<DocBlock> mine,
  List<DocBlock> theirs, {
  Set<String> takeTheirs = const {},
}) {
  final b = {for (final x in base) x.id: x};
  final m = {for (final x in mine) x.id: x};
  final t = {for (final x in theirs) x.id: x};
  final conflicts = <BlockConflict>[];
  final out = <DocBlock>[];

  for (final theirBlock in theirs) {
    final id = theirBlock.id;
    final baseBlock = b[id];
    final myBlock = m[id];
    if (myBlock == null) {
      if (baseBlock == null || baseBlock == theirBlock) {
        // Added by them, or removed by me and untouched by them.
        if (baseBlock == null) out.add(theirBlock);
        continue;
      }
      conflicts.add(BlockConflict(id: id, theirs: theirBlock));
      if (takeTheirs.contains(id)) out.add(theirBlock);
    } else if (baseBlock == null) {
      if (myBlock == theirBlock) {
        out.add(theirBlock);
      } else {
        conflicts.add(BlockConflict(id: id, mine: myBlock, theirs: theirBlock));
        out.add(takeTheirs.contains(id) ? theirBlock : myBlock);
      }
    } else if (myBlock == baseBlock) {
      out.add(theirBlock);
    } else if (theirBlock == baseBlock || theirBlock == myBlock) {
      out.add(myBlock);
    } else {
      conflicts.add(BlockConflict(id: id, mine: myBlock, theirs: theirBlock));
      out.add(takeTheirs.contains(id) ? theirBlock : myBlock);
    }
  }

  // My blocks they do not have: mine added them, or they removed them.
  String? previous;
  for (final myBlock in mine) {
    final id = myBlock.id;
    final present = out.any((x) => x.id == id);
    if (!t.containsKey(id)) {
      final baseBlock = b[id];
      var keep = baseBlock == null;
      if (baseBlock != null && baseBlock != myBlock) {
        conflicts.add(BlockConflict(id: id, mine: myBlock));
        keep = !takeTheirs.contains(id);
      }
      if (keep) {
        final at = previous == null
            ? 0
            : out.indexWhere((x) => x.id == previous) + 1;
        out.insert(at, myBlock);
        previous = id;
      }
    } else if (present) {
      previous = id;
    }
  }
  return MergeResult(List.unmodifiable(out), List.unmodifiable(conflicts));
}
