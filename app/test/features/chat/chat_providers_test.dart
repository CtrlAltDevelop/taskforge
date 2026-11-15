import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart'
    show MentionPick, SendState;
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';

ProviderContainer make(FakeChatClient server) {
  final c = ProviderContainer(
    overrides: [
      chatClientProvider.overrideWithValue(server),
      workspaceScopeProvider.overrideWithValue('w1'),
      chatMeProvider.overrideWithValue('u1'),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('spaces', () {
    test('loads the list and sums the badge', () async {
      final server = FakeChatClient(
        spaces: [
          space('a', 'general', unread: 2),
          space('g', 'team', kind: SpaceKind.group, unread: 1),
        ],
      );
      final c = make(server);
      c.listen(spacesProvider, (_, _) {});
      await settle();
      await settle();
      expect(c.read(spacesProvider).loading, isFalse);
      expect(c.read(chatUnreadProvider), 3);
    });

    test('a failed read keeps the error and can be retried', () async {
      final server = FakeChatClient()
        ..listError = const ChatException(ChatFailure.network);
      final c = make(server);
      c.listen(spacesProvider, (_, _) {});
      await settle();
      await settle();
      expect(c.read(spacesProvider).error?.failure, ChatFailure.network);
      server.listError = null;
      await c.read(spacesProvider.notifier).load();
      expect(c.read(spacesProvider).error, isNull);
    });

    test('marking read drops the badge at once and tells the server', () async {
      final server = FakeChatClient(
        spaces: [space('a', 'general', unread: 4)],
        messages: [msg('m1', 'a', 'hi')],
      );
      final c = make(server);
      c.listen(spacesProvider, (_, _) {});
      c.listen(messagesProvider('a'), (_, _) {});
      await settle();
      await settle();
      expect(c.read(chatUnreadProvider), 4);
      await c.read(messagesProvider('a').notifier).markRead();
      expect(c.read(chatUnreadProvider), 0);
      expect(server.reads, ['a:m1']);
    });

    test('a failed mark-read puts the count back', () async {
      final server = FakeChatClient(
        spaces: [space('a', 'general', unread: 4)],
        messages: [msg('m1', 'a', 'hi')],
      );
      final c = make(server);
      c.listen(spacesProvider, (_, _) {});
      c.listen(messagesProvider('a'), (_, _) {});
      await settle();
      await settle();
      server.failNext = const ChatException(ChatFailure.other);
      await c.read(messagesProvider('a').notifier).markRead();
      expect(c.read(chatUnreadProvider), 4);
    });

    test('creating a group and opening a dm put them in the list', () async {
      final server = FakeChatClient();
      final c = make(server);
      c.listen(spacesProvider, (_, _) {});
      await settle();
      final notifier = c.read(spacesProvider.notifier);
      await notifier.create(SpaceKind.group, 'Team', ['u2']);
      final dm = await notifier.openDm('u2');
      final again = await notifier.openDm('u2');
      expect(again.id, dm.id);
      final list = c.read(spacesProvider).list;
      expect(list.groups.single.name, 'Team');
      expect(list.dms.length, 1);
      expect(server.created.single, 'group:Team:u2');
    });
  });

  group('messages', () {
    Future<ProviderContainer> open(FakeChatClient server) async {
      final c = make(server);
      c.listen(spacesProvider, (_, _) {});
      c.listen(messagesProvider('a'), (_, _) {});
      await settle();
      await settle();
      return c;
    }

    test(
      'shows what is sent at once, then the saved message with its id',
      () async {
        final server = FakeChatClient(spaces: [space('a', 'general')]);
        final c = await open(server);
        final body = bodyFromComposer('hello', const []);
        final future = c.read(messagesProvider('a').notifier).send(body);
        final draft = c.read(messagesProvider('a')).messages.single;
        expect(draft.sendState, SendState.sending);
        await future;
        final after = c.read(messagesProvider('a')).messages.single;
        expect(after.sendState, SendState.sent);
        expect(after.id, draft.id); // the client id is the message id
        expect(server.sent.single.clientId, draft.id);
      },
    );

    test(
      'the live copy of a message already shown is not a second message',
      () async {
        final server = FakeChatClient(spaces: [space('a', 'general')]);
        final c = await open(server);
        await c
            .read(messagesProvider('a').notifier)
            .send(bodyFromComposer('x', const []));
        await c.read(messagesProvider('a').notifier).refresh();
        expect(c.read(messagesProvider('a')).messages.length, 1);
      },
    );

    test('a refused send stays as failed and retry sends it again', () async {
      final server = FakeChatClient(spaces: [space('a', 'general')]);
      final c = await open(server);
      final notifier = c.read(messagesProvider('a').notifier);
      server.failNext = const ChatException(ChatFailure.other);
      await expectLater(
        notifier.send(bodyFromComposer('x', const [])),
        throwsA(isA<ChatException>()),
      );
      final failed = c.read(messagesProvider('a')).messages.single;
      expect(failed.sendState, SendState.failed);
      await notifier.retry(failed.id);
      expect(
        c.read(messagesProvider('a')).messages.single.sendState,
        SendState.sent,
      );
      expect(server.messages.length, 1);
    });

    test('discard removes a failed message', () async {
      final server = FakeChatClient(spaces: [space('a', 'general')]);
      final c = await open(server);
      final notifier = c.read(messagesProvider('a').notifier);
      server.failNext = const ChatException(ChatFailure.other);
      await expectLater(
        notifier.send(bodyFromComposer('x', const [])),
        throwsA(isA<ChatException>()),
      );
      notifier.discard(c.read(messagesProvider('a')).messages.single.id);
      expect(c.read(messagesProvider('a')).messages, isEmpty);
    });

    test('a broadcast that needs confirmation takes the draft back, then goes with the flag', () async {
      final server = FakeChatClient(spaces: [space('a', 'general')])
        ..broadcastLimit = 50;
      final c = await open(server);
      final notifier = c.read(messagesProvider('a').notifier);
      final body = bodyFromComposer('hey @channel ', const [
        MentionPick('channel', 'channel'),
      ]);
      await expectLater(
        notifier.send(body),
        throwsA(
          isA<ChatException>()
              .having((e) => e.failure, 'failure', ChatFailure.broadcastConfirm)
              .having((e) => e.memberCount, 'count', 80),
        ),
      );
      expect(c.read(messagesProvider('a')).messages, isEmpty);
      await notifier.send(body, confirmBroadcast: true);
      expect(server.sent.single.confirm, isTrue);
      expect(
        c.read(messagesProvider('a')).messages.single.sendState,
        SendState.sent,
      );
    });

    test('reacting shows at once and a refusal takes it back', () async {
      final server = FakeChatClient(
        spaces: [space('a', 'general')],
        messages: [msg('m1', 'a', 'hi')],
      );
      final c = await open(server);
      final notifier = c.read(messagesProvider('a').notifier);
      final m = c.read(messagesProvider('a')).messages.single;
      await notifier.react(m, '👍');
      expect(
        c.read(messagesProvider('a')).messages.single.reactedBy('👍', 'u1'),
        isTrue,
      );
      server.failNext = const ChatException(ChatFailure.forbidden);
      final m2 = c.read(messagesProvider('a')).messages.single;
      await expectLater(
        notifier.react(m2, '👍'),
        throwsA(isA<ChatException>()),
      );
      expect(
        c.read(messagesProvider('a')).messages.single.reactedBy('👍', 'u1'),
        isTrue,
      );
    });

    test('edit replaces the message; delete leaves a placeholder', () async {
      final server = FakeChatClient(
        spaces: [space('a', 'general')],
        messages: [msg('m1', 'a', 'hi', author: 'u1')],
      );
      final c = await open(server);
      final notifier = c.read(messagesProvider('a').notifier);
      final m = c.read(messagesProvider('a')).messages.single;
      await notifier.edit(m, bodyFromComposer('hi again', const []));
      final edited = c.read(messagesProvider('a')).messages.single;
      expect(edited.edited, isTrue);
      expect(edited.version, 2);
      await notifier.delete(edited);
      final gone = c.read(messagesProvider('a')).messages.single;
      expect(gone.deleted, isTrue);
      expect(gone.body, isEmpty);
    });

    test('earlier pages load on request', () async {
      final server = FakeChatClient(
        spaces: [space('a', 'general')],
        messages: [
          for (var i = 0; i < 60; i++)
            msg('m$i', 'a', 'n$i', at: t0.add(Duration(minutes: i))),
        ],
      );
      final c = await open(server);
      expect(c.read(messagesProvider('a')).messages.length, 50);
      expect(c.read(messagesProvider('a')).hasEarlier, isTrue);
      await c.read(messagesProvider('a').notifier).loadEarlier();
      expect(c.read(messagesProvider('a')).messages.length, 60);
      expect(c.read(messagesProvider('a')).hasEarlier, isFalse);
    });

    test('a thread reads its replies into the list', () async {
      final server = FakeChatClient(
        spaces: [space('a', 'general')],
        messages: [
          msg('m1', 'a', 'hi'),
          msg('r1', 'a', 'reply', parent: 'm1'),
        ],
      );
      final c = await open(server);
      await c.read(messagesProvider('a').notifier).loadThread('m1');
      expect(repliesOf(c.read(messagesProvider('a')).messages, 'm1').length, 1);
    });
  });
}
