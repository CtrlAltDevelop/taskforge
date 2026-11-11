import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

import 'fakes.dart';

BurndownDay day(
  int d, {
  double ideal = 0,
  double? remaining,
  int tasks = 0,
  double idealTasks = 0,
}) => BurndownDay(
  date: DateTime(2026, 11, d),
  idealPoints: ideal,
  idealTasks: idealTasks,
  hasActual: remaining != null,
  remainingPoints: remaining ?? 0,
  remainingTasks: tasks,
);

void main() {
  group('burndown chart data', () {
    final b = Burndown(
      sprint: mkSprint('s1', 'S1', state: SprintState.active),
      baselinePoints: 10,
      baselineTasks: 4,
      days: [
        day(9, ideal: 10, remaining: 10, tasks: 4, idealTasks: 4),
        day(10, ideal: 7.5, remaining: 8, tasks: 3, idealTasks: 3),
        day(11, ideal: 5, remaining: 11, tasks: 4, idealTasks: 2),
        day(12, ideal: 2.5, idealTasks: 1), // future: nothing measured
        day(13, idealTasks: 0),
      ],
      scopeChanges: [
        ScopeChange(date: DateTime(2026, 11, 11), points: 5, tasks: 1),
        ScopeChange(date: DateTime(2026, 11, 10)),
      ],
    );

    test('actual line stops where nothing was measured', () {
      final c = buildBurndownChart(b, BurndownMetric.points);

      expect(c.points.map((p) => p.actual), [10, 8, 11, null, null]);
      expect(c.points.map((p) => p.ideal), [10, 7.5, 5, 2.5, 0]);
    });

    test(
      'a scope change becomes a step on its day; zero changes are dropped',
      () {
        final c = buildBurndownChart(b, BurndownMetric.points);

        expect(c.steps, hasLength(1));
        expect(c.steps.single.index, 2);
        expect(c.steps.single.delta, 5);
      },
    );

    test('tasks metric reads task counts and task steps', () {
      final c = buildBurndownChart(b, BurndownMetric.tasks);

      expect(c.points.map((p) => p.actual), [4, 3, 4, null, null]);
      expect(c.steps.single.delta, 1);
    });

    test('the top of the chart fits the largest value (scope grew)', () {
      expect(buildBurndownChart(b, BurndownMetric.points).maxY, 11);
      expect(buildBurndownChart(b, BurndownMetric.tasks).maxY, 4);
    });

    test('an empty burndown has no points and a usable top', () {
      final c = buildBurndownChart(
        Burndown(sprint: mkSprint('s', 'S')),
        BurndownMetric.points,
      );

      expect(c.isEmpty, isTrue);
      expect(c.maxY, 1);
    });
  });

  group('back-filled days', () {
    final b = Burndown(
      sprint: mkSprint('s1', 'S1', state: SprintState.active),
      baselinePoints: 10,
      baselineTasks: 4,
      days: [
        day(9, ideal: 10, remaining: 10, tasks: 4),
        BurndownDay(
          date: DateTime(2026, 11, 10),
          idealPoints: 5,
          hasActual: true,
          backfilled: true,
          remainingPoints: 7,
          remainingTasks: 3,
        ),
        BurndownDay(
          date: DateTime(2026, 11, 11),
          idealPoints: 0,
          backfilled: true, // nothing measured: nothing to mark
        ),
      ],
    );

    test('the chart marks the days that were written late', () {
      final c = buildBurndownChart(b, BurndownMetric.points);

      expect(c.points.map((p) => p.backfilled), [false, true, true]);
      expect(c.backfilledDays, 1);
    });
  });

  group('capacity', () {
    test('a sprint reads its capacity in points or in hours', () {
      final s = mkSprint('s', 'S', capacityPoints: 12.5, capacitySec: 36000);

      expect(s.capacityIn(hours: false), 12.5);
      expect(s.capacityIn(hours: true), 10);
      expect(mkSprint('s', 'S').capacityIn(hours: true), isNull);
    });

    test('decimals are kept to two places without trailing zeros', () {
      expect(
        [decimalText(8), decimalText(12.25), decimalText(0.5)],
        ['8', '12.25', '0.5'],
      );
    });

    test('under capacity fills part of the bar', () {
      const c = Capacity(load: 8, capacity: 20);

      expect(c.fraction, 0.4);
      expect(c.over, isFalse);
      expect(c.remaining, 12);
    });

    test('over capacity fills the bar and says so', () {
      const c = Capacity(load: 25, capacity: 20);

      expect(c.fraction, 1);
      expect(c.over, isTrue);
      expect(c.remaining, -5);
    });

    test('no capacity is never over', () {
      const c = Capacity(load: 25);

      expect(c.known, isFalse);
      expect(c.over, isFalse);
      expect(c.fraction, 0);
    });

    test('load is points, or hours of estimate', () {
      final s = Sprint(
        id: 's',
        projectId: 'p',
        name: 'S',
        startDate: DateTime(2026, 11, 9),
        endDate: DateTime(2026, 11, 22),
        pointsTotal: 13,
        estimateSecTotal: 9000,
      );

      expect(sprintLoad(s, hours: false), 13);
      expect(sprintLoad(s, hours: true), 2.5);
    });
  });

  group('dates', () {
    final s = mkSprint('s', 'S', end: DateTime(2026, 11, 22));

    test('days left counts the end day and never goes below zero', () {
      expect(daysLeft(s, DateTime(2026, 11, 22, 18)), 1);
      expect(daysLeft(s, DateTime(2026, 11, 12)), 11);
      expect(daysLeft(s, DateTime(2026, 11, 30)), 0);
    });

    test('overlap ignores completed sprints, itself and neighbours', () {
      final others = [
        mkSprint(
          'a',
          'A',
          start: DateTime(2026, 11, 20),
          end: DateTime(2026, 12, 3),
        ),
        mkSprint('b', 'B', state: SprintState.completed),
        mkSprint(
          'c',
          'C',
          start: DateTime(2026, 11, 23),
          end: DateTime(2026, 12, 6),
        ),
      ];

      final hit = overlapping(
        others,
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 22),
      );

      expect(hit.map((x) => x.id), ['a']);
      expect(
        overlapping(
          others,
          DateTime(2026, 11, 20),
          DateTime(2026, 12, 3),
          exceptId: 'a',
        ).map((x) => x.id),
        ['c'],
      );
    });

    test('parseDay accepts ISO days and rejects impossible ones', () {
      expect(parseDay('2026-11-09'), DateTime(2026, 11, 9));
      expect(parseDay('2026-02-31'), isNull);
      expect(parseDay('soon'), isNull);
    });

    test('velocity keeps the last six, oldest first', () {
      final v = [
        for (var i = 1; i <= 8; i++) VelocityItem(sprintId: '$i', name: 'S$i'),
      ];

      expect(lastVelocity(v).map((x) => x.name), [
        'S3',
        'S4',
        'S5',
        'S6',
        'S7',
        'S8',
      ]);
      expect(lastVelocity(v.take(2).toList()), hasLength(2));
    });
  });

  test('conflicts show the server text, other failures a plain one', () {
    expect(
      sprintErrorMessage(
        const SprintException(
          SprintFailure.conflict,
          detail: '"S1" is already active.',
        ),
      ),
      '"S1" is already active.',
    );
    expect(
      sprintErrorMessage(const SprintException(SprintFailure.conflict)),
      contains('changed this first'),
    );
    expect(
      sprintErrorMessage(const SprintException(SprintFailure.denied)),
      contains('access'),
    );
  });
}
