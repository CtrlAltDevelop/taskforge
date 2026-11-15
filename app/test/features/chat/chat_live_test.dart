import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';

import '../../core/sync/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Map<String, dynamic> chatEvent(
  String type,
  String spaceId, {
  String origin = 'someone-else',
  int cursor = 11,
}) => {
  'type': 'event',
  'room': 'user:u1',
  'event': {
    'type': type,
    'workspace': 'w1',
    'project': '',
    'entity_id': spaceId,
    'version': 1,
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

Future<FakeConnection> openLive(
  WidgetTester tester,
  FakeChatClient chat,
  String location,
) async {
  final connector = FakeConnector();
  final timers = ManualTimers();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    chat: chat,
    overrides: [
      chatMeProvider.overrideWithValue('u1'),
      chatNowProvider.overrideWithValue(() => t0.add(const Duration(hours: 1))),
    ],
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
  await pumped.go(tester, location);
  await tester.pump();
  final c = connector.last..open();
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

void liveTest(String name, Future<void> Function(WidgetTester) body) =>
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pump(const Duration(seconds: 3));
    });

void main() {
  liveTest('send, then the other person answers: it shows without reloading', (
    tester,
  ) async {
    final chat = FakeChatClient(spaces: [space('rnd', 'random', lastRead: t0)]);
    final c = await openLive(tester, chat, '/chat/rnd');

    // This client writes.
    await tester.enterText(key('comment-input').first, 'Anyone here?');
    await tester.pump();
    await tester.tap(key('comment-send').first);
    await tester.pumpAndSettle();
    expect(find.text('Anyone here?'), findsOneWidget);
    expect(chat.sent.single.clientId, isNotEmpty);

    // The other client answers; the server tells the socket.
    chat.messages.add(
      msg(
        'r1',
        'rnd',
        'Yes, I am',
        at: DateTime.now().toUtc().add(const Duration(seconds: 1)),
      ),
    );
    c.say(chatEvent('chat.message.created', 'rnd'));
    await settle(tester);

    expect(find.text('Yes, I am'), findsOneWidget);
    expect(find.text('Anyone here?'), findsOneWidget);
  });

  liveTest('a message in a space that is not open raises its badge', (
    tester,
  ) async {
    final chat = FakeChatClient(
      spaces: [space('rnd', 'random'), space('gen', 'general')],
    );
    final c = await openLive(tester, chat, '/chat/rnd');
    expect(key('unread-gen'), findsNothing);

    chat.spaces[1] = space('gen', 'general', unread: 1);
    c.say(chatEvent('chat.message.created', 'gen'));
    await settle(tester);

    expect(
      find.descendant(of: key('unread-gen'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: key('open-chat'), matching: find.text('1')),
      findsOneWidget,
    );
  });

  liveTest('a read on another device clears the badge here', (tester) async {
    final chat = FakeChatClient(
      spaces: [space('rnd', 'random'), space('gen', 'general', unread: 2)],
    );
    final c = await openLive(tester, chat, '/chat/rnd');
    expect(key('unread-gen'), findsOneWidget);

    chat.spaces[1] = space('gen', 'general');
    c.say(chatEvent('chat.read', 'gen'));
    await settle(tester);

    expect(key('unread-gen'), findsNothing);
  });

  liveTest('an edit and a delete arrive live', (tester) async {
    final chat = FakeChatClient(
      spaces: [space('rnd', 'random')],
      messages: [msg('m1', 'rnd', 'Typo here')],
    );
    final c = await openLive(tester, chat, '/chat/rnd');
    expect(find.text('Typo here'), findsOneWidget);

    chat.messages[0] = msg('m1', 'rnd', 'Fixed here', version: 2);
    c.say(chatEvent('chat.message.updated', 'rnd'));
    await settle(tester);
    expect(find.text('Fixed here'), findsOneWidget);

    chat.messages[0] = chat.messages[0].copyWith(deleted: true, body: '');
    c.say(chatEvent('chat.message.deleted', 'rnd', cursor: 12));
    await settle(tester);
    expect(key('removed-m1'), findsOneWidget);
  });

  liveTest('this client\'s own echo is not read again', (tester) async {
    final chat = FakeChatClient(spaces: [space('rnd', 'random')]);
    final c = await openLive(tester, chat, '/chat/rnd');
    final before = chat.messageCalls;
    c.say(chatEvent('chat.message.created', 'rnd', origin: 'tag-me'));
    await settle(tester);
    expect(chat.messageCalls, before);
    expect(chat.spaces.length, 1);
  });
}
