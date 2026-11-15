import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/tasks/domain/list_drop.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

import '../board/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

final _a = task('a', 'Alpha', priority: TaskPriority.high);
final _b = task('b', 'Bravo', number: 2);
final _sub = task('s', 'Sub', number: 3, parent: 'a', depth: 1);
const _none = ListQuery();
const _byPriority = ListQuery(groupBy: 'priority');

void main() {
  group('zoneAt', () {
    test('splits a row in thirds-ish when it can nest', () {
      expect(zoneAt(2, 40, canNest: true), DropZone.above);
      expect(zoneAt(20, 40, canNest: true), DropZone.onto);
      expect(zoneAt(38, 40, canNest: true), DropZone.below);
    });

    test('has no middle when it cannot nest', () {
      expect(zoneAt(19, 40, canNest: false), DropZone.above);
      expect(zoneAt(21, 40, canNest: false), DropZone.below);
    });
  });

  group('planRowDrop', () {
    RowDrop? plan(
      DropZone zone, {
      Task? dragged,
      Task? target,
      ListQuery query = _none,
      bool canNest = true,
    }) => planRowDrop(
      dragged: dragged ?? _a,
      target: target ?? _b,
      zone: zone,
      query: query,
      canNest: canNest,
    );

    test('the middle nests when nesting is allowed, else does nothing', () {
      expect(plan(DropZone.onto), isA<NestDrop>());
      expect(plan(DropZone.onto, canNest: false), isNull);
    });

    test('above and below reorder inside the dragged task\'s own status', () {
      final above = plan(DropZone.above) as MoveDrop;
      expect((above.groupBy, above.column), ('status', 'todo'));
      expect((above.beforeId, above.afterId), ('b', ''));
      final below = plan(DropZone.below) as MoveDrop;
      expect((below.beforeId, below.afterId), ('', 'b'));
    });

    test('a subtask is not reordered', () {
      expect(plan(DropZone.above, dragged: _sub), isNull);
      expect(plan(DropZone.below, target: _sub), isNull);
    });

    test('a sorted list does not reorder', () {
      const sorted = ListQuery(sort: [SortKey('title')]);
      expect(plan(DropZone.above, query: sorted), isNull);
    });

    test('a grouped list moves into the target row\'s group', () {
      final move = plan(DropZone.below, query: _byPriority) as MoveDrop;
      expect((move.groupBy, move.column), ('priority', 'none'));
      expect(move.afterId, 'b');
    });

    test('a sorted, grouped list only moves between groups', () {
      const query = ListQuery(sort: [SortKey('title')], groupBy: 'priority');
      final move = plan(DropZone.above, query: query) as MoveDrop;
      expect((move.column, move.beforeId, move.afterId), ('none', '', ''));
      expect(plan(DropZone.above, target: _a, query: query), isNull);
    });
  });

  group('in the list', () {
    Future<FakeBoardClient> open(WidgetTester tester, List<Task> tasks) async {
      final board = FakeBoardClient(tasks);
      final pumped = await pumpProjects(
        tester,
        role: 'Owner',
        projects: [project('p1', 'Web')],
        tasks: FakeTasksClient(tasks),
        workflows: FakeWorkflowsClient(defaultWorkflow()),
        views: FakeViewsClient(),
        board: board,
        size: const Size(1400, 1000),
      );
      await pumped.go(tester, '/projects/p1');
      return board;
    }

    Future<void> dragTo(WidgetTester tester, String from, Offset to) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(Key('task-$from'))),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(to);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    testWidgets('dropping on a row\'s lower edge puts the task after it', (
      tester,
    ) async {
      final board = await open(tester, [_a, _b]);

      final row = find.byKey(const Key('drop-b'));
      await dragTo(
        tester,
        'a',
        tester.getBottomLeft(row) + const Offset(100, -3),
      );

      expect(
        board.moves.map((m) => (m.task, m.column, m.beforeId, m.afterId)),
        [('a', 'todo', '', 'b')],
      );
    });

    testWidgets('dropping on a group header moves the task into the group', (
      tester,
    ) async {
      final board = await open(tester, [_a, _b]);
      await tester.tap(find.byKey(const Key('group-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('group-by-priority')));
      await tester.pumpAndSettle();

      await dragTo(
        tester,
        'b',
        tester.getCenter(find.byKey(const Key('group-high'))),
      );

      expect(board.moves.map((m) => (m.task, m.column)), [('b', 'high')]);
    });
  });
}
