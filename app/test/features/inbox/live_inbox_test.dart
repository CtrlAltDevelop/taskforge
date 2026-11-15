import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';

import '../../core/sync/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

typedef Live = ({
  Pumped pumped,
  FakeConnector connector,
  ManualTimers timers,
  FakeInboxClient inbox,
});

Future<Live> open(
  WidgetTester tester, {
  required FakeInboxClient inbox,
  String location = '/inbox',
  CatchUp? caughtUp,
  List<String> workspaces = const ['w1'],
}) async {
  final connector = FakeConnector();
  final timers = ManualTimers();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    inbox: inbox,
    workspaces: workspaces,
    overrides: [inboxNowProvider.overrideWithValue(() => noon)],
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
  await pumped.go(tester, location);
  return (pumped: pumped, connector: connector, timers: timers, inbox: inbox);
}

Future<FakeConnection> connect(WidgetTester tester, Live live) async {
  await tester.pump();
  final c = live.connector.last..open();
  await tester.pump();
  c.say({
    'type': 'ready',
    'user': {'id': 'u1'},
    'origin': 'tag-me',
  });
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  return c;
}

Map<String, dynamic> event(
  String type, {
  String workspace = 'w1',
  String origin = 'someone-else',
  int cursor = 11,
}) => {
  'type': 'event',
  'room': 'user:u1',
  'event': {
    'type': type,
    'workspace': workspace,
    'project': '',
    'entity_id': 'u1', // you: the notification is yours
    'version': 0,
    'actor': 'u2',
    'origin': origin,
    'cursor': cursor,
  },
};

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

Finder key(String k) => find.byKey(Key(k));

void liveTest(String name, Future<void> Function(WidgetTester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pump(const Duration(seconds: 3));
    });

void main() {
  liveTest('a new notification shows in the open inbox and on the badge', (
    tester,
  ) async {
    final inbox = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final live = await open(tester, inbox: inbox);
    final c = await connect(tester, live);
    expect(key('notification-n2'), findsNothing);
    expect(find.text('1 unread'), findsOneWidget);

    inbox.items.add(note('n2', 'user.mentioned', updatedAt: noon));
    c.say(event('notification.new'));
    await settle(tester);

    expect(key('notification-n2'), findsOneWidget);
    expect(find.text('2 unread'), findsOneWidget);
    expect(
      find.descendant(of: key('open-inbox'), matching: find.text('2')),
      findsOneWidget,
    );
  });

  liveTest('the badge follows when no inbox is open', (tester) async {
    final inbox = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final live = await open(tester, inbox: inbox, location: '/projects/p1');
    final c = await connect(tester, live);
    expect(
      find.descendant(of: key('open-inbox'), matching: find.text('1')),
      findsOneWidget,
    );

    inbox.items.add(note('n2', 'task.assigned'));
    c.say(event('notification.changed'));
    await settle(tester);

    expect(
      find.descendant(of: key('open-inbox'), matching: find.text('2')),
      findsOneWidget,
    );
  });

  liveTest('one in another workspace shows on the switcher', (tester) async {
    final inbox = FakeInboxClient();
    final live = await open(
      tester,
      inbox: inbox,
      workspaces: const ['w1', 'w2'],
    );
    final c = await connect(tester, live);
    expect(tester.widget<Badge>(key('switcher-badge')).isLabelVisible, isFalse);

    inbox.items.add(note('n9', 'task.assigned', workspace: 'w2'));
    c.say(event('notification.new', workspace: 'w2'));
    await settle(tester);

    expect(tester.widget<Badge>(key('switcher-badge')).isLabelVisible, isTrue);
    expect(key('notification-n9'), findsNothing); // not this workspace's list
  });

  liveTest('this client\'s own events are not read again', (tester) async {
    final inbox = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final live = await open(tester, inbox: inbox);
    final c = await connect(tester, live);
    final before = inbox.lists.length;

    c.say(event('notification.changed', origin: 'tag-me'));
    await settle(tester);

    expect(inbox.lists.length, before); // no inbox read, no peek for an alert
  });

  liveTest('a burst of events is read once', (tester) async {
    final inbox = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final live = await open(tester, inbox: inbox);
    final c = await connect(tester, live);
    int reads() => inbox.lists.where((l) => l.filter == InboxFilter.all).length;
    final before = reads();

    for (var i = 0; i < 5; i++) {
      c.say(event('notification.changed', cursor: 20 + i));
    }
    await settle(tester);

    expect(reads(), before + 1);
  });

  liveTest('after a gap the inbox reads again', (tester) async {
    final inbox = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final live = await open(
      tester,
      inbox: inbox,
      caughtUp: const CatchUp(gap: true, head: 500),
    );
    final first = await connect(tester, live);
    expect(key('notification-n2'), findsNothing);

    inbox.items.add(note('n2', 'task.assigned', updatedAt: noon));
    await first.drop();
    await tester.pump();
    live.timers.pending
        .firstWhere((t) => t.delay < const Duration(seconds: 2))
        .fire();
    await tester.pump();
    await connect(tester, live);
    await settle(tester);

    expect(key('notification-n2'), findsOneWidget);
  });
}
