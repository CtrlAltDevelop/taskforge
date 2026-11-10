import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../tasks/fakes.dart';

Task _t(String id, {String start = '', String due = '', int n = 1}) =>
    task(id, id, number: n).withDates(start, due);

extension on Task {
  Task withDates(String start, String due) => Task(
    id: id,
    projectId: projectId,
    number: number,
    displayId: displayId,
    title: title,
    statusId: statusId,
    startDate: start,
    dueDate: due,
  );
}

void main() {
  group('days', () {
    test('a date reads the same whatever the zone or the season', () {
      for (final iso in [
        '2026-11-05',
        '2026-03-29',
        '2026-10-25',
        '2024-02-29',
      ]) {
        expect(formatDay(parseDay(iso)!), iso);
      }
      // Across a daylight-saving change, a day is still one day.
      expect(formatDay(addDays(day(2026, 3, 28), 2)), '2026-03-30');
      expect(daysBetween(day(2026, 3, 28), day(2026, 3, 30)), 2);
      expect(formatDay(addDays(day(2026, 12, 31), 1)), '2027-01-01');
    });

    test('a late-evening instant in a far zone is still that local date', () {
      // 23:30 on 5 Nov at UTC-8 and 00:30 on 6 Nov at UTC+4:30 are different
      // local dates: the date comes from the calendar, never from an instant.
      expect(formatDay(dayOf(DateTime(2026, 11, 5, 23, 30))), '2026-11-05');
      expect(formatDay(dayOf(DateTime(2026, 11, 6, 0, 30))), '2026-11-06');
    });

    test('a task lands on the same day in every zone', () {
      // The same instants seen from UTC+4:30 and UTC-8: the local date is
      // whatever the wall clock there says, and a date-only due date meets it
      // on that very day.
      final instant = DateTime.utc(2026, 11, 5, 20, 0); // 20:00 UTC
      final zones = {
        'UTC+4:30': const Duration(hours: 4, minutes: 30),
        'UTC-8': const Duration(hours: -8),
      };
      final dueFifth = _t('x', due: '2026-11-05');
      final expected = {'UTC+4:30': '2026-11-06', 'UTC-8': '2026-11-05'};
      for (final z in zones.entries) {
        final wall = instant.add(z.value); // the wall clock there
        final local = dayOf(
          DateTime(wall.year, wall.month, wall.day, wall.hour),
        );
        expect(formatDay(local), expected[z.key], reason: z.key);
        // The task never moves with the zone: it is on 5 Nov in both.
        expect(tasksOn([dueFifth], day(2026, 11, 5)), isNotEmpty);
        expect(tasksOn([dueFifth], day(2026, 11, 6)), isEmpty);
      }
    });

    test('bad dates are not dates', () {
      expect(parseDay(''), isNull);
      expect(parseDay('2026-02-30'), isNull);
      expect(parseDay('5 Nov'), isNull);
    });
  });

  group('the visible range', () {
    test('a month grid is whole weeks, from the week start', () {
      final monday = visibleRange(CalendarMode.month, day(2026, 11, 10), 1);
      expect(formatDay(monday.first), '2026-10-26');
      expect(formatDay(monday.last), '2026-12-06');
      final sunday = visibleRange(CalendarMode.month, day(2026, 11, 10), 7);
      expect(formatDay(sunday.first), '2026-11-01');
      expect(formatDay(sunday.last), '2026-12-05');
    });

    test('a week and a day', () {
      final week = visibleRange(CalendarMode.week, day(2026, 11, 10), 1);
      expect(
        [formatDay(week.first), formatDay(week.last)],
        ['2026-11-09', '2026-11-15'],
      );
      final one = visibleRange(CalendarMode.day, day(2026, 11, 10), 1);
      expect(one.first, one.last);
    });

    test('stepping a month lands on the first of that month', () {
      expect(
        formatDay(step(CalendarMode.month, day(2026, 1, 31), 1)),
        '2026-02-01',
      );
      expect(
        formatDay(step(CalendarMode.month, day(2026, 1, 15), -1)),
        '2025-12-01',
      );
      expect(
        formatDay(step(CalendarMode.week, day(2026, 11, 10), 1)),
        '2026-11-17',
      );
    });
  });

  group('bars', () {
    final weekFirst = day(2026, 11, 9); // a Monday

    test('a bar spans its columns, a single date is one column', () {
      final row = layoutWeek([
        _t('bar', start: '2026-11-10', due: '2026-11-12'),
        _t('one', due: '2026-11-14', n: 2),
      ], weekFirst);

      final bar = row.segments.firstWhere((s) => s.task.id == 'bar');
      expect((bar.startCol, bar.endCol, bar.lane), (1, 3, 0));
      final one = row.segments.firstWhere((s) => s.task.id == 'one');
      expect((one.startCol, one.endCol), (5, 5));
    });

    test('a bar that runs on into the next week says so', () {
      final row = layoutWeek([
        _t('long', start: '2026-11-12', due: '2026-11-20'),
      ], weekFirst);
      final next = layoutWeek([
        _t('long', start: '2026-11-12', due: '2026-11-20'),
      ], day(2026, 11, 16));

      expect(
        (row.segments.single.endCol, row.segments.single.continuesAfter),
        (6, true),
      );
      expect(row.segments.single.continuesBefore, isFalse);
      expect(
        (next.segments.single.startCol, next.segments.single.continuesBefore),
        (0, true),
      );
      expect(next.segments.single.endCol, 4);
    });

    test('overlapping bars never share a lane, longer ones go first', () {
      final row = layoutWeek([
        _t('short', start: '2026-11-10', due: '2026-11-11', n: 1),
        _t('long', start: '2026-11-09', due: '2026-11-13', n: 2),
        _t('late', start: '2026-11-12', due: '2026-11-13', n: 3),
      ], weekFirst);

      final lanes = {for (final s in row.segments) s.task.id: s.lane};
      expect(lanes['long'], 0);
      expect(lanes['short'], 1);
      expect(lanes['late'], 1); // free again after "short"
    });

    test('what does not fit is counted per day', () {
      final tasks = [
        for (var i = 0; i < 5; i++) _t('t$i', due: '2026-11-10', n: i + 1),
      ];

      final row = layoutWeek(tasks, weekFirst, maxLanes: 3);

      expect(row.segments, hasLength(3));
      expect(row.hidden, [0, 2, 0, 0, 0, 0, 0]);
    });

    test('tasks outside the week or without dates are skipped', () {
      final row = layoutWeek([
        _t('before', due: '2026-11-08'),
        _t('after', due: '2026-11-16'),
        _t('none'),
      ], weekFirst);

      expect(row.segments, isEmpty);
    });

    test('a start date after the due date is read the other way round', () {
      final span = spanOf(_t('x', start: '2026-11-12', due: '2026-11-10'))!;
      expect(
        [formatDay(span.first), formatDay(span.last)],
        ['2026-11-10', '2026-11-12'],
      );
    });

    test('tasksOn lists what falls on a day', () {
      final tasks = [
        _t('a', start: '2026-11-09', due: '2026-11-11', n: 2),
        _t('b', due: '2026-11-10', n: 1),
        _t('c', due: '2026-11-12'),
      ];

      expect(tasksOn(tasks, day(2026, 11, 10)).map((t) => t.id), ['a', 'b']);
    });
  });

  group('rescheduling', () {
    test('a bar keeps its length when it moves', () {
      final t = _t('t', start: '2026-11-10', due: '2026-11-12');

      // Picked up on its second day, dropped on the 20th.
      final moved = moveTask(t, day(2026, 11, 20), grabbed: day(2026, 11, 11));

      expect(moved, Dates(start: day(2026, 11, 19), due: day(2026, 11, 21)));
    });

    test('one date moves to the day, none becomes a due date', () {
      expect(
        moveTask(_t('t', due: '2026-11-10'), day(2026, 11, 20)),
        Dates(due: day(2026, 11, 20)),
      );
      expect(
        moveTask(_t('t', start: '2026-11-10'), day(2026, 11, 20)),
        Dates(start: day(2026, 11, 20)),
      );
      expect(
        moveTask(_t('t'), day(2026, 11, 20)),
        Dates(due: day(2026, 11, 20)),
      );
    });

    test('moving across a daylight-saving change keeps the length', () {
      final t = _t('t', start: '2026-03-27', due: '2026-03-29');

      final moved = moveTask(t, day(2026, 3, 30), grabbed: day(2026, 3, 27));

      expect(moved.startIso, '2026-03-30');
      expect(moved.dueIso, '2026-04-01');
    });

    test('an edge can be dragged but never past the other one', () {
      final t = _t('t', start: '2026-11-10', due: '2026-11-12');

      expect(
        resizeTask(t, BarEdge.end, day(2026, 11, 15)).dueIso,
        '2026-11-15',
      );
      expect(resizeTask(t, BarEdge.end, day(2026, 11, 1)).dueIso, '2026-11-10');
      expect(
        resizeTask(t, BarEdge.start, day(2026, 11, 8)).startIso,
        '2026-11-08',
      );
      expect(
        resizeTask(t, BarEdge.start, day(2026, 11, 30)).startIso,
        '2026-11-12',
      );
      expect(
        resizeTask(t, BarEdge.start, day(2026, 11, 8)).dueIso,
        '2026-11-12',
      );
    });

    test('a task with one date grows a second one', () {
      final due = _t('t', due: '2026-11-12');

      final grown = resizeTask(due, BarEdge.start, day(2026, 11, 9));

      expect((grown.startIso, grown.dueIso), ('2026-11-09', '2026-11-12'));
    });
  });
}
