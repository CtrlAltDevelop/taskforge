import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/calendar_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

import 'package:taskforge/core/ui/tokens/colors.dart';

const _wide = Size(1400, 1000);
const _tablet = Size(800, 1000);
const _phone = Size(420, 900);

final _today = day(2026, 11, 10); // a Tuesday

Task _t(
  String id,
  String title, {
  String start = '',
  String due = '',
  int n = 1,
  String statusId = 'todo',
  TaskPriority priority = TaskPriority.none,
  bool blocked = false,
  String blockersDue = '',
  String blocksDue = '',
  String dueTime = '',
}) {
  final base = task(
    id,
    title,
    number: n,
    statusId: statusId,
    statusName: fakeStatuses[statusId]!.$1,
    category: fakeStatuses[statusId]!.$2,
    priority: priority,
    isBlocked: blocked,
    blockedBy: blocked ? ['WEB-9 (In progress)'] : const [],
  );
  return Task(
    id: base.id,
    projectId: base.projectId,
    number: base.number,
    displayId: base.displayId,
    title: base.title,
    statusId: base.statusId,
    statusName: base.statusName,
    statusCategory: base.statusCategory,
    priority: base.priority,
    startDate: start,
    dueDate: due,
    dueTime: dueTime,
    isBlocked: base.isBlocked,
    blockedBy: base.blockedBy,
    blockersDue: blockersDue,
    blocksDue: blocksDue,
  );
}

typedef Opened = ({
  FakeTasksClient tasks,
  FakeCalendarClient calendar,
  FakeViewsClient views,
});

Future<Opened> _open(
  WidgetTester tester, {
  List<Task>? tasks,
  String role = 'Owner',
  Size size = _wide,
  FakeViewsClient? views,
  int weekStart = 1,
  int trayPage = 50,
}) async {
  final all =
      tasks ??
      [
        _t('a', 'Alpha', due: '2026-11-12'),
        _t('b', 'Bravo', start: '2026-11-09', due: '2026-11-11', n: 2),
        _t('c', 'Charlie', n: 3),
        _t('d', 'Delta', due: '2026-11-12', n: 4, statusId: 'done'),
      ];
  final server = FakeTasksClient(all);
  final calendar = FakeCalendarClient(server)..trayPageSize = trayPage;
  final saved =
      views ??
      (FakeViewsClient()
        ..calendars.add(
          SavedCalendar(
            id: 'c1',
            name: personalLayoutName,
            layout: CalendarLayout(weekStart: weekStart),
            isShared: false,
            version: 1,
          ),
        ));
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    views: saved,
    calendar: calendar,
    today: _today,
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('view-switch')),
      matching: find.byIcon(TfIcons.calendar.glyph),
    ),
  );
  await tester.pumpAndSettle();
  return (tasks: server, calendar: calendar, views: saved);
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> _drag(WidgetTester tester, Offset from, Offset to) async {
  final gesture = await tester.startGesture(from);
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveBy(const Offset(0, 24));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveTo(to);
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.up();
  await tester.pumpAndSettle();
}

Offset _dayCenter(WidgetTester tester, String iso) =>
    tester.getCenter(find.byKey(Key('day-$iso')));

Task _stored(Opened o, String id) =>
    o.tasks.tasks.firstWhere((t) => t.id == id);

void main() {
  group('the month', () {
    testWidgets('shows today, bars across their days and single dates', (
      tester,
    ) async {
      await _open(tester);

      expect(find.byKey(const Key('today-marker')), findsOneWidget);
      expect(find.byKey(const Key('cal-title')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('cal-title'))).data,
        'November 2026',
      );
      final bar = find.byKey(const Key('bar-b-2026-11-09'));
      final chip = find.byKey(const Key('bar-a-2026-11-09'));
      expect(bar, findsOneWidget);
      expect(chip, findsOneWidget);
      // Bravo covers Mon–Wed: three columns; Alpha only Thursday.
      expect(
        tester.getSize(bar).width,
        closeTo(3 * tester.getSize(chip).width, 8),
      );
      expect(
        tester.getTopLeft(chip).dx,
        greaterThan(tester.getTopLeft(bar).dx),
      );
    });

    testWidgets('only the days on screen are asked for', (tester) async {
      final s = await _open(tester);

      expect(s.calendar.ranges.single.first, '2026-10-26');
      expect(s.calendar.ranges.single.last, '2026-12-06');
    });

    testWidgets('flipping to the next month reads that range', (tester) async {
      final s = await _open(tester);

      await _tap(tester, 'cal-next');

      expect(
        tester.widget<Text>(find.byKey(const Key('cal-title'))).data,
        'December 2026',
      );
      expect(s.calendar.ranges.last.first, '2026-11-30');
      await _tap(tester, 'cal-today');
      expect(
        tester.widget<Text>(find.byKey(const Key('cal-title'))).data,
        'November 2026',
      );
    });

    testWidgets('an answer for a month that was flipped past is dropped', (
      tester,
    ) async {
      final s = await _open(
        tester,
        tasks: [
          _t('dec', 'December task', due: '2026-12-15'),
          _t('nov', 'November task', due: '2026-11-15', n: 2),
        ],
      );
      final gate = s.calendar.rangeGate = Completer<void>();

      await tester.tap(find.byKey(const Key('cal-next')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('cal-next')));
      await tester.pump();
      s.calendar.rangeGate = null;
      gate.complete();
      await tester.pumpAndSettle();

      // The read for the month flipped past was told to stop.
      expect(s.calendar.tokens.first!.isCancelled, isTrue);

      // Two months on is January: neither task is there, and no stale answer
      // for December or November was drawn.
      expect(find.text('December task'), findsNothing);
      expect(find.text('November task'), findsNothing);
      expect(
        tester.widget<Text>(find.byKey(const Key('cal-title'))).data,
        'January 2027',
      );
    });

    testWidgets('a crowded day says how many more', (tester) async {
      await _open(
        tester,
        tasks: [
          for (var i = 1; i <= 5; i++)
            _t('t$i', 'Task $i', due: '2026-11-20', n: i),
        ],
      );

      expect(find.text('+2 more'), findsOneWidget);

      await _tap(tester, 'more-2026-11-20');
      expect(find.text('Task 5'), findsOneWidget);
    });

    testWidgets('the first weekday comes from the locale unless chosen', (
      tester,
    ) async {
      final s = await _open(tester, weekStart: 0);

      // en-US weeks start on Sunday: the grid begins on 1 November.
      expect(s.calendar.ranges.single.first, '2026-11-01');
    });

    testWidgets('finished tasks can be hidden', (tester) async {
      final s = await _open(tester);
      expect(find.byKey(const Key('bar-d-2026-11-09')), findsOneWidget);

      await _tap(tester, 'cal-hide-done');
      await tester.pump(const Duration(milliseconds: 700));

      expect(s.calendar.ranges.last.includeDone, isFalse);
      expect(find.byKey(const Key('bar-d-2026-11-09')), findsNothing);
      expect(s.views.calendarSaves.last.layout.hideDone, isTrue);
    });
  });

  group('rescheduling', () {
    testWidgets('dragging a bar keeps its length', (tester) async {
      final s = await _open(tester);
      final bar = find.byKey(const Key('bar-b-2026-11-09'));
      // Picked up on its first day, dropped on the 17th.
      final grab = tester.getTopLeft(bar) + const Offset(30, 10);

      await _drag(tester, grab, _dayCenter(tester, '2026-11-17'));

      final moved = _stored(s, 'b');
      expect((moved.startDate, moved.dueDate), ('2026-11-17', '2026-11-19'));
    });

    testWidgets('a single date moves to the day it is dropped on', (
      tester,
    ) async {
      final s = await _open(tester);
      final chip = find.byKey(const Key('bar-a-2026-11-09'));

      await _drag(
        tester,
        tester.getCenter(chip),
        _dayCenter(tester, '2026-11-20'),
      );

      expect(_stored(s, 'a').dueDate, '2026-11-20');
      expect(_stored(s, 'a').startDate, '');
    });

    testWidgets('an edge drags the end of a bar', (tester) async {
      final s = await _open(tester);

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('resize-end-b-2026-11-09'))),
        _dayCenter(tester, '2026-11-14'),
      );

      final resized = _stored(s, 'b');
      expect(
        (resized.startDate, resized.dueDate),
        ('2026-11-09', '2026-11-14'),
      );
    });

    testWidgets('the start edge cannot pass the end', (tester) async {
      final s = await _open(tester);

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('resize-start-b-2026-11-09'))),
        _dayCenter(tester, '2026-11-25'),
      );

      expect(_stored(s, 'b').startDate, '2026-11-11');
    });

    testWidgets('a refused move puts the bar back and says why', (
      tester,
    ) async {
      final s = await _open(tester);
      s.tasks.failNext = const TaskException(TaskFailure.forbidden);

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('bar-a-2026-11-09'))),
        _dayCenter(tester, '2026-11-20'),
      );

      expect(
        find.text('You do not have permission to do that.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('bar-a-2026-11-09')), findsOneWidget);
      expect(_stored(s, 'a').dueDate, '2026-11-12');
    });

    testWidgets('moving a task before its blocker is due warns', (
      tester,
    ) async {
      await _open(
        tester,
        tasks: [
          _t(
            'a',
            'Alpha',
            due: '2026-11-12',
            blocked: true,
            blockersDue: '2026-11-18',
          ),
        ],
      );

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('bar-a-2026-11-09'))),
        _dayCenter(tester, '2026-11-14'),
      );

      expect(find.textContaining('due before 2026-11-18'), findsOneWidget);
      expect(find.textContaining('Blocked by WEB-9'), findsOneWidget);
    });

    testWidgets('moving a task after one it blocks warns', (tester) async {
      await _open(
        tester,
        tasks: [_t('a', 'Alpha', due: '2026-11-12', blocksDue: '2026-11-16')],
      );

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('bar-a-2026-11-09'))),
        _dayCenter(tester, '2026-11-20'),
      );

      expect(find.textContaining('due after 2026-11-16'), findsOneWidget);
    });

    testWidgets('a move that keeps the order of its links says nothing', (
      tester,
    ) async {
      await _open(
        tester,
        tasks: [
          _t(
            'a',
            'Alpha',
            due: '2026-11-12',
            blocked: true,
            blockersDue: '2026-11-10',
          ),
        ],
      );

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('bar-a-2026-11-09'))),
        _dayCenter(tester, '2026-11-14'),
      );

      expect(find.textContaining('Rescheduled'), findsNothing);
    });

    testWidgets(
      'a due time shows on the bar and the day list, on the viewer clock',
      (tester) async {
        final t = _t('a', 'Alpha', due: '2026-11-12', dueTime: '14:30');
        final local = dueTimeLocal(t);
        await _open(tester, tasks: [t]);

        expect(find.text('$local Alpha'), findsOneWidget);
        expect(local, matches(RegExp(r'^\d{2}:\d{2}$')));
        // The date is the due date whatever the zone: still on the 12th.
        expect(find.byKey(const Key('bar-a-2026-11-09')), findsOneWidget);
      },
    );

    testWidgets('a viewer sees the calendar but cannot move or resize', (
      tester,
    ) async {
      final s = await _open(tester, role: 'Viewer');

      expect(find.byKey(const Key('resize-end-b-2026-11-09')), findsNothing);
      expect(find.byKey(const Key('schedule-c')), findsNothing);
      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('bar-a-2026-11-09'))),
        _dayCenter(tester, '2026-11-20'),
      );
      expect(s.tasks.updates, isEmpty);
    });
  });

  group('the unscheduled tray', () {
    testWidgets('lists open tasks without dates and not the others', (
      tester,
    ) async {
      await _open(tester);

      expect(find.byKey(const Key('tray-c')), findsOneWidget);
      expect(find.byKey(const Key('tray-a')), findsNothing);
      expect(find.byKey(const Key('tray-d')), findsNothing);
    });

    testWidgets('a task dragged onto a day gets it as its due date', (
      tester,
    ) async {
      final s = await _open(tester);

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('tray-c'))),
        _dayCenter(tester, '2026-11-13'),
      );

      expect(_stored(s, 'c').dueDate, '2026-11-13');
      expect(find.byKey(const Key('tray-c')), findsNothing);
      expect(find.byKey(const Key('bar-c-2026-11-09')), findsOneWidget);
      expect(find.byKey(const Key('tray-empty')), findsOneWidget);
    });

    testWidgets('a refused scheduling puts the task back in the tray', (
      tester,
    ) async {
      final s = await _open(tester);
      s.tasks.failNext = const TaskException(TaskFailure.forbidden);

      await _drag(
        tester,
        tester.getCenter(find.byKey(const Key('tray-c'))),
        _dayCenter(tester, '2026-11-13'),
      );

      expect(find.byKey(const Key('tray-c')), findsOneWidget);
      expect(find.byKey(const Key('bar-c-2026-11-09')), findsNothing);
    });

    testWidgets('Schedule… asks for a day, the way without a mouse', (
      tester,
    ) async {
      final s = await _open(tester);

      await _tap(tester, 'schedule-c');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(_stored(s, 'c').dueDate, '2026-11-10');
      expect(find.byKey(const Key('tray-c')), findsNothing);
    });

    testWidgets('a long tray loads the next page at its end', (tester) async {
      final many = [for (var i = 1; i <= 12; i++) _t('t$i', 'Task $i', n: i)];
      final s = await _open(tester, tasks: many, trayPage: 5);

      // 12 tasks in pages of 5: the first page, then two more as the end shows.
      expect(s.calendar.trayCursors, ['', '5', '10']);
    });
  });

  group('week and day', () {
    testWidgets('a week shows its seven days with every task', (tester) async {
      final s = await _open(tester);

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('cal-mode')),
          matching: find.text('Week'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const Key('cal-title'))).data,
        '2026-11-09 – 2026-11-15',
      );
      expect(s.calendar.ranges.last.first, '2026-11-09');
      expect(s.calendar.ranges.last.last, '2026-11-15');
      expect(find.byKey(const Key('bar-b-2026-11-09')), findsOneWidget);
    });

    testWidgets('a day lists its tasks with a way to reschedule them', (
      tester,
    ) async {
      final s = await _open(tester);

      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      await _tap(tester, 'cal-next');
      await _tap(tester, 'cal-next');

      // 12 November: Alpha and the finished Delta.
      expect(find.byKey(const Key('agenda-a')), findsOneWidget);
      await _tap(tester, 'reschedule-a');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(_stored(s, 'a').dueDate, '2026-11-12');
    });

    testWidgets('the colour can follow the priority and is remembered', (
      tester,
    ) async {
      final s = await _open(
        tester,
        tasks: [
          _t('a', 'Alpha', due: '2026-11-12', priority: TaskPriority.urgent),
        ],
      );

      await _tap(tester, 'cal-color-menu');
      await _tap(tester, 'cal-color-priority');
      await tester.pump(const Duration(milliseconds: 700));

      expect(s.views.calendarSaves.last.layout.colorBy, 'priority');
      final chip = tester.widget<Material>(
        find
            .descendant(
              of: find.byKey(const Key('bar-a-2026-11-09')),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(chip.color, TfColors.light.danger.fg);
    });
  });

  group('what is read', () {
    testWidgets('colouring differently does not read the days again', (
      tester,
    ) async {
      final s = await _open(tester);
      final before = s.calendar.ranges.length;

      await _tap(tester, 'cal-color-menu');
      await _tap(tester, 'cal-color-priority');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(s.calendar.ranges.length, before);
      expect(find.byKey(const Key('bar-a-2026-11-09')), findsOneWidget);
    });

    testWidgets('a phone reads the whole month even if week is chosen', (
      tester,
    ) async {
      final views = FakeViewsClient()
        ..calendars.add(
          const SavedCalendar(
            id: 'c1',
            name: personalLayoutName,
            layout: CalendarLayout(mode: 'week', weekStart: 1),
            isShared: false,
            version: 1,
          ),
        );
      final s = await _open(tester, size: _phone, views: views);

      expect(s.calendar.ranges.last.first, '2026-10-26');
      expect(s.calendar.ranges.last.last, '2026-12-06');
      expect(find.byKey(const Key('has-tasks-2026-11-12')), findsOneWidget);
    });

    testWidgets('moving to another month clears the chosen day', (
      tester,
    ) async {
      await _open(tester, size: _phone);
      await _tap(tester, 'dot-2026-11-12');
      expect(find.byKey(const Key('agenda-a')), findsOneWidget);

      await _tap(tester, 'cal-next');

      expect(find.byKey(const Key('agenda-a')), findsNothing);
      expect(find.byKey(const Key('day-empty')), findsOneWidget);
    });
  });

  group('other sizes', () {
    testWidgets('on a tablet a bar is picked up with a long press', (
      tester,
    ) async {
      final s = await _open(tester, size: _tablet);
      final chip = tester.getCenter(find.byKey(const Key('bar-a-2026-11-09')));

      // A plain drag does not move it (it would scroll).
      await _drag(tester, chip, _dayCenter(tester, '2026-11-20'));
      expect(s.tasks.updates, isEmpty);

      final gesture = await tester.startGesture(chip);
      await tester.pump(const Duration(milliseconds: 700));
      await gesture.moveBy(const Offset(0, 24));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(_dayCenter(tester, '2026-11-20'));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(_stored(s, 'a').dueDate, '2026-11-20');
    });

    testWidgets('a phone gets month dots and the tasks of the chosen day', (
      tester,
    ) async {
      final s = await _open(tester, size: _phone);

      expect(find.byKey(const Key('has-tasks-2026-11-12')), findsOneWidget);
      expect(find.byKey(const Key('has-tasks-2026-11-20')), findsNothing);
      await _tap(tester, 'dot-2026-11-12');
      expect(find.byKey(const Key('agenda-a')), findsOneWidget);

      await _tap(tester, 'reschedule-a');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(s.tasks.updates, isEmpty); // 12 November is where it already is
    });

    testWidgets('on a phone Unscheduled opens as a sheet and schedules', (
      tester,
    ) async {
      final s = await _open(tester, size: _phone);

      await _tap(tester, 'cal-tray-button');
      expect(find.byKey(const Key('tray-c')), findsOneWidget);
      await _tap(tester, 'schedule-c');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(_stored(s, 'c').dueDate, '2026-11-10');
    });

    testWidgets('a tablet keeps the month and moves the tray to a sheet', (
      tester,
    ) async {
      await _open(tester, size: _tablet);

      expect(find.byKey(const Key('week-2026-11-09')), findsOneWidget);
      expect(find.byKey(const Key('tray-list')), findsNothing);
      await _tap(tester, 'cal-tray-button');
      expect(find.byKey(const Key('tray-c')), findsOneWidget);
    });

    testWidgets('a desktop shows the tray beside the month', (tester) async {
      await _open(tester);

      expect(find.byKey(const Key('tray-list')), findsOneWidget);
      expect(find.byKey(const Key('cal-tray-button')), findsNothing);
    });
  });

  testWidgets('a failed read offers a retry', (tester) async {
    final server = FakeTasksClient([_t('a', 'Alpha', due: '2026-11-12')]);
    final calendar = FakeCalendarClient(server)
      ..failRange = const TaskException(TaskFailure.network);
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      tasks: server,
      workflows: FakeWorkflowsClient(defaultWorkflow()),
      calendar: calendar,
      today: _today,
    );
    await pumped.go(tester, '/projects/p1');
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('view-switch')),
        matching: find.byIcon(TfIcons.calendar.glyph),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-error')), findsOneWidget);

    await _tap(tester, 'retry-calendar');

    expect(find.byKey(const Key('calendar-error')), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('Calendar and List switch back and forth', (tester) async {
    await _open(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('view-switch')),
        matching: find.byIcon(TfIcons.list.glyph),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cal-title')), findsNothing);
    expect(find.byKey(const Key('task-a')), findsOneWidget);
  });

  testWidgets('keys: Tab reaches a bar and Enter opens it', (tester) async {
    await _open(tester);
    final target = find.byKey(const Key('chip-a-2026-11-09')).evaluate().single;
    for (var i = 0; i < 80; i++) {
      var inside = false;
      FocusManager.instance.primaryFocus?.context?.visitAncestorElements((e) {
        inside = identical(e, target);
        return !inside;
      });
      if (inside) break;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('WEB-1'), findsWidgets);
  });
}
