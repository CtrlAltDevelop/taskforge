import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/workspaces/data/workspace_client.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/gen/infrastructure/workspaces/grpc/workspaces.pbgrpc.dart'
    as pb;

import '../../support/fake_jwt.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _Service extends pb.WorkspaceControllerServiceBase {
  final metadata = <Map<String, String>?>[];
  pb.WorkspaceUpdateRequest? lastUpdate;
  GrpcError? failWith;

  void _record(ServiceCall call) {
    metadata.add(call.clientMetadata);
    if (failWith != null) throw failWith!;
  }

  @override
  Future<pb.WorkspaceList> list(ServiceCall call, Empty request) async {
    _record(call);
    return pb.WorkspaceList(
      workspaces: [
        pb.Workspace(
          id: 'w1',
          name: 'Acme',
          slug: 'acme',
          version: 3,
          isOwner: true,
        ),
      ],
    );
  }

  @override
  Future<pb.WorkspaceList> listDeleted(ServiceCall call, Empty request) async {
    _record(call);
    return pb.WorkspaceList(
      workspaces: [pb.Workspace(id: 'd1', name: 'Gone', slug: 'gone')],
    );
  }

  @override
  Future<pb.Workspace> update(
    ServiceCall call,
    pb.WorkspaceUpdateRequest request,
  ) async {
    _record(call);
    lastUpdate = request;
    return pb.Workspace(
      id: request.id,
      name: 'Renamed',
      slug: 'acme',
      version: 4,
    );
  }

  @override
  Future<pb.Workspace> create(
    ServiceCall call,
    pb.WorkspaceCreateRequest request,
  ) async {
    _record(call);
    return pb.Workspace();
  }

  @override
  Future<pb.Workspace> delete(
    ServiceCall call,
    pb.WorkspaceDeleteRequest request,
  ) => throw UnimplementedError();

  @override
  Future<pb.Workspace> restore(
    ServiceCall call,
    pb.WorkspaceRestoreRequest request,
  ) => throw UnimplementedError();
}

void main() {
  late Server server;
  late ClientChannel channel;
  late _Service service;
  late AuthSession session;

  setUp(() async {
    service = _Service();
    server = Server.create(services: [service]);
    await server.serve(address: InternetAddress.loopbackIPv4, port: 0);
    channel = ClientChannel(
      '127.0.0.1',
      port: server.port ?? 0,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    final store = MemoryTokenStore();
    await store.write(
      AuthTokens(
        accessToken: fakeJwt(DateTime.now().add(const Duration(minutes: 10))),
        refreshToken: 'r',
        sessionId: 's',
      ),
    );
    session = AuthSession(api: _MockAuthApi(), store: store);
    await session.restore();
  });

  tearDown(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  GrpcWorkspaceClient clientWith({http.Client? httpClient, String? selected}) =>
      GrpcWorkspaceClient(
        channel,
        session,
        restUrl: 'http://api.test',
        selectedWorkspace: () => selected,
        httpClient: httpClient,
      );

  test('list maps workspaces and sends the bearer token', () async {
    final list = await clientWith().list();

    expect(
      list.single,
      const Workspace(
        id: 'w1',
        name: 'Acme',
        slug: 'acme',
        version: 3,
        isOwner: true,
      ),
    );
    expect(service.metadata.single!['authorization'], startsWith('Bearer '));
  });

  test(
    'update sends only the fields that changed, with the expected version',
    () async {
      await clientWith().update('w1', expectedVersion: 3, name: 'Renamed');

      final sent = service.lastUpdate!;
      expect(sent.expectedVersion, 3);
      expect(sent.hasName(), isTrue);
      expect(sent.hasSlug(), isFalse);
    },
  );

  for (final (code, failure) in [
    (StatusCode.alreadyExists, WorkspaceFailure.slugTaken),
    (StatusCode.permissionDenied, WorkspaceFailure.forbidden),
    (StatusCode.aborted, WorkspaceFailure.stale),
    (StatusCode.invalidArgument, WorkspaceFailure.invalid),
    (StatusCode.notFound, WorkspaceFailure.notFound),
  ]) {
    test('gRPC $code becomes $failure', () async {
      service.failWith = GrpcError.custom(code, 'nope');

      await expectLater(
        clientWith().create(name: 'A', slug: 'abc'),
        throwsA(
          isA<WorkspaceException>().having(
            (e) => e.failure,
            'failure',
            failure,
          ),
        ),
      );
    });
  }

  test('listDeleted maps the recently deleted workspaces', () async {
    final list = await clientWith().listDeleted();

    expect(list.single.id, 'd1');
  });

  test('invalid-argument shows the message without its server title', () async {
    service.failWith = GrpcError.custom(
      StatusCode.invalidArgument,
      'UPLOAD_INVALID: The logo is too big.',
    );

    await expectLater(
      clientWith().create(name: 'A', slug: 'abc'),
      throwsA(
        isA<WorkspaceException>().having(
          (e) => e.detail,
          'detail',
          'The logo is too big.',
        ),
      ),
    );
  });

  test('scoped call options add x-workspace beside the token', () async {
    final options = scopedCallOptions(session, () => 'w9');
    final metadata = <String, String>{};
    for (final provider in options.metadataProviders) {
      await provider(metadata, 'uri');
    }

    expect(metadata[workspaceMetadataKey], 'w9');
    expect(metadata['authorization'], startsWith('Bearer '));
    expect(scopedHeaders('t', 'w9'), {
      'Authorization': 'Bearer t',
      'X-Workspace': 'w9',
    });
    expect(scopedHeaders('t', null).containsKey('X-Workspace'), isFalse);
  });

  group('uploadLogo', () {
    const old = Workspace(
      id: 'w1',
      name: 'Acme',
      slug: 'acme',
      version: 3,
      isOwner: true,
    );

    test(
      'posts multipart with the bearer, workspace header and version',
      () async {
        late http.BaseRequest seen;
        final httpClient = MockClient.streaming((request, body) async {
          seen = request;
          final reply = jsonEncode({
            'data': {
              'id': 'w1',
              'name': 'Acme',
              'slug': 'acme',
              'logo': '/media/l.png',
              'version': 4,
            },
          });
          return http.StreamedResponse(Stream.value(utf8.encode(reply)), 200);
        });

        final updated = await clientWith(
          httpClient: httpClient,
          selected: 'w1',
        ).uploadLogo(old, bytes: [1, 2, 3], filename: 'l.png');

        expect(
          seen.url.toString(),
          'http://api.test/api/v1/workspaces/w1/logo',
        );
        expect(seen.headers['Authorization'], startsWith('Bearer '));
        expect(seen.headers['X-Workspace'], 'w1');
        expect(updated.logo, '/media/l.png');
        expect(updated.version, 4);
        expect(updated.isOwner, isTrue);
      },
    );

    test('409 is a stale version', () async {
      final httpClient = MockClient.streaming(
        (_, _) async => http.StreamedResponse(const Stream.empty(), 409),
      );

      await expectLater(
        clientWith(httpClient: httpClient)
            .uploadLogo(old, bytes: [1], filename: 'l.png'),
        throwsA(
          isA<WorkspaceException>().having(
            (e) => e.failure,
            'failure',
            WorkspaceFailure.stale,
          ),
        ),
      );
    });
  });
}
