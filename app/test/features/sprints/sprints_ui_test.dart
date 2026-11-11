import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<Pumped> open(
  WidgetTester tester,
  FakeSprintsClient sprints, {
  bool enabled = true,
  String role = 'Owner',
  Size size = const Size(1400, 1200),
  String location = '/projects/p1/sprints',
}) async {
  final pumped = await pumpProjects(
    tester,
    role: role,
    size: size,
    projects: [
      project('p1', 'Web', enabled: enabled ? {sprintsFeature} : {}),
    ],
    sprints: sprints,
    overrides: [
      sprintTodayProvider.overrideWithValue(() => DateTime(2026, 11, 12)),
    ],
  );
  await pumped.go(tester, location);
  return pumped;
}

FakeSprintsClient planning() => FakeSprintsClient(
  sprints: [mkSprint('s1', 'Sprint 1', goal: 'Ship login')],
  tasks: [
    sTask('a', points: 3),
    sTask('b', points: 5),
    sTask('c'),
    sTask('d', sprint: 's1', points: 8),
  ],
);

Burndown sampleBurndown() => Burndown(
  sprint: mkSprint('s1', 'Sprint 1', state: SprintState.active),
  baselinePoints: 10,
  baselineTasks: 4,
  averageVelocity: 9,
  days: [
    BurndownDay(
      date: DateTime(2026, 11, 9),
      idealPoints: 10,
      idealTasks: 4,
      hasActual: true,
      remainingPoints: 10,
      remainingTasks: 4,
    ),
    BurndownDay(date: DateTime(2026, 11, 10), idealPoints: 5, idealTasks: 2),
  ],
  scopeChanges: [ScopeChange(date: DateTime(2026, 11, 9), points: 2, tasks: 1)],
  velocity: [
    const VelocityItem(
      sprintId: 'x',
      name: 'Old 1',
      committedPoints: 8,
      completedPoints: 6,
    ),
    const VelocityItem(
      sprintId: 'y',
      name: 'Old 2',
      committedPoints: 9,
      completedPoints: 9,
    ),
  ],
);

void main() {
  testWidgets('a project with sprints off says so and loads nothing', (
    tester,
  ) async {
    final s = planning();
    await open(tester, s, enabled: false);

    expect(key('sprints-disabled'), findsOneWidget);
    expect(s.calls, isEmpty);
  });

  testWidgets('the sidebar offers Sprints only where the feature is on', (
    tester,
  ) async {
    await open(tester, planning(), location: '/projects/p1');

    expect(key('open-sprints-p1'), findsOneWidget);
  });

  testWidgets('the sidebar hides Sprints when the feature is off', (
    tester,
  ) async {
    await open(tester, planning(), enabled: false, location: '/projects/p1');

    expect(key('open-sprints-p1'), findsNothing);
  });

  testWidgets('planning shows backlog, sprint, header and capacity', (
    tester,
  ) async {
    await open(tester, planning());

    expect(find.text('Backlog (3)'), findsOneWidget);
    expect(find.text('Sprint 1 (1)'), findsOneWidget);
    expect(key('sprint-state'), findsOneWidget);
    expect(find.text('planned'), findsOneWidget);
    expect(find.text('Goal: Ship login'), findsOneWidget);
    expect(find.text('Load 8 pts (no capacity set)'), findsOneWidget);
    expect(key('start-sprint'), findsOneWidget);
  });

  testWidgets(
    'capacity compares the load with what is set, and warns when over',
    (tester) async {
      await open(tester, planning());

      await tester.tap(key('capacity-edit'));
      await tester.pumpAndSettle();
      await tester.enterText(key('capacity-field'), '6');
      await tester.tap(key('capacity-save'));
      await tester.pumpAndSettle();

      expect(find.text('Load 8 pts of 6 pts'), findsOneWidget);
      expect(key('capacity-over'), findsOneWidget);
      expect(find.text('Over capacity by 2 pts'), findsOneWidget);

      await tester.tap(find.text('Hours'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Load 0h'), findsOneWidget);
    },
  );

  testWidgets('selecting backlog tasks and Add to sprint moves them', (
    tester,
  ) async {
    final s = planning();
    await open(tester, s);

    expect(tester.widget<FilledButton>(key('add-to-sprint')).onPressed, isNull);
    await tester.tap(key('select-a'));
    await tester.tap(key('select-b'));
    await tester.pump();
    await tester.tap(key('add-to-sprint'));
    await tester.pumpAndSettle();

    expect(s.calls, contains('add:a,b'));
    expect(find.text('Backlog (1)'), findsOneWidget);
    expect(find.text('Sprint 1 (3)'), findsOneWidget);
    expect(find.text('Load 16 pts (no capacity set)'), findsOneWidget);
  });

  testWidgets('dragging a task to the sprint adds it, and back removes it', (
    tester,
  ) async {
    final s = planning();
    await open(tester, s);

    var from = tester.getCenter(key('drag-a'));
    await tester.dragFrom(from, tester.getCenter(key('sprint-pane')) - from);
    await tester.pumpAndSettle();
    expect(s.calls, contains('add:a'));
    expect(find.text('Sprint 1 (2)'), findsOneWidget);

    from = tester.getCenter(key('drag-d'));
    await tester.dragFrom(from, tester.getCenter(key('backlog-pane')) - from);
    await tester.pumpAndSettle();
    expect(s.calls, contains('remove:d'));
    expect(find.text('Backlog (3)'), findsOneWidget);
  });

  testWidgets('on a phone the two lists are stacked', (tester) async {
    await open(tester, planning(), size: const Size(500, 1100));

    final backlog = tester.getTopLeft(key('backlog-pane'));
    final sprint = tester.getTopLeft(key('sprint-pane'));
    expect(sprint.dy, greaterThan(backlog.dy));
    expect(sprint.dx, backlog.dx);
  });

  testWidgets('points are edited through SetPoints and can be cleared', (
    tester,
  ) async {
    final s = planning();
    await open(tester, s);

    await tester.tap(key('points-c'));
    await tester.pumpAndSettle();
    await tester.enterText(key('points-field'), 'lots');
    await tester.tap(key('points-save'));
    await tester.pumpAndSettle();
    expect(find.text('Use a number, or leave empty to clear.'), findsOneWidget);
    await tester.enterText(key('points-field'), '2.5');
    await tester.tap(key('points-save'));
    await tester.pumpAndSettle();

    expect(s.points['c'], '2.5');
    expect(find.text('2.5'), findsOneWidget);

    await tester.tap(key('points-c'));
    await tester.pumpAndSettle();
    await tester.enterText(key('points-field'), '');
    await tester.tap(key('points-save'));
    await tester.pumpAndSettle();
    expect(s.points['c'], '');
  });

  testWidgets('start makes the sprint active and shows days left', (
    tester,
  ) async {
    final s = planning();
    await open(tester, s);

    await tester.tap(key('start-sprint'));
    await tester.pumpAndSettle();

    expect(find.text('active'), findsOneWidget);
    expect(find.text('11 days left'), findsOneWidget);
    expect(key('start-sprint'), findsNothing);
    expect(key('complete-sprint'), findsOneWidget);
  });

  testWidgets('a second active sprint is refused with the server text', (
    tester,
  ) async {
    final s = FakeSprintsClient(
      sprints: [
        mkSprint('s1', 'Sprint 1', state: SprintState.active),
        mkSprint(
          's2',
          'Sprint 2',
          start: DateTime(2026, 11, 23),
          end: DateTime(2026, 12, 6),
        ),
      ],
    );
    await open(tester, s);
    await tester.tap(key('sprint-picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sprint 2').last);
    await tester.pumpAndSettle();

    await tester.tap(key('start-sprint'));
    await tester.pumpAndSettle();

    expect(
      find.text('"Sprint 1" is already active. Complete it first.'),
      findsOneWidget,
    );
    expect(find.text('planned'), findsOneWidget);
  });

  testWidgets('tasks added after the start are flagged as scope change', (
    tester,
  ) async {
    final s = FakeSprintsClient(
      sprints: [mkSprint('s1', 'Sprint 1', state: SprintState.active)],
      tasks: [sTask('a', points: 3)],
    );
    await open(tester, s);
    await tester.tap(key('select-a'));
    await tester.pump();
    await tester.tap(key('add-to-sprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.textContaining('1 added after the sprint started'),
      findsOneWidget,
    );
  });

  testWidgets(
    'complete shows the counts and carries unfinished tasks to the next sprint',
    (tester) async {
      final s = FakeSprintsClient(
        sprints: [
          mkSprint('s1', 'Sprint 1', state: SprintState.active),
          mkSprint(
            's2',
            'Sprint 2',
            start: DateTime(2026, 11, 23),
            end: DateTime(2026, 12, 6),
          ),
        ],
        tasks: [
          sTask('a', sprint: 's1', points: 3, category: 'done'),
          sTask('b', sprint: 's1', points: 5),
          sTask('c', sprint: 's1'),
        ],
      );
      await open(tester, s);

      await tester.tap(key('complete-sprint'));
      await tester.pumpAndSettle();
      expect(find.text('1 done, 2 unfinished'), findsOneWidget);
      await tester.tap(key('complete-confirm'));
      await tester.pumpAndSettle();

      expect(s.completes.single, (carry: 'next', next: 's2'));
      expect(s.all.where((t) => t.sprintId == 's2').map((t) => t.id), [
        'b',
        'c',
      ]);
      expect(find.text('Sprint 2 (2)'), findsOneWidget);
      expect(find.text('Sprint 1 completed.'), findsOneWidget);
    },
  );

  testWidgets('complete can send unfinished tasks back to the backlog', (
    tester,
  ) async {
    final s = FakeSprintsClient(
      sprints: [
        mkSprint('s1', 'Sprint 1', state: SprintState.active),
        mkSprint(
          's2',
          'Sprint 2',
          start: DateTime(2026, 11, 23),
          end: DateTime(2026, 12, 6),
        ),
      ],
      tasks: [sTask('b', sprint: 's1', points: 5)],
    );
    await open(tester, s);

    await tester.tap(key('complete-sprint'));
    await tester.pumpAndSettle();
    await tester.tap(key('carry-backlog'));
    await tester.pump();
    await tester.tap(key('complete-confirm'));
    await tester.pumpAndSettle();

    expect(s.completes.single.carry, 'backlog');
    expect(s.all.single.sprintId, '');
  });

  testWidgets('without a planned sprint the only choice is the backlog', (
    tester,
  ) async {
    final s = FakeSprintsClient(
      sprints: [mkSprint('s1', 'Sprint 1', state: SprintState.active)],
      tasks: [sTask('b', sprint: 's1')],
    );
    await open(tester, s);

    await tester.tap(key('complete-sprint'));
    await tester.pumpAndSettle();

    expect(find.text('No planned sprint to move them to'), findsOneWidget);
    await tester.tap(key('complete-confirm'));
    await tester.pumpAndSettle();
    expect(s.completes.single.carry, 'backlog');
  });

  testWidgets(
    'a new sprint warns about overlapping dates before and after saving',
    (tester) async {
      final s = planning()..warnNext = ['Dates overlap "Sprint 1".'];
      await open(tester, s);

      await tester.tap(key('new-sprint'));
      await tester.pumpAndSettle();
      await tester.enterText(key('sprint-name'), 'Sprint 2');
      await tester.enterText(key('sprint-start'), '2026-11-20');
      await tester.enterText(key('sprint-end'), '2026-12-03');
      await tester.pump();
      expect(key('sprint-overlap'), findsOneWidget);
      expect(find.textContaining('Sprint 1'), findsWidgets);

      await tester.tap(key('sprint-save'));
      await tester.pumpAndSettle();
      expect(find.text('Dates overlap "Sprint 1".'), findsOneWidget);
      await tester.tap(key('sprint-done'));
      await tester.pumpAndSettle();

      expect(s.sprints.map((x) => x.name), contains('Sprint 2'));
    },
  );

  testWidgets('the form checks the dates before asking the server', (
    tester,
  ) async {
    final s = planning();
    await open(tester, s);

    await tester.tap(key('new-sprint'));
    await tester.pumpAndSettle();
    await tester.enterText(key('sprint-name'), 'X');
    await tester.enterText(key('sprint-start'), '2026-12-10');
    await tester.enterText(key('sprint-end'), '2026-12-01');
    await tester.tap(key('sprint-save'));
    await tester.pumpAndSettle();

    expect(
      find.text('The sprint cannot end before it starts.'),
      findsOneWidget,
    );
    expect(s.calls, isNot(contains('create')));
  });

  testWidgets('editing with a stale version shows the conflict cleanly', (
    tester,
  ) async {
    final s = planning();
    await open(tester, s);
    // Someone else edits it first.
    s.sprints[0] = mkSprint('s1', 'Sprint 1', goal: 'Ship login', version: 2);

    await tester.tap(key('edit-sprint'));
    await tester.pumpAndSettle();
    await tester.enterText(key('sprint-name'), 'Renamed');
    await tester.tap(key('sprint-save'));
    await tester.pumpAndSettle();

    expect(s.updates.single, ['name']);
    expect(find.textContaining('changed since you opened it'), findsOneWidget);
  });

  testWidgets(
    'reports draw the burndown, toggle the metric and show velocity',
    (tester) async {
      final s = FakeSprintsClient(
        sprints: [mkSprint('s1', 'Sprint 1', state: SprintState.active)],
      )..burndownAnswer = sampleBurndown();
      await open(tester, s);

      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      expect(key('burndown-chart'), findsOneWidget);
      expect(key('velocity-chart'), findsOneWidget);
      expect(find.textContaining('last 2 sprints'), findsOneWidget);
      await tester.tap(key('metric-tasks'));
      await tester.pumpAndSettle();
      expect(key('burndown-chart'), findsOneWidget);
    },
  );

  testWidgets('a sprint not yet started has an empty velocity message', (
    tester,
  ) async {
    await open(tester, planning());

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    expect(key('burndown-empty'), findsOneWidget);
    expect(key('velocity-empty'), findsOneWidget);
  });

  testWidgets('a viewer sees the plan but cannot change it', (tester) async {
    await open(tester, planning(), role: 'Viewer');

    expect(find.text('Sprint 1 (1)'), findsOneWidget);
    expect(key('new-sprint'), findsNothing);
    expect(key('start-sprint'), findsNothing);
    expect(key('add-to-sprint'), findsNothing);
    expect(key('drag-a'), findsNothing);
  });

  testWidgets('a failed load can be retried', (tester) async {
    final s = planning()
      ..failList = const SprintException(SprintFailure.network);
    await open(tester, s);

    expect(key('sprints-error'), findsOneWidget);
    s.failList = null;
    await tester.tap(key('sprints-retry'));
    await tester.pumpAndSettle();

    expect(find.text('Sprint 1 (1)'), findsOneWidget);
  });
}
