import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../recurrence/fakes.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

RepeatGhost _ghost(String title, String date, {String series = 's1'}) =>
    RepeatGhost(seriesId: series, projectId: 'p1', title: title, dueDate: date);

Future<FakeRecurrenceClient> _open(
  WidgetTester tester, {
  required List<RepeatGhost> ghosts,
  Size size = const Size(1400, 1000),
  Object? failWith,
}) async {
  final server = FakeTasksClient([task('a', 'Alpha', dueDate: '2026-11-17')]);
  final recurrence = FakeRecurrenceClient(ghosts: ghosts)..failWith = failWith;
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    calendar: FakeCalendarClient(server),
    recurrence: recurrence,
    today: day(2026, 11, 10),
    size: size,
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.text('Calendar'));
  await tester.pumpAndSettle();
  return recurrence;
}

final _rows = find.byWidgetPredicate(
  (w) => w.key.toString().contains('ghost-row-'),
);

void main() {
  testWidgets('the grid shows a faded line for a date still to be made', (
    tester,
  ) async {
    final recurrence = await _open(
      tester,
      ghosts: [_ghost('Weekly report', '2026-11-17')],
    );
    expect(find.text('Weekly report'), findsOneWidget);
    expect(_rows, findsOneWidget);
    expect(find.text('Alpha'), findsWidgets); // the real task is still there
    // It asked for exactly the days on screen.
    final (start, end) = recurrence.ghostRanges.last;
    expect(
      DateTime.parse(start).isBefore(DateTime.parse('2026-11-02')),
      isTrue,
    );
    expect(DateTime.parse(end).isAfter(DateTime.parse('2026-11-30')), isTrue);
  });

  testWidgets('a week without ghosts has no ghost row', (tester) async {
    await _open(tester, ghosts: [_ghost('Weekly report', '2026-11-17')]);
    expect(_rows, findsOneWidget); // only the week that has one
  });

  testWidgets('a crowded day says how many more there are', (tester) async {
    await _open(
      tester,
      ghosts: [
        _ghost('One', '2026-11-18', series: 's1'),
        _ghost('Two', '2026-11-18', series: 's2'),
        _ghost('Three', '2026-11-18', series: 's3'),
      ],
    );
    expect(find.text('+1 more'), findsOneWidget);
    expect(find.text('Three'), findsNothing);
  });

  testWidgets('a failed read of the ghosts leaves the calendar alone', (
    tester,
  ) async {
    await _open(
      tester,
      ghosts: [_ghost('Weekly report', '2026-11-17')],
      failWith: const RepeatException(RepeatFailure.network),
    );
    expect(find.text('Weekly report'), findsNothing);
    expect(find.text('Alpha'), findsWidgets);
    expect(find.byKey(const Key('calendar-error')), findsNothing);
  });

  testWidgets('on a phone a ghost is a hollow dot and a line in the day', (
    tester,
  ) async {
    await _open(
      tester,
      ghosts: [_ghost('Weekly report', '2026-11-24')],
      size: const Size(420, 900),
    );
    expect(find.byKey(const Key('has-ghost-2026-11-24')), findsOneWidget);
    await tester.tap(find.byKey(const Key('dot-2026-11-24')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ghost-s1-2026-11-24')), findsOneWidget);
    expect(find.text('Repeats: not made yet'), findsOneWidget);
    expect(find.byKey(const Key('day-empty')), findsNothing);
  });
}
