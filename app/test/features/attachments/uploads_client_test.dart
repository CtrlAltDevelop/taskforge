import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:mocktail/mocktail.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/attachments/data/attachments_client.dart';
import 'package:taskforge/features/attachments/data/uploads_client.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/gen/infrastructure/attachments/grpc/attachments.pb.dart'
    as pb;

import '../workspaces/fakes.dart' show MockAuthApi;

/// A token that does not look expired (exp far in the future).
String jwt(String tag) {
  final claims = base64Url
      .encode(utf8.encode('{"exp":4102444800,"tag":"$tag"}'))
      .replaceAll('=', '');
  return 'h.$claims.s';
}

final _tokens = AuthTokens(
  accessToken: jwt('one'),
  refreshToken: 'r',
  sessionId: 's',
);

Future<AuthSession> signedIn(MockAuthApi api) async {
  final store = MemoryTokenStore();
  await store.write(_tokens);
  final session = AuthSession(api: api, store: store);
  await session.restore();
  return session;
}

http.Response envelope(
  int status, {
  Object? data,
  String title = 'SUCCESS',
  List<String>? errors,
}) => http.Response(
  jsonEncode({
    'errors': errors,
    'data': data,
    'isSuccess': status < 400,
    'statusCode': status,
    'title': title,
  }),
  status,
);

Future<HttpUploadsClient> clientFor(
  Future<http.Response> Function(http.Request) handler, {
  MockAuthApi? api,
}) async => HttpUploadsClient(
  await signedIn(api ?? MockAuthApi()),
  restUrl: 'http://api.test',
  selectedWorkspace: () => 'w1',
  httpClient: MockClient(handler),
);

Matcher failure(AttachmentFailure f) =>
    throwsA(isA<AttachmentException>().having((e) => e.failure, 'failure', f));

void main() {
  group('uploads', () {
    test('create posts the file and reads the session', () async {
      late http.Request seen;
      final client = await clientFor((r) async {
        seen = r;
        return envelope(
          200,
          data: {
            'id': 'u1',
            'chunk_size': 4,
            'chunk_count': 3,
            'received': [0],
          },
        );
      });

      final session = await client.create(
        workspaceId: 'w1',
        projectId: 'p1',
        taskId: 't1',
        filename: 'a.txt',
        size: 10,
        commentId: 'c1',
      );

      expect(seen.method, 'POST');
      expect(seen.url.toString(), 'http://api.test/api/v1/uploads');
      expect(seen.headers['Authorization'], 'Bearer ${jwt('one')}');
      expect(seen.headers['X-Workspace'], 'w1');
      expect(jsonDecode(seen.body), {
        'workspace_id': 'w1',
        'project_id': 'p1',
        'task_id': 't1',
        'comment_id': 'c1',
        'filename': 'a.txt',
        'size': 10,
      });
      expect(session.id, 'u1');
      expect(session.chunkCount, 3);
      expect(session.received, {0});
    });

    test(
      'a chunk goes up as raw bytes and the answer lists what is held',
      () async {
        late http.Request seen;
        final client = await clientFor((r) async {
          seen = r;
          return envelope(
            200,
            data: {
              'received': [0, 1],
            },
          );
        });

        final held = await client.putChunk('u1', 1, [9, 8, 7]);

        expect(seen.method, 'PUT');
        expect(seen.url.path, '/api/v1/uploads/u1/chunk/1');
        expect(seen.headers['Content-Type'], 'application/octet-stream');
        expect(seen.bodyBytes, [9, 8, 7]);
        expect(held, {0, 1});
      },
    );

    test('status and cancel use the session address', () async {
      final seen = <String>[];
      final client = await clientFor((r) async {
        seen.add('${r.method} ${r.url.path}');
        return envelope(
          200,
          data: {'id': 'u1', 'chunk_size': 4, 'chunk_count': 1, 'received': []},
        );
      });

      await client.status('u1');
      await client.cancel('u1');

      expect(seen, ['GET /api/v1/uploads/u1', 'DELETE /api/v1/uploads/u1']);
    });

    test('complete returns the stored attachment', () async {
      final client = await clientFor(
        (r) async => envelope(
          200,
          data: {
            'id': 'f1',
            'task_id': 't1',
            'comment_id': null,
            'uploader_id': 'u1',
            'filename': 'a.png',
            'mime': 'image/png',
            'size': 10,
            'has_thumb': true,
            'created_at': '2026-01-02T03:04:05+00:00',
          },
        ),
      );

      final file = await client.complete('u1');

      expect(file.id, 'f1');
      expect(file.commentId, '');
      expect(file.hasThumb, isTrue);
      expect(file.isImage, isTrue);
      expect(file.createdAt.year, 2026);
    });

    test('a link may be relative to the server', () async {
      late http.Request seen;
      final client = await clientFor((r) async {
        seen = r;
        return envelope(
          200,
          data: {
            'url': '/api/v1/files/f1/raw?token=x',
            'expires_at': '2026-01-02T03:04:05+00:00',
          },
        );
      });

      final link = await client.link('f1', thumb: true);

      expect(seen.url.queryParameters, {'thumb': '1'});
      expect(link.url, 'http://api.test/api/v1/files/f1/raw?token=x');
    });

    test('text is fetched with a Range and cut to the limit', () async {
      late http.BaseRequest seen;
      final client = await clientFor((r) async {
        seen = r;
        return http.Response('abcdefghij', 200);
      });

      final cut = await client.fetchText('http://x/f', maxBytes: 4);
      expect(seen.headers['Range'], 'bytes=0-4');
      expect(cut.text, 'abcd');
      expect(cut.truncated, isTrue);

      final whole = await client.fetchText('http://x/f');
      expect(whole.text, 'abcdefghij');
      expect(whole.truncated, isFalse);
    });

    test('a missing text file is not found', () async {
      final client = await clientFor((r) async => http.Response('', 404));

      await expectLater(
        client.fetchText('http://x/f'),
        failure(AttachmentFailure.notFound),
      );
    });
  });

  group('refusals', () {
    Future<Object?> call(http.Response answer) async {
      final client = await clientFor((r) async => answer);
      try {
        await client.complete('u1');
      } on AttachmentException catch (e) {
        return e;
      }
      return null;
    }

    test('too big, by title or by status', () async {
      expect(
        (await call(
          envelope(422, title: 'ATTACHMENT_TOO_BIG'),
        ) as AttachmentException).failure,
        AttachmentFailure.tooBig,
      );
      expect(
        (await call(http.Response('', 413)) as AttachmentException).failure,
        AttachmentFailure.tooBig,
      );
    });

    test(
      'quota, refused with its reason, incomplete with what is missing',
      () async {
        expect(
          (await call(
            envelope(409, title: 'ATTACHMENT_QUOTA'),
          ) as AttachmentException).failure,
          AttachmentFailure.quota,
        );
        final refused = await call(
          envelope(
            422,
            title: 'ATTACHMENT_REFUSED',
            data: {'reason': 'programs'},
          ),
        ) as AttachmentException;
        expect(refused.detail, 'programs');
        final incomplete = await call(
          envelope(
            409,
            title: 'UPLOAD_INCOMPLETE',
            data: {
              'missing': [2, 5],
            },
          ),
        ) as AttachmentException;
        expect(incomplete.missing, [2, 5]);
        final fromList = await call(
          envelope(
            409,
            title: 'UPLOAD_INCOMPLETE',
            data: {
              'missing': [7, 8],
            },
          ),
        ) as AttachmentException;
        expect(fromList.missing, [7, 8]);
        final noNumbers = await call(
          envelope(409, title: 'UPLOAD_INCOMPLETE', data: {'missing': ''}),
        ) as AttachmentException;
        expect(noNumbers.missing, isEmpty);
      },
    );

    test('expired, denied, gone, a server error and a bad body', () async {
      Future<AttachmentFailure?> kind(http.Response r) async =>
          (await call(r) as AttachmentException?)?.failure;
      expect(
        await kind(envelope(410, title: 'UPLOAD_EXPIRED')),
        AttachmentFailure.expired,
      );
      expect(
        await kind(envelope(403, title: 'LINK_EXPIRED')),
        AttachmentFailure.expired,
      );
      expect(await kind(envelope(403)), AttachmentFailure.forbidden);
      expect(
        await kind(envelope(403, data: {'permission': 'task.update'})),
        AttachmentFailure.denied,
      );
      expect(await kind(envelope(404)), AttachmentFailure.notFound);
      expect(await kind(http.Response('oops', 502)), AttachmentFailure.network);
      expect(
        await kind(envelope(400, errors: const ['bad'])),
        AttachmentFailure.other,
      );
    });

    test('no connection is the network failure', () async {
      final client = await clientFor(
        (r) async => throw http.ClientException('down'),
      );

      await expectLater(
        client.status('u1'),
        failure(AttachmentFailure.network),
      );
    });
  });

  group('what the server added in round two', () {
    Future<AttachmentFailure?> failureOf(
      http.Response answer,
      Future<void> Function(HttpUploadsClient) act,
    ) async {
      final client = await clientFor((r) async => answer);
      try {
        await act(client);
      } on AttachmentException catch (e) {
        return e.failure;
      }
      return null;
    }

    test(
      'a scanner that is down (503) is retryable whatever the title',
      () async {
        final kind = await failureOf(
          envelope(503, title: 'ATTACHMENT_REFUSED'),
          (c) => c.complete('u1'),
        );

        expect(kind, AttachmentFailure.unavailable);
      },
    );

    test(
      'too many open uploads (429) is not the workspace being full (409)',
      () async {
        expect(
          await failureOf(
            envelope(429, title: 'ATTACHMENT_QUOTA'),
            (c) => c.create(
              workspaceId: 'w',
              projectId: 'p',
              taskId: 't',
              filename: 'a',
              size: 1,
            ),
          ),
          AttachmentFailure.tooManyUploads,
        );
        expect(
          await failureOf(
            envelope(409, title: 'ATTACHMENT_QUOTA'),
            (c) => c.create(
              workspaceId: 'w',
              projectId: 'p',
              taskId: 't',
              filename: 'a',
              size: 1,
            ),
          ),
          AttachmentFailure.quota,
        );
      },
    );

    test('a chunk the server will not take is a try-again, a gone session is expired', () async {
      Future<void> put(HttpUploadsClient c) => c.putChunk('u1', 0, [1]);
      expect(
        await failureOf(envelope(413, title: 'ATTACHMENT_TOO_BIG'), put),
        AttachmentFailure.chunkRejected,
      );
      expect(
        await failureOf(envelope(400, title: 'BAD_REQUEST'), put),
        AttachmentFailure.chunkRejected,
      );
      expect(
        await failureOf(envelope(404, title: 'UPLOAD_EXPIRED'), put),
        AttachmentFailure.expired,
      );
      expect(
        await failureOf(http.Response('', 404), put),
        AttachmentFailure.expired,
      );
    });

    test('413 when starting an upload is still too big', () async {
      expect(
        await failureOf(
          envelope(413, title: 'ATTACHMENT_TOO_BIG'),
          (c) => c.create(
            workspaceId: 'w',
            projectId: 'p',
            taskId: 't',
            filename: 'a',
            size: 1,
          ),
        ),
        AttachmentFailure.tooBig,
      );
    });

    test('completing for a removed comment is not found', () async {
      expect(
        await failureOf(
          envelope(404, title: 'NOT_FOUND'),
          (c) => c.complete('u1'),
        ),
        AttachmentFailure.notFound,
      );
    });

    test('a call that takes too long counts as no connection', () async {
      final never = Completer<http.Response>();
      final client = HttpUploadsClient(
        await signedIn(MockAuthApi()),
        restUrl: 'http://api.test',
        selectedWorkspace: () => 'w1',
        httpClient: MockClient((r) => never.future),
        shortTimeout: const Duration(milliseconds: 20),
      );

      await expectLater(
        client.status('u1'),
        failure(AttachmentFailure.network),
      );
    });
  });

  test('a rejected token is renewed once and the call repeated', () async {
    final api = MockAuthApi();
    when(() => api.refresh(any(), requestId: any(named: 'requestId')))
        .thenAnswer(
          (_) async => AuthTokens(
            accessToken: jwt('two'),
            refreshToken: 'r2',
            sessionId: 's',
          ),
        );
    final calls = <String?>[];
    final client = await clientFor((r) async {
      calls.add(r.headers['Authorization']);
      return calls.length == 1
          ? envelope(401, title: 'UNAUTHORIZED')
          : envelope(
              200,
              data: {'id': 'u1', 'chunk_size': 4, 'chunk_count': 1},
            );
    }, api: api);

    final session = await client.status('u1');

    expect(session.id, 'u1');
    expect(calls, ['Bearer ${jwt('one')}', 'Bearer ${jwt('two')}']);
  });

  group('the gRPC side', () {
    test('a message becomes an attachment', () {
      final file = attachmentFromPb(
        pb.Attachment(
          id: 'f1',
          taskId: 't1',
          commentId: 'c1',
          uploaderId: 'u1',
          filename: 'a.pdf',
          mime: 'application/pdf',
          size: Int64(5000000000), // more than 32 bits
          hasThumb: true,
          createdAt: '2026-01-02T03:04:05+00:00',
        ),
      );

      expect(file.size, 5000000000);
      expect(file.isPdf, isTrue);
      expect(file.commentId, 'c1');
    });

    test('errors are mapped to what the screens know', () {
      expect(
        mapAttachmentError(GrpcError.permissionDenied()).failure,
        AttachmentFailure.forbidden,
      );
      expect(
        mapAttachmentError(GrpcError.notFound()).failure,
        AttachmentFailure.notFound,
      );
      expect(
        mapAttachmentError(GrpcError.unavailable()).failure,
        AttachmentFailure.network,
      );
      expect(
        mapAttachmentError(StateError('x')).failure,
        AttachmentFailure.other,
      );
      const own = AttachmentException(AttachmentFailure.quota);
      expect(identical(mapAttachmentError(own), own), isTrue);
    });
  });

  group('domain', () {
    test('sizes read as people say them', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(1023), '1023 B');
      expect(formatBytes(1024), '1 KB');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(150 * 1024 * 1024), '150 MB');
      expect(formatBytes(3 * 1024 * 1024 * 1024), '3 GB');
    });

    test('a file source reads just the range asked', () async {
      final source = XFileSource(
        XFile.fromData(
          Uint8List.fromList(List.generate(10, (i) => i)),
          name: 'x.bin',
        ),
      );

      expect(await source.length(), 10);
      final got = <int>[await for (final part in source.read(2, 6)) ...part];
      expect(got, [2, 3, 4, 5]);
      expect(
        XFileSource(XFile.fromData(Uint8List(1)), nameOverride: 'y.png').name,
        'y.png',
      );
    });

    test('a memory source never reads past its end', () async {
      final source = BytesSource('m', Uint8List.fromList([1, 2, 3]));

      final got = <int>[await for (final p in source.read(1, 99)) ...p];

      expect(got, [2, 3]);
    });

    test('an upload item knows its progress and whether it can retry', () {
      const item = UploadItem(localId: 'l', filename: 'a', size: 10, sent: 5);
      expect(item.progress, 0.5);
      expect(
        const UploadItem(localId: 'l', filename: 'a', size: 0).progress,
        0,
      );
      final failed = item.copyWith(
        state: UploadState.failed,
        error: AttachmentFailure.network,
      );
      expect(failed.canRetry, isTrue);
      expect(
        failed.copyWith(error: AttachmentFailure.refused).canRetry,
        isFalse,
      );
      expect(item.copyWith(state: UploadState.uploading).error, isNull);
    });

    test('every failure has a message', () {
      for (final f in AttachmentFailure.values) {
        expect(attachmentErrorMessage(AttachmentException(f)), isNotEmpty);
      }
      expect(
        attachmentErrorMessage(
          const AttachmentException(AttachmentFailure.denied, detail: 'no'),
        ),
        'no',
      );
    });
  });
}
