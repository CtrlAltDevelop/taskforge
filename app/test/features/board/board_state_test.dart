import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../fields/fakes.dart';
import '../tasks/fakes.dart';
import '../views/fakes.dart';
import 'fakes.dart';

const _wait = Duration(milliseconds: 750);

ProviderContainer _container({
  FakeBoardClient? board,
  FakeViewsClient? views,
  FakeTasksClient? tasks,
}) {
  final container = ProviderContainer(
    overrides: [
      boardClientProvider.overrideWithValue(board ?? FakeBoardClient()),
      viewsClientProvider.overrideWithValue(views ?? FakeViewsClient()),
      tasksClientProvider.overrideWithValue(tasks ?? FakeTasksClient()),
      fieldsClientProvider.overrideWithValue(FakeFieldsClient()),
      workspaceScopeProvider.overrideWithValue('w1'),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _loaded(ProviderContainer c) async {
  final sub = c.listen(boardProvider('p1'), (_, _) {});
  addTearDown(sub.close);
  while (c.read(boardProvider('p1')).loading) {
    await Future<void>.delayed(Duration.zero);
  }
}

List<String> _ids(ProviderContainer c, String column, {String lane = ''}) => [
  for (final t
      in c
          .read(boardProvider('p1'))
          .lanes
          .firstWhere((l) => l.key == lane)
          .columns
          .firstWhere((x) => x.key == column)
          .tasks)
    t.id,
];

int _count(ProviderContainer c, String column) => c
    .read(boardProvider('p1'))
    .lanes
    .first
    .columns
    .firstWhere((x) => x.key == column)
    .count;

void main() {
  group('dropCard', () {
    final a = task('a', 'A');
    final b = task('b', 'B', number: 2);
    final c = task('c', 'C', number: 3, statusId: 'done');
    final lanes = [
      BoardLane(
        key: '',
        columns: [
          BoardColumn(key: 'todo', count: 2, tasks: [a, b]),
          BoardColumn(key: 'done', count: 1, tasks: [c]),
        ],
      ),
    ];

    List<String> ids(List<BoardLane> l, int column) => [
      for (final t in l.first.columns[column].tasks) t.id,
    ];

    test('puts the card before a neighbour and moves the counts', () {
      final next = dropCard(
        lanes,
        a,
        laneKey: '',
        toColumn: 'done',
        beforeId: 'c',
      );

      expect(ids(next, 0), ['b']);
      expect(ids(next, 1), ['a', 'c']);
      expect(next.first.columns.map((x) => x.count), [1, 2]);
    });

    test('after a neighbour, else last', () {
      expect(
        ids(dropCard(lanes, c, laneKey: '', toColumn: 'todo', afterId: 'a'), 0),
        ['a', 'c', 'b'],
      );
      expect(ids(dropCard(lanes, c, laneKey: '', toColumn: 'todo'), 0), [
        'a',
        'b',
        'c',
      ]);
    });

    test('inside its own column the count does not change', () {
      final next = dropCard(
        lanes,
        a,
        laneKey: '',
        toColumn: 'todo',
        afterId: 'b',
      );

      expect(ids(next, 0), ['b', 'a']);
      expect(next.first.columns.first.count, 2);
    });

    test('another lane is left alone', () {
      final two = [
        ...lanes,
        const BoardLane(
          key: 'u1',
          columns: [BoardColumn(key: 'todo')],
        ),
      ];

      final next = dropCard(two, a, laneKey: 'u1', toColumn: 'todo');

      expect(ids(next, 0), ['a', 'b']);
      expect(next.last.columns.first.tasks.map((t) => t.id), ['a']);
    });

    test('a later page skips cards that are already shown', () {
      final next = appendPage(
        lanes,
        laneKey: '',
        columnKey: 'todo',
        tasks: [b, task('d', 'D', number: 4)],
        cursor: '',
      );

      expect(ids(next, 0), ['a', 'b', 'd']);
    });
  });

  group('the board', () {
    test('reads columns with counts and the first cards', () async {
      final c = _container(
        board: FakeBoardClient([task('a', 'A'), task('b', 'B', number: 2)]),
      );
      await _loaded(c);

      expect(_ids(c, 'todo'), ['a', 'b']);
      expect(_count(c, 'todo'), 2);
    });

    test('loads the next page of one column and no more than once', () async {
      final fake = FakeBoardClient([
        for (var i = 1; i <= 5; i++) task('t$i', 'T$i', number: i),
      ])..pageSize = 2;
      final c = _container(board: fake);
      await _loaded(c);
      final board = c.read(boardProvider('p1').notifier);

      await Future.wait([
        board.loadMore('', 'todo'),
        board.loadMore('', 'todo'),
      ]);
      await board.loadMore('', 'todo');

      expect(_ids(c, 'todo'), ['t1', 't2', 't3', 't4', 't5']);
      expect(fake.listColumnCalls, hasLength(2));
    });

    test('a drop shows at once and keeps the server\'s answer', () async {
      final fake = FakeBoardClient([task('a', 'A'), task('b', 'B', number: 2)]);
      final c = _container(board: fake);
      await _loaded(c);
      final a = c
          .read(boardProvider('p1'))
          .lanes
          .first
          .columns
          .first
          .tasks
          .first;

      final saved = await c
          .read(boardProvider('p1').notifier)
          .move(a, laneKey: '', column: 'done');

      expect(saved.version, 2);
      expect(_ids(c, 'todo'), ['b']);
      expect(_ids(c, 'done'), ['a']);
      expect(_count(c, 'done'), 1);
      expect(fake.moves.single.column, 'done');
    });

    test('a refused drop puts the card back and throws', () async {
      final fake = FakeBoardClient([task('a', 'A')])
        ..failMove = const TaskException(TaskFailure.transitionNotAllowed);
      final c = _container(board: fake);
      await _loaded(c);
      final a = c
          .read(boardProvider('p1'))
          .lanes
          .first
          .columns
          .first
          .tasks
          .first;

      await expectLater(
        c
            .read(boardProvider('p1').notifier)
            .move(a, laneKey: '', column: 'done'),
        throwsA(
          isA<TaskException>().having(
            (e) => e.failure,
            'failure',
            TaskFailure.transitionNotAllowed,
          ),
        ),
      );

      expect(_ids(c, 'todo'), ['a']);
      expect(_ids(c, 'done'), isEmpty);
      expect(_count(c, 'done'), 0);
    });

    test(
      'a quick-added card lands last in its column with its value',
      () async {
        final fake = FakeBoardClient([task('a', 'A')]);
        final tasks = FakeTasksClient();
        final c = _container(board: fake, tasks: tasks);
        await _loaded(c);

        final created = await c
            .read(boardProvider('p1').notifier)
            .add('New', laneKey: '', column: 'done');

        expect(created.statusId, 'done');
        expect(_ids(c, 'done'), [created.id]);
        expect(_count(c, 'done'), 1);
      },
    );

    test('a change of grouping reads the board again', () async {
      final fake = FakeBoardClient([
        task('a', 'A', priority: TaskPriority.high),
      ]);
      final c = _container(board: fake);
      await _loaded(c);

      c
          .read(boardLayoutProvider('p1').notifier)
          .update((l) => l.copyWith(groupBy: 'priority'));
      await Future<void>.delayed(Duration.zero);
      await _loaded(c);

      expect(fake.getCalls.last.groupBy, 'priority');
      expect(_ids(c, 'high'), ['a']);
    });
  });

  group('the saved board layout', () {
    test(
      'is read first, so the board is read once in the saved order',
      () async {
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
        final fake = FakeBoardClient();
        final c = _container(board: fake, views: views);

        await _loaded(c);

        expect(fake.getCalls.map((q) => q.groupBy), ['priority']);
      },
    );

    test('a change is saved a moment later, once', () async {
      final views = FakeViewsClient();
      final c = _container(views: views);
      await _loaded(c);
      final layout = c.read(boardLayoutProvider('p1').notifier);

      layout.update((l) => l.withLimit('todo', 3));
      layout.update((l) => l.withCardField('assignee', shown: false));
      await Future<void>.delayed(_wait);

      expect(views.boardSaves, hasLength(1));
      expect(views.boardSaves.single.layout.limits, {'todo': 3});
      expect(
        views.boardSaves.single.layout.cardFields,
        isNot(contains('assignee')),
      );
    });

    test('a first read that failed does not stop later saves', () async {
      final views = FakeViewsClient()
        ..boards.add(
          const SavedBoard(
            id: 'b1',
            name: personalLayoutName,
            layout: BoardLayout(),
            isShared: false,
            version: 1,
          ),
        )
        ..failListBoards = const ViewException(ViewFailure.network);
      final c = _container(views: views);
      await _loaded(c);
      views.failListBoards = null;

      c
          .read(boardLayoutProvider('p1').notifier)
          .update((l) => l.copyWith(swimlane: 'assignee'));
      await Future<void>.delayed(_wait);

      expect(c.read(boardLayoutProvider('p1')).saveFailed, isFalse);
      expect(views.boards.single.layout.swimlane, 'assignee');
    });
  });

  test('a layout only changes through its copies', () {
    const base = BoardLayout();

    final changed = base.withLimit('todo', 2).withLimit('done', 5);

    expect(changed.limits, {'todo': 2, 'done': 5});
    expect(changed.withLimit('todo', null).limits, {'done': 5});
    expect(base.limits, isEmpty);
    expect(changed.withCardField('due_date', shown: false).cardFields, [
      'assignee',
      'priority',
      'progress',
    ]);
  });
}
