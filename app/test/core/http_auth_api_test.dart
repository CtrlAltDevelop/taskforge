import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskforge/core/auth/auth_api.dart';

http.Response _json(int status, Map<String, Object?> body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

Map<String, Object?> _credentials() => {
  'data': {
    'requires_second_factor': false,
    'credentials': {
      'access_token': 'a',
      'refresh_token': 'r',
      'session_id': 's',
    },
  },
};

void main() {
  test(
    'sign-in posts the email as the identifier and parses the credentials',
    () async {
      late http.Request seen;
      final api = HttpAuthApi(
        'http://api.test',
        client: MockClient((request) async {
          seen = request;
          return _json(200, _credentials());
        }),
      );

      final tokens = await api.signIn('zoe@example.com', 'Xq7-mnbvcz');

      expect(seen.url.path, '/api/v1/auth/password/login');
      expect(jsonDecode(seen.body), {
        'identifier': 'zoe@example.com',
        'password': 'Xq7-mnbvcz',
      });
      expect(
        (tokens.accessToken, tokens.refreshToken, tokens.sessionId),
        ('a', 'r', 's'),
      );
    },
  );

  test('sign-up sends the email as both identifier and email', () async {
    late http.Request seen;
    final api = HttpAuthApi(
      'http://api.test',
      client: MockClient((request) async {
        seen = request;
        return _json(200, _credentials());
      }),
    );

    await api.signUp('zoe@example.com', 'Xq7-mnbvcz');

    expect(
      jsonDecode(seen.body),
      containsPair('identifier', 'zoe@example.com'),
    );
    expect(jsonDecode(seen.body), containsPair('email', 'zoe@example.com'));
  });

  test(
    'an error answer becomes an exception carrying its title and messages',
    () async {
      final api = HttpAuthApi(
        'http://api.test',
        client: MockClient(
          (_) async => _json(401, {
            'errors': ['Those credentials are not valid.'],
            'title': 'INVALID_CREDENTIALS',
          }),
        ),
      );

      await expectLater(
        api.signIn('zoe@example.com', 'wrong-password'),
        throwsA(
          isA<AuthApiException>()
              .having((e) => e.title, 'title', 'INVALID_CREDENTIALS')
              .having((e) => e.status, 'status', 401)
              .having(
                (e) => e.message,
                'message',
                'Those credentials are not valid.',
              ),
        ),
      );
    },
  );

  test('a refresh race is reported by its title', () async {
    final api = HttpAuthApi(
      'http://api.test',
      client: MockClient(
        (_) async => _json(409, {
          'title': 'REFRESH_RACE',
          'errors': ['just spent'],
        }),
      ),
    );

    await expectLater(
      api.refresh('r'),
      throwsA(
        isA<AuthApiException>().having((e) => e.title, 'title', 'REFRESH_RACE'),
      ),
    );
  });

  test('a second-factor challenge is not mistaken for a sign-in', () async {
    final api = HttpAuthApi(
      'http://api.test',
      client: MockClient(
        (_) async => _json(200, {
          'data': {'requires_second_factor': true, 'credentials': null},
        }),
      ),
    );

    await expectLater(
      api.signIn('zoe@example.com', 'Xq7-mnbvcz'),
      throwsA(isA<AuthApiException>()),
    );
  });

  test(
    'an unreachable server is a NetworkUnavailable, not an auth failure',
    () async {
      final api = HttpAuthApi(
        'http://api.test',
        client: MockClient(
          (_) async => throw http.ClientException('connection refused'),
        ),
      );

      await expectLater(
        api.signIn('zoe@example.com', 'Xq7-mnbvcz'),
        throwsA(isA<NetworkUnavailable>()),
      );
    },
  );

  test('revoking a session sends a bearer token to the session URL', () async {
    late http.Request seen;
    final api = HttpAuthApi(
      'http://api.test',
      client: MockClient((request) async {
        seen = request;
        return _json(200, {'data': {}});
      }),
    );

    await api.revokeSession('tok', 'abc');

    expect(seen.method, 'DELETE');
    expect(seen.url.path, '/api/v1/auth/token/sessions/abc');
    expect(seen.headers['Authorization'], 'Bearer tok');
  });

  test(
    'cookie mode asks the server to keep the refresh token in a cookie',
    () async {
      late http.Request seen;
      final api = HttpAuthApi(
        'http://api.test',
        cookieMode: true,
        client: MockClient((request) async {
          seen = request;
          return _json(200, _credentials());
        }),
      );

      await api.signIn('zoe@example.com', 'Xq7-mnbvcz');

      expect(seen.headers['X-Refresh-Transport'], 'cookie');
    },
  );

  test('without cookie mode the header is not sent', () async {
    late http.Request seen;
    final api = HttpAuthApi(
      'http://api.test',
      client: MockClient((request) async {
        seen = request;
        return _json(200, _credentials());
      }),
    );

    await api.signIn('zoe@example.com', 'Xq7-mnbvcz');

    expect(seen.headers.containsKey('X-Refresh-Transport'), isFalse);
  });

  test(
    'credentials may come back with no refresh token (it is in the cookie)',
    () async {
      final api = HttpAuthApi(
        'http://api.test',
        cookieMode: true,
        client: MockClient(
          (_) async => _json(200, {
            'data': {
              'requires_second_factor': false,
              'credentials': {
                'access_token': 'a',
                'refresh_token': '',
                'session_id': 's',
              },
            },
          }),
        ),
      );

      final tokens = await api.signIn('zoe@example.com', 'Xq7-mnbvcz');

      expect(tokens.refreshToken, '');
    },
  );

  test(
    'changing the password sends both passwords with a bearer token',
    () async {
      late http.Request seen;
      final api = HttpAuthApi(
        'http://api.test',
        client: MockClient((request) async {
          seen = request;
          return _json(200, {'data': {}});
        }),
      );

      await api.changePassword('tok', 'old-password-1', 'new-password-2');

      expect(seen.url.path, '/api/v1/auth/password/change');
      expect(seen.headers['Authorization'], 'Bearer tok');
      expect(jsonDecode(seen.body), {
        'current_password': 'old-password-1',
        'new_password': 'new-password-2',
      });
    },
  );

  test(
    'requesting a reset returns the ticket and sends only the email',
    () async {
      late http.Request seen;
      final api = HttpAuthApi(
        'http://api.test',
        client: MockClient((request) async {
          seen = request;
          return _json(200, {
            'data': {'detail': 'sent', 'ticket': 't-9', 'expires_in': 300},
          });
        }),
      );

      final ticket = await api.requestPasswordReset('zoe@example.com');

      expect(ticket, 't-9');
      expect(seen.url.path, '/api/v1/auth/password/forgot');
      expect(jsonDecode(seen.body), {'email': 'zoe@example.com'});
    },
  );

  test('resetting posts the ticket, the code and the new password', () async {
    late http.Request seen;
    final api = HttpAuthApi(
      'http://api.test',
      client: MockClient((request) async {
        seen = request;
        return _json(200, {'data': {}});
      }),
    );

    await api.resetPassword(
      ticket: 't-9',
      code: '418239',
      newPassword: 'new-password-2',
    );

    expect(seen.url.path, '/api/v1/auth/password/reset');
    expect(jsonDecode(seen.body), {
      'ticket': 't-9',
      'code': '418239',
      'password': 'new-password-2',
    });
  });
}
