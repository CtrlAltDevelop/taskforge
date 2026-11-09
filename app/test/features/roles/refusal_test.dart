import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/gen/infrastructure/workspaces/grpc/workspaces.pbgrpc.dart'
    as pb;

import '../workspaces/fakes.dart';

/// Real gRPC server: the caller starts as an Admin and can be demoted.
class _Server extends pb.RoleControllerServiceBase {
  bool demoted = false;
  int checks = 0;

  @override
  Future<pb.Role> update(ServiceCall call, pb.RoleUpdateRequest request) async {
    if (demoted) {
      throw const GrpcError.permissionDenied(
        'PERMISSION_DENIED_REASON: missing: role.manage; your role: Viewer',
      );
    }
    return pb.Role(id: request.id, name: request.name, version: 2);
  }

  @override
  Future<pb.Role> create(ServiceCall call, pb.RoleCreateRequest request) =>
      throw UnimplementedError();

  @override
  Future<pb.RoleEmpty> delete(ServiceCall call, pb.RoleDeleteRequest request) =>
      throw UnimplementedError();

  @override
  Future<pb.RoleList> list(ServiceCall call, pb.RoleListRequest request) =>
      throw UnimplementedError();
}

class _Checks extends pb.PermissionControllerServiceBase {
  _Checks(this.server);

  final _Server server;

  @override
  Future<pb.PermissionCheckResponse> check(
    ServiceCall call,
    pb.PermissionCheckRequest request,
  ) async {
    server.checks++;
    return pb.PermissionCheckResponse(
      roleName: server.demoted ? 'Viewer' : 'Admin',
      answers: [
        for (final k in request.keys)
          pb.PermissionAnswer(
            key: k,
            allowed: !server.demoted || k == Perm.workspaceView,
          ),
      ],
    );
  }
}

/// Unexpired, so the session sends it without refreshing.
final _jwt =
    'h.${base64Url.encode(utf8.encode('{"exp":4102444800}')).replaceAll('=', '')}.s';

void main() {
  test(
    'a refused update re-reads permissions so the gate corrects itself',
    () async {
      final backend = _Server();
      final server = Server.create(services: [backend, _Checks(backend)]);
      await server.serve(address: 'localhost', port: 0);
      final channel = ClientChannel(
        'localhost',
        port: server.port!,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );
      final store = MemoryTokenStore();
      await store.write(
        AuthTokens(accessToken: _jwt, refreshToken: 'r', sessionId: 's'),
      );
      final session = AuthSession(api: MockAuthApi(), store: store);
      await session.restore();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWithValue(session),
          grpcChannelProvider.overrideWithValue(channel),
          workspaceScopeProvider.overrideWithValue('w1'),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await channel.shutdown();
        await server.shutdown();
      });

      // The gate still believes the caller may manage roles.
      await container.read(permissionsProvider.future);
      expect(
        container.read(permissionSetProvider).can(Perm.roleManage),
        isTrue,
      );

      backend.demoted = true;
      final before = backend.checks;
      final attempt = container
          .read(rolesClientProvider)
          .update(
            'w1',
            'r1',
            name: 'Support',
            permissions: {},
            expectedVersion: 1,
          );
      await expectLater(
        attempt,
        throwsA(
          isA<RoleException>()
              .having((e) => e.failure, 'failure', RoleFailure.denied)
              .having(
                (e) => roleErrorMessage(e),
                'message',
                'You need permission "role.manage" — your role is Viewer',
              ),
        ),
      );
      await container.read(permissionsProvider.future);

      expect(backend.checks, greaterThan(before));
      expect(
        container.read(permissionSetProvider).can(Perm.roleManage),
        isFalse,
      );
    },
  );
}
