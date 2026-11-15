import 'dart:async';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attachments_io.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

import '../attachments/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

BytesSource bytes(String name, int length) =>
    BytesSource(name, Uint8List.fromList(List.generate(length, (i) => i)));

Override picking(List<UploadSource> sources) =>
    filePickerProvider.overrideWithValue(() async => sources);

Comment seed(
  String id,
  String text, {
  String author = 'u2',
  String parent = '',
}) => Comment(
  id: id,
  taskId: 'a',
  authorId: author,
  parentId: parent,
  body: bodyFromComposer(text, const []),
  createdAt: DateTime.now(),
);

Attachment onComment(
  String id,
  String filename,
  String commentId, {
  String uploader = 'u1',
  String mime = 'text/plain',
}) => Attachment(
  id: id,
  taskId: 'a',
  commentId: commentId,
  uploaderId: uploader,
  filename: filename,
  mime: mime,
  size: 5,
  createdAt: DateTime.now(),
);

Future<void> open(
  WidgetTester tester, {
  required FakeCommentsClient comments,
  required FakeAttachments files,
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
    comments: comments,
    attachments: files,
    overrides: overrides,
    size: const Size(1400, 2400),
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.text('Fix login'));
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)).first);
  await tester.tap(find.byKey(Key(key)).first);
  await tester.pumpAndSettle();
}

Future<void> write(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('comment-input')).first, text);
  await tester.pump();
}

Future<void> sendMain(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tapKey(tester, 'comment-send');
}

void main() {
  testWidgets(
    'files chosen in the composer show as chips and can be taken off',
    (tester) async {
      final files = FakeAttachments();
      await open(
        tester,
        comments: FakeCommentsClient(),
        files: files,
        overrides: [
          picking([bytes('a.txt', 3), bytes('b.txt', 3)]),
        ],
      );

      await tapKey(tester, 'comment-attach-add');

      expect(find.byKey(const Key('chosen-file-0')), findsOneWidget);
      expect(find.text('a.txt'), findsOneWidget);
      expect(find.text('b.txt'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove a.txt'));
      await tester.pumpAndSettle();
      expect(find.text('a.txt'), findsNothing);
      expect(find.text('b.txt'), findsOneWidget);
      expect(files.created, isEmpty); // nothing goes up before the comment
    },
  );

  testWidgets('sending uploads the files to the new comment, after it exists', (
    tester,
  ) async {
    final comments = FakeCommentsClient();
    final files = FakeAttachments();
    await open(
      tester,
      comments: comments,
      files: files,
      overrides: [
        picking([bytes('notes.txt', 9)]),
      ],
    );
    await write(tester, 'See attached');
    await tapKey(tester, 'comment-attach-add');

    await sendMain(tester);

    expect(comments.created, hasLength(1));
    final made = comments.comments.single;
    expect(files.created.single.filename, 'notes.txt');
    expect(files.created.single.commentId, made.id);
    // The file shows under its comment, not in the task's own grid.
    expect(
      find.descendant(
        of: find.byKey(Key('comment-files-${made.id}')),
        matching: find.text('notes.txt'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('attachment-grid')), findsNothing);
    // The composer is empty again.
    expect(find.byKey(const Key('chosen-files')), findsNothing);
  });

  testWidgets('progress shows under the comment while the file goes up', (
    tester,
  ) async {
    final files = FakeAttachments()..gate = Completer<void>();
    await open(
      tester,
      comments: FakeCommentsClient(),
      files: files,
      overrides: [
        picking([bytes('big.bin', 8)]),
      ],
    );
    await write(tester, 'Big one');
    await tapKey(tester, 'comment-attach-add');

    await sendMain(tester);
    await tester.pump();

    final progress = find.byWidgetPredicate(
      (w) =>
          w is LinearProgressIndicator &&
          w.key.toString().contains('upload-progress'),
    );
    expect(progress, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('comment-files-n1')),
        matching: progress,
      ),
      findsOneWidget,
    );

    files.gate!.complete();
    await tester.pumpAndSettle();
    expect(progress, findsNothing);
  });

  testWidgets('a failed upload does not lose the comment, and can be retried', (
    tester,
  ) async {
    final comments = FakeCommentsClient();
    final files = FakeAttachments()
      ..failCreate = const AttachmentException(AttachmentFailure.quota);
    await open(
      tester,
      comments: comments,
      files: files,
      overrides: [
        picking([bytes('a.txt', 3)]),
      ],
    );
    await write(tester, 'Keep me');
    await tapKey(tester, 'comment-attach-add');

    await sendMain(tester);

    expect(comments.comments, hasLength(1)); // the comment is there
    expect(find.byKey(const Key('comment-n1')), findsOneWidget);
    expect(
      find.text('This workspace has used all its storage.'),
      findsOneWidget,
    );

    final retry = find.byWidgetPredicate(
      (w) => w.key.toString().contains('upload-retry'),
    );
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(files.files.single.commentId, 'n1');
    expect(comments.comments, hasLength(1)); // not sent twice
  });

  testWidgets('a comment that fails to send keeps its files in the composer', (
    tester,
  ) async {
    final comments = FakeCommentsClient()
      ..failNext = const CommentException(CommentFailure.network);
    final files = FakeAttachments();
    await open(
      tester,
      comments: comments,
      files: files,
      overrides: [
        picking([bytes('a.txt', 3)]),
      ],
    );
    await write(tester, 'Flaky');
    await tapKey(tester, 'comment-attach-add');

    await sendMain(tester);

    expect(find.byKey(const Key('chosen-file-0')), findsOneWidget);
    expect(files.created, isEmpty); // no comment, so nothing to attach to

    await sendMain(tester);

    expect(files.created.single.commentId, isNotEmpty);
    expect(find.byKey(const Key('chosen-files')), findsNothing);
  });

  testWidgets('retrying a failed comment sends its files too', (tester) async {
    final comments = FakeCommentsClient()
      ..failNext = const CommentException(CommentFailure.network);
    final files = FakeAttachments();
    await open(
      tester,
      comments: comments,
      files: files,
      overrides: [
        picking([bytes('a.txt', 3)]),
      ],
    );
    await write(tester, 'Flaky');
    await tapKey(tester, 'comment-attach-add');
    await sendMain(tester);

    await tapKey(tester, 'retry-local-1');

    expect(files.files.single.commentId, 'n1');
  });

  testWidgets('a reply can carry files', (tester) async {
    final comments = FakeCommentsClient(initial: [seed('c1', 'Question?')]);
    final files = FakeAttachments();
    await open(
      tester,
      comments: comments,
      files: files,
      overrides: [
        picking([bytes('answer.txt', 3)]),
      ],
    );
    await tester.ensureVisible(find.byKey(const Key('menu-c1')));
    await tester.tap(find.byKey(const Key('menu-c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    final reply = find.byKey(const Key('reply-composer'));
    Finder inReply(String key) =>
        find.descendant(of: reply, matching: find.byKey(Key(key)));
    Future<void> tapInReply(String key) async {
      await tester.ensureVisible(inReply(key));
      await tester.tap(inReply(key));
      await tester.pumpAndSettle();
    }

    await tester.enterText(inReply('comment-input'), 'Here you go');
    await tapInReply('comment-attach-add');
    await tapInReply('comment-send');

    expect(files.created.single.commentId, 'n1');
    expect(comments.comments.last.parentId, 'c1');
  });

  testWidgets('files of a comment show as chips and open the viewer', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [
        onComment('f1', 'log.txt', 'c1'),
        onComment('f2', 'shot.png', 'c1', mime: 'image/png'),
      ],
    )..textBody = 'inside the log';
    await open(
      tester,
      comments: FakeCommentsClient(initial: [seed('c1', 'Look at these')]),
      files: files,
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('comment-files-c1')),
        matching: find.text('log.txt'),
      ),
      findsOneWidget,
    );
    await tapKey(tester, 'open-f1');

    expect(find.byKey(const Key('attachment-viewer')), findsOneWidget);
    expect(find.textContaining('inside the log'), findsOneWidget);
  });

  testWidgets('a comment without files shows nothing extra', (tester) async {
    await open(
      tester,
      comments: FakeCommentsClient(initial: [seed('c1', 'Just words')]),
      files: FakeAttachments(),
    );

    expect(find.byKey(const Key('comment-files-c1')), findsNothing);
  });

  testWidgets('only the uploader (or a manager) can delete a comment file', (
    tester,
  ) async {
    final files = FakeAttachments(
      initial: [
        onComment('f1', 'mine.txt', 'c1', uploader: 'u1'),
        onComment('f2', 'theirs.txt', 'c1', uploader: 'u2'),
      ],
    );
    await open(
      tester,
      comments: FakeCommentsClient(initial: [seed('c1', 'Files')]),
      files: files,
      role: 'Member',
    );

    expect(find.byKey(const Key('attachment-delete-f1')), findsOneWidget);
    expect(find.byKey(const Key('attachment-delete-f2')), findsNothing);

    await tapKey(tester, 'attachment-delete-f1');
    await tapKey(tester, 'delete-attachment-confirm');

    expect(files.deleted, ['f1']);
    expect(find.byKey(const Key('attachment-f1')), findsNothing);
  });

  testWidgets('an owner can delete anybody\'s comment file', (tester) async {
    final files = FakeAttachments(
      initial: [onComment('f2', 'theirs.txt', 'c1', uploader: 'u2')],
    );
    await open(
      tester,
      comments: FakeCommentsClient(initial: [seed('c1', 'Files')]),
      files: files,
    );

    await tapKey(tester, 'attachment-delete-f2');
    await tapKey(tester, 'delete-attachment-confirm');

    expect(files.deleted, ['f2']);
  });

  testWidgets('an archived project shows comment files read-only', (
    tester,
  ) async {
    await open(
      tester,
      comments: FakeCommentsClient(initial: [seed('c1', 'Old')]),
      files: FakeAttachments(initial: [onComment('f1', 'old.txt', 'c1')]),
      archived: true,
    );

    expect(find.byKey(const Key('attachment-f1')), findsOneWidget);
    expect(find.byKey(const Key('attachment-delete-f1')), findsNothing);
    expect(find.byKey(const Key('comment-attach-add')), findsNothing);
  });

  testWidgets('editing a comment offers no attachments', (tester) async {
    await open(
      tester,
      comments: FakeCommentsClient(initial: [seed('c1', 'Mine', author: 'u1')]),
      files: FakeAttachments(),
    );
    await tester.ensureVisible(find.byKey(const Key('menu-c1')));
    await tester.tap(find.byKey(const Key('menu-c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit-c1')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('edit-c1')),
        matching: find.byKey(const Key('comment-attach-add')),
      ),
      findsNothing,
    );
  });
}
