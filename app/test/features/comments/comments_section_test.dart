import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

String body(String text) => bodyFromComposer(text, const []);

Comment seed(
  String id,
  String text, {
  String author = 'u2',
  String parent = '',
  DateTime? at,
  bool pinned = false,
}) => Comment(
  id: id,
  taskId: 'a',
  authorId: author,
  parentId: parent,
  body: body(text),
  createdAt: at ?? DateTime.now(),
  pinned: pinned,
);

/// A shown comment body (not the text boxes) that contains [text].
Finder bodyWith(String text) => find.byWidgetPredicate(
  (w) =>
      w is SelectableText &&
      (w.textSpan?.toPlainText() ?? w.data ?? '').contains(text),
);

typedef Opened = ({Pumped pumped, FakeCommentsClient comments});

Future<Opened> open(
  WidgetTester tester, {
  List<Comment> comments = const [],
  String role = 'Owner',
  bool archived = false,
  bool private = false,
  FakeCommentsClient? client,
  int pageSize = 50,
}) async {
  final fake = (client ?? FakeCommentsClient(initial: comments))
    ..pageSize = pageSize;
  final server = FakeTasksClient([task('a', 'Fix login')]);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web', archived: archived, private: private)],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    comments: fake,
    size: const Size(1400, 2000), // the files section sits above the comments
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.text('Fix login'));
  await tester.pumpAndSettle();
  return (pumped: pumped, comments: fake);
}

Future<void> type(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('comment-input')).first, text);
  await tester.pump();
  await tester.pump();
}

Future<void> send(WidgetTester tester) async {
  // A snack bar from an earlier refusal sits over the button until it has gone.
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('comment-send')).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('comment-send')).first);
  await tester.pumpAndSettle();
}

Future<void> menu(WidgetTester tester, String id, String item) async {
  await tester.ensureVisible(find.byKey(Key('menu-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('menu-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the conversation by day with who wrote what', (
    tester,
  ) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await open(
      tester,
      comments: [
        seed('c1', 'First thoughts', at: yesterday),
        seed('c2', 'Mine', author: 'u1'),
      ],
    );

    expect(find.byKey(const Key('comments')), findsOneWidget);
    expect(find.text('Comments (2)'), findsOneWidget);
    expect(find.byKey(const Key('day-Yesterday')), findsOneWidget);
    expect(find.byKey(const Key('day-Today')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('comment-c1')),
        matching: find.text('Hank Hill'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('comment-c2')),
        matching: find.text('You'),
      ),
      findsOneWidget,
    );
    expect(bodyWith('First thoughts'), findsOneWidget);
  });

  testWidgets('an empty task says so', (tester) async {
    await open(tester);

    expect(find.byKey(const Key('no-comments')), findsOneWidget);
  });

  testWidgets('a comment shows at once as sending, then as sent', (
    tester,
  ) async {
    final fake = FakeCommentsClient()..gate = Completer<void>();
    await open(tester, client: fake);

    await type(tester, 'Looks good');
    await tester.ensureVisible(find.byKey(const Key('comment-send')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('comment-send')).first);
    await tester.pump();

    expect(find.byKey(const Key('sending-local-1')), findsOneWidget);
    expect(bodyWith('Looks good'), findsOneWidget);

    fake.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sending-local-1')), findsNothing);
    expect(fake.created.single.parentId, '');
    expect(plainTextOf(fake.created.single.body), 'Looks good');
    expect(find.text('Comments (1)'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('comment-input')))
          .controller!
          .text,
      '',
    );
  });

  testWidgets('a failed send stays, says so, and can be retried or discarded', (
    tester,
  ) async {
    final fake = FakeCommentsClient()
      ..failNext = const CommentException(CommentFailure.network);
    await open(tester, client: fake);

    await type(tester, 'Flaky');
    await send(tester);

    expect(find.byKey(const Key('failed-local-1')), findsOneWidget);
    expect(find.text('Not sent'), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry-local-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('failed-local-1')), findsNothing);
    expect(fake.created, hasLength(2));
    expect(find.text('Comments (1)'), findsOneWidget);

    fake.failNext = const CommentException(CommentFailure.network);
    await type(tester, 'Again');
    await send(tester);
    await tester.tap(find.byKey(const Key('discard-local-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('failed-local-2')), findsNothing);
  });

  testWidgets(
    '@ lists people who can see the task and a pick becomes a mention',
    (tester) async {
      final fake = FakeCommentsClient();
      await open(tester, client: fake);

      await type(tester, 'hey @ana');

      expect(find.byKey(const Key('mention-picker')), findsOneWidget);
      expect(find.byKey(const Key('mention-u-ana')), findsOneWidget);
      expect(
        find.byKey(const Key('mention-u2')),
        findsNothing,
      ); // "Hank Hill" does not match "ana"
      expect(fake.queries, contains('ana'));

      await tester.tap(find.byKey(const Key('mention-u-ana')));
      await tester.pumpAndSettle();
      await send(tester);

      final sent = jsonDecode(fake.created.single.body) as Map<String, dynamic>;
      final nodes = (sent['content'] as List).single['content'] as List;
      expect(nodes.map((n) => n['type']), [
        'text',
        'mention',
        'text',
      ]); // the space after the pick
      expect(nodes[1]['attrs'], {'id': 'u-ana', 'label': 'Ana Silva'});
      expect(bodyWith('@Ana Silva'), findsOneWidget);
    },
  );

  testWidgets('an email-like @ in the middle of a word opens nothing', (
    tester,
  ) async {
    await open(tester);

    await type(tester, 'write to me@example.com');

    expect(find.byKey(const Key('mention-picker')), findsNothing);
  });

  testWidgets(
    'mentioning somebody who cannot see the task offers to add them (managers only)',
    (tester) async {
      final fake = FakeCommentsClient()
        ..failNext = const CommentException(
          CommentFailure.mentionNoAccess,
          people: ['u2'],
        );
      await open(tester, client: fake, private: true);

      await type(tester, 'ping @Hank Hill now');
      await send(tester);

      expect(find.byKey(const Key('grant-dialog')), findsOneWidget);
      expect(find.textContaining('Hank Hill'), findsWidgets);
      await tester.tap(find.byKey(const Key('grant-add')));
      await tester.pumpAndSettle();

      expect(fake.created.last.grant, isTrue);
      expect(find.text('Comments (1)'), findsOneWidget);
      // Posted, so the box is empty: another send cannot post it twice.
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('comment-input')).first)
            .controller!
            .text,
        isEmpty,
      );
    },
  );

  testWidgets(
    'in an open project nobody can be added, only the mention taken out',
    (tester) async {
      final fake = FakeCommentsClient()
        ..failNext = const CommentException(
          CommentFailure.mentionNoAccess,
          people: ['u2'],
        );
      await open(tester, client: fake, role: 'Member');

      await type(tester, 'ping');
      await send(tester);

      expect(find.byKey(const Key('grant-dialog')), findsOneWidget);
      expect(find.byKey(const Key('grant-add')), findsNothing);
      await tester.tap(find.byKey(const Key('grant-cancel')));
      await tester.pumpAndSettle();

      expect(fake.created, hasLength(1)); // nothing was sent again
      expect(find.text('Comments (0)'), findsNothing);
    },
  );

  testWidgets(
    'a reply goes under its comment and replies cannot be replied to',
    (tester) async {
      final fake = FakeCommentsClient(initial: [seed('c1', 'Question?')]);
      await open(tester, client: fake);

      await menu(tester, 'c1', 'Reply');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('reply-composer')),
          matching: find.byKey(const Key('comment-input')),
        ),
        'Answer',
      );
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('reply-composer')),
          matching: find.byKey(const Key('comment-send')),
        ),
      );
      await tester.pumpAndSettle();

      expect(fake.created.single.parentId, 'c1');
      expect(find.byKey(const Key('reply-composer')), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('menu-n1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu-n1')));
      await tester.pumpAndSettle();
      expect(find.text('Reply'), findsNothing); // one level deep
    },
  );

  testWidgets(
    'the author edits, it is marked edited and the history can be read',
    (tester) async {
      final fake = FakeCommentsClient(
        initial: [seed('c1', 'draft', author: 'u1')],
      );
      await open(tester, client: fake);

      await menu(tester, 'c1', 'Edit');
      final box = find.descendant(
        of: find.byKey(const Key('edit-c1')),
        matching: find.byKey(const Key('comment-input')),
      );
      expect(tester.widget<TextField>(box).controller!.text, 'draft');
      await tester.enterText(box, 'final');
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('edit-c1')),
          matching: find.byKey(const Key('comment-send')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('edited-c1')), findsOneWidget);
      expect(bodyWith('final'), findsOneWidget);

      await tester.tap(find.byKey(const Key('edited-c1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history-dialog')), findsOneWidget);
      final dialog = find.byKey(const Key('history-dialog'));
      expect(
        find.descendant(of: dialog, matching: find.text('draft')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('final')),
        findsOneWidget,
      );
      expect(find.textContaining('current'), findsOneWidget);
    },
  );

  testWidgets("others' comments cannot be edited, and a locked one says so", (
    tester,
  ) async {
    final fake = FakeCommentsClient(
      initial: [
        seed('c1', 'theirs'),
        seed('c2', 'mine', author: 'u1'),
      ],
    );
    await open(tester, client: fake);

    await tester.ensureVisible(find.byKey(const Key('menu-c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu-c1')));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsNothing);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    fake.failNext = const CommentException(CommentFailure.locked);
    await menu(tester, 'c2', 'Edit');
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('edit-c2')),
        matching: find.byKey(const Key('comment-input')),
      ),
      'too late',
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('edit-c2')),
        matching: find.byKey(const Key('comment-send')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('That comment can no longer be edited.'), findsOneWidget);
  });

  testWidgets('deleting asks first and leaves "Comment removed"', (
    tester,
  ) async {
    final fake = FakeCommentsClient(
      initial: [seed('c1', 'oops', author: 'u1')],
    );
    await open(tester, client: fake);

    await menu(tester, 'c1', 'Delete');
    expect(find.byKey(const Key('delete-comment-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-delete-comment')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('removed-c1')), findsOneWidget);
    expect(bodyWith('oops'), findsNothing);
  });

  testWidgets('a moderator deletes anyone\'s, a member only their own', (
    tester,
  ) async {
    final theirs = [seed('c1', 'theirs')];
    await open(tester, comments: theirs, role: 'Member');
    expect(
      find.byKey(const Key('menu-c1')),
      findsOneWidget,
    ); // reply, subtask and pin are there
    await tester.tap(find.byKey(const Key('menu-c1')));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('reactions are given, counted and taken back', (tester) async {
    final fake = FakeCommentsClient(initial: [seed('c1', 'nice')]);
    await open(tester, client: fake);

    await tester.ensureVisible(find.byKey(const Key('react-c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('react-c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('👍').last);
    await tester.pumpAndSettle();

    final chip = find.byKey(const Key('reaction-c1-👍'));
    expect(chip, findsOneWidget);
    expect(find.text('👍 1'), findsOneWidget);
    expect(fake.comments.single.reactions, {
      '👍': ['u1'],
    });

    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(chip, findsNothing);
    expect(fake.comments.single.reactions, isEmpty);
  });

  testWidgets('a pinned comment shows in a strip on top', (tester) async {
    final fake = FakeCommentsClient(initial: [seed('c1', 'important')]);
    await open(tester, client: fake);

    await menu(tester, 'c1', 'Pin');

    expect(find.byKey(const Key('pinned-c1')), findsOneWidget);
    await menu(tester, 'c1', 'Unpin');
    expect(find.byKey(const Key('pinned-c1')), findsNothing);
  });

  testWidgets('a comment becomes a subtask in one click', (tester) async {
    final fake = FakeCommentsClient(initial: [seed('c1', 'do this')]);
    await open(tester, client: fake);

    await menu(tester, 'c1', 'Make a subtask');

    expect(fake.subtasks, ['c1']);
    expect(find.text('Subtask created.'), findsOneWidget);
  });

  testWidgets('a viewer reads but cannot write', (tester) async {
    await open(tester, comments: [seed('c1', 'read me')], role: 'Viewer');

    expect(find.byKey(const Key('comments-readonly')), findsOneWidget);
    expect(find.byKey(const Key('comment-input')), findsNothing);
    expect(find.byKey(const Key('react-c1')), findsNothing);
  });

  testWidgets('an archived project is read-only too', (tester) async {
    await open(tester, comments: [seed('c1', 'old')], archived: true);

    expect(find.byKey(const Key('comments-readonly')), findsOneWidget);
    expect(find.byKey(const Key('comment-input')), findsNothing);
  });

  testWidgets('earlier comments are loaded on request, oldest first', (
    tester,
  ) async {
    final all = [for (var i = 1; i <= 5; i++) seed('c$i', 'comment $i')];
    final fake = FakeCommentsClient(initial: all);
    await open(tester, client: fake, pageSize: 2);

    expect(find.text('Comments (2)'), findsOneWidget);
    expect(find.byKey(const Key('load-earlier')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('load-earlier')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('load-earlier')));
    await tester.pumpAndSettle();

    expect(find.text('Comments (4)'), findsOneWidget);
    expect(fake.lists.last, isNotEmpty);
    await tester.ensureVisible(find.byKey(const Key('load-earlier')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('load-earlier')));
    await tester.pumpAndSettle();
    expect(find.text('Comments (5)'), findsOneWidget);
    expect(find.byKey(const Key('load-earlier')), findsNothing);
  });

  testWidgets('a failed read offers a retry', (tester) async {
    final fake = FakeCommentsClient(initial: [seed('c1', 'there')]);
    final server = FakeTasksClient([task('a', 'Fix login')]);
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      tasks: server,
      workflows: FakeWorkflowsClient(defaultWorkflow()),
      comments: _Failing(fake),
    );
    await pumped.go(tester, '/projects/p1');
    await tester.tap(find.text('Fix login'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('comments-retry')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('comments-retry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('comments-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('comments-retry')), findsNothing);
    expect(bodyWith('there'), findsOneWidget);
  });

  testWidgets('Ctrl+Enter sends the comment', (tester) async {
    final opened = await open(tester);
    await type(tester, 'Shipped');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(opened.comments.created, hasLength(1));
  });

  testWidgets('the toolbar marks up the text', (tester) async {
    final opened = await open(tester);
    await type(tester, 'item');
    await tester.tap(find.byKey(const Key('format-bullet')).first);
    await tester.pump();
    final field = tester.widget<TextField>(
      find.byKey(const Key('comment-input')).first,
    );
    expect(field.controller!.text, '- item');

    await tester.tap(find.byKey(const Key('format-link')).first);
    await tester.pump();
    expect(field.controller!.text, contains('[](https://)'));
    expect(opened.comments.created, isEmpty);
  });
}

/// A client whose first read is refused.
class _Failing extends FakeCommentsClient {
  _Failing(FakeCommentsClient inner) : super(initial: inner.comments);

  var _failed = false;

  @override
  Future<CommentPage> list(
    String workspaceId,
    String projectId,
    String taskId, {
    String before = '',
  }) async {
    if (!_failed) {
      _failed = true;
      throw const CommentException(CommentFailure.network);
    }
    return super.list(workspaceId, projectId, taskId, before: before);
  }
}
