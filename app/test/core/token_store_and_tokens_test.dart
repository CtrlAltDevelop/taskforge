import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';

import '../support/fake_jwt.dart';

void main() {
  group('SecureTokenStore', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('reads nothing before anything is written', () async {
      expect(await SecureTokenStore().read(), isNull);
    });

    test('round-trips tokens and forgets them on clear', () async {
      final store = SecureTokenStore();
      const tokens = AuthTokens(
        accessToken: 'a',
        refreshToken: 'r',
        sessionId: 's',
      );

      await store.write(tokens);
      expect(await store.read(), tokens);

      await store.clear();
      expect(await store.read(), isNull);
    });

    test('treats an unreadable stored value as signed out', () async {
      FlutterSecureStorage.setMockInitialValues({'auth.tokens': 'not json'});

      expect(await SecureTokenStore().read(), isNull);
    });

    test(
      'stores the three values under a single key so a crash cannot split them',
      () async {
        final storage = FlutterSecureStorage();
        await SecureTokenStore(storage).write(
          const AuthTokens(accessToken: 'a', refreshToken: 'r', sessionId: 's'),
        );

        expect((await storage.readAll()).keys, ['auth.tokens']);
      },
    );
  });

  group('AuthTokens.expiresWithin', () {
    AuthTokens withAccess(String access) =>
        AuthTokens(accessToken: access, refreshToken: 'r', sessionId: 's');

    test('is false for a token valid well beyond the margin', () {
      final tokens = withAccess(
        fakeJwt(DateTime.now().add(const Duration(minutes: 10))),
      );
      expect(tokens.expiresWithin(const Duration(seconds: 30)), isFalse);
    });

    test('is true inside the margin', () {
      final tokens = withAccess(
        fakeJwt(DateTime.now().add(const Duration(seconds: 10))),
      );
      expect(tokens.expiresWithin(const Duration(seconds: 30)), isTrue);
    });

    test('treats a token that is not a readable JWT as expired', () {
      expect(withAccess('not-a-jwt').expiresWithin(Duration.zero), isTrue);
      expect(withAccess('a.%%%.c').expiresWithin(Duration.zero), isTrue);
    });
  });
}
