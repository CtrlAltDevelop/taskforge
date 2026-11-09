import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskforge/core/auth/auth_api.dart';

final _tokenInQuery = RegExp(r'[?&](access_|refresh_)?token=');

void main() {
  test(
    'no REST request carries a token in its URL; bearer is a header',
    () async {
      final seen = <http.Request>[];
      final api = HttpAuthApi(
        'http://api.test',
        client: MockClient((request) async {
          seen.add(request);
          return http.Response(
            jsonEncode({
              'data': {
                'ticket': 't',
                'access_token': 'ACCESS',
                'refresh_token': 'REFRESH',
                'session_id': 's',
                'credentials': {
                  'access_token': 'ACCESS',
                  'refresh_token': 'REFRESH',
                  'session_id': 's',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await api.signIn('a@b.co', 'pw');
      await api.refresh('REFRESH', requestId: 'r1');
      await api.logout('REFRESH');
      await api.revokeSession('ACCESS', 'sid');
      await api.changePassword('ACCESS', 'old', 'new');
      await api.requestPasswordReset('a@b.co');
      await api.resetPassword(ticket: 't', code: '1', newPassword: 'n');

      expect(seen, hasLength(7));
      for (final r in seen) {
        expect(r.url.hasQuery, isFalse, reason: '${r.url}');
        expect(r.url.toString(), isNot(contains('ACCESS')));
        expect(r.url.toString(), isNot(contains('REFRESH')));
      }
      final revoke = seen.firstWhere(
        (r) => r.url.path.endsWith('/sessions/sid'),
      );
      expect(revoke.headers['Authorization'], 'Bearer ACCESS');
    },
  );

  test('lib/ never builds a URL with a token query parameter', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.contains('/gen/')) continue;
      if (_tokenInQuery.hasMatch(f.readAsStringSync())) offenders.add(f.path);
    }
    expect(offenders, isEmpty);
  });
}
