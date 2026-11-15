import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/chat/data/chat_codecs.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart'
    show MentionPick, SendState;

import 'fakes.dart';

void main() {
  group('unread math', () {
    test('the badge sums unread of every space but the fully muted', () {
      final list = SpaceList(
        channels: [
          space('a', 'general', unread: 3),
          Space(
            id: 'm',
            kind: SpaceKind.channel,
            unreadCount: 9,
            mutedCompletely: true,
          ),
        ],
        groups: [space('g', 'g', kind: SpaceKind.group, unread: 2)],
        dms: [space('d', '', kind: SpaceKind.dm, unread: 1)],
      );
      expect(unreadTotal(list), 6);
    });

    test('first unread skips own and local messages and older ones', () {
      final read = t0.add(const Duration(minutes: 5));
      final timeline = [
        msg('1', 's', 'old', at: t0),
        msg(
          '2',
          's',
          'mine',
          author: 'u1',
          at: read.add(const Duration(minutes: 1)),
        ),
        msg('3', 's', 'new', at: read.add(const Duration(minutes: 2))),
        msg('4', 's', 'newer', at: read.add(const Duration(minutes: 3))),
      ];
      expect(firstUnreadId(timeline, read, 'u1'), '3');
      expect(unreadAfter(timeline, read, 'u1'), 2);
    });

    test('nothing is "new" when nothing was ever read', () {
      expect(firstUnreadId([msg('1', 's', 'a')], null, 'u1'), isNull);
      expect(unreadAfter([msg('1', 's', 'a')], null, 'u1'), 0);
    });

    test('no divider when everything is read', () {
      final timeline = [msg('1', 's', 'a', at: t0)];
      expect(
        firstUnreadId(timeline, t0.add(const Duration(hours: 1)), 'u1'),
        isNull,
      );
    });
  });

  group('messages', () {
    test('upsert keeps oldest first and replaces by id', () {
      var list = <ChatMessage>[];
      list = upsertMessage(
        list,
        msg('b', 's', 'two', at: t0.add(const Duration(minutes: 1))),
      );
      list = upsertMessage(list, msg('a', 's', 'one', at: t0));
      expect([for (final m in list) m.id], ['a', 'b']);
      list = upsertMessage(list, msg('a', 's', 'one!', version: 2, at: t0));
      expect(list.length, 2);
      expect(list.first.version, 2);
    });

    test('an older copy never replaces a newer one', () {
      final list = upsertMessage([
        msg('a', 's', 'v2', version: 2),
      ], msg('a', 's', 'v1'));
      expect(list.single.version, 2);
    });

    test('a local draft is replaced by the saved message with its id', () {
      final draft = msg(
        'x',
        's',
        'hi',
        author: 'u1',
      ).copyWith(sendState: SendState.sending);
      final list = upsertMessage([
        draft,
      ], msg('x', 's', 'hi', author: 'u1', version: 1));
      expect(list.single.sendState, SendState.sent);
    });

    test('reactions toggle for one person without touching the original', () {
      final m = msg('a', 's', 'hi');
      final on = withReaction(m, '👍', 'u1', on: true);
      expect(on.reactedBy('👍', 'u1'), isTrue);
      expect(m.reactions, isEmpty);
      final off = withReaction(on, '👍', 'u1', on: false);
      expect(off.reactions, isEmpty);
    });

    test('top level and replies split the thread out', () {
      final all = [msg('a', 's', 'x'), msg('b', 's', 'y', parent: 'a')];
      expect(topLevel(all).single.id, 'a');
      expect(repliesOf(all, 'a').single.id, 'b');
    });

    test('an author may edit for 24 hours, nobody else, no placeholder', () {
      final m = msg('a', 's', 'x', author: 'u1', at: t0);
      expect(
        canEditMessage(m, 'u1', t0.add(const Duration(hours: 23))),
        isTrue,
      );
      expect(
        canEditMessage(m, 'u1', t0.add(const Duration(hours: 25))),
        isFalse,
      );
      expect(canEditMessage(m, 'u2', t0), isFalse);
      expect(canEditMessage(m.copyWith(deleted: true), 'u1', t0), isFalse);
    });

    test('channel and here mentions are broadcasts', () {
      final body = bodyFromComposer('hi @channel ', const [
        MentionPick('channel', 'channel'),
      ]);
      expect(isBroadcast(body), isTrue);
      final one = bodyFromComposer('hi @Ana ', const [
        MentionPick('u-ana', 'Ana'),
      ]);
      expect(isBroadcast(one), isFalse);
    });
  });

  group('space list', () {
    test('withSpace replaces in place and adds new ones to their group', () {
      var list = SpaceList(channels: [space('a', 'general')]);
      list = list.withSpace(space('a', 'general', unread: 4));
      expect(list.channels.single.unreadCount, 4);
      list = list.withSpace(space('g', 'team', kind: SpaceKind.group));
      list = list.withSpace(space('d', '', kind: SpaceKind.dm));
      expect(list.groups.length, 1);
      expect(list.dms.length, 1);
      expect(list.byId('d'), isNotNull);
    });

    test('matching searches names, direct message people and task chats', () {
      final list = SpaceList(
        channels: [space('a', 'general'), space('b', 'random')],
        dms: [space('d', '', kind: SpaceKind.dm, peer: 'u2')],
        taskChats: const [
          TaskChatRef(
            taskId: 't',
            projectId: 'p',
            title: 'Fix login',
            displayId: 'WEB-1',
          ),
        ],
      );
      String dm(Space s) => 'Hank Hill';
      expect(list.matching('gen', dm).channels.single.id, 'a');
      expect(list.matching('hank', dm).dms.length, 1);
      expect(list.matching('hank', dm).channels, isEmpty);
      expect(list.matching('web-1', dm).taskChats.length, 1);
      expect(list.matching('', dm).channels.length, 2);
    });

    test('flags: muted, can post, can join', () {
      final now = t0;
      expect(
        Space(
          id: 'a',
          kind: SpaceKind.channel,
          mutedUntil: now.add(const Duration(hours: 1)),
        ).isMuted(now),
        isTrue,
      );
      expect(
        Space(
          id: 'a',
          kind: SpaceKind.channel,
          mutedUntil: now.subtract(const Duration(hours: 1)),
        ).isMuted(now),
        isFalse,
      );
      expect(space('a', 'x', archived: true).canPost, isFalse);
      expect(space('a', 'x', readOnly: true).canPost, isFalse);
      expect(space('a', 'x', joined: false).canJoin, isTrue);
      expect(
        space('a', 'x', kind: SpaceKind.group, joined: false).canJoin,
        isFalse,
      );
    });
  });

  group('codecs', () {
    test('a message survives the local copy', () {
      final m = withReaction(
        msg('a', 's', 'hi', parent: 'p'),
        '👍',
        'u1',
        on: true,
      );
      final back = chatMessageFromJson(chatMessageToJson(m));
      expect(back.id, 'a');
      expect(back.parentId, 'p');
      expect(back.body, m.body);
      expect(back.reactedBy('👍', 'u1'), isTrue);
    });

    test('a space survives the local copy', () {
      final s = space('a', 'general', unread: 2, lastRead: t0, isDefault: true);
      final back = spaceFromJson(spaceToJson(s));
      expect(back.unreadCount, 2);
      expect(back.lastReadAt, t0);
      expect(back.isDefault, isTrue);
      expect(back.kind, SpaceKind.channel);
    });
  });
}
