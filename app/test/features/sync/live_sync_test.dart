import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../../core/sync/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';

typedef Live = ({
  Pumped pumped,
  FakeTasksClient tasks,
  FakeConnector connector,
  ManualTimers timers,
});

Future<Live> _open(WidgetTester tester, {CatchUp? caughtUp}) async {
  final server = FakeTasksClient([
    task('a', 'Alpha'),
    task('b', 'Bravo', number: 2),
  ]);
  final connector = FakeConnector();
  final timers = ManualTimers();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: server,
    sync: syncClientProvider.overrideWith((ref) {
      final client = SyncClient(
        connector: connector,
        url: Uri.parse('ws://test/ws/sync'),
        token: () async => 'tok',
        head: () async => 10,
        catchUp: (_) async => caughtUp ?? const CatchUp(),
        timers: timers.call,
      )..subscribe('ws:w1');
      client.start();
      ref.onDispose(() => unawaited(client.dispose()));
      return client;
    }),
  );
  await pumped.go(tester, '/projects/p1');
  return (pumped: pumped, tasks: server, connector: connector, timers: timers);
}

/// The tag the server says marks this client's own changes.
const ownTag = 'tag-me';

/// The server accepts the connection.
Future<FakeConnection> _connect(WidgetTester tester, Live live) async {
  await tester.pump();
  final c = live.connector.last..open();
  await tester.pump();
  c.say({
    'type': 'ready',
    'user': {'id': 'me'},
    'origin': ownTag,
  });
  await tester.pump();
  await tester.pump();
  // The first connection has the screens read once more (see SyncClient).
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  return c;
}

Map<String, dynamic> _event(
  String type, {
  String entity = 'a',
  String origin = 'someone-else',
  int cursor = 11,
  String project = 'p1',
}) => {
  'type': 'event',
  'room': 'proj:p1',
  'event': {
    'type': type,
    'workspace': 'w1',
    'project': project,
    'entity_id': entity,
    'version': 2,
    'actor': 'u2',
    'origin': origin,
    'cursor': cursor,
  },
};

void _rename(FakeTasksClient server, String id, String title) {
  final i = server.tasks.indexWhere((t) => t.id == id);
  final now = server.tasks[i].apply(TaskPatch(title: title));
  server.tasks[i] = Task(
    id: now.id,
    projectId: now.projectId,
    number: now.number,
    displayId: now.displayId,
    title: now.title,
    statusId: now.statusId,
    statusName: now.statusName,
    statusCategory: now.statusCategory,
    version: server.tasks[i].version + 1, // the server's copy is newer
  );
}

/// A widget test that, once done, lets the flash and coalescing timers run out
/// (the tree is torn down after the pending-timer check).
void liveTest(String name, Future<void> Function(WidgetTester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pump(const Duration(seconds: 3));
    });

void main() {
  liveTest('the project room is joined and the indicator says live', (
    tester,
  ) async {
    final live = await _open(tester);
    expect(find.byKey(const Key('live-connecting')), findsOneWidget);

    final c = await _connect(tester, live);

    expect(find.byKey(const Key('live-live')), findsOneWidget);
    expect(c.sentOf('subscribe').map((f) => f['room']).toSet(), {
      'ws:w1',
      'proj:p1',
    });
  });

  liveTest('the first connection has the open screens read once more', (
    tester,
  ) async {
    final live = await _open(tester);
    final before = live.tasks.listCalls;
    _rename(live.tasks, 'a', 'Changed before the socket listened');

    await _connect(tester, live);

    expect(live.tasks.listCalls, before + 1);
    expect(find.text('Changed before the socket listened'), findsOneWidget);
  });

  liveTest("somebody else's change shows up on its own, and flashes", (
    tester,
  ) async {
    final live = await _open(tester);
    final c = await _connect(tester, live);
    expect(find.text('Alpha'), findsOneWidget);
    final reads = live.tasks.listCalls;

    _rename(live.tasks, 'a', 'Alpha 2');
    c.say(_event('task.updated'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Alpha 2'), findsOneWidget);
    expect(live.tasks.listCalls, reads + 1);
    expect(find.byKey(const Key('live-flash')), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('live-flash')), findsNothing);
  });

  liveTest('a burst of changes is read once', (tester) async {
    final live = await _open(tester);
    final c = await _connect(tester, live);
    final reads = live.tasks.listCalls;

    for (var i = 0; i < 20; i++) {
      c.say(_event('task.updated', cursor: 20 + i));
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(live.tasks.listCalls, reads + 1);
  });

  liveTest("this app's own change is not read back (no flicker)", (
    tester,
  ) async {
    final live = await _open(tester);
    final c = await _connect(tester, live);
    final reads = live.tasks.listCalls;

    c.say(_event('task.updated', origin: ownTag));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(live.tasks.listCalls, reads);
    expect(find.byKey(const Key('live-flash')), findsNothing);
  });

  liveTest('a change in another project leaves this one alone', (tester) async {
    final live = await _open(tester);
    final c = await _connect(tester, live);
    final reads = live.tasks.listCalls;

    c.say(_event('task.updated', project: 'p2'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(live.tasks.listCalls, reads);
  });

  liveTest(
    'a dropped connection shows a banner, and what was missed arrives once back',
    (tester) async {
      final live = await _open(
        tester,
        caughtUp: const CatchUp(
          events: [
            SyncEvent(
              type: 'task.updated',
              project: 'p1',
              entityId: 'a',
              version: 2,
              cursor: 12,
            ),
          ],
          head: 12,
        ),
      );
      final first = await _connect(tester, live);
      expect(find.byKey(const Key('reconnecting-banner')), findsNothing);

      await first.drop();
      await tester.pump();

      expect(find.byKey(const Key('reconnecting-banner')), findsOneWidget);
      expect(find.byKey(const Key('live-reconnecting')), findsOneWidget);

      _rename(live.tasks, 'a', 'While you were away');
      live.timers.pending
          .firstWhere((t) => t.delay < const Duration(seconds: 2))
          .fire();
      final second = await _connect(tester, live);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(second.sentOf('subscribe').map((f) => f['room']).toSet(), {
        'ws:w1',
        'proj:p1',
      });
      expect(find.byKey(const Key('reconnecting-banner')), findsNothing);
      expect(find.text('While you were away'), findsOneWidget);
    },
  );

  liveTest(
    'a task detail tells the others, shows who else is there and who is typing',
    (tester) async {
      final live = await _open(tester);
      final c = await _connect(tester, live);

      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();

      expect(c.sentOf('presence').last, {
        'type': 'presence',
        'project': 'p1',
        'task': 'a',
        'state': 'viewing',
      });
      expect(find.byKey(const Key('presence-strip')), findsNothing);

      c.say({
        'type': 'presence',
        'project': 'p1',
        'task': 'a',
        'users': [
          {'id': 'me', 'editing': false},
          {'id': 'u2', 'editing': true},
        ],
      });
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('presence-strip')), findsOneWidget);
      expect(find.byKey(const Key('viewer-u2')), findsOneWidget);
      expect(find.byKey(const Key('viewer-me')), findsNothing);
      expect(find.byKey(const Key('editing-hint')), findsOneWidget);
      expect(find.textContaining('is editing this'), findsOneWidget);
    },
  );

  liveTest(
    'typing in the description tells the others, and closing the detail leaves',
    (tester) async {
      final live = await _open(tester);
      final c = await _connect(tester, live);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('detail-description')));
      await tester.pump();
      expect(c.sentOf('presence').last['state'], 'editing');

      await tester.tap(find.byKey(const Key('close-detail')));
      await tester.pumpAndSettle();
      expect(c.sentOf('presence').last['state'], 'left');
    },
  );

  liveTest('who else is on a task is forgotten when the connection drops', (
    tester,
  ) async {
    final live = await _open(tester);
    final c = await _connect(tester, live);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    c.say({
      'type': 'presence',
      'project': 'p1',
      'task': 'a',
      'users': [
        {'id': 'u2', 'editing': true},
      ],
    });
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('viewer-u2')), findsOneWidget);

    await c.drop();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('viewer-u2')), findsNothing);
    expect(find.byKey(const Key('editing-hint')), findsNothing);
  });
}
