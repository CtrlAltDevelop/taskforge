import 'package:fixnum/fixnum.dart' show Int64;
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/gen/infrastructure/docs/grpc/wikidocs.pbgrpc.dart'
    as pb;

abstract interface class DocsClient {
  Future<List<DocNode>> tree(
    String workspaceId, {
    String projectId = '',
    bool includeArchived = false,
  });
  Future<DocPage> get(String workspaceId, String docId);
  Future<DocPage> create(
    String workspaceId, {
    String projectId = '',
    String parentId = '',
    String title = '',
    String icon = '',
    List<DocBlock> blocks = const [],
  });

  /// Only the named [fields] (`title`, `icon`, `blocks`) change.
  Future<DocPage> update(
    String workspaceId,
    String docId, {
    required int expectedVersion,
    required List<String> fields,
    String title = '',
    String icon = '',
    List<DocBlock> blocks = const [],
  });
  Future<DocPage> move(
    String workspaceId,
    String docId, {
    required String parentId,
    required int index,
  });
  Future<DocPage> archive(String workspaceId, String docId);
  Future<DocPage> restore(String workspaceId, String docId);
  Future<DocPage> setAccess(
    String workspaceId,
    String docId, {
    required bool restricted,
    required List<String> userIds,
  });
  Future<List<RevisionInfo>> revisions(String workspaceId, String docId);
  Future<List<DocBlock>> revision(
    String workspaceId,
    String docId,
    int revisionId,
  );
  Future<DocPage> restoreRevision(
    String workspaceId,
    String docId,
    int revisionId, {
    required int expectedVersion,
  });
  Future<List<DocNode>> backlinks(String workspaceId, String docId);
  Future<List<TaskCardInfo>> taskCards(
    String workspaceId,
    List<String> taskIds,
  );
  Future<List<DocEditor>> presence(
    String workspaceId,
    String docId,
    String state,
  );
  Future<({String title, String markdown})> exportMarkdown(
    String workspaceId,
    String docId,
  );
  Future<List<RelatedDoc>> forTask(
    String workspaceId,
    String projectId,
    String taskId,
  );
  Future<List<RelatedDoc>> linkTask(
    String workspaceId,
    String projectId,
    String taskId,
    String docId,
  );
  Future<List<RelatedDoc>> unlinkTask(
    String workspaceId,
    String projectId,
    String taskId,
    String docId,
  );
}

DocException mapDocError(Object error) {
  if (error is DocException) return error;
  if (error is GrpcError) {
    final raw = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(raw)?.group(1);
    final message = raw.replaceFirst(RegExp(r'^[A-Z][A-Z0-9_]*: '), '');
    return switch (error.code) {
      StatusCode.invalidArgument => DocException(
        DocFailure.invalid,
        detail: message,
      ),
      StatusCode.aborted => DocException(
        DocFailure.conflict,
        detail: message,
        conflict: DocConflict(
          version:
              int.tryParse(errorTrailer(error, 'x-error-version-bin')) ?? 0,
          blocksJson: errorTrailer(error, 'x-error-blocks-bin').isEmpty
              ? null
              : errorTrailer(error, 'x-error-blocks-bin'),
        ),
      ),
      StatusCode.alreadyExists => DocException(
        title == 'DOC_CYCLE' ? DocFailure.cycle : DocFailure.archived,
        detail: message,
      ),
      StatusCode.permissionDenied => const DocException(DocFailure.denied),
      StatusCode.notFound => const DocException(DocFailure.notFound),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const DocException(DocFailure.network),
      _ => const DocException(DocFailure.other),
    };
  }
  return const DocException(DocFailure.network);
}

DocNode nodeFromPb(pb.DocNode n) => DocNode(
  id: n.id,
  projectId: n.projectId,
  parentId: n.parentId,
  title: n.title,
  icon: n.icon,
  position: n.position,
  restricted: n.restricted,
  archived: n.archived,
  createdBy: n.createdBy,
  updatedAt: n.updatedAt,
);

TaskCardInfo cardFromPb(pb.TaskCard c) => TaskCardInfo(
  taskId: c.taskId,
  hidden: c.hidden,
  projectId: c.projectId,
  key: c.key,
  title: c.title,
  statusName: c.statusName,
  statusCategory: c.statusCategory,
  priority: c.priority,
);

List<DocEditor> _editors(Iterable<pb.Editor> e) => List.unmodifiable([
  for (final x in e) DocEditor(userId: x.userId, editing: x.editing),
]);

DocPage pageFromPb(pb.DocAnswer a) => DocPage(
  node: nodeFromPb(a.doc),
  version: a.version,
  blocks: parseBlocks(a.blocksJson),
  updatedBy: a.updatedBy,
  editing: _editors(a.editing),
  cards: List.unmodifiable(a.cards.map(cardFromPb)),
  canEdit: a.canEdit,
  canManage: a.canManage,
  accessUserIds: List.unmodifiable(a.accessUserIds),
);

List<RelatedDoc> _related(pb.RelatedDocs r) => List.unmodifiable([
  for (final d in r.docs) RelatedDoc(doc: nodeFromPb(d.doc), kind: d.kind),
]);

class GrpcDocsClient implements DocsClient {
  GrpcDocsClient(ClientChannelBase channel, this._session)
    : _client = pb.DocControllerClient(channel);

  final pb.DocControllerClient _client;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapDocError(e);
    }
  }

  @override
  Future<List<DocNode>> tree(
    String workspaceId, {
    String projectId = '',
    bool includeArchived = false,
  }) => _run(() async {
    final t = await _client.tree(
      pb.DocTreeRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        includeArchived: includeArchived,
      ),
      options: _options,
    );
    return List.unmodifiable(t.docs.map(nodeFromPb));
  });

  @override
  Future<DocPage> get(String workspaceId, String docId) => _run(
    () async => pageFromPb(
      await _client.get(
        pb.DocGetRequest(workspaceId: workspaceId, docId: docId),
        options: _options,
      ),
    ),
  );

  @override
  Future<DocPage> create(
    String workspaceId, {
    String projectId = '',
    String parentId = '',
    String title = '',
    String icon = '',
    List<DocBlock> blocks = const [],
  }) => _run(
    () async => pageFromPb(
      await _client.create(
        pb.DocCreateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          parentId: parentId,
          title: title,
          icon: icon,
          blocksJson: blocks.isEmpty ? '' : encodeBlocks(blocks),
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<DocPage> update(
    String workspaceId,
    String docId, {
    required int expectedVersion,
    required List<String> fields,
    String title = '',
    String icon = '',
    List<DocBlock> blocks = const [],
  }) => _run(
    () async => pageFromPb(
      await _client.update(
        pb.DocUpdateRequest(
          workspaceId: workspaceId,
          docId: docId,
          expectedVersion: expectedVersion,
          fields: fields,
          title: title,
          icon: icon,
          blocksJson: encodeBlocks(blocks),
          schemaVersion: docSchemaVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<DocPage> move(
    String workspaceId,
    String docId, {
    required String parentId,
    required int index,
  }) => _run(
    () async => pageFromPb(
      await _client.move(
        pb.DocMoveRequest(
          workspaceId: workspaceId,
          docId: docId,
          parentId: parentId,
          index: index,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<DocPage> archive(String workspaceId, String docId) => _run(
    () async => pageFromPb(
      await _client.archive(
        pb.DocArchiveRequest(workspaceId: workspaceId, docId: docId),
        options: _options,
      ),
    ),
  );

  @override
  Future<DocPage> restore(String workspaceId, String docId) => _run(
    () async => pageFromPb(
      await _client.restore(
        pb.DocRestoreRequest(workspaceId: workspaceId, docId: docId),
        options: _options,
      ),
    ),
  );

  @override
  Future<DocPage> setAccess(
    String workspaceId,
    String docId, {
    required bool restricted,
    required List<String> userIds,
  }) => _run(
    () async => pageFromPb(
      await _client.setAccess(
        pb.DocSetAccessRequest(
          workspaceId: workspaceId,
          docId: docId,
          restricted: restricted,
          userIds: userIds,
        ),
        options: _options,
      ),
    ),
  );

  RevisionInfo _rev(pb.RevisionInfo r) => RevisionInfo(
    id: r.id,
    version: r.version,
    title: r.title,
    authorId: r.authorId,
    at: r.at,
    savedAt: r.savedAt,
  );

  @override
  Future<List<RevisionInfo>> revisions(String workspaceId, String docId) =>
      _run(() async {
        final l = await _client.revisionList(
          pb.DocRevisionListRequest(workspaceId: workspaceId, docId: docId),
          options: _options,
        );
        return List.unmodifiable(l.revisions.map(_rev));
      });

  @override
  Future<List<DocBlock>> revision(
    String workspaceId,
    String docId,
    int revisionId,
  ) => _run(() async {
    final r = await _client.revisionGet(
      pb.DocRevisionGetRequest(
        workspaceId: workspaceId,
        docId: docId,
        revisionId: Int64(revisionId),
      ),
      options: _options,
    );
    return parseBlocks(r.blocksJson);
  });

  @override
  Future<DocPage> restoreRevision(
    String workspaceId,
    String docId,
    int revisionId, {
    required int expectedVersion,
  }) => _run(
    () async => pageFromPb(
      await _client.revisionRestore(
        pb.DocRevisionRestoreRequest(
          workspaceId: workspaceId,
          docId: docId,
          revisionId: Int64(revisionId),
          expectedVersion: expectedVersion,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<DocNode>> backlinks(String workspaceId, String docId) =>
      _run(() async {
        final t = await _client.backlinks(
          pb.DocBacklinksRequest(workspaceId: workspaceId, docId: docId),
          options: _options,
        );
        return List.unmodifiable(t.docs.map(nodeFromPb));
      });

  @override
  Future<List<TaskCardInfo>> taskCards(
    String workspaceId,
    List<String> taskIds,
  ) => _run(() async {
    final c = await _client.taskCards(
      pb.DocTaskCardsRequest(workspaceId: workspaceId, taskIds: taskIds),
      options: _options,
    );
    return List.unmodifiable(c.cards.map(cardFromPb));
  });

  @override
  Future<List<DocEditor>> presence(
    String workspaceId,
    String docId,
    String state,
  ) => _run(() async {
    final p = await _client.presence(
      pb.DocPresenceRequest(
        workspaceId: workspaceId,
        docId: docId,
        state: state,
      ),
      options: _options,
    );
    return _editors(p.editing);
  });

  @override
  Future<({String title, String markdown})> exportMarkdown(
    String workspaceId,
    String docId,
  ) => _run(() async {
    final m = await _client.exportMarkdown(
      pb.DocExportRequest(workspaceId: workspaceId, docId: docId),
      options: _options,
    );
    return (title: m.title, markdown: m.markdown);
  });

  @override
  Future<List<RelatedDoc>> forTask(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(
    () async => _related(
      await _client.forTask(
        pb.DocForTaskRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
        ),
        options: _options,
      ),
    ),
  );

  pb.DocLinkTaskRequest _link(String w, String p, String t, String d) =>
      pb.DocLinkTaskRequest(workspaceId: w, projectId: p, taskId: t, docId: d);

  @override
  Future<List<RelatedDoc>> linkTask(
    String workspaceId,
    String projectId,
    String taskId,
    String docId,
  ) => _run(
    () async => _related(
      await _client.linkTask(
        _link(workspaceId, projectId, taskId, docId),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<RelatedDoc>> unlinkTask(
    String workspaceId,
    String projectId,
    String taskId,
    String docId,
  ) => _run(
    () async => _related(
      await _client.unlinkTask(
        _link(workspaceId, projectId, taskId, docId),
        options: _options,
      ),
    ),
  );
}
