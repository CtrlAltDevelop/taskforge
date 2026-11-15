import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

final monday = DateTime(2026, 11, 9);

Future<({Pumped pumped, FakeTimeClient time})> open(
  WidgetTester tester, {
  FakeTimeClient? time,
  String role = 'Owner',
}) async {
  final fake = time ?? FakeTimeClient();
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [
      project('p1', 'Web', enabled: {timeFeature}),
    ],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    time: fake,
    overrides: [
      currentUserIdProvider.overrideWithValue('u1'),
      timeNowProvider.overrideWithValue(() => DateTime(2026, 11, 11, 12)),
    ],
  );
  await pumped.go(tester, '/timesheet');
  return (pumped: pumped, time: fake);
}

void main() {
  testWidgets('an empty week says so; the sidebar leads here', (tester) async {
    await open(tester);

    expect(key('timesheet-empty'), findsOneWidget);
    expect(find.text('2026-11-09 – 2026-11-15'), findsOneWidget);
  });

  testWidgets('the grid shows a row per task with day and week totals', (
    tester,
  ) async {
    final time = FakeTimeClient();
    time.add(
      time.make(
        task: 'a',
        startedAt: monday.add(const Duration(hours: 9)),
        seconds: 3600,
      ),
    );
    time.add(
      time.make(
        task: 'a',
        startedAt: monday.add(const Duration(days: 2, hours: 9)),
        seconds: 1800,
      ),
    );
    time.add(
      time.make(
        task: 'a',
        startedAt: monday.add(const Duration(hours: 14)),
        seconds: 600,
        user: 'u2',
      ),
    );
    await open(tester, time: time);

    expect(find.text('WEB-a Task a'), findsOneWidget);
    expect(find.text('1h 00m'), findsWidgets);
    expect(find.text('30m'), findsWidgets);
    expect(find.text('1h 30m'), findsWidgets); // the task total
    expect(tester.widget<Text>(key('sheet-total')).data, '1h 30m');
    expect(time.timesheetAsks.single.week, monday);
    expect(time.timesheetAsks.single.offset, monday.timeZoneOffset.inMinutes);
  });

  testWidgets('moving between weeks asks for those weeks', (tester) async {
    final o = await open(tester);

    await tester.tap(key('week-next'));
    await tester.pumpAndSettle();
    expect(find.text('2026-11-16 – 2026-11-22'), findsOneWidget);
    await tester.tap(key('week-previous'));
    await tester.tap(key('week-previous'));
    await tester.pumpAndSettle();
    expect(find.text('2026-11-02 – 2026-11-08'), findsOneWidget);
    await tester.tap(key('week-this'));
    await tester.pumpAndSettle();

    expect(find.text('2026-11-09 – 2026-11-15'), findsOneWidget);
    expect(o.time.timesheetAsks.map((a) => a.week).toSet(), {
      DateTime(2026, 11, 16),
      DateTime(2026, 11, 2),
      monday,
    });
  });

  testWidgets('a cell opens that day\'s entries to change, delete or add to', (
    tester,
  ) async {
    final time = FakeTimeClient();
    final entry = time.add(
      time.make(
        task: 'a',
        startedAt: monday.add(const Duration(hours: 9)),
        seconds: 3600,
      ),
    );
    await open(tester, time: time);

    await tester.tap(find.text('1h 00m').first);
    await tester.pumpAndSettle();
    expect(key('cell-entry-${entry.id}'), findsOneWidget);

    await tester.tap(key('cell-edit-${entry.id}'));
    await tester.pumpAndSettle();
    await tester.enterText(key('entry-duration'), '2h');
    await tester.tap(key('entry-save'));
    await tester.pumpAndSettle();
    expect(time.entries_.single.durationSec, 7200);

    await tester.tap(key('cell-add'));
    await tester.pumpAndSettle();
    expect(key('entry-date'), findsNothing); // the day is fixed by the cell
    await tester.enterText(key('entry-duration'), '30m');
    await tester.tap(key('entry-save'));
    await tester.pumpAndSettle();
    expect(time.entries_.length, 2);
    expect(time.entries_.last.startedAt.day, 9);

    await tester.tap(key('cell-delete-${entry.id}'));
    await tester.pumpAndSettle();
    await tester.tap(key('confirm-delete'));
    await tester.pumpAndSettle();
    expect(time.entries_.length, 1);
  });

  testWidgets('an admin can look at another person\'s week, but not edit it', (
    tester,
  ) async {
    final time = FakeTimeClient();
    time.add(
      time.make(
        task: 'a',
        startedAt: monday.add(const Duration(hours: 9)),
        seconds: 5400,
        user: 'u2',
      ),
    );
    await open(tester, time: time, role: 'Admin');
    expect(key('timesheet-empty'), findsOneWidget); // mine is empty

    await tester.tap(key('sheet-person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hank Hill').last);
    await tester.pumpAndSettle();

    expect(time.timesheetAsks.last.user, 'u2');
    expect(find.text('1h 30m'), findsWidgets);
    await tester.tap(find.text('1h 30m').first);
    await tester.pumpAndSettle();
    expect(key('cell-dialog'), findsNothing);
  });

  testWidgets('a member has no person picker', (tester) async {
    await open(tester, role: 'Member');

    expect(key('sheet-person'), findsNothing);
  });

  testWidgets('project totals list people for the week', (tester) async {
    final time = FakeTimeClient();
    time.add(
      time.make(
        task: 'a',
        startedAt: monday.add(const Duration(hours: 9)),
        seconds: 3600,
        billable: true,
      ),
    );
    time.add(
      time.make(
        task: 'a',
        startedAt: monday.add(const Duration(hours: 10)),
        seconds: 1800,
        user: 'u2',
      ),
    );
    await open(tester, time: time);

    await tester.tap(key('totals-project'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('WEB Web').last);
    await tester.pumpAndSettle();

    expect(find.text('1h 00m  (1h 00m billable)'), findsOneWidget);
    expect(key('total-u2'), findsOneWidget);
    expect(time.totalsAsks.single.project, 'p1');
    expect(
      time.totalsAsks.single.end
          .difference(time.totalsAsks.single.start)
          .inDays,
      7,
    );
  });

  testWidgets('a failed read offers a retry', (tester) async {
    final time = FakeTimeClient()
      ..failSheets = const TimeException(TimeFailure.network);
    await open(tester, time: time);

    expect(find.textContaining('Could not reach the server'), findsOneWidget);
    time.failSheets = null;
    await tester.tap(key('timesheet-retry'));
    await tester.pumpAndSettle();

    expect(key('timesheet-empty'), findsOneWidget);
  });

  testWidgets('the sidebar opens the timesheet', (tester) async {
    final o = await open(tester);
    await o.pumped.go(tester, '/inbox');

    await tester.tap(key('open-timesheet'));
    await tester.pumpAndSettle();

    expect(
      o.pumped.container.read(routerProvider).state.uri.toString(),
      '/timesheet',
    );
  });
}
