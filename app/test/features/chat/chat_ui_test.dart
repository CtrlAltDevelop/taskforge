import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

final _now = t0.add(const Duration(hours: 1));

Future<Pumped> open(
  WidgetTester tester,
  FakeChatClient chat, {
  String location = '/chat',
  Size size = const Size(1400, 1000),
}) async {
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Fix login')]),
    chat: chat,
    size: size,
    overrides: [
      chatMeProvider.overrideWithValue('u1'),
      chatNowProvider.overrideWithValue(() => _now),
    ],
  );
  await pumped.go(tester, location);
  await tester.pumpAndSettle();
  return pumped;
}

Finder key(String k) => find.byKey(Key(k));

Future<void> write(WidgetTester tester, String text) async {
  await tester.enterText(key('comment-input').first, text);
  await tester.pump();
  await tester.pump();
}

Future<void> sendIt(WidgetTester tester) async {
  await tester.tap(key('comment-send').first);
  await tester.pumpAndSettle();
}

FakeChatClient server({List<ChatMessage> messages = const []}) =>
    FakeChatClient(
      spaces: [
        space('gen', 'general', unread: 2, isDefault: true),
        space('rnd', 'random'),
        space('grp', 'Leads', kind: SpaceKind.group, unread: 1),
        space('dm1', '', kind: SpaceKind.dm, peer: 'u2'),
      ],
      taskChats: const [
        TaskChatRef(
          taskId: 'a',
          projectId: 'p1',
          title: 'Fix login',
          displayId: 'WEB-1',
        ),
      ],
      messages: messages,
    );

void main() {
  group('list', () {
    testWidgets('groups spaces and shows unread badges', (tester) async {
      await open(tester, server());
      for (final s in [
        'section-channels',
        'section-groups',
        'section-dms',
        'section-task-chats',
      ]) {
        expect(key(s), findsOneWidget);
      }
      expect(find.text('general'), findsOneWidget);
      expect(find.text('Leads'), findsOneWidget);
      expect(find.text('Hank Hill'), findsOneWidget); // the dm takes the name
      expect(
        find.descendant(of: key('unread-gen'), matching: find.text('2')),
        findsOneWidget,
      );
      expect(key('unread-rnd'), findsNothing);
    });

    testWidgets('the sidebar entry carries the sum of unread', (tester) async {
      await open(tester, server());
      expect(
        find.descendant(of: key('open-chat'), matching: find.text('3')),
        findsOneWidget,
      );
    });

    testWidgets('search narrows every group', (tester) async {
      await open(tester, server());
      await tester.enterText(key('chat-search'), 'lead');
      await tester.pump();
      expect(find.text('Leads'), findsOneWidget);
      expect(find.text('general'), findsNothing);
      expect(key('section-channels'), findsNothing);
      await tester.enterText(key('chat-search'), 'zzz');
      await tester.pump();
      expect(key('chat-list-empty'), findsOneWidget);
    });

    testWidgets('a task chat opens that task, where its chat is', (
      tester,
    ) async {
      await open(tester, server(), size: const Size(1400, 2000));
      await tester.tap(key('task-chat-a'));
      await tester.pumpAndSettle();
      expect(key('comments'), findsOneWidget);
    });

    testWidgets('shows an error with retry, then the list', (tester) async {
      final chat = server()
        ..listError = const ChatException(ChatFailure.network);
      await open(tester, chat);
      expect(key('chat-list-error'), findsOneWidget);
      chat.listError = null;
      await tester.tap(key('chat-list-retry'));
      await tester.pumpAndSettle();
      expect(find.text('general'), findsOneWidget);
    });

    testWidgets('an empty workspace says how to start', (tester) async {
      await open(tester, FakeChatClient());
      expect(key('chat-list-empty'), findsOneWidget);
    });
  });

  group('conversation', () {
    testWidgets('opens beside the list on a wide screen', (tester) async {
      await open(tester, server(messages: [msg('m1', 'rnd', 'Hello team')]));
      await tester.tap(key('space-rnd'));
      await tester.pumpAndSettle();
      expect(key('space-gen'), findsOneWidget); // the list stays
      expect(find.text('Hello team'), findsOneWidget);
      expect(key('chat-title'), findsOneWidget);
    });

    testWidgets('one pane at a time on a phone', (tester) async {
      await open(
        tester,
        server(messages: [msg('m1', 'rnd', 'Hello team')]),
        size: const Size(400, 900),
      );
      expect(key('space-rnd'), findsOneWidget);
      expect(key('comment-input'), findsNothing);
      await tester.tap(key('space-rnd'));
      await tester.pumpAndSettle();
      expect(find.text('Hello team'), findsOneWidget);
      expect(key('space-gen'), findsNothing);
      await tester.tap(key('chat-to-list'));
      await tester.pumpAndSettle();
      expect(key('space-gen'), findsOneWidget);
    });

    testWidgets('an empty conversation says hi', (tester) async {
      await open(tester, server(), location: '/chat/rnd');
      expect(key('chat-empty'), findsOneWidget);
    });

    testWidgets('a failed read shows an error with retry', (tester) async {
      final chat = server(messages: [msg('m1', 'rnd', 'Hello')])
        ..messagesError = const ChatException(ChatFailure.network);
      await open(tester, chat, location: '/chat/rnd');
      expect(key('chat-error'), findsOneWidget);
      chat.messagesError = null;
      await tester.tap(key('chat-retry'));
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('the unread divider sits above the first new message', (
      tester,
    ) async {
      final read = t0.add(const Duration(minutes: 5));
      final chat = FakeChatClient(
        spaces: [space('gen', 'general', unread: 2, lastRead: read)],
        messages: [
          msg('m1', 'gen', 'Old news', at: t0),
          msg(
            'm2',
            'gen',
            'First new',
            at: read.add(const Duration(minutes: 1)),
          ),
          msg(
            'm3',
            'gen',
            'Second new',
            at: read.add(const Duration(minutes: 2)),
          ),
        ],
      );
      await open(tester, chat, location: '/chat/gen');
      expect(key('unread-divider'), findsOneWidget);
      expect(
        tester.getTopLeft(key('unread-divider')).dy,
        greaterThan(tester.getTopLeft(key('message-m1')).dy),
      );
      expect(
        tester.getTopLeft(key('unread-divider')).dy,
        lessThan(tester.getTopLeft(key('message-m2')).dy),
      );
    });

    testWidgets('marks read when visible at the bottom', (tester) async {
      final read = t0.add(const Duration(minutes: 5));
      final chat = FakeChatClient(
        spaces: [space('gen', 'general', unread: 1, lastRead: read)],
        messages: [
          msg('m1', 'gen', 'New', at: read.add(const Duration(minutes: 1))),
        ],
      );
      await open(tester, chat, location: '/chat/gen');
      expect(chat.reads, ['gen:m1']);
      expect(key('unread-gen'), findsNothing);
    });

    testWidgets('jump to latest appears when scrolled up and brings you back', (
      tester,
    ) async {
      final chat = FakeChatClient(
        spaces: [space('gen', 'general')],
        messages: [
          for (var i = 0; i < 40; i++)
            msg(
              'm$i',
              'gen',
              'Line number $i',
              at: t0.add(Duration(minutes: i)),
            ),
        ],
      );
      await open(tester, chat, location: '/chat/gen');
      expect(key('jump-to-latest'), findsNothing);
      await tester.drag(key('chat-messages'), const Offset(0, 900));
      await tester.pumpAndSettle();
      expect(key('jump-to-latest'), findsOneWidget);
      await tester.tap(key('jump-to-latest'));
      await tester.pumpAndSettle();
      expect(key('jump-to-latest'), findsNothing);
    });

    testWidgets('earlier messages load on request', (tester) async {
      final chat = FakeChatClient(
        spaces: [space('gen', 'general')],
        messages: [
          for (var i = 0; i < 55; i++)
            msg('m$i', 'gen', 'Line $i', at: t0.add(Duration(minutes: i))),
        ],
      );
      await open(tester, chat, location: '/chat/gen');
      await tester.scrollUntilVisible(
        key('chat-load-earlier'),
        500,
        scrollable: find
            .descendant(
              of: key('chat-messages'),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(key('chat-load-earlier'));
      await tester.pumpAndSettle();
      expect(key('chat-load-earlier'), findsNothing);
      expect(chat.messageCalls, greaterThan(1));
    });
  });

  group('composer', () {
    testWidgets('sends a message and shows it', (tester) async {
      final chat = server();
      await open(tester, chat, location: '/chat/rnd');
      await write(tester, 'Good morning');
      await sendIt(tester);
      expect(find.text('Good morning'), findsOneWidget);
      expect(chat.sent.single.clientId, isNotEmpty);
      expect(find.text('Sending…'), findsNothing);
    });

    testWidgets('@ offers channel and here beside people', (tester) async {
      await open(tester, server(), location: '/chat/rnd');
      await write(tester, '@');
      expect(key('mention-channel'), findsOneWidget);
      expect(key('mention-here'), findsOneWidget);
      expect(key('mention-u2'), findsOneWidget);
    });

    testWidgets('a direct message does not offer channel or here', (
      tester,
    ) async {
      await open(tester, server(), location: '/chat/dm1');
      await write(tester, '@');
      expect(key('mention-channel'), findsNothing);
      expect(key('mention-u2'), findsOneWidget);
    });

    testWidgets('@channel over the limit asks before it goes out', (
      tester,
    ) async {
      final chat = server()..broadcastLimit = 50;
      await open(tester, chat, location: '/chat/rnd');
      await write(tester, '@');
      await tester.tap(key('mention-channel'));
      await tester.pump();
      await sendIt(tester);
      expect(key('broadcast-dialog'), findsOneWidget);
      expect(find.textContaining('80'), findsOneWidget);
      expect(chat.sent, isEmpty);
      await tester.tap(key('broadcast-send'));
      await tester.pumpAndSettle();
      expect(chat.sent.single.confirm, isTrue);
      expect(key('broadcast-dialog'), findsNothing);
    });

    testWidgets(
      'cancelling the confirmation keeps the text and sends nothing',
      (tester) async {
        final chat = server()..broadcastLimit = 50;
        await open(tester, chat, location: '/chat/rnd');
        await write(tester, '@');
        await tester.tap(key('mention-here'));
        await tester.pump();
        await sendIt(tester);
        await tester.tap(key('broadcast-cancel'));
        await tester.pumpAndSettle();
        expect(chat.sent, isEmpty);
        final field = tester.widget<TextField>(key('comment-input').first);
        expect(field.controller!.text, contains('@here'));
      },
    );

    testWidgets('a refused send stays as failed, with retry and discard', (
      tester,
    ) async {
      final chat = server()..failNext = const ChatException(ChatFailure.other);
      await open(tester, chat, location: '/chat/rnd');
      await write(tester, 'Will fail');
      await sendIt(tester);
      expect(find.text('Not sent'), findsOneWidget);
      final id = chat.messages.isEmpty ? null : chat.messages.first.id;
      expect(id, isNull);
      await tester.tap(find.textContaining('Retry').first);
      await tester.pumpAndSettle();
      expect(chat.messages.length, 1);
      expect(find.text('Not sent'), findsNothing);
    });
  });

  group('messages', () {
    FakeChatClient mine() => FakeChatClient(
      spaces: [space('rnd', 'random')],
      messages: [
        ChatMessage(
          id: 'm1',
          spaceId: 'rnd',
          authorId: 'u1',
          authorName: 'Me',
          body: msg('x', 'rnd', 'My words').body,
          createdAt: _now.subtract(const Duration(minutes: 5)),
        ),
        msg(
          'm2',
          'rnd',
          'Their words',
          at: _now.subtract(const Duration(minutes: 4)),
        ),
      ],
    );

    testWidgets('own message can be edited within 24 hours', (tester) async {
      final chat = mine();
      await open(tester, chat, location: '/chat/rnd');
      await tester.tap(key('menu-m1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: key('edit-m1'), matching: key('comment-input')),
        'Better words',
      );
      await tester.tap(
        find.descendant(of: key('edit-m1'), matching: key('comment-send')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Better words'), findsOneWidget);
      expect(key('edited-m1'), findsOneWidget);
    });

    testWidgets("somebody else's message has no edit or delete", (
      tester,
    ) async {
      await open(tester, mine(), location: '/chat/rnd');
      await tester.tap(key('menu-m2'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('an old own message cannot be edited', (tester) async {
      final chat = FakeChatClient(
        spaces: [space('rnd', 'random')],
        messages: [
          ChatMessage(
            id: 'old',
            spaceId: 'rnd',
            authorId: 'u1',
            body: msg('x', 'rnd', 'Ancient').body,
            createdAt: _now.subtract(const Duration(hours: 30)),
          ),
        ],
      );
      await open(tester, chat, location: '/chat/rnd');
      await tester.tap(key('menu-old'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('delete leaves "message removed"', (tester) async {
      await open(tester, mine(), location: '/chat/rnd');
      await tester.tap(key('menu-m1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(key('removed-m1'), findsOneWidget);
      expect(find.text('message removed'), findsOneWidget);
      expect(find.text('My words'), findsNothing);
    });

    testWidgets('reactions toggle', (tester) async {
      final chat = mine();
      await open(tester, chat, location: '/chat/rnd');
      await tester.tap(key('react-m2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('👍').last);
      await tester.pumpAndSettle();
      expect(key('reaction-m2-👍'), findsOneWidget);
      expect(chat.messages.last.reactedBy('👍', 'u1'), isTrue);
    });

    testWidgets('a reply opens the thread and is sent under its message', (
      tester,
    ) async {
      final chat = FakeChatClient(
        spaces: [space('rnd', 'random')],
        messages: [
          msg(
            'm2',
            'rnd',
            'Their words',
            at: _now.subtract(const Duration(minutes: 4)),
          ),
          msg(
            'r1',
            'rnd',
            'An answer',
            parent: 'm2',
            at: _now.subtract(const Duration(minutes: 3)),
          ),
        ],
      );
      await open(tester, chat, location: '/chat/rnd');
      expect(find.text('An answer'), findsNothing); // not in the timeline
      expect(find.text('1 reply'), findsOneWidget);
      await tester.tap(key('replies-m2'));
      await tester.pumpAndSettle();
      expect(find.text('An answer'), findsOneWidget);
      await write(tester, 'My reply');
      await sendIt(tester);
      expect(chat.sent.single.parentId, 'm2');
      expect(find.text('My reply'), findsOneWidget);
      await tester.tap(key('thread-back'));
      await tester.pumpAndSettle();
      expect(find.text('2 replies'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('an archived space is read-only', (tester) async {
      final chat = FakeChatClient(
        spaces: [space('old', 'old', archived: true)],
      );
      await open(tester, chat, location: '/chat/old');
      expect(key('chat-readonly'), findsOneWidget);
      expect(key('comment-input'), findsNothing);
    });

    testWidgets('a conversation left by a former member is read-only', (
      tester,
    ) async {
      final chat = FakeChatClient(
        spaces: [
          space('d', '', kind: SpaceKind.dm, peer: 'gone', readOnly: true),
        ],
      );
      await open(tester, chat, location: '/chat/d');
      expect(key('chat-readonly'), findsOneWidget);
      expect(find.text('Former member'), findsWidgets);
    });

    testWidgets('a channel not joined offers Join instead of the composer', (
      tester,
    ) async {
      final chat = FakeChatClient(spaces: [space('c', 'open', joined: false)]);
      await open(tester, chat, location: '/chat/c');
      expect(key('comment-input'), findsNothing);
      await tester.tap(key('chat-join'));
      await tester.pumpAndSettle();
      expect(key('comment-input'), findsOneWidget);
    });

    testWidgets('a space that is not in the list says it is gone', (
      tester,
    ) async {
      await open(tester, server(), location: '/chat/nope');
      expect(key('chat-placeholder'), findsOneWidget);
    });

    testWidgets('no space chosen on a wide screen asks to choose', (
      tester,
    ) async {
      await open(tester, server());
      expect(key('chat-placeholder'), findsOneWidget);
    });
  });

  group('new dialog', () {
    testWidgets('creates a channel and opens it', (tester) async {
      final chat = server();
      await open(tester, chat);
      await tester.tap(key('chat-new'));
      await tester.pumpAndSettle();
      await tester.tap(key('chat-create'));
      await tester.pumpAndSettle();
      expect(key('new-chat-problem'), findsOneWidget); // a name is needed
      await tester.enterText(key('new-chat-name'), 'ideas');
      await tester.tap(key('chat-create'));
      await tester.pumpAndSettle();
      expect(chat.created.single, 'channel:ideas:');
      expect(key('chat-title'), findsOneWidget);
    });

    testWidgets('a group needs a name and members', (tester) async {
      final chat = server();
      await open(tester, chat);
      await tester.tap(key('chat-new'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Group'));
      await tester.pumpAndSettle();
      await tester.enterText(key('new-chat-name'), 'Plan');
      await tester.tap(key('chat-create'));
      await tester.pumpAndSettle();
      expect(key('new-chat-problem'), findsOneWidget);
      final people = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('pick-'),
      );
      await tester.tap(people.first);
      await tester.pump();
      await tester.tap(key('chat-create'));
      await tester.pumpAndSettle();
      expect(chat.created.single, startsWith('group:Plan:'));
    });

    testWidgets('a message opens the direct message of the person picked', (
      tester,
    ) async {
      final chat = server();
      await open(tester, chat);
      await tester.tap(key('chat-new'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(key('chat-create')).onPressed, isNull);
      final people = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('pick-'),
      );
      await tester.tap(people.first);
      await tester.pump();
      await tester.tap(key('chat-create'));
      await tester.pumpAndSettle();
      expect(chat.opened.length, 1);
    });
  });

  group('settings', () {
    testWidgets('mute, notify and leave', (tester) async {
      final chat = server();
      await open(tester, chat, location: '/chat/rnd');
      await tester.tap(key('chat-settings'));
      await tester.pumpAndSettle();
      await tester.tap(key('mute-8h'));
      await tester.pumpAndSettle();
      await tester.tap(key('mute-completely'));
      await tester.pumpAndSettle();
      expect(chat.mutes, ['rnd:true:false:false', 'rnd:false:true:true']);
      await tester.tap(key('leave-space'));
      await tester.pumpAndSettle();
      expect(chat.spaces.any((s) => s.id == 'rnd'), isFalse);
    });

    testWidgets('the default channel cannot be left', (tester) async {
      await open(tester, server(), location: '/chat/gen');
      await tester.tap(key('chat-settings'));
      await tester.pumpAndSettle();
      expect(key('leave-space'), findsNothing);
      expect(key('notify-all'), findsOneWidget);
    });
  });
}
