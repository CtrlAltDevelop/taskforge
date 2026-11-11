import 'dart:async';
import 'dart:io' show FileSystemException;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show currentUserIdProvider;
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';

const ref = (project: 'p1', task: 'a');

class Harness {
  Harness(this.server) {
    container = ProviderContainer(
      overrides: [
        workspaceScopeProvider.overrideWithValue('w1'),
        currentUserIdProvider.overrideWithValue('u1'),
        attachmentsClientProvider.overrideWithValue(server),
        uploadsClientProvider.overrideWithValue(server),
      ],
    );
    container.listen(attachmentsProvider(ref), (_, _) {});
    container.read(attachmentsProvider(ref).notifier).backoff = (_) async {};
  }

  final FakeAttachments server;
  late ProviderContainer container;

  AttachmentsNotifier get notifier =>
      container.read(attachmentsProvider(ref).notifier);
  AttachmentsState get state => container.read(attachmentsProvider(ref));
}

BytesSource file(String name, int length) =>
    BytesSource(name, Uint8List.fromList(List.generate(length, (i) => i)));

Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Harness open(FakeAttachments server) {
  final h = Harness(server);
  addTearDown(h.container.dispose);
  return h;
}

void main() {
  moreTests();
  test('it reads the files of the task', () async {
    final h = open(FakeAttachments(initial: [attachment('f1', 'a.pdf')]));
    expect(h.state.loading, isTrue);

    await settle();

    expect(h.state.loading, isFalse);
    expect(h.state.attachments.map((a) => a.filename), ['a.pdf']);
  });

  test('an added file uploads and joins the list', () async {
    final h = open(FakeAttachments());
    await settle();

    await h.notifier.add([file('notes.txt', 10)]);
    await settle();

    expect(h.state.uploads, isEmpty);
    expect(h.state.attachments.map((a) => a.filename), ['notes.txt']);
    expect(h.server.created.single.filename, 'notes.txt');
  });

  test('progress shows while a chunk is on its way', () async {
    final server = FakeAttachments()..gate = Completer<void>();
    final h = open(server);
    await settle();

    await h.notifier.add([file('big.bin', 10)]);
    await settle();

    final item = h.state.uploads.single;
    expect(item.state, UploadState.uploading);
    expect(item.progress, 0);

    server.gate!.complete();
    await settle();
    expect(h.state.uploads, isEmpty);
  });

  test('files go up one after another', () async {
    final h = open(FakeAttachments());
    await settle();

    await h.notifier.add([file('one.txt', 5), file('two.txt', 5)]);
    await settle();

    expect(h.state.attachments.map((a) => a.filename), ['one.txt', 'two.txt']);
  });

  test('an upload for a comment says which', () async {
    final h = open(FakeAttachments());
    await settle();

    await h.notifier.add([file('c.txt', 3)], commentId: 'cm1');
    await settle();

    expect(h.server.created.single.commentId, 'cm1');
  });

  test('a file over the limit is refused without being sent', () async {
    final server = FakeAttachments(
      usageValue: const StorageUsage(
        usedBytes: 0,
        quotaBytes: 0,
        fileCount: 0,
        maxFileBytes: 8,
      ),
    );
    final h = open(server);
    await settle();

    await h.notifier.add([file('huge.bin', 9)]);
    await settle();

    final item = h.state.uploads.single;
    expect(item.state, UploadState.failed);
    expect(item.error, AttachmentFailure.tooBig);
    expect(item.canRetry, isFalse);
    expect(server.created, isEmpty);
  });

  test(
    'a failed upload can be retried and carries on from the server',
    () async {
      final server = FakeAttachments()
        ..putFailures.addAll([
          const AttachmentException(AttachmentFailure.other),
        ]);
      final h = open(server);
      await settle();
      await h.notifier.add([file('a.txt', 10)]);
      await settle();
      expect(h.state.uploads.single.state, UploadState.failed);

      await h.notifier.retry(h.state.uploads.single.localId);
      await settle();

      expect(h.state.uploads, isEmpty);
      expect(server.created, hasLength(1)); // the same session carried on
      expect(h.state.attachments.single.size, 10);
    },
  );

  test('a server refusal fails the item with its reason', () async {
    final server = FakeAttachments()
      ..failCreate = const AttachmentException(AttachmentFailure.quota);
    final h = open(server);
    await settle();

    await h.notifier.add([file('a.txt', 3)]);
    await settle();

    expect(h.state.uploads.single.error, AttachmentFailure.quota);
  });

  test('cancelling a running upload stops it and tells the server', () async {
    final server = FakeAttachments()..gate = Completer<void>();
    final h = open(server);
    await settle();
    await h.notifier.add([file('a.txt', 10)]);
    await settle();

    h.notifier.cancel(h.state.uploads.single.localId);
    server.gate!.complete();
    await settle();

    expect(h.state.uploads.single.state, UploadState.cancelled);
    expect(server.cancelled, hasLength(1));
    expect(h.state.attachments, isEmpty);
  });

  test('cancelling one that has not started leaves it out', () async {
    final server = FakeAttachments()..gate = Completer<void>();
    final h = open(server);
    await settle();
    await h.notifier.add([file('a.txt', 4), file('b.txt', 4)]);
    await settle();

    final second = h.state.uploads.last;
    h.notifier.cancel(second.localId);
    server.gate!.complete();
    await settle();

    expect(h.state.uploads.last.state, UploadState.cancelled);
    expect(server.created.map((c) => c.filename), ['a.txt']);
  });

  test('a cancelled upload can be started again', () async {
    final server = FakeAttachments()..gate = Completer<void>();
    final h = open(server);
    await settle();
    await h.notifier.add([file('a.txt', 4)]);
    await settle();
    h.notifier.cancel(h.state.uploads.single.localId);
    server.gate!.complete();
    await settle();

    await h.notifier.retry(h.state.uploads.single.localId);
    await settle();

    expect(h.state.attachments.single.filename, 'a.txt');
    expect(h.state.uploads, isEmpty);
  });

  test('a failed upload can be dismissed', () async {
    final server = FakeAttachments()
      ..failCreate = const AttachmentException(AttachmentFailure.quota);
    final h = open(server);
    await settle();
    await h.notifier.add([file('a.txt', 4)]);
    await settle();

    h.notifier.dismiss(h.state.uploads.single.localId);

    expect(h.state.uploads, isEmpty);
  });

  test('a delete takes the file off at once and keeps it gone', () async {
    final server = FakeAttachments(initial: [attachment('f1', 'a.pdf')]);
    final h = open(server);
    await settle();

    final done = h.notifier.delete(h.state.attachments.single);
    expect(h.state.attachments, isEmpty);
    await done;

    expect(server.deleted, ['f1']);
  });

  test('a refused delete puts the file back and says why', () async {
    final server = FakeAttachments(initial: [attachment('f1', 'a.pdf')])
      ..failDelete = const AttachmentException(AttachmentFailure.forbidden);
    final h = open(server);
    await settle();

    await h.notifier.delete(h.state.attachments.single);

    expect(h.state.attachments.map((a) => a.id), ['f1']);
    expect(h.state.error?.failure, AttachmentFailure.forbidden);
    h.notifier.clearError();
    expect(h.state.error, isNull);
  });

  test('refresh reads again', () async {
    final server = FakeAttachments();
    final h = open(server);
    await settle();
    server.files.add(attachment('f9', 'late.png'));

    await h.notifier.refresh();

    expect(h.state.attachments.map((a) => a.id), ['f9']);
  });

  test('a failed read is kept as the error', () async {
    final h = open(_Broken());
    await settle();

    expect(h.state.error?.failure, AttachmentFailure.network);
    expect(h.state.loading, isFalse);
  });

  test('the usage and a file link come from the server', () async {
    final server = FakeAttachments(
      usageValue: const StorageUsage(
        usedBytes: 5,
        quotaBytes: 10,
        fileCount: 1,
        maxFileBytes: 7,
      ),
    );
    final h = open(server);

    final usage = await h.container.read(storageUsageProvider.future);
    final link = await h.container.read(
      fileLinkProvider((id: 'f1', thumb: true)).future,
    );

    expect(usage.usedBytes, 5);
    expect(link.url, 'https://files.test/f1/thumb');
  });
}

class _Vanishing implements UploadSource {
  const _Vanishing();

  @override
  String get name => 'vanished.bin';

  @override
  Future<int> length() async => throw const FileSystemException('gone');

  @override
  Stream<List<int>> read(int start, int end) => throw StateError('never read');
}

class _FailsWhileReading implements UploadSource {
  const _FailsWhileReading();

  @override
  String get name => 'broken.bin';

  @override
  Future<int> length() async => 8;

  @override
  Stream<List<int>> read(int start, int end) async* {
    throw const FileSystemException('permission withdrawn');
  }
}

class _Workspace extends Notifier<String?> {
  @override
  String? build() => 'w1';

  void switchTo(String id) => state = id;
}

final _workspace = NotifierProvider<_Workspace, String?>(_Workspace.new);

void moreTests() {
  test(
    'a file that cannot be read fails by itself and the others go up',
    () async {
      final server = FakeAttachments();
      final h = open(server);
      await settle();

      await h.notifier.add([const _Vanishing(), file('ok.txt', 3)]);
      await settle();

      expect(h.state.uploads.single.filename, 'vanished.bin');
      expect(h.state.uploads.single.error, AttachmentFailure.unreadable);
      expect(h.state.uploads.single.canRetry, isFalse);
      expect(h.state.attachments.map((a) => a.filename), ['ok.txt']);
    },
  );

  test('a file that fails while being read does not stop the queue', () async {
    final server = FakeAttachments();
    final h = open(server);
    await settle();

    await h.notifier.add([const _FailsWhileReading(), file('ok.txt', 3)]);
    await settle();

    expect(h.state.uploads.map((u) => (u.filename, u.state)), [
      ('broken.bin', UploadState.failed),
    ]);
    expect(h.state.attachments.map((a) => a.filename), ['ok.txt']);
  });

  test('too many open uploads and a down scanner are told apart from a full workspace', () async {
    final server = FakeAttachments()
      ..failCreate = const AttachmentException(
        AttachmentFailure.tooManyUploads,
      );
    final h = open(server);
    await settle();
    await h.notifier.add([file('a.txt', 3)]);
    await settle();
    expect(h.state.uploads.single.error, AttachmentFailure.tooManyUploads);
    expect(h.state.uploads.single.canRetry, isTrue);
    h.notifier.dismiss(h.state.uploads.single.localId);

    server.failComplete = const AttachmentException(
      AttachmentFailure.unavailable,
    );
    await h.notifier.add([file('b.txt', 3)]);
    await settle();
    final waiting = h.state.uploads.single;
    expect(waiting.error, AttachmentFailure.unavailable);

    await h.notifier.retry(waiting.localId); // the scanner is back
    await settle();
    expect(h.state.uploads, isEmpty);
    expect(h.state.attachments.map((a) => a.filename), ['b.txt']);
    expect(server.created, hasLength(1)); // the retry kept b.txt's session
  });

  test('a lost answer to complete does not show the file twice', () async {
    final server = FakeAttachments()..loseCompleteAnswers = 1;
    final h = open(server);
    await settle();

    await h.notifier.add([file('a.txt', 3)]);
    await settle();

    expect(server.files, hasLength(1));
    expect(h.state.attachments.map((a) => a.id), [server.files.single.id]);
    expect(h.state.uploads, isEmpty);
  });

  test(
    'retrying after the session was lost finds the file already stored',
    () async {
      final server = FakeAttachments()
        ..putFailures.add(const AttachmentException(AttachmentFailure.other));
      final h = open(server);
      await settle();
      await h.notifier.add([file('a.txt', 3)]);
      await settle();
      expect(h.state.uploads.single.state, UploadState.failed);
      // Meanwhile the file made it (an earlier answer was lost) and the session went.
      server.files.add(attachment('f1', 'a.txt', size: 3));
      server.forgetSessions = true;

      await h.notifier.retry(h.state.uploads.single.localId);
      await settle();

      expect(server.created, hasLength(1)); // no second session
      expect(h.state.uploads, isEmpty);
      expect(h.state.attachments.map((a) => a.id), ['f1']);
    },
  );

  test(
    'dismissing a failed upload tells the server to drop what it holds',
    () async {
      final server = FakeAttachments()
        ..putFailures.add(const AttachmentException(AttachmentFailure.other));
      final h = open(server);
      await settle();
      await h.notifier.add([file('a.txt', 3)]);
      await settle();

      h.notifier.dismiss(h.state.uploads.single.localId);
      await settle();

      expect(server.cancelled, ['up1']);
      expect(h.state.uploads, isEmpty);
    },
  );

  test('cancelling drops the request in flight', () async {
    final server = FakeAttachments()..gate = Completer<void>();
    final h = open(server);
    await settle();
    await h.notifier.add([file('a.txt', 3)]);
    await settle();
    var aborted = false;
    unawaited(server.lastAbort!.then((_) => aborted = true));

    h.notifier.cancel(h.state.uploads.single.localId);
    await settle();

    expect(aborted, isTrue);
    server.gate!.complete();
    await settle();
    expect(h.state.uploads.single.state, UploadState.cancelled);
  });

  test(
    'a delete that finishes after the screen is gone does nothing',
    () async {
      final server = FakeAttachments(initial: [attachment('f1', 'a.pdf')])
        ..deleteGate = Completer<void>()
        ..failDelete = const AttachmentException(AttachmentFailure.forbidden);
      final h = open(server);
      await settle();

      final pending = h.notifier.delete(h.state.attachments.single);
      h.container.dispose();
      server.deleteGate!.complete();

      await pending; // no "used after dispose"
    },
  );

  test('a refused delete puts back only that file', () async {
    final server =
        FakeAttachments(
            initial: [attachment('f1', 'a.pdf'), attachment('f2', 'b.pdf')],
          )
          ..deleteGate = Completer<void>()
          ..failDelete = const AttachmentException(AttachmentFailure.forbidden);
    final h = open(server);
    await settle();

    final pending = h.notifier.delete(h.state.attachments.first);
    // While it waits, somebody else adds f3 and the list is read again.
    server.files.add(attachment('f3', 'c.pdf'));
    await h.notifier.refresh();
    expect(h.state.attachments.map((a) => a.id), ['f1', 'f2', 'f3']);
    server.deleteGate!.complete();
    await pending;

    expect(h.state.attachments.map((a) => a.id).toSet(), {'f1', 'f2', 'f3'});
    expect(h.state.attachments.where((a) => a.id == 'f1'), hasLength(1));
  });

  test('an upload never lands in another workspace after a switch', () async {
    final server = FakeAttachments()..gate = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        workspaceScopeProvider.overrideWith((ref) => ref.watch(_workspace)),
        currentUserIdProvider.overrideWithValue('u1'),
        attachmentsClientProvider.overrideWithValue(server),
        uploadsClientProvider.overrideWithValue(server),
      ],
    );
    addTearDown(container.dispose);
    container.listen(attachmentsProvider(ref), (_, _) {});
    container.read(attachmentsProvider(ref).notifier).backoff = (_) async {};
    await settle();
    await container.read(attachmentsProvider(ref).notifier).add([
      file('a.txt', 3),
    ]);
    await settle();
    expect(container.read(attachmentsProvider(ref)).uploads, hasLength(1));

    container.read(_workspace.notifier).switchTo('w2');
    await settle();
    server.gate!.complete();
    await settle();

    final now = container.read(attachmentsProvider(ref));
    expect(now.uploads, isEmpty);
    expect(now.attachments, isEmpty);
    expect(server.created.single.workspace, 'w1');
    expect(server.files, isEmpty); // the upload was stopped, not finished there
    expect(server.cancelled, hasLength(1));
  });

  test('a gap in the live feed reads the list again', () async {
    final server = FakeAttachments();
    final h = open(server);
    await settle();
    server.files.add(attachment('f9', 'late.png'));

    h.container.read(attachmentsResyncProvider.notifier).bump();
    await settle();

    expect(h.state.attachments.map((a) => a.id), ['f9']);
  });
}

class _Broken extends FakeAttachments {
  @override
  Future<List<Attachment>> list(String w, String p, String t) async =>
      throw const AttachmentException(AttachmentFailure.network);
}
