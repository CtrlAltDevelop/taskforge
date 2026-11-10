import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _wide = Size(1400, 1000);
const _phone = Size(420, 900);
final _today = day(2026, 11, 10);

Task _t(String id, String title, String projectId, String due, {int n = 1}) {
  final base = task(id, title, number: n, project: projectId);
  return Task(
    id: base.id,
    projectId: projectId,
    number: n,
    displayId: '${projectId.toUpperCase()}-$n',
    title: title,
    statusId: 'todo',
    dueDate: due,
  );
}

Future<({Pumped pumped, FakeTasksClient tasks, FakeCalendarClient calendar})>
_open(
  WidgetTester tester, {
  Size size = _wide,
  String role = 'Owner',
  List<Task>? tasks,
}) async {
  final server = FakeTasksClient(
    tasks ??
        [
          _t('w', 'Web task', 'p1', '2026-11-12'),
          _t('a', 'Api task', 'p2', '2026-11-12', n: 2),
        ],
  );
  final calendar = FakeCalendarClient(server);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web'), project('p2', 'Api')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    calendar: calendar,
    today: _today,
    size: size,
  );
  await pumped.go(tester, '/calendar');
  return (pumped: pumped, tasks: server, calendar: calendar);
}

Color _barColor(WidgetTester tester, String id) => tester
    .widget<Material>(
      find
          .descendant(
            of: find.byKey(Key('bar-$id-2026-11-08')),
            matching: find.byType(Material),
          )
          .first,
    )
    .color!;

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

void main() {
  testWidgets('shows the tasks of every project with a legend', (tester) async {
    final s = await _open(tester);

    expect(find.text('Web task'), findsOneWidget);
    expect(find.text('Api task'), findsOneWidget);
    expect(find.byKey(const Key('legend-p1')), findsOneWidget);
    expect(find.byKey(const Key('legend-p2')), findsOneWidget);
    expect(s.calendar.workspaceReads, hasLength(1));
    expect(s.calendar.ranges, isEmpty); // not the per-project read
  });

  testWidgets('colours by project: each project its own colour', (
    tester,
  ) async {
    await _open(tester);

    expect(_barColor(tester, 'w'), isNot(_barColor(tester, 'a')));
  });

  testWidgets('a project can be hidden from the legend and shown again', (
    tester,
  ) async {
    final s = await _open(tester);

    await tester.tap(find.byKey(const Key('legend-p2')));
    await tester.pumpAndSettle();
    expect(find.text('Api task'), findsNothing);
    expect(find.text('Web task'), findsOneWidget);
    expect(s.calendar.workspaceReads, hasLength(1)); // no new read for that

    await tester.tap(find.byKey(const Key('legend-p2')));
    await tester.pumpAndSettle();
    expect(find.text('Api task'), findsOneWidget);
  });

  testWidgets('the colour can follow status or priority instead', (
    tester,
  ) async {
    await _open(tester);

    await tester.tap(find.byKey(const Key('cal-color-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cal-color-project')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cal-color-status')));
    await tester.pumpAndSettle();

    expect(_barColor(tester, 'w'), _barColor(tester, 'a')); // same status
    expect(
      _barColor(tester, 'w'),
      isNot(Colors.blueGrey),
    ); // a real status colour
  });

  testWidgets('there is no tray: unscheduled is per project', (tester) async {
    await _open(tester);

    expect(find.byKey(const Key('tray-list')), findsNothing);
    expect(find.byKey(const Key('cal-tray-button')), findsNothing);
  });

  testWidgets('dragging a task of any project changes its dates', (
    tester,
  ) async {
    final s = await _open(tester);

    await _drag(
      tester,
      tester.getCenter(find.byKey(const Key('bar-a-2026-11-08'))),
      tester.getCenter(find.byKey(const Key('day-2026-11-20'))),
    );

    expect(s.tasks.updates.single.task.id, 'a');
    expect(s.tasks.tasks.firstWhere((t) => t.id == 'a').dueDate, '2026-11-20');
  });

  testWidgets('a refused move (no permission there) puts the bar back', (
    tester,
  ) async {
    final s = await _open(tester);
    s.tasks.failNext = const TaskException(TaskFailure.forbidden);

    await _drag(
      tester,
      tester.getCenter(find.byKey(const Key('bar-a-2026-11-08'))),
      tester.getCenter(find.byKey(const Key('day-2026-11-20'))),
    );

    expect(find.text('You do not have permission to do that.'), findsOneWidget);
    expect(s.tasks.tasks.firstWhere((t) => t.id == 'a').dueDate, '2026-11-12');
  });

  testWidgets('opening a task goes to its project', (tester) async {
    await _open(tester);

    await tester.tap(find.byKey(const Key('chip-a-2026-11-08')));
    await tester.pumpAndSettle();

    // The project's own screen is open, with that task's detail beside it.
    expect(find.byKey(const Key('cal-title')), findsNothing);
    expect(find.byKey(const Key('view-switch')), findsOneWidget);
    expect(find.text('P2-2'), findsWidgets);
  });

  testWidgets('a viewer reads it but cannot move anything', (tester) async {
    final s = await _open(tester, role: 'Viewer');

    await _drag(
      tester,
      tester.getCenter(find.byKey(const Key('bar-a-2026-11-08'))),
      tester.getCenter(find.byKey(const Key('day-2026-11-20'))),
    );

    expect(s.tasks.updates, isEmpty);
  });

  testWidgets('a phone gets the agenda with the tasks of the chosen day', (
    tester,
  ) async {
    await _open(tester, size: _phone);

    await tester.tap(find.byKey(const Key('dot-2026-11-12')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('agenda-w')), findsOneWidget);
    expect(find.byKey(const Key('agenda-a')), findsOneWidget);
  });

  testWidgets(
    'hidden projects and the view are kept when it is left and reopened',
    (tester) async {
      final s = await _open(tester);
      await tester.tap(find.byKey(const Key('legend-p2')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('cal-mode')),
          matching: find.text('Week'),
        ),
      );
      await tester.pumpAndSettle();

      await s.pumped.go(tester, '/');
      await s.pumped.go(tester, '/calendar');

      expect(find.text('Api task'), findsNothing);
      expect(find.text('Web task'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('cal-title'))).data,
        contains('–'),
      );
    },
  );

  testWidgets('the home screen opens it', (tester) async {
    final server = FakeTasksClient();
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      tasks: server,
      calendar: FakeCalendarClient(server),
      today: _today,
    );
    await pumped.go(tester, '/');

    await tester.tap(find.byKey(const Key('open-calendar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cal-title')), findsOneWidget);
  });
}
