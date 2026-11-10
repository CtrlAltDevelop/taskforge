import 'dart:ui' show Offset, Rect;

import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

Task task(
  String id, {
  String start = '',
  String due = '',
  String parent = '',
  String status = 'Todo',
  List<String> assignees = const [],
}) => Task(
  id: id,
  projectId: 'p',
  number: 1,
  displayId: 'W-$id',
  title: id,
  statusId: 's',
  statusName: status,
  startDate: start,
  dueDate: due,
  parentId: parent,
  assigneeIds: assignees,
);

String titles(List<TimelineRow> rows) => rows
    .map(
      (r) =>
          r.header != null ? '[${r.header}]' : '${'-' * r.depth}${r.task!.id}',
    )
    .join(' ');

void main() {
  group('the axis', () {
    final axis = TimeAxis(day(2026, 11, 1), 10);

    test('maps days to pixels and back', () {
      expect(axis.xOf(day(2026, 11, 4)), 30);
      expect(axis.xOf(day(2026, 10, 31)), -10);
      expect(axis.dayAt(35), day(2026, 11, 4));
      expect(axis.dayAt(-1), day(2026, 10, 31));
    });

    test('a bar covers both its first and its last day', () {
      expect(axis.widthOf(day(2026, 11, 2), day(2026, 11, 4)), 30);
    });
  });

  group('zoom', () {
    test('gets finer or coarser and stops at the ends', () {
      expect(TimelineZoom.week.finer, TimelineZoom.day);
      expect(TimelineZoom.day.finer, TimelineZoom.day);
      expect(TimelineZoom.month.coarser, TimelineZoom.quarter);
      expect(TimelineZoom.quarter.coarser, TimelineZoom.quarter);
    });

    test('a pinch changes it only when it is clear', () {
      expect(zoomAfter(TimelineZoom.week, 1.1), TimelineZoom.week);
      expect(zoomAfter(TimelineZoom.week, 1.6), TimelineZoom.day);
      expect(zoomAfter(TimelineZoom.week, 0.5), TimelineZoom.month);
    });

    test('every read stays within what the server allows', () {
      for (final z in TimelineZoom.values) {
        final r = readRange(z, day(2026, 11, 1));
        expect(daysBetween(r.first, r.last), lessThanOrEqualTo(1100));
      }
    });
  });

  group('rows', () {
    test(
      'subtasks follow their parent; a parent out of range does not hide them',
      () {
        final rows = buildRows([
          task('a'),
          task('a1', parent: 'a'),
          task('a1x', parent: 'a1'),
          task('b'),
          task('orphan', parent: 'gone'),
        ], groupNone);

        expect(titles(rows), 'a -a1 --a1x b orphan');
      },
    );

    test('a parent cycle in bad data neither loops nor hides a task', () {
      final rows = buildRows([
        task('a', parent: 'b'),
        task('b', parent: 'a'),
      ], groupNone);

      expect(titles(rows), 'a -b');
    });

    test('groups by status in name order', () {
      final rows = buildRows([
        task('x', status: 'Todo'),
        task('y', status: 'Doing'),
        task('z', status: 'Todo'),
      ], groupStatus);

      expect(titles(rows), '[Doing] y [Todo] x z');
    });

    test('groups by assignee with the unassigned last', () {
      final rows = buildRows(
        [
          task('x', assignees: ['u2']),
          task('y'),
          task('z', assignees: ['u1']),
        ],
        groupAssignee,
        assigneeName: (id) => id == 'u1' ? 'Zed' : 'Amy',
      );

      expect(titles(rows), '[Amy] x [Zed] z [Unassigned] y');
    });
  });

  group('bars', () {
    final axis = TimeAxis(day(2026, 11, 1), 10);

    test('a bar spans its days on its row', () {
      final r = barRect(
        task('a', start: '2026-11-02', due: '2026-11-04'),
        axis,
        2,
      )!;

      expect((r.left, r.width), (10, 30));
      expect(r.top, 2 * rowHeight + (rowHeight - barHeight) / 2);
    });

    test(
      'a task with one date is a milestone: a square centred on its day',
      () {
        final t = task('m', due: '2026-11-05');
        final r = barRect(t, axis, 0)!;

        expect(isMilestone(t), isTrue);
        expect((r.width, r.height), (barHeight, barHeight));
        expect(r.center.dx, 45);
      },
    );

    test('a task with no date has no bar', () {
      expect(barRect(task('u'), axis, 0), isNull);
      expect(isMilestone(task('u')), isFalse);
      expect(
        isMilestone(task('b', start: '2026-11-01', due: '2026-11-02')),
        isFalse,
      );
    });
  });

  group('virtualisation', () {
    test('only the rows in view (and one either side) are asked for', () {
      final r = visibleRows(10 * rowHeight, 5 * rowHeight, 1000);

      expect((r.first, r.last), (9, 16));
    });

    test('stays inside the rows and copes with none', () {
      expect(visibleRows(0, 100, 3), (first: 0, last: 2));
      expect(
        visibleRows(0, 100, 0).last,
        lessThan(visibleRows(0, 100, 0).first),
      );
    });

    test(
      'a link crossing the viewport shows although both ends are off screen',
      () {
        const range = (first: 10, last: 20);

        expect(linkVisible(2, 30, range), isTrue);
        expect(linkVisible(2, 5, range), isFalse);
        expect(linkVisible(25, 30, range), isFalse);
        expect(linkVisible(15, 5, range), isTrue);
      },
    );
  });

  group('arrows', () {
    test('an elbow when the dependent starts well after', () {
      final pts = arrowPoints(
        Rect.fromLTWH(0, 0, 50, 20),
        Rect.fromLTWH(100, 32, 50, 20),
      );

      expect(pts.first, const Offset(50, 10));
      expect(pts.last, const Offset(100, 42));
      expect(pts, hasLength(4));
    });

    test('goes around when the dependent starts too soon', () {
      final pts = arrowPoints(
        Rect.fromLTWH(0, 0, 50, 20),
        Rect.fromLTWH(40, 32, 50, 20),
      );

      expect(pts, hasLength(6));
      expect(pts.last, const Offset(40, 42));
    });

    test('a dependent that starts before its blocker is due is a conflict', () {
      final blocker = task('a', start: '2026-11-01', due: '2026-11-05');

      expect(
        linkConflicts(
          blocker,
          task('b', start: '2026-11-05', due: '2026-11-08'),
        ),
        isTrue,
      );
      expect(
        linkConflicts(
          blocker,
          task('b', start: '2026-11-06', due: '2026-11-08'),
        ),
        isFalse,
      );
      expect(linkConflicts(blocker, task('b')), isFalse);
    });
  });

  group('axis ticks', () {
    test('a day tick each day, the month name on the 1st', () {
      final t = axisTicks(
        TimelineZoom.day,
        day(2026, 10, 30),
        day(2026, 11, 2),
      );

      expect(t.map((e) => e.label), ['30', '31', 'Nov', '2']);
      expect(t[2].major, isTrue);
    });

    test('a week tick each Monday', () {
      final t = axisTicks(
        TimelineZoom.week,
        day(2026, 11, 1),
        day(2026, 11, 16),
      );

      expect(t.map((e) => e.label), ['2 Nov', '9 Nov', '16 Nov']);
    });

    test('a month tick on the 1st, the year in January', () {
      final t = axisTicks(
        TimelineZoom.month,
        day(2026, 11, 15),
        day(2027, 2, 1),
      );

      expect(t.map((e) => e.label), ['Dec', '2027', 'Feb']);
    });

    test('a quarter tick every three months', () {
      final t = axisTicks(
        TimelineZoom.quarter,
        day(2026, 1, 1),
        day(2026, 12, 31),
      );

      expect(t.map((e) => e.label), [
        'Q1 2026',
        'Q2 2026',
        'Q3 2026',
        'Q4 2026',
      ]);
    });
  });
}
