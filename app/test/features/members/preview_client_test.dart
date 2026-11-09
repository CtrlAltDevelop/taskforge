import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/features/members/data/members_client.dart';
import 'package:taskforge/features/members/domain/members.dart';

class _Session extends Mock implements AuthSession {}

class _Channel extends Mock implements ClientChannel {}

GrpcMembersClient _client(MockClient http) => GrpcMembersClient(
  _Channel(),
  _Session(),
  restUrl: 'http://api.test',
  httpClient: http,
);

void main() {
  test('preview POSTs the token in the body, never in the URL', () async {
    late http.Request seen;
    final client = _client(
      MockClient((request) async {
        seen = request;
        return http.Response(
          jsonEncode({
            'data': {
              'workspace_name': 'Globex',
              'inviter_name': 'Hank',
              'email_bound': true,
              'state': 'expired',
            },
          }),
          200,
        );
      }),
    );

    final preview = await client.preview('s3cret/tok');

    expect(seen.method, 'POST');
    expect(seen.url.toString(), 'http://api.test/api/v1/invites/preview');
    expect(jsonDecode(seen.body), {'token': 's3cret/tok'});
    expect(preview.workspaceName, 'Globex');
    expect(preview.emailBound, isTrue);
    expect(preview.state, InviteState.expired);
  });

  test('preview maps 404 to notFound', () async {
    final client = _client(MockClient((_) async => http.Response('{}', 404)));

    expect(
      client.preview('x'),
      throwsA(
        isA<InviteException>().having(
          (e) => e.failure,
          'failure',
          InviteFailure.notFound,
        ),
      ),
    );
  });
}
