import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attachments_io.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

BytesSource bytes(String name, int length) =>
    BytesSource(name, Uint8List.fromList(List.generate(length, (i) => i)));

Future<void> open(
  WidgetTester tester,
  FakeAttachments files, {
  String role = 'Owner',
  bool archived = false,
  List<Override> overrides = const [],
}) async {
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web', archived: archived)],
    tasks: FakeTasksClient([task('a', 'Fix login')]),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    attachments: files,
    overrides: overrides,
    size: const Size(1400, 2000),
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.text('Fix login'));
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Override picking(List<UploadSource> sources) =>
    filePickerProvider.overrideWithValue(() async => sources);

void main() {
  testWidgets('shows the files with their size and what the workspace uses', (
    tester,
  ) async {
    await open(
      tester,
      FakeAttachments(
        initial: [
          attachment('f1', 'spec.pdf', size: 2048, mime: 'application/pdf'),
        ],
        usageValue: const StorageUsage(
          usedBytes: 3 * 1024 * 1024,
          quotaBytes: 10 * 1024 * 1024 * 1024,
          fileCount: 1,
          maxFileBytes: 1 << 20,
        ),
      ),
    );

    expect(find.text('Attachments (1)'), findsOneWidget);
    expect(find.text('spec.pdf'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);
    expect(find.text('3 MB of 10 GB used'), findsOneWidget);
  });

  testWidgets('without a limit the usage line just says what is used', (
    tester,
  ) async {
    await open(
      tester,
      FakeAttachments(
        usageValue: const StorageUsage(
          usedBytes: 500,
          quotaBytes: 0,
          fileCount: 0,
          maxFileBytes: 0,
        ),
      ),
    );

    expect(find.byKey(const Key('storage-usage')), findsOneWidget);
    expect(find.text('500 B used'), findsOneWidget);
  });

  testWidgets('a viewer reads only: no zone, no Add, and says so when empty', (
    tester,
  ) async {
    await open(tester, FakeAttachments(), role: 'Viewer');

    expect(find.byKey(const Key('no-attachments')), findsOneWidget);
    expect(find.byKey(const Key('attachment-add')), findsNothing);
    expect(find.byKey(const Key('drop-zone')), findsNothing);
  });

  testWidgets('an archived project keeps its files but takes no more', (
    tester,
  ) async {
    await open(
      tester,
      FakeAttachments(initial: [attachment('f1', 'old.txt')]),
      archived: true,
    );

    expect(find.byKey(const Key('attachment-f1')), findsOneWidget);
    expect(find.byKey(const Key('attachment-add')), findsNothing);
    expect(find.byKey(const Key('attachment-delete-f1')), findsNothing);
  });

  testWidgets('Add picks files and they upload into the grid', (tester) async {
    final files = FakeAttachments();
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('notes.txt', 9)]),
      ],
    );

    await tapKey(tester, 'attachment-add');

    expect(find.text('notes.txt'), findsOneWidget);
    expect(files.created.single.filename, 'notes.txt');
    expect(files.puts.map((p) => p.n), [0, 1, 2]);
    expect(find.text('Attachments (1)'), findsOneWidget);
  });

  testWidgets('progress shows, and cancel stops the upload for a retry', (
    tester,
  ) async {
    final files = FakeAttachments()..gate = Completer<void>();
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('big.bin', 8)]),
      ],
    );

    await tapKey(tester, 'attachment-add');
    await tester.pump();

    final progress = find.byWidgetPredicate(
      (w) =>
          w is LinearProgressIndicator &&
          w.key.toString().contains('upload-progress'),
    );
    expect(progress, findsOneWidget);

    final cancel = find.byWidgetPredicate(
      (w) => w.key.toString().contains('upload-cancel'),
    );
    await tester.tap(cancel);
    files.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsOneWidget);
    expect(files.cancelled, hasLength(1));
    expect(find.text('Attachments (1)'), findsNothing);

    final retry = find.byWidgetPredicate(
      (w) => w.key.toString().contains('upload-retry'),
    );
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(find.text('Attachments (1)'), findsOneWidget);
    expect(find.text('Cancelled'), findsNothing);
  });

  testWidgets('a refused upload says why in plain words and can be dismissed', (
    tester,
  ) async {
    final files = FakeAttachments()
      ..failCreate = const AttachmentException(AttachmentFailure.quota);
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('a.txt', 3)]),
      ],
    );

    await tapKey(tester, 'attachment-add');

    expect(
      find.text('This workspace has used all its storage.'),
      findsOneWidget,
    );
    final dismiss = find.byWidgetPredicate(
      (w) => w.key.toString().contains('upload-dismiss'),
    );
    await tester.tap(dismiss);
    await tester.pumpAndSettle();
    expect(find.text('This workspace has used all its storage.'), findsNothing);
  });

  testWidgets('a file over the size limit is refused before it is sent', (
    tester,
  ) async {
    final files = FakeAttachments(
      usageValue: const StorageUsage(
        usedBytes: 0,
        quotaBytes: 0,
        fileCount: 0,
        maxFileBytes: 5,
      ),
    );
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('huge.bin', 9)]),
      ],
    );

    await tapKey(tester, 'attachment-add');

    expect(
      find.text('That file is larger than an attachment may be.'),
      findsOneWidget,
    );
    expect(files.created, isEmpty);
    expect(
      find.byWidgetPredicate((w) => w.key.toString().contains('upload-retry')),
      findsNothing,
    );
  });

  testWidgets('a refusal after the bytes are up shows what the server said', (
    tester,
  ) async {
    final files = FakeAttachments()
      ..failComplete = const AttachmentException(
        AttachmentFailure.refused,
        detail: 'programs are not allowed',
      );
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('run.exe', 3)]),
      ],
    );

    await tapKey(tester, 'attachment-add');

    expect(
      find.text('That file is not accepted: programs are not allowed'),
      findsOneWidget,
    );
  });

  testWidgets('the uploader deletes their own file after confirming', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f1', 'mine.txt', uploader: 'u1')],
    );
    await open(tester, files, role: 'Member');

    await tapKey(tester, 'attachment-delete-f1');
    expect(find.byKey(const Key('delete-attachment-dialog')), findsOneWidget);
    await tapKey(tester, 'delete-attachment-cancel');
    expect(files.deleted, isEmpty);

    await tapKey(tester, 'attachment-delete-f1');
    await tapKey(tester, 'delete-attachment-confirm');

    expect(files.deleted, ['f1']);
    expect(find.byKey(const Key('attachment-f1')), findsNothing);
  });

  testWidgets("a member cannot delete somebody else's file, an owner can", (
    tester,
  ) async {
    final theirs = [attachment('f2', 'theirs.txt', uploader: 'u2')];
    await open(tester, FakeAttachments(initial: theirs), role: 'Member');
    expect(find.byKey(const Key('attachment-f2')), findsOneWidget);
    expect(find.byKey(const Key('attachment-delete-f2')), findsNothing);
  });

  testWidgets('an owner holds attachment management and deletes any file', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f2', 'theirs.txt', uploader: 'u2')],
    );
    await open(tester, files);

    await tapKey(tester, 'attachment-delete-f2');
    await tapKey(tester, 'delete-attachment-confirm');

    expect(files.deleted, ['f2']);
  });

  testWidgets('a refused delete brings the file back with the reason', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f1', 'mine.txt', uploader: 'u1')],
    )..failDelete = const AttachmentException(AttachmentFailure.forbidden);
    await open(tester, files);

    await tapKey(tester, 'attachment-delete-f1');
    await tapKey(tester, 'delete-attachment-confirm');

    expect(find.byKey(const Key('attachment-f1')), findsOneWidget);
    expect(find.text('You are not allowed to do that.'), findsOneWidget);
    await tapKey(tester, 'attachment-error-dismiss');
    expect(find.byKey(const Key('attachment-error')), findsNothing);
  });

  testWidgets('camera and gallery are offered on a phone and add files', (
    tester,
  ) async {
    final files = FakeAttachments();
    await open(
      tester,
      files,
      overrides: [
        cameraPickerProvider.overrideWithValue(
          () async => [bytes('shot.png', 4)],
        ),
        galleryPickerProvider.overrideWithValue(
          () async => [bytes('one.jpg', 4), bytes('two.jpg', 4)],
        ),
      ],
    );
    expect(find.byKey(const Key('attachment-paste')), findsNothing);

    await tapKey(tester, 'attachment-camera');
    await tapKey(tester, 'attachment-gallery');

    expect(files.files.map((f) => f.filename), [
      'shot.png',
      'one.jpg',
      'two.jpg',
    ]);
  });

  testWidgets('on a desktop an image from the clipboard can be pasted', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final files = FakeAttachments();
    await open(
      tester,
      files,
      overrides: [
        clipboardImageProvider.overrideWithValue(
          () async => bytes('pasted-1.png', 5),
        ),
      ],
    );
    expect(find.byKey(const Key('attachment-camera')), findsNothing);

    await tapKey(tester, 'attachment-paste');
    debugDefaultTargetPlatformOverride = null;

    expect(files.files.single.filename, 'pasted-1.png');
  });

  testWidgets('an empty clipboard pastes nothing', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final files = FakeAttachments();
    await open(
      tester,
      files,
      overrides: [clipboardImageProvider.overrideWithValue(() async => null)],
    );

    await tapKey(tester, 'attachment-paste');
    debugDefaultTargetPlatformOverride = null;

    expect(files.created, isEmpty);
  });

  testWidgets('an image opens in the lightbox, which can download and close', (
    tester,
  ) async {
    final opened = <Uri>[];
    final files = FakeAttachments(
      initial: [attachment('f1', 'shot.png', mime: 'image/png', thumb: true)],
    );
    await open(
      tester,
      files,
      overrides: [
        urlOpenerProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return true;
        }),
      ],
    );

    await tapKey(tester, 'open-f1');
    expect(find.byKey(const Key('attachment-viewer')), findsOneWidget);
    expect(find.byKey(const Key('viewer-image')), findsOneWidget);

    await tester.tap(find.byKey(const Key('viewer-download')));
    await tester.pumpAndSettle();
    expect(opened.single.toString(), 'https://files.test/f1');

    await tester.tap(find.byKey(const Key('viewer-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('attachment-viewer')), findsNothing);
  });

  testWidgets('a text file shows its first part in the lightbox', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f1', 'log.txt', mime: 'text/plain')],
    )..textBody = 'line one\nline two';
    await open(tester, files);

    await tapKey(tester, 'open-f1');

    expect(find.byKey(const Key('viewer-text')), findsOneWidget);
    expect(find.textContaining('line two'), findsOneWidget);
  });

  testWidgets('a PDF shows its first page and an Open button', (tester) async {
    final opened = <Uri>[];
    final files = FakeAttachments(
      initial: [
        attachment('f1', 'spec.pdf', mime: 'application/pdf', thumb: true),
      ],
    );
    await open(
      tester,
      files,
      overrides: [
        urlOpenerProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return false; // the system could not open it
        }),
      ],
    );

    await tapKey(tester, 'open-f1');
    expect(find.byKey(const Key('viewer-fallback')), findsOneWidget);

    await tester.tap(find.byKey(const Key('viewer-open')));
    await tester.pumpAndSettle();

    expect(opened, hasLength(1));
    expect(find.text('Could not open the file.'), findsOneWidget);
  });

  testWidgets('any other file gets a plain card and a download button', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f1', 'data.zip', mime: 'application/zip')],
    );
    await open(tester, files);

    await tapKey(tester, 'open-f1');

    expect(find.byKey(const Key('viewer-fallback')), findsOneWidget);
    expect(find.byKey(const Key('viewer-open')), findsNothing);
    expect(find.byKey(const Key('viewer-download')), findsOneWidget);
  });

  testWidgets('the lightbox can delete a file the person may delete', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f1', 'data.zip', uploader: 'u1')],
    );
    await open(tester, files);

    await tapKey(tester, 'open-f1');
    await tapKey(tester, 'viewer-delete');
    // It asks first, as the grid does: the viewer stays until it is answered.
    expect(find.byKey(const Key('delete-attachment-dialog')), findsOneWidget);
    expect(find.byKey(const Key('attachment-viewer')), findsOneWidget);
    await tapKey(tester, 'delete-attachment-cancel');
    expect(files.deleted, isEmpty);
    expect(find.byKey(const Key('attachment-viewer')), findsOneWidget);

    await tapKey(tester, 'viewer-delete');
    await tapKey(tester, 'delete-attachment-confirm');

    expect(files.deleted, ['f1']);
    expect(find.byKey(const Key('attachment-viewer')), findsNothing);
  });

  testWidgets('the lightbox of a file somebody else owns has no delete', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f2', 'theirs.zip', uploader: 'u2')],
    );
    await open(tester, files, role: 'Member');

    await tapKey(tester, 'open-f2');

    expect(find.byKey(const Key('viewer-delete')), findsNothing);
  });

  testWidgets('too many open uploads says so, apart from a full workspace', (
    tester,
  ) async {
    final files = FakeAttachments()
      ..failCreate = const AttachmentException(
        AttachmentFailure.tooManyUploads,
      );
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('a.txt', 3)]),
      ],
    );

    await tapKey(tester, 'attachment-add');

    expect(
      find.text('Too many uploads are open. Finish or cancel some first.'),
      findsOneWidget,
    );
    expect(find.text('This workspace has used all its storage.'), findsNothing);
  });

  testWidgets('a scanner that is down says to try again, and trying works', (
    tester,
  ) async {
    final files = FakeAttachments()
      ..failComplete = const AttachmentException(AttachmentFailure.unavailable);
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('a.txt', 3)]),
      ],
    );

    await tapKey(tester, 'attachment-add');
    expect(
      find.text('The file could not be checked right now. Try again.'),
      findsOneWidget,
    );

    final retry = find.byWidgetPredicate(
      (w) => w.key.toString().contains('upload-retry'),
    );
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(find.text('Attachments (1)'), findsOneWidget);
    expect(files.created, hasLength(1)); // the same upload was completed
  });

  testWidgets('a picture that fails to load asks for a fresh link once', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [attachment('f1', 'shot.png', mime: 'image/png', thumb: true)],
    );
    await open(tester, files);

    expect(files.links.where((l) => l == 'f1/thumb'), hasLength(2));
    expect(find.byKey(const Key('attachment-f1')), findsOneWidget);
  });

  testWidgets('a picker that fails is told, not thrown', (tester) async {
    await open(
      tester,
      FakeAttachments(),
      overrides: [
        filePickerProvider.overrideWithValue(
          () async => throw StateError('permission revoked'),
        ),
      ],
    );

    await tapKey(tester, 'attachment-add');

    expect(find.text('Could not read that file.'), findsOneWidget);
  });

  testWidgets('a file that cannot be read does not stop the others', (
    tester,
  ) async {
    final files = FakeAttachments();
    await open(
      tester,
      files,
      overrides: [
        picking([_Gone(), bytes('ok.txt', 3)]),
      ],
    );

    await tapKey(tester, 'attachment-add');

    expect(find.text('Could not read that file.'), findsOneWidget);
    expect(find.text('ok.txt'), findsOneWidget);
  });

  testWidgets('progress, errors and buttons can be read by a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final files = FakeAttachments(initial: [attachment('f1', 'mine.txt')])
      ..gate = Completer<void>();
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('big.bin', 8)]),
      ],
    );

    await tapKey(tester, 'attachment-add');
    await tester.pump();

    expect(
      find.bySemanticsLabel(RegExp(r'big\.bin, \d+ percent uploaded')),
      findsOneWidget,
    );
    expect(find.byTooltip('Cancel big.bin'), findsOneWidget);
    expect(find.byTooltip('Delete mine.txt'), findsOneWidget);
    expect(find.bySemanticsLabel('Open mine.txt'), findsOneWidget);
    // Buttons are at least the size a finger needs.
    final box = tester.getSize(find.byKey(const Key('attachment-delete-f1')));
    expect(box.width, greaterThanOrEqualTo(48));
    expect(box.height, greaterThanOrEqualTo(48));

    files.gate!.complete();
    await tester.pumpAndSettle();
    handle.dispose();
  });

  testWidgets('a failure is announced as it appears', (tester) async {
    final handle = tester.ensureSemantics();
    final files = FakeAttachments()
      ..failCreate = const AttachmentException(AttachmentFailure.quota);
    await open(
      tester,
      files,
      overrides: [
        picking([bytes('a.txt', 3)]),
      ],
    );

    await tapKey(tester, 'attachment-add');

    final status = find.byWidgetPredicate(
      (w) => w.key.toString().contains('upload-status'),
    );
    final node = tester.getSemantics(
      find.ancestor(of: status, matching: find.byType(Semantics)).first,
    );
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('files of a comment are not in the task grid', (tester) async {
    final files = FakeAttachments(
      initial: [
        attachment('f1', 'on-task.txt'),
        Attachment(
          id: 'f2',
          taskId: 'a',
          commentId: 'c1',
          uploaderId: 'u1',
          filename: 'on-comment.txt',
          mime: 'text/plain',
          size: 3,
          createdAt: DateTime.now(),
        ),
      ],
    );
    await open(tester, files);

    expect(find.text('Attachments (1)'), findsOneWidget);
    expect(find.text('on-task.txt'), findsOneWidget);
    expect(find.text('on-comment.txt'), findsNothing);
  });
}

class _Gone implements UploadSource {
  @override
  String get name => 'gone.bin';

  @override
  Future<int> length() async => throw StateError('moved');

  @override
  Stream<List<int>> read(int start, int end) => const Stream.empty();
}
