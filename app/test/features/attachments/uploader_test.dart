import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/attachments/application/uploader.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';

import 'fakes.dart';

Future<void> noWait(int attempt) async {}

Future<Attachment> upload(
  FakeAttachments server,
  List<int> bytes, {
  String name = 'a.txt',
  String? sessionId,
  bool Function()? cancelled,
  void Function(String, int)? onProgress,
}) => runUpload(
  client: server,
  source: BytesSource(name, Uint8List.fromList(bytes)),
  workspaceId: 'w1',
  projectId: 'p1',
  taskId: 'a',
  sessionId: sessionId,
  onProgress: onProgress ?? (_, _) {},
  cancelled: cancelled ?? () => false,
  backoff: noWait,
  findUploaded: (name, size, comment) async => server.files
      .where((f) => f.filename == name && f.size == size)
      .firstOrNull,
);

void main() {
  test('a file goes up in chunks and comes back as an attachment', () async {
    final server = FakeAttachments(chunkSize: 4);
    final seen = <int>[];

    final done = await upload(
      server,
      List.generate(10, (i) => i),
      onProgress: (_, sent) => seen.add(sent),
    );

    expect(server.puts.map((p) => p.n), [0, 1, 2]);
    expect(server.puts.map((p) => p.length), [4, 4, 2]);
    expect(seen, [0, 4, 8, 10]);
    expect(done.filename, 'a.txt');
    expect(done.size, 10);
  });

  test('an empty file is one empty chunk', () async {
    final server = FakeAttachments();

    await upload(server, const []);

    expect(server.puts.map((p) => p.length), [0]);
  });

  test('a resumed upload sends only what the server does not have', () async {
    final server = FakeAttachments(chunkSize: 4);
    final earlier = await server.create(
      workspaceId: 'w1',
      projectId: 'p1',
      taskId: 'a',
      filename: 'a.txt',
      size: 12,
    );
    await server.putChunk(earlier.id, 0, [0, 1, 2, 3]);
    await server.putChunk(earlier.id, 1, [4, 5, 6, 7]);
    server.puts.clear();

    await upload(server, List.generate(12, (i) => i), sessionId: earlier.id);

    expect(server.puts.map((p) => p.n), [2]);
    expect(server.created, hasLength(1)); // the same session carried on
  });

  test('progress starts from what the server already holds', () async {
    final server = FakeAttachments(chunkSize: 4);
    final first = await server.create(
      workspaceId: 'w1',
      projectId: 'p1',
      taskId: 'a',
      filename: 'a.txt',
      size: 10,
    );
    await server.putChunk(first.id, 0, [0, 1, 2, 3]);
    final seen = <int>[];

    await upload(
      server,
      List.generate(10, (i) => i),
      sessionId: first.id,
      onProgress: (_, sent) => seen.add(sent),
    );

    expect(seen.first, 4);
    expect(seen.last, 10);
  });

  test('a forgotten session starts again from the top', () async {
    final server = FakeAttachments(chunkSize: 4)..forgetSessions = true;

    await upload(server, List.generate(8, (i) => i), sessionId: 'gone');

    expect(server.created, hasLength(1));
    expect(server.puts.map((p) => p.n), [0, 1]);
  });

  test('a chunk lost to the network is tried again', () async {
    final server = FakeAttachments(chunkSize: 4)
      ..putFailures.addAll(const [
        AttachmentException(AttachmentFailure.network),
        AttachmentException(AttachmentFailure.network),
      ]);

    await upload(server, List.generate(4, (i) => i));

    expect(server.puts.map((p) => p.n), [0, 0, 0]);
  });

  test(
    'after three failed tries the upload fails with the network error',
    () async {
      final server = FakeAttachments(chunkSize: 4)
        ..putFailures.addAll(
          List.filled(5, const AttachmentException(AttachmentFailure.network)),
        );

      await expectLater(
        upload(server, List.generate(4, (i) => i)),
        throwsA(
          isA<AttachmentException>().having(
            (e) => e.failure,
            'failure',
            AttachmentFailure.network,
          ),
        ),
      );
      expect(server.puts, hasLength(3));
    },
  );

  test('a refusal is not retried', () async {
    final server = FakeAttachments(chunkSize: 4)
      ..putFailures.add(const AttachmentException(AttachmentFailure.quota));

    await expectLater(
      upload(server, List.generate(4, (i) => i)),
      throwsA(isA<AttachmentException>()),
    );
    expect(server.puts, hasLength(1));
  });

  test('chunks the server lost are sent again before it is done', () async {
    final server = FakeAttachments(chunkSize: 4)..dropChunks.add(1);

    final done = await upload(server, List.generate(10, (i) => i));

    expect(server.puts.map((p) => p.n), [0, 1, 2, 1]);
    expect(done.size, 10);
  });

  test('cancelling stops between chunks and tells the server', () async {
    final server = FakeAttachments(chunkSize: 4);
    var sentChunks = 0;

    await expectLater(
      upload(
        server,
        List.generate(12, (i) => i),
        cancelled: () => sentChunks >= 1,
        onProgress: (_, sent) => sentChunks = sent ~/ 4,
      ),
      throwsA(isA<UploadCancelled>()),
    );

    expect(server.puts, hasLength(1));
    expect(server.cancelled, ['up1']);
  });

  test('a refusal at the end is passed on', () async {
    final server = FakeAttachments()
      ..failComplete = const AttachmentException(
        AttachmentFailure.refused,
        detail: 'programs',
      );

    await expectLater(
      upload(server, [1, 2]),
      throwsA(
        isA<AttachmentException>().having(
          (e) => e.detail,
          'detail',
          'programs',
        ),
      ),
    );
  });

  test('a lost answer to complete does not upload the file twice', () async {
    final server = FakeAttachments(chunkSize: 4)..loseCompleteAnswers = 1;

    final done = await upload(server, List.generate(8, (i) => i));

    // complete worked the first time; asking again found no session, and the
    // file on the task is what was returned.
    expect(server.files, hasLength(1));
    expect(done.id, server.files.single.id);
    expect(server.completes, 2);
    expect(server.created, hasLength(1));
  });

  test('complete is tried again after a dropped connection', () async {
    final server = FakeAttachments(chunkSize: 4)
      ..completeFailures.addAll(const [
        AttachmentException(AttachmentFailure.network),
        AttachmentException(AttachmentFailure.network),
      ]);

    final done = await upload(server, [1, 2, 3]);

    expect(server.completes, 3);
    expect(done.size, 3);
  });

  test('complete gives up after three dropped connections', () async {
    final server = FakeAttachments(chunkSize: 4)
      ..completeFailures.addAll(
        List.filled(5, const AttachmentException(AttachmentFailure.network)),
      );

    await expectLater(
      upload(server, [1, 2, 3]),
      failsWith(AttachmentFailure.network),
    );
    expect(server.completes, 3);
    expect(server.files, isEmpty);
  });

  test(
    'a session that is gone, for a file that is already there, is done',
    () async {
      final server = FakeAttachments(
        chunkSize: 4,
        initial: [attachment('f1', 'a.txt', size: 8)],
      )..forgetSessions = true;

      final done = await runUpload(
        client: server,
        source: BytesSource(
          'a.txt',
          Uint8List.fromList(List.generate(8, (i) => i)),
        ),
        workspaceId: 'w1',
        projectId: 'p1',
        taskId: 'a',
        sessionId: 'up-lost',
        onProgress: (_, _) {},
        cancelled: () => false,
        backoff: noWait,
        findUploaded: (name, size, comment) async => server.files
            .where((f) => f.filename == name && f.size == size)
            .firstOrNull,
      );

      expect(done.id, 'f1');
      expect(server.created, isEmpty);
      expect(server.puts, isEmpty);
    },
  );

  test(
    'a session that is gone, and no such file, starts a new upload',
    () async {
      final server = FakeAttachments(chunkSize: 4)..forgetSessions = true;

      await runUpload(
        client: server,
        source: BytesSource('a.txt', Uint8List.fromList([1, 2])),
        workspaceId: 'w1',
        projectId: 'p1',
        taskId: 'a',
        sessionId: 'up-lost',
        onProgress: (_, _) {},
        cancelled: () => false,
        backoff: noWait,
        findUploaded: (name, size, comment) async => null,
      );

      expect(server.created, hasLength(1));
    },
  );

  test(
    'a scanner that is down keeps the upload: trying again only completes',
    () async {
      final server = FakeAttachments(chunkSize: 4)
        ..failComplete = const AttachmentException(
          AttachmentFailure.unavailable,
        );
      String? session;
      await expectLater(
        upload(
          server,
          List.generate(8, (i) => i),
          onProgress: (id, _) => session = id,
        ),
        failsWith(AttachmentFailure.unavailable),
      );
      server.puts.clear();

      await upload(server, List.generate(8, (i) => i), sessionId: session);

      expect(server.puts, isEmpty); // nothing sent again
      expect(server.files, hasLength(1));
    },
  );

  test('the request in flight is handed the abort signal', () async {
    final server = FakeAttachments(chunkSize: 4);
    final abort = Completer<void>();

    await runUpload(
      client: server,
      source: BytesSource('a.txt', Uint8List.fromList([1, 2, 3])),
      workspaceId: 'w1',
      projectId: 'p1',
      taskId: 'a',
      onProgress: (_, _) {},
      cancelled: () => false,
      abort: abort.future,
      backoff: noWait,
    );

    expect(server.lastAbort, same(abort.future));
  });

  test(
    'cancelling while a failed chunk waits to be retried stops there',
    () async {
      final server = FakeAttachments(chunkSize: 4)
        ..putFailures.add(const AttachmentException(AttachmentFailure.network));
      var cancel = false;

      await expectLater(
        runUpload(
          client: server,
          source: BytesSource('a.txt', Uint8List.fromList([1, 2, 3])),
          workspaceId: 'w1',
          projectId: 'p1',
          taskId: 'a',
          onProgress: (_, _) {},
          cancelled: () => cancel,
          backoff: (_) async => cancel = true, // cancelled during the wait
        ),
        throwsA(isA<UploadCancelled>()),
      );

      expect(server.puts, hasLength(1));
      expect(server.cancelled, ['up1']);
    },
  );

  test(
    'a chunk the server refuses ends the upload for a retry from the server',
    () async {
      final server = FakeAttachments(chunkSize: 4)
        ..putFailures.add(
          const AttachmentException(AttachmentFailure.chunkRejected),
        );

      await expectLater(
        upload(server, [1, 2, 3]),
        failsWith(AttachmentFailure.chunkRejected),
      );

      expect(server.puts, hasLength(1)); // not hammered
    },
  );
}

Matcher failsWith(AttachmentFailure f) =>
    throwsA(isA<AttachmentException>().having((e) => e.failure, 'failure', f));
