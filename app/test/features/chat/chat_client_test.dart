import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:taskforge/features/chat/data/chat_client.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/gen/infrastructure/chat/grpc/chat.pbgrpc.dart' as pb;

String _bin(String text) => base64.encode(utf8.encode(text));

void main() {
  group('errors', () {
    test('a broadcast confirmation carries how many would be told', () {
      final e = mapChatError(
        GrpcError.custom(
          StatusCode.failedPrecondition,
          'CHAT_BROADCAST_CONFIRM: confirm',
          null,
          null,
        ),
      );
      expect(e.failure, ChatFailure.broadcastConfirm);
      final withCount = mapChatError(
        GrpcError.custom(
          StatusCode.failedPrecondition,
          'CHAT_BROADCAST_CONFIRM: confirm',
          null,
          null,
          {'x-error-member_count-bin': _bin('72')},
        ),
      );
      expect(withCount.memberCount, 72);
    });

    test('a mention of somebody outside the space names them', () {
      final e = mapChatError(
        GrpcError.custom(
          StatusCode.invalidArgument,
          'MENTION_NO_ACCESS: nope',
          null,
          null,
          {'x-error-users-bin': _bin('u1,u2')},
        ),
      );
      expect(e.failure, ChatFailure.mentionNoAccess);
      expect(e.people, ['u1', 'u2']);
    });

    test('other errors map like the rest of the app', () {
      expect(
        mapChatError(GrpcError.unavailable('down')).failure,
        ChatFailure.network,
      );
      expect(
        mapChatError(GrpcError.notFound('gone')).failure,
        ChatFailure.notFound,
      );
      expect(mapChatError(StateError('x')).failure, ChatFailure.other);
      const own = ChatException(ChatFailure.archived);
      expect(mapChatError(own), same(own));
    });
  });

  group('wire to domain', () {
    test('a space', () {
      final s = spaceFromPb(
        pb.Space(
          id: 's',
          kind: 'dm',
          name: '',
          unreadCount: 3,
          lastReadAt: '2026-11-12T10:00:00Z',
          peerId: 'u2',
          readOnly: true,
          mutedCompletely: true,
        ),
      );
      expect(s.kind, SpaceKind.dm);
      expect(s.unreadCount, 3);
      expect(s.lastReadAt, DateTime.utc(2026, 11, 12, 10));
      expect(s.lastMessageAt, isNull);
      expect(s.peerId, 'u2');
      expect(s.readOnly, isTrue);
      expect(s.mutedCompletely, isTrue);
    });

    test('a message with reactions and an edit time', () {
      final m = messageFromPb(
        pb.Message(
          id: 'm',
          spaceId: 's',
          authorId: 'u2',
          authorName: 'Hank',
          parentId: 'p',
          createdAt: '2026-11-12T10:00:00Z',
          editedAt: '2026-11-12T10:05:00Z',
          version: 2,
          reactions: [
            pb.ReactionResponse(emoji: '👍', userIds: ['u1']),
          ],
        ),
      );
      expect(m.isReply, isTrue);
      expect(m.edited, isTrue);
      expect(m.reactedBy('👍', 'u1'), isTrue);
      expect(m.version, 2);
    });
  });
}
