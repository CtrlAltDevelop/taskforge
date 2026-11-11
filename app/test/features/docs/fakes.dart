import 'dart:async';

import 'package:taskforge/features/docs/data/docs_client.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

DocNode node(
  String id,
  String title, {
  String parent = '',
  String project = '',
  bool restricted = false,
  bool archived = false,
}) => DocNode(
  id: id,
  title: title,
  parentId: parent,
  projectId: project,
  restricted: restricted,
  archived: archived,
);

DocBlock para(String id, String text) => DocBlock({
  'id': id,
  'type': 'paragraph',
  'content': [
    {'type': 'text', 'text': text},
  ],
});

DocBlock heading(String id, String text, {int level = 1}) => DocBlock({
  'id': id,
  'type': 'heading',
  'attrs': {'level': level},
  'content': [
    {'type': 'text', 'text': text},
  ],
});

DocBlock taskCard(String id, String taskId) => DocBlock({
  'id': id,
  'type': 'task_card',
  'attrs': {'task_id': taskId},
});

/// An in-memory docs server. Pages are listed in tree order.
class FakeDocsClient implements DocsClient {
  /// While set, `get` waits for it before answering.
  Completer<void>? holdGet;

  FakeDocsClient({
    List<DocNode> nodes = const [],
    Map<String, List<DocBlock>> bodies = const {},
  }) : nodes = [...nodes],
       bodies = {
         for (final e in bodies.entries) e.key: [...e.value],
       };

  final List<DocNode> nodes;
  final Map<String, List<DocBlock>> bodies;
  final versions = <String, int>{};
  final canEdit = <String, bool>{};
  bool defaultCanEdit = true;
  bool defaultCanManage = true;
  final access = <String, List<String>>{};
  final cards = <String, TaskCardInfo>{};
  final revisionList =
      <String, List<({RevisionInfo info, List<DocBlock> blocks})>>{};
  final editing = <String, List<DocEditor>>{};
  final related = <String, List<RelatedDoc>>{};
  final backlinkMap = <String, List<DocNode>>{};

  final calls = <String>[];
  final updates =
      <
        ({
          String doc,
          int expected,
          List<String> fields,
          List<DocBlock> blocks,
          String title,
          String icon,
        })
      >[];
  final presenceCalls = <String>[];
  DocException? failNext;

  /// Leaves the server's blocks out of a conflict (they are "too big").
  bool omitConflictBlocks = false;
  var _next = 1;

  int version(String id) => versions[id] ?? 1;

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  /// Somebody else saves [blocks]: the version moves on.
  void externalSave(String id, List<DocBlock> blocks) {
    bodies[id] = [...blocks];
    versions[id] = version(id) + 1;
  }

  DocNode _node(String id) {
    final n = nodes.where((n) => n.id == id).firstOrNull;
    if (n == null) throw const DocException(DocFailure.notFound);
    return n;
  }

  void _put(DocNode n) {
    final i = nodes.indexWhere((x) => x.id == n.id);
    nodes[i] = n;
  }

  DocNode _copy(
    DocNode n, {
    String? title,
    String? icon,
    String? parent,
    bool? restricted,
    bool? archived,
  }) => DocNode(
    id: n.id,
    title: title ?? n.title,
    projectId: n.projectId,
    parentId: parent ?? n.parentId,
    icon: icon ?? n.icon,
    position: n.position,
    restricted: restricted ?? n.restricted,
    archived: archived ?? n.archived,
  );

  DocPage _page(String id, {bool body = true}) {
    final n = _node(id);
    return DocPage(
      node: n,
      version: body ? version(id) : 0,
      blocks: body ? List.unmodifiable(bodies[id] ?? const []) : const [],
      editing: editing[id] ?? const [],
      cards: [
        for (final taskId in taskCardIds(bodies[id] ?? const [])) _card(taskId),
      ],
      canEdit: canEdit[id] ?? defaultCanEdit,
      canManage: defaultCanManage,
      accessUserIds: access[id] ?? const [],
    );
  }

  TaskCardInfo _card(String taskId) =>
      cards[taskId] ?? TaskCardInfo(taskId: taskId, hidden: true);

  Set<String> _subtree(String id) => DocTreeView(nodes).subtree(id);

  @override
  Future<List<DocNode>> tree(
    String workspaceId, {
    String projectId = '',
    bool includeArchived = false,
  }) async {
    calls.add('tree:$projectId');
    _maybeFail();
    return [
      for (final n in nodes)
        if (n.projectId == projectId && (includeArchived || !n.archived)) n,
    ];
  }

  @override
  Future<DocPage> get(String workspaceId, String docId) async {
    calls.add('get:$docId');
    _maybeFail();
    final page = _page(docId);
    final gate = holdGet;
    if (gate != null) await gate.future;
    return page;
  }

  @override
  Future<DocPage> create(
    String workspaceId, {
    String projectId = '',
    String parentId = '',
    String title = '',
    String icon = '',
    List<DocBlock> blocks = const [],
  }) async {
    calls.add('create:$parentId');
    _maybeFail();
    final id = 'new${_next++}';
    final n = DocNode(
      id: id,
      title: title,
      projectId: projectId,
      parentId: parentId,
    );
    // After its parent's last descendant, like the server's tree order.
    var at = nodes.length;
    if (parentId.isNotEmpty) {
      final family = _subtree(parentId);
      at = nodes.lastIndexWhere((x) => family.contains(x.id)) + 1;
    }
    nodes.insert(at, n);
    bodies[id] = [...blocks];
    return _page(id);
  }

  @override
  Future<DocPage> update(
    String workspaceId,
    String docId, {
    required int expectedVersion,
    required List<String> fields,
    String title = '',
    String icon = '',
    List<DocBlock> blocks = const [],
  }) async {
    calls.add('update:$docId');
    _maybeFail();
    updates.add((
      doc: docId,
      expected: expectedVersion,
      fields: fields,
      blocks: blocks,
      title: title,
      icon: icon,
    ));
    final n = _node(docId);
    if (n.archived) {
      throw const DocException(DocFailure.archived, detail: 'archived');
    }
    if (expectedVersion != version(docId)) {
      throw DocException(
        DocFailure.conflict,
        conflict: DocConflict(
          version: version(docId),
          blocksJson: omitConflictBlocks
              ? null
              : encodeBlocks(bodies[docId] ?? const []),
        ),
      );
    }
    if (fields.contains('title')) _put(_copy(n, title: title));
    if (fields.contains('icon')) _put(_copy(_node(docId), icon: icon));
    if (fields.contains('blocks')) {
      bodies[docId] = [...blocks];
      revisionList.putIfAbsent(docId, () => []).insert(0, (
        info: RevisionInfo(
          id: _next++,
          version: version(docId) + 1,
          title: title,
          authorId: 'u1',
        ),
        blocks: [...blocks],
      ));
    }
    versions[docId] = version(docId) + 1;
    return _page(docId);
  }

  @override
  Future<DocPage> move(
    String workspaceId,
    String docId, {
    required String parentId,
    required int index,
  }) async {
    calls.add('move:$docId>$parentId@$index');
    _maybeFail();
    final n = _node(docId);
    if (parentId == docId || _subtree(docId).contains(parentId)) {
      throw const DocException(DocFailure.cycle);
    }
    final family = _subtree(docId);
    final moved = nodes.where((x) => family.contains(x.id)).toList();
    nodes.removeWhere((x) => family.contains(x.id));
    final sibs = nodes
        .where((x) => x.parentId == parentId && x.projectId == n.projectId)
        .toList();
    final i = index.clamp(0, sibs.length);
    var at = nodes.length;
    if (i < sibs.length) {
      at = nodes.indexWhere((x) => x.id == sibs[i].id);
    } else if (sibs.isNotEmpty) {
      final f = _subtreeOf(sibs.last.id);
      at = nodes.lastIndexWhere((x) => f.contains(x.id)) + 1;
    } else if (parentId.isNotEmpty) {
      at = nodes.indexWhere((x) => x.id == parentId) + 1;
    }
    moved[0] = _copy(moved[0], parent: parentId);
    nodes.insertAll(at, moved);
    return _page(docId, body: false);
  }

  Set<String> _subtreeOf(String id) => DocTreeView(nodes).subtree(id);

  @override
  Future<DocPage> archive(String workspaceId, String docId) async {
    calls.add('archive:$docId');
    _maybeFail();
    for (final id in _subtree(docId)) {
      _put(_copy(_node(id), archived: true));
    }
    return _page(docId, body: false);
  }

  @override
  Future<DocPage> restore(String workspaceId, String docId) async {
    calls.add('restore:$docId');
    _maybeFail();
    for (final id in _subtree(docId)) {
      _put(_copy(_node(id), archived: false));
    }
    return _page(docId, body: false);
  }

  @override
  Future<DocPage> setAccess(
    String workspaceId,
    String docId, {
    required bool restricted,
    required List<String> userIds,
  }) async {
    calls.add('access:$docId:$restricted:${userIds.join(',')}');
    _maybeFail();
    _put(_copy(_node(docId), restricted: restricted));
    access[docId] = [...userIds];
    return _page(docId, body: false);
  }

  @override
  Future<List<RevisionInfo>> revisions(String workspaceId, String docId) async {
    calls.add('revisions:$docId');
    return [for (final r in revisionList[docId] ?? const []) r.info];
  }

  @override
  Future<List<DocBlock>> revision(
    String workspaceId,
    String docId,
    int revisionId,
  ) async {
    calls.add('revision:$revisionId');
    return revisionList[docId]!
        .firstWhere((r) => r.info.id == revisionId)
        .blocks;
  }

  @override
  Future<DocPage> restoreRevision(
    String workspaceId,
    String docId,
    int revisionId, {
    required int expectedVersion,
  }) async {
    calls.add('restoreRevision:$revisionId@$expectedVersion');
    _maybeFail();
    if (expectedVersion != version(docId)) {
      throw DocException(
        DocFailure.conflict,
        conflict: DocConflict(version: version(docId)),
      );
    }
    final r = revisionList[docId]!.firstWhere((r) => r.info.id == revisionId);
    bodies[docId] = [...r.blocks];
    versions[docId] = version(docId) + 1;
    return _page(docId);
  }

  @override
  Future<List<DocNode>> backlinks(String workspaceId, String docId) async =>
      backlinkMap[docId] ?? const [];

  @override
  Future<List<TaskCardInfo>> taskCards(
    String workspaceId,
    List<String> taskIds,
  ) async {
    calls.add('cards:${taskIds.join(',')}');
    return [for (final t in taskIds) _card(t)];
  }

  @override
  Future<List<DocEditor>> presence(
    String workspaceId,
    String docId,
    String state,
  ) async {
    presenceCalls.add('$docId:$state');
    return editing[docId] ?? const [];
  }

  @override
  Future<({String title, String markdown})> exportMarkdown(
    String workspaceId,
    String docId,
  ) async => (
    title: _node(docId).title,
    markdown:
        '# ${_node(docId).title}\n\n${(bodies[docId] ?? const []).map((b) => b.plain).join('\n\n')}\n',
  );

  @override
  Future<List<RelatedDoc>> forTask(
    String workspaceId,
    String projectId,
    String taskId,
  ) async => related[taskId] ?? const [];

  @override
  Future<List<RelatedDoc>> linkTask(
    String workspaceId,
    String projectId,
    String taskId,
    String docId,
  ) async {
    calls.add('link:$taskId:$docId');
    _maybeFail();
    related[taskId] = [
      ...?related[taskId],
      RelatedDoc(doc: _node(docId), kind: 'link'),
    ];
    return related[taskId]!;
  }

  @override
  Future<List<RelatedDoc>> unlinkTask(
    String workspaceId,
    String projectId,
    String taskId,
    String docId,
  ) async {
    calls.add('unlink:$taskId:$docId');
    related[taskId] = [
      for (final r in related[taskId] ?? const <RelatedDoc>[])
        if (r.doc.id != docId) r,
    ];
    return related[taskId]!;
  }
}
