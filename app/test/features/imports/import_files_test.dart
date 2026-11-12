import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskforge/features/imports/data/import_files.dart';
import 'package:taskforge/features/imports/domain/imports.dart';

import '../attachments/uploads_client_test.dart' show envelope, signedIn;
import '../workspaces/fakes.dart' show MockAuthApi;

Future<HttpImportFiles> _files(
  Future<http.Response> Function(http.Request) handler,
) async => HttpImportFiles(
  await signedIn(MockAuthApi()),
  restUrl: 'http://api.test',
  selectedWorkspace: () => 'w1',
  httpClient: MockClient(handler),
);

Matcher _fails(ImportFailure f) =>
    throwsA(isA<ImportException>().having((e) => e.failure, 'failure', f));

Future<UploadResult> _send(HttpImportFiles files) => files.upload(
  workspaceId: 'w1',
  filename: 'export.csv',
  stream: Stream.value([1, 2, 3]),
  size: 3,
  source: 'jira_csv',
);

void main() {
  group('upload', () {
    test(
      'sends the file as multipart with the workspace and the token',
      () async {
        late http.Request seen;
        final files = await _files((r) async {
          seen = r;
          return envelope(
            200,
            data: {
              'id': 'j1',
              'source': 'jira_csv',
              'filename': 'export.csv',
              'size': 3,
              'members': ['a.csv', 'b.csv'],
            },
          );
        });
        final result = await _send(files);
        expect(seen.url.toString(), 'http://api.test/api/v1/imports/upload');
        expect(seen.headers['Authorization'], startsWith('Bearer '));
        expect(seen.headers['Content-Type'], startsWith('multipart/form-data'));
        final body = seen.body;
        expect(body, contains('name="workspace_id"'));
        expect(body, contains('w1'));
        expect(body, contains('name="source"'));
        expect(body, contains('filename="export.csv"'));
        expect((result.id, result.size, result.members.length), ('j1', 3, 2));
      },
    );

    test('leaves out the source when it is to be detected', () async {
      late String body;
      final files = await _files((r) async {
        body = r.body;
        return envelope(
          200,
          data: {'id': 'j', 'source': 'csv', 'filename': 'f', 'size': 1},
        );
      });
      await files.upload(
        workspaceId: 'w1',
        filename: 'f.csv',
        stream: Stream.value([1]),
        size: 1,
      );
      expect(body, isNot(contains('name="source"')));
    });

    test('maps refusals to failures', () async {
      for (final (status, failure) in [
        (403, ImportFailure.denied),
        (413, ImportFailure.tooBig),
        (422, ImportFailure.invalid),
        (500, ImportFailure.other),
      ]) {
        final files = await _files((_) async => envelope(status, data: null));
        await expectLater(_send(files), _fails(failure), reason: '$status');
      }
    });

    test('a dropped line is a network failure', () async {
      final files = await _files((_) async => throw http.ClientException('x'));
      await expectLater(_send(files), _fails(ImportFailure.network));
    });

    test(
      'an expired token is refreshed and the person is asked to retry',
      () async {
        final files = await _files((_) async => envelope(401, data: null));
        await expectLater(_send(files), _fails(ImportFailure.network));
      },
    );
  });

  group('fetch', () {
    test('returns the bytes of a signed path', () async {
      late Uri seen;
      final files = await _files((r) async {
        seen = r.url;
        return http.Response.bytes([80, 75], 200);
      });
      expect(await files.fetch('/exports/download?token=t'), [80, 75]);
      expect(
        seen.toString(),
        'http://api.test/api/v1/exports/download?token=t',
      );
    });

    test('an expired link says so; any other refusal is a failure', () async {
      var status = 410;
      final files = await _files((_) async => http.Response('', status));
      await expectLater(
        files.fetch('/p'),
        throwsA(
          isA<ImportException>()
              .having((e) => e.failure, 'failure', ImportFailure.conflict)
              .having((e) => e.detail, 'detail', contains('expired')),
        ),
      );
      status = 404;
      await expectLater(files.fetch('/p'), _fails(ImportFailure.other));
    });

    test('a dropped line is a network failure', () async {
      final files = await _files((_) async => throw http.ClientException('x'));
      await expectLater(files.fetch('/p'), _fails(ImportFailure.network));
    });
  });

  test('close closes the client', () async {
    final files = await _files((_) async => http.Response('', 200));
    files.close();
    expect(jsonEncode(1), '1');
  });
}
