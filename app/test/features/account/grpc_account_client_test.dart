import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/account/account_client.dart'
    show AccountClient, GrpcAccountClient;
import 'package:taskforge/gen/infrastructure/accounts/grpc/accounts.pbgrpc.dart';
import 'package:taskforge/gen/infrastructure/oauth/rotation/grpc/oauth_rotation.pbgrpc.dart';

import '../../support/fake_jwt.dart';

/// Records the Authorization header of each call and answers with canned data.
class _Accounts extends AccountControllerServiceBase {
  final seenAuth = <String?>[];
  int rejectFirst =
      0; // answer UNAUTHENTICATED this many times before succeeding

  @override
  Future<Account> me(ServiceCall call, Empty request) async {
    seenAuth.add(call.clientMetadata?['authorization']);
    if (rejectFirst > 0) {
      rejectFirst--;
      throw GrpcError.unauthenticated('revoked');
    }
    return Account(
      email: 'zoe@example.com',
      profile: Profile(displayName: 'Zoe'),
    );
  }

  @override
  Future<Account> updateProfile(ServiceCall call, ProfileUpdate request) =>
      throw UnimplementedError();
}

class _Tokens extends RotationTokenRpcControllerServiceBase {
  @override
  Future<SessionList> sessions(ServiceCall call, Empty request) async =>
      SessionList(
        sessions: [
          // The server never says which session is the caller's; the app knows ('s1').
          Session(
            sessionId: 's1',
            userAgent: 'TaskForge macOS',
            ipAddress: '127.0.0.1',
          ),
          Session(sessionId: 's2', userAgent: 'Firefox', ipAddress: '10.0.0.2'),
        ],
      );

  @override
  Future<Message> endSession(ServiceCall call, EndSessionRequest request) =>
      throw UnimplementedError();

  @override
  Future<Credentials> refresh(ServiceCall call, RefreshRequest request) =>
      throw UnimplementedError();

  @override
  Future<Message> revoke(ServiceCall call, RevokeRequest request) =>
      throw UnimplementedError();
}

class _NoApi implements AuthApi {
  _NoApi({this.refreshResult});

  /// What `refresh` answers with; null makes it fail like a revoked session.
  AuthTokens? refreshResult;
  int refreshCalls = 0;

  @override
  Future<AuthTokens> signIn(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<AuthTokens> signUp(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<AuthTokens> refresh(String refreshToken, {String? requestId}) async {
    refreshCalls++;
    return refreshResult ??
        (throw const AuthApiException(
          status: 401,
          title: 'SESSION_ENDED',
          message: 'ended',
        ));
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> revokeSession(String accessToken, String sessionId) async {}
  @override
  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  ) => throw UnimplementedError();

  @override
  Future<String> requestPasswordReset(String email) =>
      throw UnimplementedError();

  @override
  Future<void> resetPassword({
    required String ticket,
    required String code,
    required String newPassword,
  }) => throw UnimplementedError();
}

void main() {
  late Server server;
  late ClientChannel channel;
  late _Accounts accounts;
  late AccountClient client;
  late AuthSession session;
  late _NoApi api;

  setUp(() async {
    accounts = _Accounts();
    server = Server.create(services: [accounts, _Tokens()]);
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
        sessionId: 's1',
      ),
    );
    api = _NoApi(
      refreshResult: AuthTokens(
        accessToken: fakeJwt(DateTime.now().add(const Duration(minutes: 15))),
        refreshToken: 'r2',
        sessionId: 's1',
      ),
    );
    session = AuthSession(api: api, store: store);
    await session.restore();
    client = GrpcAccountClient(channel, session);
  });

  tearDown(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  test(
    'me() sends the access token as a bearer header and maps the account',
    () async {
      final account = await client.me();

      expect(account.email, 'zoe@example.com');
      expect(account.displayName, 'Zoe');
      expect(accounts.seenAuth.single, startsWith('Bearer '));
    },
  );

  test(
    'sessions() marks the one matching the stored session id as current',
    () async {
      final sessions = await client.sessions();

      expect(sessions.map((s) => s.id), ['s1', 's2']);
      expect(sessions.where((s) => s.current).map((s) => s.userAgent), [
        'TaskForge macOS',
      ]);
    },
  );

  test(
    'a token the server rejects is refreshed once and the call retried',
    () async {
      accounts.rejectFirst = 1;

      final account = await client.me();

      expect(account.email, 'zoe@example.com');
      expect(api.refreshCalls, 1);
      expect(accounts.seenAuth, hasLength(2));
    },
  );

  test('when the refresh is refused too, the session ends and the error is surfaced', () async {
    accounts.rejectFirst = 1;
    api.refreshResult = null; // the session was revoked elsewhere

    await expectLater(client.me(), throwsA(isA<GrpcError>()));

    expect(session.status, AuthStatus.signedOut);
  });
}
