import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:http/testing.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/maintenance.dart';
import 'package:taskforge/features/auth/validators.dart';
import 'package:taskforge/features/workspaces/data/workspace_client.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

import 'package:http/http.dart' as http;

void main() {
  group('isMaintenance', () {
    test('recognises gRPC UNAVAILABLE that says maintenance', () {
      expect(
        isMaintenance(GrpcError.unavailable('Down for MAINTENANCE')),
        isTrue,
      );
    });

    test('does not mistake an unreachable server for maintenance', () {
      expect(
        isMaintenance(GrpcError.unavailable('Connection refused')),
        isFalse,
      );
      expect(isMaintenance(GrpcError.internal('maintenance')), isFalse);
      expect(isMaintenance(StateError('x')), isFalse);
    });

    test('recognises the REST 503 flag', () {
      expect(
        isMaintenance(
          const AuthApiException(
            status: 503,
            title: 'X',
            message: 'x',
            maintenance: true,
          ),
        ),
        isTrue,
      );
      expect(
        isMaintenance(
          const AuthApiException(status: 503, title: 'X', message: 'x'),
        ),
        isFalse,
      );
    });
  });

  group('the REST auth path', () {
    http.Response answer(int status, String body) => http.Response(
      body,
      status,
      headers: {'content-type': 'application/json'},
    );

    Future<Object?> signInAgainst(http.Response response) async {
      final api = HttpAuthApi(
        'http://api.test',
        client: MockClient((_) async => response),
      );
      try {
        await api.signIn('a@b.c', 'x');
      } on Object catch (e) {
        return e;
      }
      return null;
    }

    test('503 with maintenance true is flagged', () async {
      final e = await signInAgainst(answer(503, '{"maintenance": true}'));
      expect(e, isA<AuthApiException>());
      expect((e as AuthApiException).maintenance, isTrue);
      expect(isMaintenance(e), isTrue);
    });

    test('a 503 without the flag is not maintenance', () async {
      final e = await signInAgainst(answer(503, '{"title": "BUSY"}'));
      expect((e as AuthApiException).maintenance, isFalse);
    });

    test('sign-in explains maintenance in plain words', () {
      const e = AuthApiException(
        status: 503,
        title: 'X',
        message: 'x',
        maintenance: true,
      );
      expect(authErrorMessage(e), contains('updated'));
    });
  });

  test('workspace errors map both signals to the maintenance failure', () {
    expect(
      mapWorkspaceError(GrpcError.unavailable('maintenance')).failure,
      WorkspaceFailure.maintenance,
    );
    expect(
      mapWorkspaceError(
        const AuthApiException(
          status: 503,
          title: 'X',
          message: 'x',
          maintenance: true,
        ),
      ).failure,
      WorkspaceFailure.maintenance,
    );
    expect(
      mapWorkspaceError(GrpcError.unavailable('no route')).failure,
      WorkspaceFailure.network,
    );
  });
}
