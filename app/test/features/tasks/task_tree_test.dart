import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import 'fakes.dart';

Task t(
  String id, {
  String parent = '',
  int depth = 0,
  String status = 'todo',
}) => changed(
  task(
    id,
    id.toUpperCase(),
    number: id.hashCode.abs() % 1000,
    parent: parent,
    depth: depth,
  ),
  statusId: status,
);

/// A
/// ├─ B
/// │  └─ D
/// └─ C
/// E
List<Task> sample() => [
  t('a'),
  t('b', parent: 'a', depth: 1),
  t('d', parent: 'b', depth: 2),
  t('c', parent: 'a', depth: 1),
  t('e'),
];

void main() {
  group('rows', () {
    test('every task shows, indented by its depth, when nothing is folded', () {
      final rows = TaskTree(sample()).visibleRows({});

      expect([for (final r in rows) r.task.id], ['a', 'b', 'd', 'c', 'e']);
      expect([for (final r in rows) r.depth], [0, 1, 2, 1, 0]);
      expect(
        [for (final r in rows) r.hasChildren],
        [true, true, false, false, false],
      );
      expect(rows.every((r) => r.expanded), isTrue);
    });

    test('a folded parent hides everything under it, at any depth', () {
      final tree = TaskTree(sample());

      expect(
        [
          for (final r in tree.visibleRows({'a'})) r.task.id,
        ],
        ['a', 'e'],
      );
      expect(
        [
          for (final r in tree.visibleRows({'b'})) r.task.id,
        ],
        ['a', 'b', 'c', 'e'],
      );
      expect(tree.visibleRows({'a'}).first.expanded, isFalse);
    });

    test('a task whose parent is not in the list is shown at the top', () {
      final rows = TaskTree([t('x', parent: 'gone', depth: 3)]).visibleRows({});

      expect(rows.single.depth, 0);
    });

    test('an empty list has no rows', () {
      expect(TaskTree(const []).visibleRows({}), isEmpty);
    });
  });

  group('progress', () {
    test('counts every descendant and the done ones', () {
      final tree = TaskTree([
        t('a'),
        t('b', parent: 'a', depth: 1),
        t('d', parent: 'b', depth: 2, status: 'done'),
        t('c', parent: 'a', depth: 1, status: 'done'),
      ]);

      expect((tree.progressOf('a').done, tree.progressOf('a').total), (2, 3));
      expect((tree.progressOf('b').done, tree.progressOf('b').total), (1, 1));
      expect(tree.progressOf('c').isEmpty, isTrue);
      expect(tree.progressOf('a').fraction, closeTo(2 / 3, 0.0001));
      expect(tree.progressOf('nope').isEmpty, isTrue);
    });

    test('a cancelled subtask is not done, but is not open either', () {
      final cancelled = Task(
        id: 'k',
        projectId: 'p1',
        number: 2,
        displayId: 'WEB-2',
        title: 'K',
        statusId: 'x',
        statusName: 'Cancelled',
        statusCategory: StatusCategory.cancelled,
        parentId: 'a',
        depth: 1,
      );
      final tree = TaskTree([t('a'), cancelled]);

      expect(tree.progressOf('a').done, 0);
      expect(tree.openBelow('a'), 0);
    });

    test('open subtasks are the live ones that are not finished', () {
      final tree = TaskTree([
        t('a'),
        t('b', parent: 'a', depth: 1),
        t('c', parent: 'a', depth: 1, status: 'done'),
        t('d', parent: 'b', depth: 2, status: 'doing'),
      ]);

      expect(tree.openBelow('a'), 2);
      expect(tree.openBelow('c'), 0);
    });
  });

  group('shape', () {
    final tree = TaskTree(sample());

    test('the breadcrumb runs from the top down to the task', () {
      expect([for (final x in tree.breadcrumb('d')) x.id], ['a', 'b', 'd']);
      expect([for (final x in tree.breadcrumb('a')) x.id], ['a']);
      expect(tree.breadcrumb('nope'), isEmpty);
    });

    test('a subtree is the task and everything under it', () {
      expect(tree.subtreeIds('a'), {'a', 'b', 'd', 'c'});
      expect(tree.subtreeIds('d'), {'d'});
    });

    test('levels below counts the depth of the subtree', () {
      expect(tree.levelsBelow('a'), 2);
      expect(tree.levelsBelow('b'), 1);
      expect(tree.levelsBelow('e'), 0);
    });

    test('a task cannot go under itself or one of its own subtasks', () {
      expect(tree.wouldCycle('a', 'a'), isTrue);
      expect(tree.wouldCycle('a', 'd'), isTrue);
      expect(tree.wouldCycle('b', 'd'), isTrue);
      expect(tree.wouldCycle('d', 'a'), isFalse);
      expect(tree.wouldCycle('e', 'a'), isFalse);
    });

    test('candidate parents leave out the task and its own subtree', () {
      expect([for (final x in tree.candidateParents('a')) x.id], ['e']);
      expect(
        [for (final x in tree.candidateParents('d')) x.id],
        ['a', 'b', 'c', 'e'],
      );
    });

    test('candidate parents respect the depth limit', () {
      final deep = [
        for (var i = 0; i < softDepthLimit; i++)
          t('n$i', parent: i == 0 ? '' : 'n${i - 1}', depth: i),
        t('leaf'),
      ];
      final ids = [
        for (final x in TaskTree(deep).candidateParents('leaf')) x.id,
      ];

      expect(ids, contains('n${softDepthLimit - 2}'));
      expect(ids, isNot(contains('n${softDepthLimit - 1}')));
    });

    test('a subtree that would pass the limit cannot go under a deep task', () {
      final deep = [
        for (var i = 0; i < softDepthLimit - 1; i++)
          t('n$i', parent: i == 0 ? '' : 'n${i - 1}', depth: i),
        t('top'),
        t('kid', parent: 'top', depth: 1),
      ];

      final ids = [
        for (final x in TaskTree(deep).candidateParents('top')) x.id,
      ];

      expect(ids, isNot(contains('n${softDepthLimit - 2}')));
      expect(ids, contains('n${softDepthLimit - 3}'));
    });
  });

  test('a list of five thousand tasks builds and answers quickly', () {
    final many = <Task>[
      for (var r = 0; r < 50; r++) ...[
        t('r$r'),
        for (var c = 0; c < 99; c++) t('r$r-$c', parent: 'r$r', depth: 1),
      ],
    ];
    final timer = Stopwatch()..start();

    final tree = TaskTree(many);
    final rows = tree.visibleRows({for (var r = 0; r < 50; r += 2) 'r$r'});
    final answer = tree.progressOf('r1').total;
    timer.stop();

    expect(rows.length, 25 * 100 + 25);
    expect(answer, 99);
    expect(timer.elapsed, lessThan(const Duration(milliseconds: 500)));
  });
}
