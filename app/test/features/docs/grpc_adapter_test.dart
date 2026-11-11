import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/docs/data/docs_client.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/gen/infrastructure/docs/grpc/wikidocs.pbgrpc.dart'
    as pb;

import '../workspaces/fakes.dart';

pb.DocNode _node(String id) =>
    pb.DocNode(id: id, title: 'T$id', parentId: 'p', restricted: true);

class _Server extends pb.DocControllerServiceBase {
  final seen = <String, Object>{};
  GrpcError? fail;

  T _a<T>(String name, Object r, T answer) {
    seen[name] = r;
    final f = fail;
    if (f != null) throw f;
    return answer;
  }

  @override
  Future<pb.DocAnswer> archive(ServiceCall c, pb.DocArchiveRequest r) async =>
      _a('archive', r, pb.DocAnswer(doc: _node(r.docId)));
  @override
  Future<pb.DocTree> backlinks(ServiceCall c, pb.DocBacklinksRequest r) async =>
      _a('backlinks', r, pb.DocTree(docs: [_node('b1')]));
  @override
  Future<pb.DocAnswer> create(ServiceCall c, pb.DocCreateRequest r) async =>
      _a('create', r, pb.DocAnswer(doc: _node('new'), version: 1));
  @override
  Future<pb.DocMarkdown> exportMarkdown(
    ServiceCall c,
    pb.DocExportRequest r,
  ) async => _a('export', r, pb.DocMarkdown(title: 'T', markdown: '# T'));
  @override
  Future<pb.RelatedDocs> linkTask(
    ServiceCall c,
    pb.DocLinkTaskRequest r,
  ) async => _a(
    'link',
    r,
    pb.RelatedDocs(
      docs: [pb.RelatedDoc(doc: _node('a'), kind: 'link')],
    ),
  );
  @override
  Future<pb.DocAnswer> restore(ServiceCall c, pb.DocRestoreRequest r) async =>
      _a('restore', r, pb.DocAnswer(doc: _node(r.docId)));
  @override
  Future<pb.DocRevisionList> revisionList(
    ServiceCall c,
    pb.DocRevisionListRequest r,
  ) async => _a(
    'revList',
    r,
    pb.DocRevisionList(
      revisions: [pb.RevisionInfo(id: 3, version: 2, title: 'Old')],
    ),
  );
  @override
  Future<pb.RelatedDocs> unlinkTask(
    ServiceCall c,
    pb.DocLinkTaskRequest r,
  ) async => _a('unlink', r, pb.RelatedDocs());

  @override
  Future<pb.DocTree> tree(ServiceCall call, pb.DocTreeRequest r) async =>
      _a('tree', r, pb.DocTree(docs: [_node('a'), _node('b')]));

  @override
  Future<pb.DocAnswer> get(ServiceCall call, pb.DocGetRequest r) async => _a(
    'get',
    r,
    pb.DocAnswer(
      doc: _node(r.docId),
      version: 4,
      blocksJson: '[{"id":"x","type":"whiteboard","k":1}]',
      editing: [pb.Editor(userId: 'u2', editing: true)],
      cards: [pb.TaskCard(taskId: 't', hidden: true)],
      canEdit: true,
      accessUserIds: ['u1'],
    ),
  );

  @override
  Future<pb.DocAnswer> update(ServiceCall call, pb.DocUpdateRequest r) async =>
      _a('update', r, pb.DocAnswer(doc: _node(r.docId), version: 5));

  @override
  Future<pb.DocAnswer> move(ServiceCall call, pb.DocMoveRequest r) async =>
      _a('move', r, pb.DocAnswer(doc: _node(r.docId)));

  @override
  Future<pb.DocAnswer> setAccess(
    ServiceCall call,
    pb.DocSetAccessRequest r,
  ) async => _a('access', r, pb.DocAnswer(doc: _node(r.docId)));

  @override
  Future<pb.DocRevisionAnswer> revisionGet(
    ServiceCall call,
    pb.DocRevisionGetRequest r,
  ) async => _a('revGet', r, pb.DocRevisionAnswer(blocksJson: '[]'));

  @override
  Future<pb.DocAnswer> revisionRestore(
    ServiceCall call,
    pb.DocRevisionRestoreRequest r,
  ) async => _a('revRestore', r, pb.DocAnswer(doc: _node(r.docId), version: 6));

  @override
  Future<pb.DocPresence> presence(
    ServiceCall call,
    pb.DocPresenceRequest r,
  ) async => _a(
    'presence',
    r,
    pb.DocPresence(editing: [pb.Editor(userId: 'u9', editing: true)]),
  );

  @override
  Future<pb.DocTaskCards> taskCards(
    ServiceCall call,
    pb.DocTaskCardsRequest r,
  ) async => _a(
    'cards',
    r,
    pb.DocTaskCards(
      cards: [
        pb.TaskCard(taskId: 't1', key: 'W-1', title: 'Fix', statusName: 'Done'),
      ],
    ),
  );

  @override
  Future<pb.RelatedDocs> forTask(
    ServiceCall call,
    pb.DocForTaskRequest r,
  ) async => _a(
    'forTask',
    r,
    pb.RelatedDocs(
      docs: [pb.RelatedDoc(doc: _node('a'), kind: 'link')],
    ),
  );
}

void main() {
  late Server server;
  late ClientChannel channel;
  late GrpcDocsClient client;
  final docs = _Server();

  setUpAll(() async {
    server = Server.create(services: [docs]);
    await server.serve(address: '127.0.0.1', port: 0);
    channel = ClientChannel(
      '127.0.0.1',
      port: server.port!,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    final store = MemoryTokenStore();
    final payload = base64Url
        .encode(utf8.encode('{"exp":4102444800}'))
        .replaceAll('=', '');
    await store.write(
      AuthTokens(
        accessToken: 'e30.$payload.sig',
        refreshToken: 'r',
        sessionId: 's',
      ),
    );
    final session = AuthSession(api: MockAuthApi(), store: store);
    await session.restore();
    client = GrpcDocsClient(channel, session);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  tearDown(() => docs.fail = null);

  test('the tree carries scope and maps nodes', () async {
    final t = await client.tree('w1', projectId: 'p1', includeArchived: true);

    final r = docs.seen['tree']! as pb.DocTreeRequest;
    expect((r.workspaceId, r.projectId, r.includeArchived), ('w1', 'p1', true));
    expect(t.map((d) => d.id), ['a', 'b']);
    expect((t.first.parentId, t.first.restricted), ('p', true));
  });

  test('a page keeps unknown blocks and says what the caller may do', () async {
    final p = await client.get('w1', 'a');

    expect(p.version, 4);
    expect(p.blocks.single.isKnown, isFalse);
    expect(p.blocks.single.json['k'], 1);
    expect((p.canEdit, p.canManage), (true, false));
    expect(p.editing.single.userId, 'u2');
    expect(p.cards.single.hidden, isTrue);
    expect(p.accessUserIds, ['u1']);
  });

  test('an update names fields, version and schema version', () async {
    await client.update(
      'w1',
      'a',
      expectedVersion: 4,
      fields: ['blocks'],
      blocks: [DocBlock.create('divider', id: 'd')],
    );

    final r = docs.seen['update']! as pb.DocUpdateRequest;
    expect(r.fields.toList(), ['blocks']);
    expect((r.expectedVersion, r.schemaVersion), (4, docSchemaVersion));
    expect(jsonDecode(r.blocksJson), [
      {'id': 'd', 'type': 'divider'},
    ]);
  });

  test(
    'ABORTED becomes a conflict with the server version and blocks',
    () async {
      docs.fail = GrpcError.custom(
        StatusCode.aborted,
        'VERSION_CONFLICT: changed',
        null,
        null,
        {'x-error-version-bin': '9', 'x-error-blocks-bin': '[]'},
      );

      await expectLater(
        client.update('w1', 'a', expectedVersion: 1, fields: ['title']),
        throwsA(
          isA<DocException>()
              .having((e) => e.failure, 'failure', DocFailure.conflict)
              .having((e) => e.conflict?.version, 'version', 9)
              .having((e) => e.conflict?.blocksJson, 'blocks', '[]'),
        ),
      );
    },
  );

  test('a conflict without blocks says they were left out', () async {
    docs.fail = GrpcError.custom(StatusCode.aborted, 'x', null, null, {
      'x-error-version-bin': '3',
    });

    final e = await client
        .update('w1', 'a', expectedVersion: 1, fields: [])
        .then<DocException?>(
          (_) => null,
          onError: (Object e) => e as DocException,
        );

    expect(e?.conflict?.blocksJson, isNull);
  });

  test('other statuses map to failures', () async {
    Future<DocFailure> failWith(GrpcError e) async {
      docs.fail = e;
      try {
        await client.get('w1', 'a');
      } on DocException catch (x) {
        return x.failure;
      }
      throw StateError('no failure');
    }

    expect(await failWith(GrpcError.notFound('x')), DocFailure.notFound);
    expect(
      await failWith(GrpcError.alreadyExists('DOC_CYCLE: loop')),
      DocFailure.cycle,
    );
    expect(
      await failWith(GrpcError.alreadyExists('DOC_ARCHIVED: gone')),
      DocFailure.archived,
    );
    expect(
      await failWith(GrpcError.invalidArgument('DOC_INVALID: bad')),
      DocFailure.invalid,
    );
    expect(await failWith(GrpcError.unavailable('x')), DocFailure.network);
  });

  test('move, access, revisions, presence, cards and related docs', () async {
    await client.move('w1', 'a', parentId: 'p', index: 2);
    await client.setAccess('w1', 'a', restricted: true, userIds: ['u1']);
    await client.revision('w1', 'a', 7);
    await client.restoreRevision('w1', 'a', 7, expectedVersion: 4);
    final roster = await client.presence('w1', 'a', 'editing');
    final cards = await client.taskCards('w1', ['t1']);
    final rel = await client.forTask('w1', 'p1', 't1');

    final m = docs.seen['move']! as pb.DocMoveRequest;
    expect((m.parentId, m.index), ('p', 2));
    final a = docs.seen['access']! as pb.DocSetAccessRequest;
    expect(a.restricted, true);
    expect(a.userIds.toList(), ['u1']);
    expect(
      (docs.seen['revGet']! as pb.DocRevisionGetRequest).revisionId,
      Int64(7),
    );
    final rr = docs.seen['revRestore']! as pb.DocRevisionRestoreRequest;
    expect((rr.revisionId, rr.expectedVersion), (Int64(7), 4));
    expect((docs.seen['presence']! as pb.DocPresenceRequest).state, 'editing');
    expect(roster.single.userId, 'u9');
    expect((cards.single.key, cards.single.statusName), ('W-1', 'Done'));
    expect((rel.single.kind, rel.single.doc.id), ('link', 'a'));
  });

  test('create, archive, restore, revisions, backlinks and export', () async {
    final made = await client.create(
      'w1',
      projectId: 'p1',
      parentId: 'a',
      title: 'New',
      icon: 'x',
      blocks: [DocBlock.create('divider', id: 'd')],
    );
    await client.create('w1');
    await client.archive('w1', 'a');
    await client.restore('w1', 'a');
    final revs = await client.revisions('w1', 'a');
    final back = await client.backlinks('w1', 'a');
    final md = await client.exportMarkdown('w1', 'a');

    expect(made.node.id, 'new');
    final c = docs.seen['create']! as pb.DocCreateRequest;
    expect((c.title, c.blocksJson), ('', ''));
    expect(docs.seen['archive'], isA<pb.DocArchiveRequest>());
    expect(docs.seen['restore'], isA<pb.DocRestoreRequest>());
    expect((revs.single.id, revs.single.version), (3, 2));
    expect(back.single.id, 'b1');
    expect(md.markdown, '# T');
  });

  test('linking and unlinking a task answer the related docs', () async {
    final linked = await client.linkTask('w1', 'p1', 't1', 'a');
    final none = await client.unlinkTask('w1', 'p1', 't1', 'a');

    expect(linked.single.doc.id, 'a');
    expect(none, isEmpty);
    final l = docs.seen['link']! as pb.DocLinkTaskRequest;
    expect((l.projectId, l.taskId, l.docId), ('p1', 't1', 'a'));
  });

  test('denied, other statuses and non-grpc errors are mapped', () async {
    Future<DocFailure> failWith(GrpcError e) async {
      docs.fail = e;
      try {
        await client.archive('w1', 'a');
      } on DocException catch (x) {
        return x.failure;
      }
      throw StateError('no failure');
    }

    expect(await failWith(GrpcError.permissionDenied('x')), DocFailure.denied);
    expect(await failWith(GrpcError.internal('x')), DocFailure.other);
    expect(await failWith(GrpcError.deadlineExceeded('x')), DocFailure.network);
    expect(mapDocError(StateError('socket')).failure, DocFailure.network);
    const own = DocException(DocFailure.cycle);
    expect(identical(mapDocError(own), own), isTrue);
  });
}
