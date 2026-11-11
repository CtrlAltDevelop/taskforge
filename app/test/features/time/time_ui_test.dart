import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_coordinator.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';

import '../../core/sync/fakes.dart';
import '../inbox/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

typedef Opened = ({
  Pumped pumped,
  FakeTimeClient time,
  FakeLocalNotifier notes,
});

Future<Opened> open(
  WidgetTester tester, {
  FakeTimeClient? time,
  bool enabled = true,
  String role = 'Owner',
  String location = '/projects/p1?task=a',
}) async {
  final fake = time ?? FakeTimeClient();
  final notes = FakeLocalNotifier();
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [
      project('p1', 'Web', enabled: enabled ? {timeFeature} : {}),
    ],
    tasks: FakeTasksClient([task('a', 'Alpha'), task('b', 'Beta', number: 2)]),
    time: fake,
    localNotifier: notes,
    overrides: [
      currentUserIdProvider.overrideWithValue('u1'),
      timeNowProvider.overrideWithValue(() => tester.binding.clock.now()),
    ],
  );
  await pumped.go(tester, location);
  return (pumped: pumped, time: fake, notes: notes);
}

void main() {
  testWidgets('a project without time tracking shows no Time section', (
    tester,
  ) async {
    await open(tester, enabled: false);

    expect(key('time-section'), findsNothing);
  });

  testWidgets('a viewer sees the time but has no buttons', (tester) async {
    final time = FakeTimeClient();
    time.add(time.make(task: 'a', seconds: 1800, user: 'u2'));
    await open(tester, time: time, role: 'Viewer');

    expect(key('time-section'), findsOneWidget);
    expect(find.text('30m logged'), findsOneWidget);
    expect(key('time-start'), findsNothing);
    expect(key('time-add'), findsNothing);
    expect(key('time-estimate'), findsNothing);
  });

  testWidgets('start shows the chip and a button to stop; stop adds the time', (
    tester,
  ) async {
    final o = await open(tester);

    await tester.tap(key('time-start'));
    await tester.pumpAndSettle();

    expect(o.time.startCalls, ['a']);
    expect(key('timer-chip'), findsOneWidget);
    expect(find.text('WEB-a'), findsWidgets);
    expect(key('time-stop'), findsOneWidget);
    expect(key('time-start'), findsNothing);
    expect(o.notes.ongoing.values.single.body, contains('Task a'));

    o.time.clock = o.time.clock.add(const Duration(minutes: 5));
    await tester.tap(key('time-stop'));
    await tester.pumpAndSettle();

    expect(key('timer-chip'), findsNothing);
    expect(find.text('5m logged'), findsOneWidget);
    expect(o.notes.ongoing, isEmpty);
  });

  testWidgets(
    'the chip counts on from the server figure and stops from anywhere',
    (tester) async {
      final time = FakeTimeClient();
      time.add(
        time.make(
          task: 'b',
          running: true,
          startedAt: time.clock.subtract(const Duration(minutes: 90)),
        ),
      );
      final o = await open(tester, time: time, location: '/inbox');

      expect(find.text('1:30:00'), findsOneWidget); // not ticked yet
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('1:30:03'), findsOneWidget);

      await tester.tap(key('timer-stop'));
      await tester.pumpAndSettle();

      expect(key('timer-chip'), findsNothing);
      expect(o.time.running, isNull);
      expect(o.time.entries_.single.durationSec, 90 * 60);
    },
  );

  testWidgets('tapping the chip opens its task', (tester) async {
    final time = FakeTimeClient();
    time.add(time.make(task: 'b', running: true));
    final o = await open(tester, time: time, location: '/inbox');

    await tester.tap(key('timer-open-task'));
    await tester.pumpAndSettle();

    expect(
      o.pumped.container.read(routerProvider).state.uri.toString(),
      '/projects/p1?task=b',
    );
  });

  testWidgets('starting on another task moves the timer there', (tester) async {
    final time = FakeTimeClient();
    time.add(time.make(task: 'b', running: true));
    await open(tester, time: time);

    await tester.tap(key('time-start'));
    await tester.pumpAndSettle();

    expect(time.running?.taskId, 'a');
    expect(time.entries_.where((e) => e.taskId == 'b').single.running, isFalse);
  });

  testWidgets('a refusal is shown in the section', (tester) async {
    final time = FakeTimeClient()
      ..failNext = const TimeException(
        TimeFailure.invalid,
        detail: 'Switched off',
      );
    await open(tester, time: time);

    await tester.tap(key('time-start'));
    await tester.pumpAndSettle();

    expect(find.text('Switched off'), findsOneWidget);
    expect(key('timer-chip'), findsNothing);
  });

  testWidgets('manual time is added, edited and deleted', (tester) async {
    final o = await open(tester);

    await tester.tap(key('time-add'));
    await tester.pumpAndSettle();
    await tester.tap(key('entry-save')); // nothing typed
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter a time like'), findsOneWidget);
    await tester.enterText(key('entry-duration'), '1h 30m');
    await tester.enterText(key('entry-note'), 'review');
    await tester.tap(key('entry-billable'));
    await tester.tap(key('entry-save'));
    await tester.pumpAndSettle();

    final entry = o.time.entries_.single;
    expect(
      (entry.durationSec, entry.note, entry.billable),
      (5400, 'review', true),
    );
    expect(find.text('1h 30m logged'), findsOneWidget);
    expect(find.text('1h 30m of 1h 30m'), findsNothing);

    await tester.tap(key('edit-${entry.id}'));
    await tester.pumpAndSettle();
    await tester.enterText(key('entry-duration'), '45m');
    await tester.tap(key('entry-save'));
    await tester.pumpAndSettle();
    expect(o.time.entries_.single.durationSec, 2700);
    expect(find.text('45m logged'), findsOneWidget);

    await tester.tap(key('delete-${entry.id}'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep'));
    await tester.pumpAndSettle();
    expect(o.time.entries_, isNotEmpty); // not confirmed: still there
    await tester.tap(key('delete-${entry.id}'));
    await tester.pumpAndSettle();
    await tester.tap(key('confirm-delete'));
    await tester.pumpAndSettle();
    expect(o.time.entries_, isEmpty);
    expect(find.text('0m logged'), findsOneWidget);
  });

  testWidgets('the estimate is set, shown against the time, and cleared', (
    tester,
  ) async {
    final time = FakeTimeClient();
    time.add(time.make(task: 'a', seconds: 9000)); // 2h 30m
    final o = await open(tester, time: time);

    await tester.tap(key('time-estimate'));
    await tester.pumpAndSettle();
    await tester.enterText(key('estimate-field'), 'nope');
    await tester.tap(key('estimate-save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter a time like'), findsOneWidget);
    await tester.enterText(key('estimate-field'), '2h');
    await tester.tap(key('estimate-save'));
    await tester.pumpAndSettle();

    expect(o.time.estimates['a'], 7200);
    expect(find.text('2h 30m of 2h 00m'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.tap(key('time-estimate'));
    await tester.pumpAndSettle();
    await tester.enterText(key('estimate-field'), '');
    await tester.tap(key('estimate-save'));
    await tester.pumpAndSettle();
    expect(o.time.estimates, isEmpty);
    expect(find.text('2h 30m logged'), findsOneWidget);
  });

  testWidgets(
    'odd entries are flagged; others can be changed only with the right',
    (tester) async {
      final time = FakeTimeClient();
      final mine = time.add(
        time.make(task: 'a', seconds: 600, flags: ['overlap']),
      );
      final theirs = time.add(
        time.make(task: 'a', seconds: 90000, user: 'u2', flags: ['long']),
      );
      await open(tester, time: time, role: 'Member');

      expect(key('overlap-${mine.id}'), findsOneWidget);
      expect(key('long-${theirs.id}'), findsOneWidget);
      expect(key('edit-${mine.id}'), findsOneWidget);
      expect(
        key('edit-${theirs.id}'),
        findsNothing,
      ); // a Member lacks edit_others
    },
  );

  testWidgets('an admin can change somebody else\'s entry', (tester) async {
    final time = FakeTimeClient();
    final theirs = time.add(time.make(task: 'a', seconds: 600, user: 'u2'));
    await open(tester, time: time, role: 'Admin');

    expect(key('delete-${theirs.id}'), findsOneWidget);
  });

  testWidgets('another device\'s timer arrives as a live event', (
    tester,
  ) async {
    final connector = FakeConnector();
    final timers = ManualTimers();
    final time = FakeTimeClient();
    final pumped = await pumpProjects(
      tester,
      projects: [
        project('p1', 'Web', enabled: {timeFeature}),
      ],
      tasks: FakeTasksClient([task('a', 'Alpha')]),
      time: time,
      overrides: [currentUserIdProvider.overrideWithValue('u1')],
      sync: syncClientProvider.overrideWith((ref) {
        final client = SyncClient(
          connector: connector,
          url: Uri.parse('ws://test/ws/sync'),
          token: () async => 'tok',
          head: () async => 10,
          catchUp: (_) async => const CatchUp(),
          timers: timers.call,
        )..subscribe('ws:w1');
        client.start();
        ref.onDispose(() => unawaited(client.dispose()));
        return client;
      }),
    );
    await pumped.go(tester, '/inbox');
    await tester.pump();
    final c = connector.last..open();
    await tester.pump();
    c.say({
      'type': 'ready',
      'user': {'id': 'u1'},
      'origin': 'tag-me',
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(key('timer-chip'), findsNothing);

    // Started on the phone: the server has it, the event only says "look".
    time.add(time.make(task: 'a', running: true));
    c.say({
      'type': 'event',
      'room': 'user:u1',
      'event': {
        'type': 'timer.changed',
        'workspace': 'w1',
        'project': '',
        'entity_id': 'u1',
        'version': 0,
        'actor': 'u1',
        'origin': 'other-device',
        'cursor': 11,
      },
    });
    await tester.pump(syncCoalesce);
    await tester.pumpAndSettle();

    expect(key('timer-chip'), findsOneWidget);
  });

  testWidgets('starting over another timer says which one was stopped', (
    tester,
  ) async {
    final time = FakeTimeClient();
    time.add(time.make(task: 'b', running: true));
    await open(tester, time: time);

    await tester.tap(key('time-start'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Stopped the timer on WEB-b'), findsOneWidget);
  });

  testWidgets('a double tap on Start is one start', (tester) async {
    final time = FakeTimeClient()..startGate = Completer<void>();
    await open(tester, time: time);

    await tester.tap(key('time-start'));
    await tester.pump();
    await tester.tap(key('time-start'), warnIfMissed: false); // button is off
    await tester.pump();
    time.startGate!.complete();
    await tester.pumpAndSettle();

    expect(time.startCalls, ['a']);
  });

  testWidgets('changing only the note leaves the measured time alone', (
    tester,
  ) async {
    final time = FakeTimeClient();
    final e = time.add(
      time.make(
        task: 'a',
        seconds: 3937,
        startedAt: DateTime(2026, 11, 9, 9, 30, 12),
      ),
    ); // 1h 05m 37s
    await open(tester, time: time);

    await tester.tap(key('edit-${e.id}'));
    await tester.pumpAndSettle();
    await tester.enterText(key('entry-note'), 'only this');
    await tester.tap(key('entry-save'));
    await tester.pumpAndSettle();

    final after = time.entries_.single;
    expect(after.note, 'only this');
    expect(after.durationSec, 3937);
    expect(after.startedAt, DateTime(2026, 11, 9, 9, 30, 12));
  });

  testWidgets('a running entry can change its note without a duration', (
    tester,
  ) async {
    final time = FakeTimeClient();
    final e = time.add(time.make(task: 'a', running: true));
    await open(tester, time: time);

    await tester.tap(key('edit-${e.id}'));
    await tester.pumpAndSettle();
    expect(key('entry-duration'), findsNothing);
    await tester.enterText(key('entry-note'), 'working');
    await tester.tap(key('entry-save'));
    await tester.pumpAndSettle();

    expect(time.entries_.single.note, 'working');
    expect(time.entries_.single.running, isTrue);
  });

  testWidgets('a failed stop says so and the chip stays', (tester) async {
    final time = FakeTimeClient();
    time.add(time.make(task: 'b', running: true));
    await open(tester, time: time, location: '/inbox');
    time.failNext = const TimeException(TimeFailure.network);

    await tester.tap(key('timer-stop'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not reach the server'), findsOneWidget);
    expect(key('timer-chip'), findsOneWidget);
  });

  testWidgets('a failed read keeps the running timer on screen', (
    tester,
  ) async {
    final time = FakeTimeClient();
    time.add(time.make(task: 'b', running: true));
    final o = await open(tester, time: time, location: '/inbox');
    expect(key('timer-chip'), findsOneWidget);

    // The next read fails (every retry too): the last answer stays.
    time.failCurrent = const TimeException(TimeFailure.network);
    o.pumped.container.invalidate(currentTimerProvider);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(key('timer-chip'), findsOneWidget);
    expect(o.notes.ongoing, isNotEmpty);
    time.failCurrent = null; // let the provider's own retry succeed
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
  });
}
