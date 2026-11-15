import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_worker.dart';
import 'package:taskforge/features/chat/data/offline_chat_client.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comments.dart'
    show SendState;

import '../../core/offline/fakes.dart';
import 'fakes.dart';

void main() {
  late Harness h;
  late FakeChatClient server;
  late OfflineChatClient chat;
  late OutboxWorker worker;

  setUp(() {
    h = Harness.create();
    server = FakeChatClient(
      spaces: [space('rnd', 'random')],
      messages: [msg('m1', 'rnd', 'Hello')],
    );
    chat = OfflineChatClient(server, h.env);
    worker = OutboxWorker(
      store: () async => h.store,
      tasks: h.server.t,
      comments: h.server.c,
      chat: server,
      workspace: () => 'w1',
      worked: () => h.online = true,
      failed: () => h.online = false,
    );
  });

  tearDown(() => h.close());

  void goOffline() {
    server.reachable = false;
    h.online = false;
  }

  test('spaces and messages read once are answered from the copy', () async {
    await chat.listSpaces('w1');
    await chat.listMessages('w1', 'rnd');
    goOffline();
    final list = await chat.listSpaces('w1');
    final page = await chat.listMessages('w1', 'rnd');
    expect(list.channels.single.id, 'rnd');
    expect(page.messages.single.id, 'm1');
  });

  test('a message written offline shows as sending and is queued', () async {
    await chat.listMessages('w1', 'rnd');
    goOffline();
    final made = await chat.send('w1', 'rnd', 'Late news');
    expect(made.sendState, SendState.sending);
    final page = await chat.listMessages('w1', 'rnd');
    expect(page.messages.last.id, made.id);
    expect(page.messages.last.sendState, SendState.sending);
    final queue = await h.store.queue('w1');
    expect(queue.single.entity, OutboxEntity.chat);
    expect(queue.single.entityId, made.id);
  });

  test('back online the outbox sends it with its own id, once', () async {
    goOffline();
    final made = await chat.send('w1', 'rnd', 'Late news');
    server.reachable = true;
    h.online = true;
    var result = await worker.drain();
    expect(result.sent, 1);
    expect(server.sent.single.clientId, made.id);
    // A repeated send (a cut-off answer) is the same message.
    await server.send('w1', 'rnd', 'Late news', clientId: made.id);
    expect(server.messages.where((m) => m.id == made.id).length, 1);
    result = await worker.drain();
    expect(result.sent, 0);
    expect(await h.store.queue('w1'), isEmpty);
  });

  test('a send the server refuses waits for the person, not dropped', () async {
    goOffline();
    await chat.send('w1', 'rnd', 'Nope');
    server.reachable = true;
    h.online = true;
    server.failNext = const ChatException(ChatFailure.forbidden);
    final result = await worker.drain();
    expect(result.rejected, 1);
    final queue = await h.store.queue('w1');
    expect(queue.single.state, OutboxState.rejected);
    final page = await chat.listMessages('w1', 'rnd');
    expect(page.messages.last.sendState, SendState.failed);
  });

  test('a network failure during the pass keeps it queued', () async {
    goOffline();
    await chat.send('w1', 'rnd', 'Later');
    h.online = true;
    final result = await worker.drain();
    expect(result.stoppedOffline, isTrue);
    expect((await h.store.queue('w1')).single.state, OutboxState.pending);
  });

  test(
    'changes that need the server fail with a network error offline',
    () async {
      goOffline();
      await expectLater(
        chat.react('w1', msg('m1', 'rnd', 'x'), '👍', on: true),
        throwsA(
          isA<ChatException>().having(
            (e) => e.failure,
            'failure',
            ChatFailure.network,
          ),
        ),
      );
    },
  );

  test(
    'a confirmation request is not queued; it goes back to the person',
    () async {
      server
        ..broadcastLimit = 50
        ..memberCount = 80;
      final body = msg(
        'x',
        'rnd',
        '"id":"channel"',
      ).body.replaceAll('"text"', '"id":"channel","text"');
      await expectLater(
        chat.send('w1', 'rnd', body),
        throwsA(
          isA<ChatException>().having(
            (e) => e.failure,
            'failure',
            ChatFailure.broadcastConfirm,
          ),
        ),
      );
      expect(await h.store.queue('w1'), isEmpty);
    },
  );
}
