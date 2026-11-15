import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _wide = Size(1400, 900);
const _phone = Size(420, 900);

typedef Opened = ({FakeBoardClient board, FakeViewsClient views});

Future<Opened> _open(
  WidgetTester tester, {
  List<Task>? tasks,
  String role = 'Owner',
  Size size = _wide,
  int pageSize = 30,
  FakeViewsClient? views,
}) async {
  final all =
      tasks ??
      [
        task('a', 'Alpha', priority: TaskPriority.high, assignees: ['u1']),
        task('b', 'Bravo', number: 2, assignees: ['u2']),
        task('c', 'Charlie', number: 3, statusId: 'doing'),
        task('d', 'Delta', number: 4, statusId: 'done'),
      ];
  final board = FakeBoardClient(all)..pageSize = pageSize;
  final saved = views ?? FakeViewsClient();
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient(all),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    views: saved,
    board: board,
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('view-switch')),
      matching: find.byIcon(Icons.view_kanban_outlined),
    ),
  );
  await tester.pumpAndSettle();
  return (board: board, views: saved);
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

String _title(WidgetTester tester, String id) =>
    tester.widget<Text>(find.byKey(Key('card-title-$id'))).data!;

Future<void> _drag(WidgetTester tester, Finder from, Offset to) async {
  final gesture = await tester.startGesture(tester.getCenter(from));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveBy(const Offset(0, 30));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveTo(to);
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.up();
  await tester.pumpAndSettle();
}

ScrollPosition _position(WidgetTester tester, String column) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byKey(Key('cards-$column')),
            matching: find.byType(Scrollable),
          )
          .first,
    )
    .position;

/// Scrolls the column to its end, as often as pages keep arriving.
Future<void> _scrollToEnd(WidgetTester tester, String column) async {
  for (var i = 0; i < 8; i++) {
    final p = _position(tester, column);
    p.jumpTo(p.maxScrollExtent);
    await tester.pumpAndSettle();
  }
}

/// Presses Tab until the focus is on the control under [key].
Future<void> _tabTo(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key)).evaluate().single;
  for (var i = 0; i < 120; i++) {
    final focused = FocusManager.instance.primaryFocus?.context;
    var inside = false;
    focused?.visitAncestorElements((e) {
      inside = identical(e, target);
      return !inside;
    });
    if (inside) return;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }
  fail('$key cannot be reached with Tab');
}

void main() {
  group('columns and cards', () {
    testWidgets('a column per status, with counts and its cards', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('To do'), findsWidgets);
      expect(find.byKey(const Key('count-todo')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('count-todo'))).data,
        '2',
      );
      expect(_title(tester, 'a'), 'Alpha');
      expect(_title(tester, 'c'), 'Charlie');
      expect(
        find.descendant(
          of: find.byKey(const Key('card-a')),
          matching: find.text('High'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the card field chooser hides what is not wanted', (
      tester,
    ) async {
      final s = await _open(tester);

      await _tap(tester, 'board-fields-menu');
      await _tap(tester, 'card-field-priority');
      await tester.pump(const Duration(milliseconds: 700));

      expect(
        find.descendant(
          of: find.byKey(const Key('card-a')),
          matching: find.text('High'),
        ),
        findsNothing,
      );
      expect(
        s.views.boardSaves.last.layout.cardFields,
        isNot(contains('priority')),
      );
    });

    testWidgets('columns can come from the priority instead', (tester) async {
      final s = await _open(tester);

      await _tap(tester, 'board-group-menu');
      await _tap(tester, 'board-group-priority');

      expect(s.board.getCalls.last.groupBy, 'priority');
      expect(find.byKey(const Key('count-high')), findsOneWidget);
      expect(find.byKey(const Key('count-urgent')), findsOneWidget);
    });

    testWidgets('a column folds shut and opens again', (tester) async {
      await _open(tester);

      await _tap(tester, 'collapse-todo');
      expect(find.byKey(const Key('card-a')), findsNothing);
      expect(find.byKey(const Key('expand-todo')), findsOneWidget);

      await _tap(tester, 'expand-todo');
      expect(find.byKey(const Key('card-a')), findsOneWidget);
    });

    testWidgets('an empty column says where to drop', (tester) async {
      await _open(tester, tasks: [task('a', 'Alpha')]);

      expect(find.byKey(const Key('empty-done')), findsOneWidget);
    });

    testWidgets('swimlanes split the board by assignee', (tester) async {
      await _open(tester);

      await _tap(tester, 'board-lane-menu');
      await _tap(tester, 'board-lane-assignee');

      expect(find.byKey(const Key('lane-u1')), findsOneWidget);
      expect(find.text('Zoe'), findsWidgets);
      expect(find.byKey(const Key('lane-')), findsOneWidget);
    });
  });

  group('work-in-progress limits', () {
    testWidgets('a column over its limit turns its header red', (tester) async {
      final s = await _open(tester);
      expect(find.byKey(const Key('wip-over-todo')), findsNothing);

      await _tap(tester, 'column-menu-todo');
      await _tap(tester, 'set-limit-todo');
      await tester.enterText(find.byKey(const Key('wip-input')), '1');
      await _tap(tester, 'wip-save');
      await tester.pump(const Duration(milliseconds: 700));

      expect(
        tester.widget<Text>(find.byKey(const Key('count-todo'))).data,
        '2 / 1',
      );
      expect(find.byKey(const Key('wip-over-todo')), findsOneWidget);
      expect(s.views.boardSaves.last.layout.limits, {'todo': 1});
    });

    testWidgets('a limit that is met is not red, and can be cleared', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, 'column-menu-todo');
      await _tap(tester, 'set-limit-todo');
      await tester.enterText(find.byKey(const Key('wip-input')), '2');
      await _tap(tester, 'wip-save');
      expect(find.byKey(const Key('wip-over-todo')), findsNothing);

      await _tap(tester, 'column-menu-todo');
      await _tap(tester, 'set-limit-todo');
      await _tap(tester, 'wip-clear');
      await tester.pump(const Duration(milliseconds: 700));

      expect(
        tester.widget<Text>(find.byKey(const Key('count-todo'))).data,
        '2',
      );
    });
  });

  group('moving cards', () {
    testWidgets('dropping on another card puts it before that card', (
      tester,
    ) async {
      final s = await _open(tester);

      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getTopLeft(find.byKey(const Key('card-d'))) +
            const Offset(40, 4),
      );

      final move = s.board.moves.single;
      expect((move.task, move.column, move.beforeId), ('a', 'done', 'd'));
      expect(
        tester.widget<Text>(find.byKey(const Key('count-done'))).data,
        '2',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('count-todo'))).data,
        '1',
      );
    });

    testWidgets('dropping in the lower half puts it after', (tester) async {
      final s = await _open(tester);

      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getBottomLeft(find.byKey(const Key('card-d'))) -
            const Offset(-40, 8),
      );

      final move = s.board.moves.single;
      expect((move.column, move.afterId, move.beforeId), ('done', 'd', ''));
    });

    testWidgets('dropping on an empty column sends it there', (tester) async {
      final s = await _open(tester, tasks: [task('a', 'Alpha')]);

      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getCenter(find.byKey(const Key('empty-done'))),
      );

      expect(s.board.moves.single.column, 'done');
      expect(find.byKey(const Key('empty-done')), findsNothing);
      expect(_title(tester, 'a'), 'Alpha');
    });

    testWidgets('a refused move snaps the card back and says why', (
      tester,
    ) async {
      final s = await _open(tester);
      s.board.failMove = const TaskException(
        TaskFailure.transitionNotAllowed,
        detail: 'To do cannot go straight to Done.',
      );

      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getCenter(find.byKey(const Key('card-d'))),
      );

      expect(find.text('To do cannot go straight to Done.'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('count-todo'))).data,
        '2',
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('card-a'))).dx,
        lessThan(tester.getTopLeft(find.byKey(const Key('card-c'))).dx),
      );
    });

    testWidgets('a blocked task asks before it is moved anyway', (
      tester,
    ) async {
      final s = await _open(tester);
      s.board.failMove = const TaskException(
        TaskFailure.blocked,
        detail: 'WEB-4',
        canOverride: true,
      );

      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getCenter(find.byKey(const Key('card-d'))),
      );
      expect(find.byKey(const Key('blocked-text')), findsOneWidget);
      await _tap(tester, 'complete-anyway');

      expect(s.board.moves.map((m) => m.overrideBlocked), [false, true]);
    });

    testWidgets('a card only drops inside its own lane', (tester) async {
      final s = await _open(tester);
      await _tap(tester, 'board-lane-menu');
      await _tap(tester, 'board-lane-assignee');
      s.board.moves.clear();

      // "a" belongs to Zoe; "b" sits in Hank's lane.
      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getCenter(find.byKey(const Key('card-b'))),
      );

      expect(s.board.moves, isEmpty);
    });

    testWidgets('on a phone a card is picked up with a long press', (
      tester,
    ) async {
      final s = await _open(tester, size: _phone);
      final card = find.byKey(const Key('card-a'));

      final gesture = await tester.startGesture(tester.getCenter(card));
      await tester.pump(const Duration(milliseconds: 700));
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(tester.getCenter(find.byKey(const Key('card-b'))));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(s.board.moves.single.task, 'a');
      expect(s.board.moves.single.column, 'todo');
    });

    testWidgets('a viewer can look but not move or add', (tester) async {
      final s = await _open(tester, role: 'Viewer');

      expect(find.byKey(const Key('card-menu-a')), findsNothing);
      expect(find.byKey(const Key('add-todo')), findsNothing);
      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getCenter(find.byKey(const Key('card-d'))),
      );
      expect(s.board.moves, isEmpty);
    });

    testWidgets('a card dropped below itself at the end is not moved', (
      tester,
    ) async {
      final s = await _open(tester);

      await _drag(
        tester,
        find.byKey(const Key('card-b')), // the last card of To do
        tester.getBottomLeft(find.byKey(const Key('cards-todo'))) +
            const Offset(60, -10),
      );

      expect(s.board.moves, isEmpty);
    });

    testWidgets('dropping on the same place is not a move of its own', (
      tester,
    ) async {
      final s = await _open(tester);

      await _drag(
        tester,
        find.byKey(const Key('card-a')),
        tester.getCenter(find.byKey(const Key('card-a'))) + const Offset(0, 2),
      );

      expect(s.board.moves, isEmpty);
    });
  });

  group('without a mouse', () {
    testWidgets('a card has a Move to… menu reachable with Tab', (
      tester,
    ) async {
      final s = await _open(tester);

      await _tabTo(tester, 'card-menu-a');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('move-to-a-done')), findsOneWidget);
      expect(find.byKey(const Key('move-to-a-todo')), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(s.board.moves.single.task, 'a');
      expect(s.board.moves.single.column, 'done');
      expect(s.board.moves.single.beforeId, '');
    });

    testWidgets('the menu moves a card on a phone too', (tester) async {
      final s = await _open(tester, size: _phone);

      await _tap(tester, 'card-menu-a');
      await _tap(tester, 'move-to-a-doing');

      expect(s.board.moves.single.column, 'doing');
    });

    testWidgets('a card opens its task with Enter', (tester) async {
      await _open(tester);

      await _tabTo(tester, 'card-a');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('WEB-1'), findsWidgets);
    });
  });

  group('adding and paging', () {
    testWidgets('a task is added to the end of its own column', (tester) async {
      await _open(tester);

      await tester.enterText(find.byKey(const Key('add-done')), 'Echo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Echo'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('count-done'))).data,
        '2',
      );
    });

    testWidgets('a column of a thousand builds only what is on screen', (
      tester,
    ) async {
      final many = [
        for (var i = 1; i <= 1000; i++) task('t$i', 'Task $i', number: i),
      ];
      final s = await _open(tester, tasks: many);

      expect(
        tester.widget<Text>(find.byKey(const Key('count-todo'))).data,
        '1000',
      );
      expect(find.byType(Card).evaluate().length, lessThan(40));

      await _scrollToEnd(tester, 'todo');

      expect(s.board.listColumnCalls, isNotEmpty);
      expect(find.byType(Card).evaluate().length, lessThan(40));
    });

    testWidgets('scrolling to the end of a page loads the next one', (
      tester,
    ) async {
      final many = [
        for (var i = 1; i <= 12; i++) task('t$i', 'Task $i', number: i),
      ];
      final s = await _open(tester, tasks: many, pageSize: 5);
      await _scrollToEnd(tester, 'todo');

      // 12 cards in pages of 5: the first came with the board, two more were asked for.
      expect(s.board.listColumnCalls.map((c) => c.cursor), ['5', '10']);
      expect(find.byKey(const Key('card-t12')), findsOneWidget);
    });

    testWidgets('holding a card near the bottom scrolls the column', (
      tester,
    ) async {
      final many = [
        for (var i = 1; i <= 40; i++) task('t$i', 'Task $i', number: i),
      ];
      await _open(tester, tasks: many);
      final list = find.byKey(const Key('cards-todo'));
      final before = _position(tester, 'todo').pixels;

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('card-t1'))),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(tester.getBottomLeft(list) + const Offset(60, -10));
      await tester.pump(const Duration(milliseconds: 50));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      final during = _position(tester, 'todo').pixels;
      await gesture.up();
      await tester.pumpAndSettle();

      expect(during, greaterThan(before));
    });
  });

  testWidgets('the board is a loading spinner, then the columns', (
    tester,
  ) async {
    final board = FakeBoardClient([task('a', 'Alpha')]);
    final gate = board.getGate = Completer<void>();
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      workflows: FakeWorkflowsClient(defaultWorkflow()),
      board: board,
    );
    await pumped.go(tester, '/projects/p1');
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('view-switch')),
        matching: find.byIcon(Icons.view_kanban_outlined),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('board-loading')), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('board-loading')), findsNothing);
    expect(find.byKey(const Key('card-a')), findsOneWidget);
  });

  testWidgets('List and Board switch back and forth', (tester) async {
    await _open(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('view-switch')),
        matching: find.byIcon(Icons.table_rows_outlined),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('card-a')), findsNothing);
    expect(find.byKey(const Key('task-a')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('view-switch')),
        matching: find.byIcon(Icons.view_kanban_outlined),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('card-a')), findsOneWidget);
  });

  testWidgets('a saved board layout is applied when the board opens', (
    tester,
  ) async {
    final views = FakeViewsClient()
      ..boards.add(
        const SavedBoard(
          id: 'b1',
          name: personalLayoutName,
          layout: BoardLayout(groupBy: 'priority'),
          isShared: false,
          version: 1,
        ),
      );
    final s = await _open(tester, views: views);

    expect(s.board.getCalls.map((q) => q.groupBy), ['priority']);
    expect(find.byKey(const Key('count-urgent')), findsOneWidget);
  });
}
