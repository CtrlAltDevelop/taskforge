import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/views/domain/timeline_layout.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../views/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

final _today = day(2026, 11, 10);

Task _t(
  String id,
  String title, {
  String start = '',
  String due = '',
  int n = 1,
}) {
  final base = task(id, title, number: n);
  return Task(
    id: base.id,
    projectId: base.projectId,
    number: base.number,
    displayId: base.displayId,
    title: base.title,
    statusId: base.statusId,
    statusName: base.statusName,
    statusCategory: base.statusCategory,
    startDate: start,
    dueDate: due,
  );
}

typedef Opened = ({
  FakeTasksClient tasks,
  FakeTimelineClient timeline,
  FakeViewsClient views,
});

Future<Opened> _open(
  WidgetTester tester, {
  String role = 'Owner',
  Size size = const Size(1400, 1000),
  void Function(FakeTimelineClient)? setup,
  TimelineLayout layout = const TimelineLayout(),
}) async {
  final server = FakeTasksClient([
    _t('a', 'Alpha', start: '2026-11-09', due: '2026-11-11'),
    _t('b', 'Bravo', start: '2026-11-12', due: '2026-11-13', n: 2),
    _t('m', 'Mile', due: '2026-11-20', n: 3),
    _t('u', 'Nodate', n: 4),
  ]);
  final timeline = FakeTimelineClient(server)
    ..links.add(const TimelineLink('a', 'b'));
  setup?.call(timeline);
  final views = FakeViewsClient()
    ..timelines.add(
      SavedTimeline(
        id: 't1',
        name: personalLayoutName,
        layout: layout,
        isShared: false,
        version: 1,
      ),
    );
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    views: views,
    timeline: timeline,
    today: _today,
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('view-switch')),
      matching: find.byIcon(Icons.stacked_bar_chart),
    ),
  );
  await tester.pumpAndSettle();
  return (tasks: server, timeline: timeline, views: views);
}

/// Where [iso] on row [row] is on screen (the middle of that day's column).
Offset _at(
  WidgetTester tester,
  String iso,
  int row, {
  TimelineZoom zoom = TimelineZoom.week,
}) {
  final origin = readRange(zoom, _today).first;
  final topLeft = tester.getTopLeft(find.byKey(const Key('timeline-canvas')));
  return topLeft +
      Offset(
        daysBetween(origin, parseDay(iso)!) * zoom.pxPerDay + zoom.pxPerDay / 2,
        row * rowHeight + rowHeight / 2,
      );
}

Future<void> _dragBar(WidgetTester tester, Offset from, Offset to) async {
  final g = await tester.startGesture(from, kind: PointerDeviceKind.mouse);
  await tester.pump(const Duration(milliseconds: 50));
  await g.moveBy(const Offset(12, 0));
  await tester.pump(const Duration(milliseconds: 50));
  await g.moveTo(to);
  await tester.pump(const Duration(milliseconds: 50));
  await g.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens as a chart: names down the left, a canvas beside them', (
    tester,
  ) async {
    final o = await _open(tester);

    expect(find.byKey(const Key('timeline-canvas')), findsOneWidget);
    expect(find.text('WEB-1  Alpha'), findsOneWidget);
    expect(find.text('WEB-3  Mile'), findsOneWidget);
    expect(
      find.textContaining('Nodate'),
      findsNothing,
    ); // no dates: in the tray
    expect(o.timeline.reads, hasLength(1));
    expect(
      o.timeline.reads.single.first,
      '2026-07-13',
    ); // 120 days before today
  });

  testWidgets('a narrow screen opens the list, with dates in words', (
    tester,
  ) async {
    await _open(tester, size: const Size(420, 900));

    expect(find.byKey(const Key('timeline-list')), findsOneWidget);
    expect(
      find.textContaining('2026-11-09 → 2026-11-11 · 3 days'),
      findsOneWidget,
    );
    expect(find.textContaining('due 2026-11-20'), findsOneWidget);
    expect(find.byKey(const Key('timeline-canvas')), findsNothing);
  });

  testWidgets('the list can be switched to and back', (tester) async {
    await _open(tester);

    await tester.tap(find.byKey(const Key('timeline-list-mode')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('timeline-list')), findsOneWidget);

    await tester.tap(find.byKey(const Key('timeline-list-mode')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('timeline-canvas')), findsOneWidget);
  });

  testWidgets('zooming reads a wider or narrower range and is remembered', (
    tester,
  ) async {
    final o = await _open(tester);

    await tester.tap(find.text('Quarter'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(o.timeline.reads.last.first, '2025-05-19'); // 540 days before today
    expect(o.views.timelineSaves.last.layout.zoom, 'quarter');
  });

  testWidgets('dragging a bar moves it, keeping its length', (tester) async {
    final o = await _open(tester);

    await _dragBar(
      tester,
      _at(tester, '2026-11-10', 0),
      _at(tester, '2026-11-13', 0),
    );

    expect(o.timeline.previews.single.task, 'a');
    final applied = o.timeline.applied.single;
    expect(
      (applied.dates.startIso, applied.dates.dueIso),
      ('2026-11-12', '2026-11-14'),
    );
    expect(applied.affected, isEmpty);
  });

  testWidgets('dragging an end resizes it', (tester) async {
    final o = await _open(tester);
    final right = _at(tester, '2026-11-11', 0) + const Offset(6, 0);

    await _dragBar(tester, right, _at(tester, '2026-11-15', 0));

    final applied = o.timeline.applied.single;
    expect(
      (applied.dates.startIso, applied.dates.dueIso),
      ('2026-11-09', '2026-11-15'),
    );
  });

  testWidgets(
    'a move that pushes dependents asks first; shifting moves them together',
    (tester) async {
      final o = await _open(
        tester,
        setup: (t) {
          t.shifts['a'] = [
            ShiftPreview(
              _t('b', 'Bravo', start: '2026-11-12', due: '2026-11-13', n: 2),
              newStart: '2026-11-16',
              newDue: '2026-11-17',
            ),
          ];
        },
      );

      await _dragBar(
        tester,
        _at(tester, '2026-11-10', 0),
        _at(tester, '2026-11-14', 0),
      );

      expect(find.byKey(const Key('shift-dialog')), findsOneWidget);
      expect(find.textContaining('2026-11-16 – 2026-11-17'), findsOneWidget);
      expect(o.timeline.applied, isEmpty); // nothing saved before the choice

      await tester.tap(find.byKey(const Key('shift-apply')));
      await tester.pumpAndSettle();

      expect(o.timeline.applied.single.affected, ['b']);
      expect(
        o.tasks.tasks.firstWhere((t) => t.id == 'b').startDate,
        '2026-11-16',
      );
    },
  );

  testWidgets('keeping dependents moves only the task', (tester) async {
    final o = await _open(
      tester,
      setup: (t) {
        t.shifts['a'] = [
          ShiftPreview(
            _t('b', 'Bravo', start: '2026-11-12', due: '2026-11-13', n: 2),
            newStart: '2026-11-16',
            newDue: '2026-11-17',
          ),
        ];
      },
    );

    await _dragBar(
      tester,
      _at(tester, '2026-11-10', 0),
      _at(tester, '2026-11-14', 0),
    );
    await tester.tap(find.byKey(const Key('shift-keep')));
    await tester.pumpAndSettle();

    expect(o.timeline.applied, isEmpty);
    expect(o.tasks.updates.single.task.id, 'a');
    expect(
      o.tasks.tasks.firstWhere((t) => t.id == 'b').startDate,
      '2026-11-12',
    );
  });

  testWidgets('cancelling puts the bar back', (tester) async {
    final o = await _open(
      tester,
      setup: (t) {
        t.shifts['a'] = [
          ShiftPreview(
            _t('b', 'Bravo', start: '2026-11-12', due: '2026-11-13', n: 2),
            newStart: '2026-11-16',
            newDue: '2026-11-17',
          ),
        ];
      },
    );

    await _dragBar(
      tester,
      _at(tester, '2026-11-10', 0),
      _at(tester, '2026-11-14', 0),
    );
    await tester.tap(find.byKey(const Key('shift-cancel')));
    await tester.pumpAndSettle();

    expect(o.timeline.applied, isEmpty);
    expect(o.tasks.updates, isEmpty);
    expect(
      o.tasks.tasks.firstWhere((t) => t.id == 'a').startDate,
      '2026-11-09',
    );
  });

  testWidgets('a refused move says why and leaves the bar where it was', (
    tester,
  ) async {
    final o = await _open(
      tester,
      setup: (t) {
        t.failApply = const TaskException(TaskFailure.forbidden);
      },
    );

    await _dragBar(
      tester,
      _at(tester, '2026-11-10', 0),
      _at(tester, '2026-11-13', 0),
    );

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      o.tasks.tasks.firstWhere((t) => t.id == 'a').startDate,
      '2026-11-09',
    );
  });

  testWidgets('someone who may not edit tasks cannot drag', (tester) async {
    final o = await _open(tester, role: 'Viewer');

    await _dragBar(
      tester,
      _at(tester, '2026-11-10', 0),
      _at(tester, '2026-11-13', 0),
    );

    expect(o.timeline.previews, isEmpty);
  });

  testWidgets('the critical path is read only when it is lit', (tester) async {
    final o = await _open(tester, setup: (t) => t.critical = ['a', 'b']);
    expect(o.timeline.criticalReads, 0);

    await tester.tap(find.byKey(const Key('timeline-critical')));
    await tester.pumpAndSettle();

    expect(o.timeline.criticalReads, greaterThan(0));
    expect(o.views.timelineSaves.last.layout.criticalPath, isTrue);
  });

  testWidgets('the unscheduled tray schedules a task onto a day', (
    tester,
  ) async {
    final o = await _open(tester);

    await tester.tap(find.byKey(const Key('timeline-unscheduled')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('schedule-u')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final applied = o.timeline.applied.single;
    expect(applied.task, 'u');
    expect(applied.dates.startIso, applied.dates.dueIso);
  });

  testWidgets('an owner sets the working days', (tester) async {
    final o = await _open(tester);

    await tester.tap(find.byKey(const Key('timeline-working-days')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('working-day-5')));
    await tester.tap(find.byKey(const Key('working-day-6')));
    await tester.enterText(
      find.byKey(const Key('holidays-field')),
      '2026-12-25',
    );
    await tester.tap(find.byKey(const Key('working-days-save')));
    await tester.pumpAndSettle();

    expect(o.timeline.savedDays.single.days, [0, 1, 2, 3, 4]);
    expect(o.timeline.savedDays.single.holidays, ['2026-12-25']);
  });

  testWidgets('a member has no working-days button', (tester) async {
    await _open(tester, role: 'Member');

    expect(find.byKey(const Key('timeline-working-days')), findsNothing);
  });

  testWidgets('a failed read shows a retry', (tester) async {
    final o = await _open(
      tester,
      setup: (t) => t.failRead = const TaskException(TaskFailure.network),
    );

    expect(find.byKey(const Key('timeline-retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('timeline-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('timeline-retry')), findsNothing);
    expect(o.timeline.reads, hasLength(2));
  });

  group('on a tablet with touch', () {
    const tablet = Size(800, 1000);

    testWidgets('a long press then a drag moves a bar', (tester) async {
      final o = await _open(tester, size: tablet);
      final from = _at(tester, '2026-11-10', 0);

      final g = await tester.startGesture(from, kind: PointerDeviceKind.touch);
      await tester.pump(const Duration(milliseconds: 700));
      await g.moveTo(_at(tester, '2026-11-13', 0));
      await tester.pump(const Duration(milliseconds: 50));
      await g.up();
      await tester.pumpAndSettle();

      final dates = o.timeline.applied.single.dates;
      expect((dates.startIso, dates.dueIso), ('2026-11-12', '2026-11-14'));
    });

    testWidgets('a plain drag on a bar scrolls instead of moving it', (
      tester,
    ) async {
      final o = await _open(tester, size: tablet);
      final scroller = tester.state<ScrollableState>(
        find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
        ),
      );
      final before = scroller.position.pixels;

      await tester.dragFrom(
        _at(tester, '2026-11-10', 0),
        const Offset(-120, 0),
      );
      await tester.pumpAndSettle();

      expect(o.timeline.previews, isEmpty);
      expect(scroller.position.pixels, isNot(before));
    });

    testWidgets('spreading two fingers zooms in', (tester) async {
      final o = await _open(tester, size: tablet);
      final centre = tester.getCenter(find.byKey(const Key('timeline-canvas')));

      final a = await tester.startGesture(
        centre - const Offset(20, 0),
        kind: PointerDeviceKind.touch,
      );
      final b = await tester.startGesture(
        centre + const Offset(20, 0),
        kind: PointerDeviceKind.touch,
      );
      await a.moveBy(const Offset(-60, 0));
      await b.moveBy(const Offset(60, 0));
      await a.up();
      await b.up();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(o.views.timelineSaves.last.layout.zoom, 'day');
    });
  });

  testWidgets('a dependent of another project is not added to the chart', (
    tester,
  ) async {
    final other = Task(
      id: 'x',
      projectId: 'p2',
      number: 9,
      displayId: 'API-9',
      title: 'Elsewhere',
      statusId: 's',
      startDate: '2026-11-14',
      dueDate: '2026-11-15',
    );
    await _open(
      tester,
      setup: (t) {
        t.shifts['a'] = [
          ShiftPreview(other, newStart: '2026-11-18', newDue: '2026-11-19'),
        ];
      },
    );

    await _dragBar(
      tester,
      _at(tester, '2026-11-10', 0),
      _at(tester, '2026-11-14', 0),
    );
    await tester.tap(find.byKey(const Key('shift-apply')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Elsewhere'), findsNothing);
  });

  testWidgets(
    'a task scheduled from the tray that is refused leaves the chart again',
    (tester) async {
      await _open(
        tester,
        setup: (t) => t.failApply = const TaskException(TaskFailure.forbidden),
      );

      await tester.tap(find.byKey(const Key('timeline-unscheduled')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('schedule-u')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nodate'), findsNothing);
    },
  );
}
