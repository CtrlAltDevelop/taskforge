import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/search/data/search_client.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/gen/infrastructure/search/grpc/search.pbgrpc.dart'
    as pb;

import '../workspaces/fakes.dart';

class _Server extends pb.SearchControllerServiceBase {
  final seen = <String, Object>{};
  GrpcError? fail;

  @override
  Future<pb.SearchResults> query(
    ServiceCall call,
    pb.SearchQueryRequest request,
  ) async {
    seen['query'] = request;
    final f = fail;
    if (f != null) throw f;
    return pb.SearchResults(
      tasks: [
        for (var i = 0; i < 2; i++)
          pb.Hit(
            kind: 'task',
            id: 't$i',
            title: 'Login $i',
            taskId: 't$i',
            projectId: 'p1',
            key: 'WEB-$i',
            titleMarks: [pb.Span(start: 0, end: 5)],
          ),
      ],
      comments: [pb.Hit(kind: 'comment', id: 'c1', title: 'Login 0')],
      jump: request.text == 'web-1'
          ? pb.Hit(kind: 'task', id: 't1', projectId: 'p1', taskId: 't1')
          : null,
      nextCursor: 'c2',
    );
  }

  @override
  Future<pb.SearchRemembered> remember(
    ServiceCall call,
    pb.SearchRememberRequest request,
  ) async {
    seen['remember'] = request;
    return pb.SearchRemembered(ok: true);
  }

  @override
  Future<pb.SearchRecent> recent(
    ServiceCall call,
    pb.SearchRecentRequest request,
  ) async => pb.SearchRecent(queries: ['login', 'invoice']);
}

void main() {
  late Server server;
  late ClientChannel channel;
  late GrpcSearchClient client;
  final search = _Server();

  setUpAll(() async {
    server = Server.create(services: [search]);
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
    client = GrpcSearchClient(channel, session);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  test('a query sends text, kinds and cursor and reads the groups', () async {
    final found = await client.query(
      'w1',
      'login',
      types: [SearchKind.task],
      cursor: 'c1',
      pageSize: 2,
    );

    final asked = search.seen['query']! as pb.SearchQueryRequest;
    expect(
      (asked.workspaceId, asked.text, asked.cursor),
      ('w1', 'login', 'c1'),
    );
    expect(asked.types.toList(), ['task']);
    expect(found.of(SearchKind.task).map((h) => h.key), ['WEB-0', 'WEB-1']);
    expect(found.of(SearchKind.task).first.titleMarks.single.end, 5);
    expect(found.of(SearchKind.comment).single.id, 'c1');
    expect(found.jump, isNull);
    // Only the kind that filled its page has more; the comment group did not.
    expect(found.cursors, {SearchKind.task: 'c2'});
  });

  test('an id comes back as the jump', () async {
    expect((await client.query('w1', 'web-1')).jump?.id, 't1');
  });

  test('recent searches and remembering go through', () async {
    expect(await client.recent('w1'), ['login', 'invoice']);
    await client.remember('w1', 'login');
    expect(
      (search.seen['remember']! as pb.SearchRememberRequest).text,
      'login',
    );
  });

  test('a refusal is mapped', () async {
    search.fail = GrpcError.resourceExhausted('RATE_LIMITED: slow down');
    addTearDown(() => search.fail = null);

    expect(
      client.query('w1', 'x'),
      throwsA(
        isA<SearchException>().having(
          (e) => e.failure,
          'failure',
          SearchFailure.rateLimited,
        ),
      ),
    );
  });
}
