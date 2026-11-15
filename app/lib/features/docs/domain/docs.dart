import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// A page in the tree (no body).
@immutable
class DocNode {
  const DocNode({
    required this.id,
    required this.title,
    this.projectId = '',
    this.parentId = '',
    this.icon = '',
    this.position = 0,
    this.restricted = false,
    this.archived = false,
    this.createdBy = '',
    this.updatedAt = '',
  });

  final String id;
  final String projectId;
  final String parentId;
  final String title;
  final String icon;
  final int position;
  final bool restricted;
  final bool archived;
  final String createdBy;
  final String updatedAt;

  String get label => title.trim().isEmpty ? 'Untitled' : title;

  /// [label] as shown: the untitled name in the language of [l10n].
  String labelIn(AppLocalizations l10n) =>
      title.trim().isEmpty ? l10n.grpBUntitled : title;
}

@immutable
class DocEditor {
  const DocEditor({required this.userId, required this.editing});

  final String userId;
  final bool editing;
}

/// A task card as this viewer may see it.
@immutable
class TaskCardInfo {
  const TaskCardInfo({
    required this.taskId,
    this.hidden = false,
    this.projectId = '',
    this.key = '',
    this.title = '',
    this.statusName = '',
    this.statusCategory = '',
    this.priority = '',
  });

  final String taskId;
  final bool hidden;
  final String projectId;
  final String key;
  final String title;
  final String statusName;
  final String statusCategory;
  final String priority;
}

/// A page with its body and what the caller may do with it.
@immutable
class DocPage {
  const DocPage({
    required this.node,
    this.version = 0,
    this.blocks = const [],
    this.updatedBy = '',
    this.editing = const [],
    this.cards = const [],
    this.canEdit = false,
    this.canManage = false,
    this.accessUserIds = const [],
  });

  final DocNode node;
  final int version;
  final List<DocBlock> blocks;
  final String updatedBy;
  final List<DocEditor> editing;
  final List<TaskCardInfo> cards;
  final bool canEdit;
  final bool canManage;
  final List<String> accessUserIds;
}

@immutable
class RevisionInfo {
  const RevisionInfo({
    required this.id,
    required this.version,
    this.title = '',
    this.authorId = '',
    this.at = '',
    this.savedAt = '',
  });

  final int id;
  final int version;
  final String title;
  final String authorId;
  final String at;
  final String savedAt;
}

@immutable
class RelatedDoc {
  const RelatedDoc({required this.doc, required this.kind});

  final DocNode doc;

  /// `link` (linked by hand) or `card` (embedded in the page).
  final String kind;
}

/// What the server sent with a version conflict.
@immutable
class DocConflict {
  const DocConflict({required this.version, this.blocksJson});

  final int version;

  /// The server's body; null when it was too big to send (read it with Get).
  final String? blocksJson;
}

enum DocFailure {
  network,
  denied,
  invalid,
  notFound,
  conflict,
  archived,
  cycle,
  other,
}

class DocException implements Exception {
  const DocException(this.failure, {this.detail, this.conflict});

  final DocFailure failure;
  final String? detail;
  final DocConflict? conflict;

  @override
  String toString() => 'DocException($failure)';
}

String docErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! DocException) return t.grpLGeneric;
  final d = error.detail;
  final has = d != null && d.isNotEmpty;
  return switch (error.failure) {
    DocFailure.network => t.grpLNetCheckShort,
    DocFailure.denied => t.grpLNoPermDo,
    DocFailure.notFound => t.grpLDocNotFound,
    DocFailure.conflict => t.grpLDocConflict,
    DocFailure.archived => has ? d : t.grpLDocArchived,
    DocFailure.cycle => has ? d : t.grpLDocCycle,
    DocFailure.invalid => has ? d : t.grpLNotValid,
    DocFailure.other => t.grpLGeneric,
  };
}

/// Where a dropped page goes.
enum DropZone { before, into, after }

/// Reads of the flat, tree-ordered list the server sends.
class DocTreeView {
  DocTreeView(Iterable<DocNode> docs) : docs = List.unmodifiable(docs) {
    for (final d in this.docs) {
      _byId[d.id] = d;
    }
  }

  final List<DocNode> docs;
  final _byId = <String, DocNode>{};

  DocNode? byId(String id) => _byId[id];

  /// A page whose parent is not in the list is shown at the top.
  bool _isRoot(DocNode d) =>
      d.parentId.isEmpty || !_byId.containsKey(d.parentId);

  List<DocNode> children(String parentId) {
    final rows = [
      for (final d in docs)
        if (parentId.isEmpty ? _isRoot(d) : d.parentId == parentId) d,
    ];
    return rows;
  }

  bool hasChildren(String id) => docs.any((d) => d.parentId == id);

  /// Pages from the top down to (and including) [id].
  List<DocNode> trail(String id) {
    final out = <DocNode>[];
    var cur = _byId[id];
    var guard = 0;
    while (cur != null && guard++ < 50) {
      out.insert(0, cur);
      cur = _byId[cur.parentId];
    }
    return out;
  }

  Set<String> subtree(String id) {
    final out = <String>{id};
    var grew = true;
    while (grew) {
      grew = false;
      for (final d in docs) {
        if (out.contains(d.parentId) && out.add(d.id)) grew = true;
      }
    }
    return out;
  }

  /// The parent and index (among the new siblings, without the dragged page)
  /// for dropping [dragged] on [target], or null when that is not allowed.
  ({String parent, int index})? dropAt(
    String dragged,
    String target,
    DropZone zone,
  ) {
    if (dragged == target || subtree(dragged).contains(target)) return null;
    final t = _byId[target];
    if (t == null) return null;
    if (zone == DropZone.into) {
      final kids = children(target).where((d) => d.id != dragged);
      return (parent: target, index: kids.length);
    }
    final parent = _isRoot(t) ? '' : t.parentId;
    final sibs = children(parent).where((d) => d.id != dragged).toList();
    final at = sibs.indexWhere((d) => d.id == target);
    return (parent: parent, index: zone == DropZone.before ? at : at + 1);
  }

  /// Moving [id] one place up or down among its siblings.
  ({String parent, int index})? nudge(String id, int by) {
    final d = _byId[id];
    if (d == null) return null;
    final parent = _isRoot(d) ? '' : d.parentId;
    final sibs = children(parent);
    final at = sibs.indexWhere((s) => s.id == id);
    final to = at + by;
    if (at < 0 || to < 0 || to >= sibs.length) return null;
    return (parent: parent, index: to);
  }
}
