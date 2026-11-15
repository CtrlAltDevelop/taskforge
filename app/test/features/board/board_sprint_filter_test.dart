import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/board/domain/board_sprint_filter.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../sprints/fakes.dart';
import '../tasks/fakes.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _wide = Size(1400, 900);

Map<String, Object?> _ast(String json) =>
    jsonDecode(json) as Map<String, Object?>;

Future<({FakeBoardClient board, Pumped pumped})> _open(
  WidgetTester tester, {
  required FakeSprintsClient sprints,
  bool featureOn = true,
  String location = '/projects/p1',
}) async {
  final all = [task('a', 'Alpha'), task('b', 'Bravo', number: 2)];
  final board = FakeBoardClient(all);
  final pumped = await pumpProjects(
    tester,
    projects: [
      project('p1', 'Web', enabled: featureOn ? {sprintsFeature} : {}),
    ],
    tasks: FakeTasksClient(all),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    views: FakeViewsClient(),
    board: board,
    sprints: sprints,
    size: _wide,
  );
  await pumped.go(tester, location);
  return (board: board, pumped: pumped);
}

Future<void> _board(WidgetTester tester) async {
  await tester.tap(find.text('Board'));
  await tester.pumpAndSettle();
}

FakeSprintsClient _running() => FakeSprintsClient(
  sprints: [mkSprint('s1', 'Sprint 1', state: SprintState.active)],
);

void main() {
  group('the sprint condition on a filter', () {
    test('alone, it is the whole filter', () {
      final ast = _ast(withCurrentSprint(''));

      expect((ast['where'] as Map)['field'], 'sprint');
      expect((ast['where'] as Map)['cmp'], 'eq');
      expect(((ast['where'] as Map)['values'] as List).single, {
        'k': 'func',
        'v': 'currentSprint',
      });
      expect(ast['order'], isEmpty);
    });

    test('with a filter, both must hold, and the order stays', () {
      final mine = {
        'where': {
          'op': 'cmp',
          'field': 'priority',
          'cmp': 'eq',
          'values': [
            {'k': 'text', 'v': 'high'},
          ],
        },
        'order': [
          {'field': 'priority', 'desc': true},
        ],
      };

      final ast = _ast(withCurrentSprint(jsonEncode(mine)));
      final where = ast['where'] as Map;

      expect(where['op'], 'and');
      expect((where['args'] as List).first, mine['where']);
      expect(((where['args'] as List).last as Map)['field'], 'sprint');
      expect(ast['order'], mine['order']);
    });
  });

  testWidgets('with an active sprint the board offers Current sprint', (
    tester,
  ) async {
    final opened = await _open(tester, sprints: _running());
    await _board(tester);

    expect(find.byKey(const Key('board-sprint-filter')), findsOneWidget);
    expect(opened.board.filters.last, '');
  });

  testWidgets('switching it on reads the board again with the sprint filter, '
      'and off drops it', (tester) async {
    final opened = await _open(tester, sprints: _running());
    await _board(tester);

    await tester.tap(find.byKey(const Key('board-sprint-filter')));
    await tester.pumpAndSettle();
    final on = _ast(opened.board.filters.last)['where'] as Map;

    await tester.tap(find.byKey(const Key('board-sprint-filter')));
    await tester.pumpAndSettle();

    expect(on['field'], 'sprint');
    expect(opened.board.filters.last, '');
  });

  testWidgets('no chip when no sprint is active or the feature is off', (
    tester,
  ) async {
    final planned = FakeSprintsClient(sprints: [mkSprint('s1', 'Sprint 1')]);
    await _open(tester, sprints: planned);
    await _board(tester);
    expect(find.byKey(const Key('board-sprint-filter')), findsNothing);
  });

  testWidgets('no chip where the Sprints feature is off', (tester) async {
    final sprints = _running();
    await _open(tester, sprints: sprints, featureOn: false);
    await _board(tester);

    expect(find.byKey(const Key('board-sprint-filter')), findsNothing);
    expect(sprints.calls, isEmpty); // and nothing was asked of the server
  });

  testWidgets('the sprint screen links to the board of the sprint', (
    tester,
  ) async {
    final opened = await _open(
      tester,
      sprints: _running(),
      location: '/projects/p1/sprints',
    );

    await tester.tap(find.byKey(const Key('sprint-on-board')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('board-toolbar')), findsOneWidget);
    final chip = tester.widget<FilterChip>(
      find.byKey(const Key('board-sprint-filter')),
    );
    expect(chip.selected, isTrue);
    expect(
      (_ast(opened.board.filters.last)['where'] as Map)['field'],
      'sprint',
    );
  });
}
