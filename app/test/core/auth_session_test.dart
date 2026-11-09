import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';

String _jwt(DateTime expiry) {
  String part(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part({'exp': expiry.millisecondsSinceEpoch ~/ 1000})}.sig';
}

AuthTokens _tokens({required String refresh, required Duration expiresIn}) =>
    AuthTokens(
      accessToken: _jwt(DateTime.now().add(expiresIn)),
      refreshToken: refresh,
      sessionId: 's1',
    );

class _FakeApi implements AuthApi {
  _FakeApi({this.onRefresh});

  Future<AuthTokens> Function(String refreshToken)? onRefresh;
  int refreshCalls = 0;
  final requestIds = <String?>[];
  final loggedOut = <String>[];
  final changes = <(String, String)>[];

  @override
  Future<AuthTokens> signIn(String email, String password) async =>
      _tokens(refresh: 'r1', expiresIn: const Duration(minutes: 15));

  @override
  Future<AuthTokens> signUp(String email, String password) async =>
      _tokens(refresh: 'r1', expiresIn: const Duration(minutes: 15));

  @override
  Future<AuthTokens> refresh(String refreshToken, {String? requestId}) {
    refreshCalls++;
    requestIds.add(requestId);
    return onRefresh!(refreshToken);
  }

  @override
  Future<void> logout(String refreshToken) async => loggedOut.add(refreshToken);

  @override
  Future<void> revokeSession(String accessToken, String sessionId) async {}
  @override
  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  ) async {
    changes.add((currentPassword, newPassword));
  }

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
  late MemoryTokenStore store;

  setUp(() => store = MemoryTokenStore());

  test('signing in stores the tokens and signs the user in', () async {
    final session = AuthSession(api: _FakeApi(), store: store);

    await session.signIn('zoe@example.com', 'Xq7-mnbvcz');

    expect(session.status, AuthStatus.signedIn);
    expect((await store.read())?.refreshToken, 'r1');
  });

  test(
    'restore signs in when tokens are stored and out when they are not',
    () async {
      final session = AuthSession(api: _FakeApi(), store: store);
      await session.restore();
      expect(session.status, AuthStatus.signedOut);

      await store.write(
        _tokens(refresh: 'r1', expiresIn: const Duration(minutes: 5)),
      );
      await session.restore();
      expect(session.status, AuthStatus.signedIn);
    },
  );

  test('a still-valid access token is returned without refreshing', () async {
    final api = _FakeApi();
    final fresh = _tokens(
      refresh: 'r1',
      expiresIn: const Duration(minutes: 10),
    );
    await store.write(fresh);
    final session = AuthSession(api: api, store: store);
    await session.restore();

    expect(await session.accessToken(), fresh.accessToken);
    expect(api.refreshCalls, 0);
  });

  test('an expiring token is refreshed once even when many calls ask at the same time', () async {
    final gate = Completer<AuthTokens>();
    final api = _FakeApi(onRefresh: (_) => gate.future);
    await store.write(
      _tokens(refresh: 'r1', expiresIn: const Duration(seconds: 5)),
    );
    final session = AuthSession(api: api, store: store);
    await session.restore();

    final calls = [
      session.accessToken(),
      session.accessToken(),
      session.accessToken(),
    ];
    final renewed = _tokens(
      refresh: 'r2',
      expiresIn: const Duration(minutes: 15),
    );
    gate.complete(renewed);

    expect(await Future.wait(calls), everyElement(renewed.accessToken));
    expect(api.refreshCalls, 1);
    expect((await store.read())?.refreshToken, 'r2');
  });

  test(
    'a refresh race adopts the newer tokens another window already stored',
    () async {
      final newer = _tokens(
        refresh: 'r2',
        expiresIn: const Duration(minutes: 15),
      );
      final api = _FakeApi(
        onRefresh: (sent) async {
          await store.write(
            newer,
          ); // the other window won the race and stored its result
          throw const AuthApiException(
            status: 409,
            title: 'REFRESH_RACE',
            message: 'just spent',
          );
        },
      );
      await store.write(
        _tokens(refresh: 'r1', expiresIn: const Duration(seconds: 5)),
      );
      final session = AuthSession(api: api, store: store);
      await session.restore();

      expect(await session.accessToken(), newer.accessToken);
      expect(session.status, AuthStatus.signedIn);
    },
  );

  test(
    'a reused or revoked refresh token signs the user out and clears storage',
    () async {
      final api = _FakeApi(
        onRefresh: (_) async => throw const AuthApiException(
          status: 401,
          title: 'TOKEN_REUSED',
          message: 'ended',
        ),
      );
      await store.write(
        _tokens(refresh: 'r1', expiresIn: const Duration(seconds: 5)),
      );
      final session = AuthSession(api: api, store: store);
      await session.restore();

      expect(await session.accessToken(), isNull);
      expect(session.status, AuthStatus.signedOut);
      expect(await store.read(), isNull);
    },
  );

  test(
    'losing the network during a refresh does not sign the user out',
    () async {
      final api = _FakeApi(
        onRefresh: (_) async => throw const NetworkUnavailable('offline'),
      );
      await store.write(
        _tokens(refresh: 'r1', expiresIn: const Duration(seconds: 5)),
      );
      final session = AuthSession(api: api, store: store);
      await session.restore();

      await expectLater(
        session.accessToken(),
        throwsA(isA<NetworkUnavailable>()),
      );
      expect(session.status, AuthStatus.signedIn);
      expect((await store.read())?.refreshToken, 'r1');
    },
  );

  test('signing out tells the server and clears storage', () async {
    final api = _FakeApi();
    final session = AuthSession(api: api, store: store);
    await session.signIn('zoe@example.com', 'Xq7-mnbvcz');

    await session.signOut();

    expect(session.status, AuthStatus.signedOut);
    expect(api.loggedOut, ['r1']);
    expect(await store.read(), isNull);
  });

  test(
    'a refresh that finishes after sign-out does not bring the tokens back',
    () async {
      final gate = Completer<AuthTokens>();
      final api = _FakeApi(onRefresh: (_) => gate.future);
      await store.write(
        _tokens(refresh: 'r1', expiresIn: const Duration(seconds: 5)),
      );
      final session = AuthSession(api: api, store: store);
      await session.restore();

      final pending = session.accessToken();
      await Future<void>.delayed(Duration.zero); // let the refresh start
      await session.signOut();
      gate.complete(
        _tokens(refresh: 'r2', expiresIn: const Duration(minutes: 15)),
      );

      expect(await pending, isNull);
      expect(await store.read(), isNull);
      expect(session.status, AuthStatus.signedOut);
    },
  );

  test(
    'forceRefresh renews even though the access token still looks valid',
    () async {
      final renewed = _tokens(
        refresh: 'r2',
        expiresIn: const Duration(minutes: 15),
      );
      final api = _FakeApi(onRefresh: (_) async => renewed);
      await store.write(
        _tokens(refresh: 'r1', expiresIn: const Duration(minutes: 10)),
      );
      final session = AuthSession(api: api, store: store);
      await session.restore();

      expect(await session.forceRefresh(), renewed.accessToken);
      expect(api.refreshCalls, 1);
    },
  );

  test(
    'a refresh whose response was lost is retried with the same request id',
    () async {
      var attempt = 0;
      final api = _FakeApi(
        onRefresh: (_) async {
          if (++attempt == 1) throw const NetworkUnavailable('response lost');
          return _tokens(refresh: 'r2', expiresIn: const Duration(minutes: 15));
        },
      );
      await store.write(
        _tokens(refresh: 'r1', expiresIn: const Duration(seconds: 5)),
      );
      final session = AuthSession(
        api: api,
        store: store,
        requestIdFactory: () => 'id-${api.refreshCalls}',
      );
      await session.restore();

      await expectLater(
        session.accessToken(),
        throwsA(isA<NetworkUnavailable>()),
      );
      await session.accessToken();

      expect(api.requestIds, hasLength(2));
      expect(
        api.requestIds.toSet(),
        hasLength(1),
        reason: 'both attempts must carry one id',
      );
      expect((await store.read())?.refreshToken, 'r2');
      expect(
        (await store.read())?.pendingRefreshId,
        isNull,
        reason: 'cleared once it succeeded',
      );
    },
  );

  test('the pending request id survives an app restart', () async {
    var attempt = 0;
    final api = _FakeApi(
      onRefresh: (_) async {
        if (++attempt == 1) throw const NetworkUnavailable('response lost');
        return _tokens(refresh: 'r2', expiresIn: const Duration(minutes: 15));
      },
    );
    await store.write(
      _tokens(refresh: 'r1', expiresIn: const Duration(seconds: 5)),
    );
    var counter = 0;
    final first = AuthSession(
      api: api,
      store: store,
      requestIdFactory: () => 'id-${counter++}',
    );
    await first.restore();
    await expectLater(first.accessToken(), throwsA(isA<NetworkUnavailable>()));

    final relaunched = AuthSession(
      api: api,
      store: store,
      requestIdFactory: () => 'id-${counter++}',
    );
    await relaunched.restore();
    await relaunched.accessToken();

    expect(api.requestIds, ['id-0', 'id-0']);
  });

  group('cookie session (web)', () {
    AuthTokens cookieTokens(
      String access, {
      Duration expiresIn = const Duration(minutes: 15),
    }) => AuthTokens(
      accessToken: _jwt(DateTime.now().add(expiresIn)),
      refreshToken: '',
      sessionId: 's1',
    );

    test('restoring with nothing stored signs in through the cookie', () async {
      final api = _FakeApi(
        onRefresh: (sent) async {
          expect(
            sent,
            '',
            reason: 'the refresh token itself is in the cookie, not in script',
          );
          return cookieTokens('fresh');
        },
      );
      final session = AuthSession(api: api, store: store, cookieSession: true);

      await session.restore();

      expect(session.status, AuthStatus.signedIn);
      expect(await session.accessToken(), isNotNull);
    });

    test('restoring with no valid cookie leaves the user signed out', () async {
      final api = _FakeApi(
        onRefresh: (_) async => throw const AuthApiException(
          status: 400,
          title: 'TOKEN_REQUIRED',
          message: 'none',
        ),
      );
      final session = AuthSession(api: api, store: store, cookieSession: true);

      await session.restore();

      expect(session.status, AuthStatus.signedOut);
    });

    test(
      'restoring while offline leaves the user signed out rather than crashing',
      () async {
        final api = _FakeApi(
          onRefresh: (_) async => throw const NetworkUnavailable('offline'),
        );
        final session = AuthSession(
          api: api,
          store: store,
          cookieSession: true,
        );

        await session.restore();

        expect(session.status, AuthStatus.signedOut);
      },
    );

    test('a refresh race is retried once after a short wait, since the cookie is shared', () async {
      var attempt = 0;
      final api = _FakeApi(
        onRefresh: (_) async {
          if (++attempt == 1) {
            throw const AuthApiException(
              status: 409,
              title: 'REFRESH_RACE',
              message: 'spent',
            );
          }
          return cookieTokens('renewed');
        },
      );
      await store.write(
        cookieTokens('old', expiresIn: const Duration(seconds: 5)),
      );
      final session = AuthSession(
        api: api,
        store: store,
        cookieSession: true,
        raceRetryDelay: Duration.zero,
      );
      await session.restore();

      expect(await session.accessToken(), isNotNull);
      expect(api.refreshCalls, 2);
      expect(session.status, AuthStatus.signedIn);
    });
  });

  test(
    'changing the password ends the local session without calling logout',
    () async {
      final api = _FakeApi();
      final session = AuthSession(api: api, store: store);
      await session.signIn('zoe@example.com', 'Xq7-mnbvcz');

      await session.changePassword('Xq7-mnbvcz', 'N3w-passphrase');

      expect(api.changes, [('Xq7-mnbvcz', 'N3w-passphrase')]);
      expect(session.status, AuthStatus.signedOut);
      expect(await store.read(), isNull);
      expect(
        api.loggedOut,
        isEmpty,
        reason: 'the server already revoked every token',
      );
    },
  );
}
