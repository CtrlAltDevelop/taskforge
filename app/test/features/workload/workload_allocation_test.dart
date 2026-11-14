import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workload/domain/workload.dart';

DateTime d(int day) => DateTime.utc(2026, 3, day); // 2026-03-02 is a Monday

const weekdays = [0, 1, 2, 3, 4];

Capacity cap(String user, {double hours = 8}) => Capacity(
  userId: user,
  hoursPerDay: hours,
  workingDays: weekdays,
  isSet: true,
);

LoadTask task({
  DateTime? start,
  DateTime? due,
  int estimate = 8 * 3600,
  List<String> assignees = const ['a'],
  Map<String, int> own = const {},
}) => LoadTask(
  id: 't1',
  projectId: 'p',
  displayId: 'P-1',
  title: 'T',
  version: 1,
  start: start,
  due: due,
  estimateSec: estimate,
  assigneeIds: assignees,
  own: own,
);

WorkloadData data({
  Set<DateTime> holidays = const {},
  List<String> users = const ['a'],
}) => WorkloadData(
  start: d(2),
  end: d(15),
  canSeeAll: true,
  people: [
    for (final u in users)
      PersonLoad(
        userId: u,
        capacity: cap(u),
        timeOff: const [],
        days: const {},
      ),
  ],
  tasks: const {},
  unplaced: const [],
  holidays: holidays,
  truncated: false,
);

void main() {
  group('spreadEstimate', () {
    bool working(DateTime day) => day.weekday <= 5;

    test('spreads equally over working days and skips the weekend', () {
      final out = spreadEstimate(10 * 3600, d(5), d(9), working); // Thu..Mon
      expect(out.keys.toList(), [d(5), d(6), d(9)]);
      expect(out.values.fold(0, (a, b) => a + b), 10 * 3600);
    });

    test('remainder seconds go to the earliest days', () {
      final out = spreadEstimate(10, d(2), d(4), working);
      expect(out.values.toList(), [4, 3, 3]);
    });

    test('puts everything on the due date when no day works', () {
      final out = spreadEstimate(3600, d(7), d(8), working); // Sat..Sun
      expect(out, {d(8): 3600});
    });

    test('a missing date makes a one-day range; no estimate gives nothing', () {
      expect(spreadEstimate(3600, null, d(4), working), {d(4): 3600});
      expect(spreadEstimate(3600, d(4), null, working), {d(4): 3600});
      expect(spreadEstimate(0, d(4), d(4), working), isEmpty);
      expect(spreadEstimate(3600, null, null, working), isEmpty);
    });
  });

  group('splitEstimate', () {
    test('equal split with the remainder on the first people', () {
      expect(splitEstimate(7, ['a', 'b', 'c'], {}), {'a': 3, 'b': 2, 'c': 2});
    });

    test('own estimates are kept and the rest share what is left', () {
      expect(splitEstimate(3600, ['a', 'b', 'c'], {'a': 1800}), {
        'a': 1800,
        'b': 900,
        'c': 900,
      });
    });

    test('nothing is left over when own estimates exceed the total', () {
      expect(splitEstimate(100, ['a', 'b'], {'a': 500}), {'a': 500});
    });
  });

  group('recount (optimistic allocation)', () {
    test('holidays and weekends carry no load', () {
      // Mon 2 .. Fri 6, with Wednesday a holiday: 4 working days.
      final moved = task(start: d(2), due: d(6), estimate: 4 * 3600);
      final out = recount(data(holidays: {d(4)}), moved);
      final person = out.people.single;
      expect(person.days.keys.toSet(), {d(2), d(3), d(5), d(6)});
      expect(person.loadOn(d(4)), 0);
      expect(person.loadOn(d(2)), 3600);
      expect(out.tasks['t1'], moved);
    });

    test('several assignees split the estimate between their rows', () {
      final moved = task(
        start: d(2),
        due: d(3),
        estimate: 4 * 3600,
        assignees: ['a', 'b'],
      );
      final out = recount(data(users: ['a', 'b']), moved);
      expect(out.people[0].loadOn(d(2)), 3600);
      expect(out.people[1].loadOn(d(3)), 3600);
    });

    test('a person who is not assigned any more loses the task', () {
      final first = recount(
        data(users: ['a', 'b']),
        task(start: d(2), due: d(2), assignees: ['a', 'b']),
      );
      final out = recount(first, task(start: d(2), due: d(2)));
      expect(out.people[1].days, isEmpty);
      expect(out.people[0].loadOn(d(2)), 8 * 3600);
    });

    test('days outside the window are left out', () {
      final out = recount(data(), task(start: d(13), due: d(18)));
      expect(out.people.single.days.keys.every((k) => !k.isAfter(d(15))), true);
    });

    test('moving a task replaces its earlier cells', () {
      final first = recount(data(), task(start: d(2), due: d(2)));
      final out = recount(first, task(start: d(3), due: d(3)));
      expect(out.people.single.loadOn(d(2)), 0);
      expect(out.people.single.loadOn(d(3)), 8 * 3600);
    });
  });

  test('columnStart and nextColumn', () {
    expect(columnStart(WorkloadZoom.week, d(5)), d(2));
    expect(columnStart(WorkloadZoom.month, d(20)), DateTime.utc(2026, 3));
    expect(nextColumn(WorkloadZoom.week, d(2)), d(9));
    expect(
      nextColumn(WorkloadZoom.month, DateTime.utc(2026, 12)),
      DateTime.utc(2027),
    );
  });

  test('hoursText trims zeros', () {
    expect(hoursText(3600), '1');
    expect(hoursText(5400), '1.5');
    expect(hoursText(2700), '0.75');
  });
}
