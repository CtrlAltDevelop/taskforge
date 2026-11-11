import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_models.dart';

import 'fakes.dart';

Map<String, dynamic> eventFrame(
  int cursor, {
  String type = 'task.updated',
  String origin = '',
  int version = 2,
  String entity = 't1',
}) => {
  'type': 'event',
  'room': 'proj:p1',
  'event': {
    'type': type,
    'workspace': 'w1',
    'project': 'p1',
    'entity_id': entity,
    'version': version,
    'actor': 'u1',
    'origin': origin,
    'ts': '2026-11-11T10:00:00Z',
    'cursor': cursor,
  },
};

SyncEvent entry(int cursor, {String entity = 't1'}) => SyncEvent(
  type: 'task.updated',
  project: 'p1',
  entityId: entity,
  version: 2,
  cursor: cursor,
);

class Harness {
  Harness({
    int head = 100,
    Future<CatchUp> Function(int)? catchUp,
    double jitter = 1,
  }) {
    client = SyncClient(
      connector: connector,
      url: Uri.parse('ws://test/ws/sync'),
      token: () async => tokenValue,
      head: () async => head,
      catchUp: (cursor) async {
        catchUps.add(cursor);
        return catchUp == null ? const CatchUp() : catchUp(cursor);
      },
      random: FixedRandom(jitter),
      timers: timers.call,
      clientId: 'client-1',
      refreshToken: () async {
        refreshes++;
        return 'tok-refreshed';
      },
    );
    client.events.listen((e) {
      // The first connection says "read the screens again" once: not what these tests are about.
      if (e.isGap && !firstGapSeen) {
        firstGapSeen = true;
        firstGaps++;
        return;
      }
      events.add(e);
    });
    client.presence.listen(presence.add);
    client.lost.listen(lost.add);
    client.state.addListener(() => states.add(client.state.value));
  }

  final connector = FakeConnector();
  final timers = ManualTimers();
  late final SyncClient client;
  String? tokenValue = 'tok-1';
  final catchUps = <int>[];
  var refreshes = 0;
  final events = <SyncEvent>[];
  var firstGapSeen = false;
  var firstGaps = 0;
  final presence = <PresenceUpdate>[];
  final lost = <RoomLost>[];
  final states = <SyncState>[];

  /// Connects and completes the handshake.
  Future<FakeConnection> goLive() async {
    client.start();
    await settle();
    final c = connector.last..open();
    await settle();
    c.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await settle();
    return c;
  }

  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

void main() {
  test(
    'signs in first, then joins its rooms, then goes live from the head',
    () async {
      final h = Harness(head: 100)..client.subscribe('ws:w1');

      final c = await h.goLive();

      expect(c.sent.first['type'], 'authenticate');
      expect(c.sent.first['token'], 'tok-1');
      expect(c.sentOf('subscribe').map((f) => f['room']), ['ws:w1']);
      expect(h.client.state.value, SyncState.live);
      expect(h.client.cursor, 100);
      expect(h.catchUps, isEmpty); // first connect: nothing to catch up
      expect(h.states, [SyncState.connecting, SyncState.live]);
      expect(h.firstGaps, 1); // the screens are asked to read again, once
    },
  );

  test('nothing is sent before the server has said ready', () async {
    final h = Harness();
    h.client.start();
    await h.settle();
    final c = h.connector.last..open();
    await h.settle();

    h.client.subscribe('proj:p1');
    h.client.sendPresence('p1', 't1', 'viewing');
    h.client.subscribe('proj:p2');

    expect(c.sentTypes, ['authenticate']);

    c.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await h.settle();

    expect(c.sentOf('subscribe').map((f) => f['room']).toSet(), {
      'proj:p1',
      'proj:p2',
    });
  });

  test(
    'a room asked for while live is joined at once, and left on request',
    () async {
      final h = Harness();
      final c = await h.goLive();

      h.client.subscribe('proj:p1');
      h.client.subscribe('proj:p1'); // twice: once
      h.client.unsubscribe('proj:p1');

      expect(c.sentTypes, ['authenticate', 'subscribe', 'unsubscribe']);
      expect(h.client.rooms, isEmpty);
    },
  );

  test('events arrive once each and move the cursor', () async {
    final h = Harness();
    final c = await h.goLive();

    c.say(eventFrame(101));
    c.say(eventFrame(101)); // the same change by its other room
    c.say(eventFrame(103, type: 'task.created', version: 1, entity: 't2'));
    await h.settle();

    expect(h.events.map((e) => (e.type, e.entityId, e.cursor)), [
      ('task.updated', 't1', 101),
      ('task.created', 't2', 103),
    ]);
    expect(h.client.cursor, 103);
  });

  test('presence frames say who is on the task and who is typing', () async {
    final h = Harness();
    final c = await h.goLive();

    c.say({
      'type': 'presence',
      'project': 'p1',
      'task': 't1',
      'users': [
        {'id': 'a', 'editing': false},
        {'id': 'b', 'editing': true},
      ],
    });
    await h.settle();

    expect(h.presence.single.task, 't1');
    expect(h.presence.single.users, [
      const PresenceUser('a'),
      const PresenceUser('b', editing: true),
    ]);
  });

  test('a dropped socket means reconnecting, then back with the rooms and what was missed', () async {
    final h = Harness(
      catchUp: (cursor) async => CatchUp(
        events: [
          entry(108),
          entry(109, entity: 't2'),
        ],
        head: 109,
      ),
    )..client.subscribe('proj:p1');
    final first = await h.goLive();
    first.say(eventFrame(105));
    await h.settle();

    await first.drop();
    await h.settle();

    expect(h.client.state.value, SyncState.reconnecting);
    final retry = h.timers.pending.firstWhere(
      (t) => t.delay.inMilliseconds >= 500 && t.delay.inMilliseconds <= 1000,
    );
    retry.fire();
    await h.settle();
    final second = h.connector.last..open();
    await h.settle();
    second.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await h.settle();

    expect(h.connector.connections, hasLength(2));
    expect(second.sent.first['type'], 'authenticate');
    expect(second.sentOf('subscribe').map((f) => f['room']), ['proj:p1']);
    expect(h.catchUps, [
      105,
    ]); // the cursor it holds (the server rereads a little before it)
    expect(h.events.map((e) => e.cursor), [105, 108, 109]);
    expect(h.client.state.value, SyncState.live);
    expect(h.client.cursor, 109);
  });

  test('a hundred changes made while away all arrive, none twice', () async {
    final missed = [for (var i = 101; i <= 200; i++) entry(i, entity: 'e$i')];
    final h = Harness(
      head: 100,
      catchUp: (_) async => CatchUp(events: missed, head: 200),
    );
    final first = await h.goLive();
    for (var i = 91; i <= 100; i++) {
      first.say(eventFrame(i, entity: 'old$i')); // seen before the drop
    }
    await h.settle();
    h.events.clear();
    await first.drop();
    await h.settle();
    h.timers.pending.last.fire();
    await h.settle();
    h.connector.last.open();
    await h.settle();
    h.connector.last.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await h.settle();

    expect(h.events.map((e) => e.cursor), [for (var i = 101; i <= 200; i++) i]);
    expect(h.client.cursor, 200);
  });

  test(
    'a cursor older than the log asks for everything to be read again',
    () async {
      final h = Harness(
        catchUp: (_) async => const CatchUp(gap: true, head: 500),
      );
      final first = await h.goLive();
      await first.drop();
      await h.settle();
      h.timers.pending.last.fire();
      await h.settle();
      h.connector.last.open();
      await h.settle();
      h.connector.last.say({
        'type': 'ready',
        'user': {'id': 'u1'},
      });
      await h.settle();

      expect(h.events.single.isGap, isTrue);
      expect(h.client.cursor, 500);
      expect(h.client.state.value, SyncState.live);
    },
  );

  test('the wait before each retry grows, is capped, and is jittered', () {
    final low = Harness(jitter: 0).client;
    final high = Harness(jitter: 1).client;

    expect(
      [for (var n = 1; n <= 7; n++) high.retryDelay(n).inSeconds],
      [1, 2, 4, 8, 16, 30, 30],
    );
    expect(
      [for (var n = 1; n <= 7; n++) low.retryDelay(n).inMilliseconds],
      [500, 1000, 2000, 4000, 8000, 15000, 15000],
    );
  });

  test('a handshake that fails is tried again', () async {
    final h = Harness();
    h.client.start();
    await h.settle();

    h.connector.last.failToOpen();
    await h.settle();

    expect(h.client.state.value, SyncState.reconnecting);
    expect(h.timers.pending, isNotEmpty);
  });

  test('a room the server took away is not asked for again', () async {
    final h = Harness()..client.subscribe('proj:p1');
    final c = await h.goLive();

    c.say({'type': 'unsubscribed', 'room': 'proj:p1', 'reason': 'access'});
    await h.settle();

    expect(h.lost.single.room, 'proj:p1');
    expect(h.lost.single.reason, 'access');
    expect(h.client.rooms, isEmpty);
  });

  test('a refused room is reported and dropped', () async {
    final h = Harness();
    final c = await h.goLive();
    h.client.subscribe('proj:p9');

    c.say({'type': 'error', 'code': 'forbidden', 'room': 'proj:p9'});
    await h.settle();

    expect(h.lost.single.reason, 'forbidden');
    expect(h.client.rooms, isEmpty);
  });

  test('a heartbeat goes out on schedule', () async {
    final h = Harness();
    final c = await h.goLive();

    h.timers.waiting(const Duration(seconds: 25)).fire();

    expect(c.sentOf('ping'), hasLength(1));
    expect(
      h.timers.pending.any((t) => t.delay == const Duration(seconds: 25)),
      isTrue,
    );
  });

  test('a connection that goes silent is treated as dead', () async {
    final h = Harness();
    final c = await h.goLive();

    h.timers.waiting(const Duration(seconds: 70)).fire();
    await h.settle();

    expect(h.client.state.value, SyncState.reconnecting);
    expect(c.closed, isTrue);
  });

  test('anything heard resets the silence timer', () async {
    final h = Harness();
    final c = await h.goLive();
    final before = h.timers.waiting(const Duration(seconds: 70));

    c.say({'type': 'pong'});
    await h.settle();

    expect(before.cancelled, isTrue);
    expect(h.timers.waiting(const Duration(seconds: 70)).isActive, isTrue);
  });

  test('stopping closes the socket and does not reconnect', () async {
    final h = Harness();
    final c = await h.goLive();

    await h.client.stop();
    await c.drop();
    await h.settle();

    expect(h.client.state.value, SyncState.offline);
    expect(c.closed, isTrue);
    expect(h.timers.pending, isEmpty);
    expect(h.client.cursor, isNull);
  });

  test(
    'a late frame from a connection that was already replaced is ignored',
    () async {
      final h = Harness();
      final first = await h.goLive();
      h.timers.waiting(const Duration(seconds: 70)).fire(); // judged dead
      await h.settle();
      h.timers.pending.last.fire();
      await h.settle();

      first.say(eventFrame(300));
      await h.settle();

      expect(h.events, isEmpty);
    },
  );

  test(
    'signs in with its own id and learns the tag its changes carry',
    () async {
      final h = Harness();
      h.client.start();
      await h.settle();
      final c = h.connector.last..open();
      await h.settle();
      await h.settle();

      expect(c.sent.first, {
        'type': 'authenticate',
        'token': 'tok-1',
        'client_id': 'client-1',
      });

      c.say({
        'type': 'ready',
        'user': {'id': 'u1'},
        'origin': 'tag-abc',
      });
      await h.settle();

      expect(h.client.ownOrigin, 'tag-abc');
    },
  );

  test('nothing is read before every room is joined', () async {
    final h = Harness()..client.subscribe('proj:p1');
    h.client.start();
    await h.settle();
    final first = h.connector.last..open();
    await h.settle();
    first.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await h.settle();
    await first.drop();
    await h.settle();
    h.timers.pending.last.fire();
    await h.settle();
    final second = h.connector.last
      ..answerSubscribe = false
      ..open();
    await h.settle();
    second.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await h.settle();

    expect(second.sentOf('subscribe'), hasLength(1));
    expect(h.catchUps, isEmpty); // waiting for the server to say it has joined
    expect(h.client.state.value, SyncState.reconnecting);

    second.say({'type': 'subscribed', 'room': 'proj:p1'});
    await h.settle();

    expect(h.catchUps, hasLength(1));
    expect(h.client.state.value, SyncState.live);
  });

  test('the cursor moves past entries this person cannot see', () async {
    final h = Harness(catchUp: (_) async => const CatchUp(head: 400));
    final first = await h.goLive();
    await first.drop();
    await h.settle();
    h.timers.pending.last.fire();
    await h.settle();
    h.connector.last.open();
    await h.settle();
    h.connector.last.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await h.settle();

    expect(h.client.cursor, 400);
  });

  test(
    'a socket that closes while it is catching up does not go live',
    () async {
      final slow = Completer<CatchUp>();
      final h = Harness(catchUp: (_) => slow.future);
      final first = await h.goLive();
      await first.drop();
      await h.settle();
      h.timers.pending.last.fire();
      await h.settle();
      final second = h.connector.last..open();
      await h.settle();
      second.say({
        'type': 'ready',
        'user': {'id': 'u1'},
      });
      await h.settle();

      await second.drop(); // closes while the catch-up is still being read
      await h.settle();
      slow.complete(const CatchUp());
      await h.settle();

      expect(h.client.state.value, SyncState.reconnecting);
      expect(
        h.timers.pending.where((t) => t.delay == const Duration(seconds: 25)),
        isEmpty,
      );
    },
  );

  test('the wait grows when catching up keeps outliving the socket', () async {
    final slow = Completer<CatchUp>();
    final h = Harness(catchUp: (_) => slow.future);
    final first = await h.goLive();
    await first.drop();
    await h.settle();
    final before = h.timers.pending.last.delay;
    h.timers.pending.last.fire();
    await h.settle();
    final second = h.connector.last..open();
    await h.settle();
    second.say({
      'type': 'ready',
      'user': {'id': 'u1'},
    });
    await h.settle();
    await second.drop();
    await h.settle();
    slow.complete(const CatchUp());
    await h.settle();

    expect(h.timers.pending.last.delay, greaterThan(before));
  });

  test(
    'the echo of its own unsubscribe does not undo a join made since',
    () async {
      final h = Harness();
      final c = await h.goLive();
      h.client.subscribe('proj:p1');
      h.client.unsubscribe('proj:p1');
      h.client.subscribe('proj:p1');

      c.say({'type': 'unsubscribed', 'room': 'proj:p1', 'reason': 'requested'});
      await h.settle();

      expect(h.client.rooms, {'proj:p1'});
      expect(h.lost, isEmpty);
    },
  );

  test(
    'refused as unauthenticated, the next attempt gets a freshly renewed token',
    () async {
      final h = Harness();
      h.client.start();
      await h.settle();
      final c = h.connector.last..open();
      await h.settle();
      c.say({'type': 'error', 'code': 'unauthenticated'});
      await h.settle();
      h.timers.pending.last.fire();
      await h.settle();
      h.connector.last.open();
      await h.settle();
      await h.settle();

      expect(h.refreshes, 1);
      expect(h.connector.last.sent.first['token'], 'tok-refreshed');
    },
  );
}
