import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/application/live_alerts.dart';
import 'package:taskforge/features/inbox/application/push.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../../core/sync/fakes.dart';
import '../workspaces/fakes.dart';
import 'fakes.dart';

class Harness {
  Harness({
    required this.container,
    required this.connector,
    required this.inbox,
    required this.local,
    required this.session,
  });

  final ProviderContainer container;
  final FakeConnector connector;
  final FakeInboxClient inbox;
  final FakeLocalNotifier local;
  final AuthSession session;
  Uri where = Uri.parse('/');
  var _cursor = 30;

  FakeConnection get socket => connector.last;

  /// The server says a notification event happened.
  Future<void> hear({
    String workspace = 'w1',
    String origin = 'someone-else',
  }) async {
    socket.say({
      'type': 'event',
      'room': 'user:u1',
      'event': {
        'type': 'notification.new',
        'workspace': workspace,
        'project': '',
        'entity_id': 'u1',
        'version': 0,
        'actor': 'u2',
        'origin': origin,
        'cursor': ++_cursor, // the feed drops a cursor it has seen
      },
    });
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await pumpEventQueue();
  }
}

Future<Harness> start({
  List<InboxNotificationSeed> items = const [],
  FakeInboxClient? client,
  PushToken? token,
}) async {
  final store = MemoryTokenStore();
  await store.write(
    const AuthTokens(accessToken: 'a.b.c', refreshToken: 'r', sessionId: 's'),
  );
  final session = AuthSession(api: MockAuthApi(), store: store);
  await session.restore();
  final connector = FakeConnector();
  final inbox = client ?? FakeInboxClient();
  final local = FakeLocalNotifier();
  late Harness h;
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWithValue(session),
      workspaceScopeProvider.overrideWithValue('w1'),
      inboxClientProvider.overrideWithValue(inbox),
      localNotifierProvider.overrideWithValue(local),
      pushTokenSourceProvider.overrideWithValue(FakePushTokenSource(token)),
      inboxNowProvider.overrideWithValue(() => noon),
      alertCoalesceProvider.overrideWithValue(const Duration(milliseconds: 5)),
      alertLocationProvider.overrideWithValue(() => h.where),
      syncClientProvider.overrideWith((ref) {
        final client = SyncClient(
          connector: connector,
          url: Uri.parse('ws://test/ws/sync'),
          token: () async => 'tok',
          head: () async => 10,
          catchUp: (_) async => const CatchUp(),
          timers: ManualTimers().call,
        )..subscribe('ws:w1');
        client.start();
        ref.onDispose(() => unawaited(client.dispose()));
        return client;
      }),
    ],
  );
  addTearDown(container.dispose);
  h = Harness(
    container: container,
    connector: connector,
    inbox: inbox,
    local: local,
    session: session,
  );
  container.read(
    liveAlertsProvider,
  ); // the app watches it for as long as it runs
  await pumpEventQueue();
  h.socket
    ..open()
    ..say({
      'type': 'ready',
      'user': {'id': 'u1'},
      'origin': 'tag-me',
    });
  await pumpEventQueue();
  return h;
}

typedef InboxNotificationSeed = Object;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a new assignment shows as a system notification', () async {
    final h = await start();
    h.inbox.items.add(note('n1', 'task.assigned', updatedAt: noon));

    await h.hear();

    expect(h.local.shown, hasLength(1));
    final shown = h.local.shown.single;
    expect(shown.title, 'Assigned to you');
    expect(shown.body, 'Hank assigned you WEB-1 Alpha');
    expect(shown.payload, 'p1|a');
  });

  test(
    'a kind the person has not asked to be pinged about stays quiet',
    () async {
      final h = await start();
      h.inbox.items.add(note('n1', 'user.mentioned', updatedAt: noon));

      await h.hear();

      expect(h.local.shown, isEmpty); // inbox only, by their own choice
    },
  );

  test('the same one is shown once, and again only when it grows', () async {
    final h = await start();
    h.inbox.items.add(note('n1', 'task.assigned', updatedAt: noon));
    await h.hear();
    await h.hear(); // heard again, nothing new
    expect(h.local.shown, hasLength(1));

    h.inbox.items[0] = note('n1', 'task.assigned', updatedAt: noon, count: 3);
    await h.hear();
    expect(h.local.shown, hasLength(2));
  });

  test('what was already old when the app started is not announced', () async {
    final h = await start();
    h.inbox.items.add(
      note(
        'n1',
        'task.assigned',
        updatedAt: noon.subtract(const Duration(hours: 5)),
      ),
    );

    await h.hear();

    expect(h.local.shown, isEmpty);
  });

  test('nothing is shown for the task the person is looking at', () async {
    final h = await start();
    h.where = Uri.parse('/projects/p1?task=a');
    h.inbox.items.add(note('n1', 'task.assigned', updatedAt: noon));

    await h.hear();
    expect(h.local.shown, isEmpty);

    // Another task: it is shown.
    h.inbox.items.add(note('n2', 'task.assigned', task: 'b', updatedAt: noon));
    await h.hear();
    expect(h.local.shown.map((s) => s.payload), ['p1|b']);
  });

  test('nor while the inbox of that workspace is open', () async {
    final h = await start();
    h.where = Uri.parse('/inbox');
    h.inbox.items.add(note('n1', 'task.assigned', updatedAt: noon));

    await h.hear();

    expect(h.local.shown, isEmpty);
  });

  test('but with the app in the background it always is', () async {
    final h = await start();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    addTearDown(
      () => binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed),
    );
    h.where = Uri.parse('/projects/p1?task=a');
    h.inbox.items.add(note('n1', 'task.assigned', updatedAt: noon));

    await h.hear();

    expect(h.local.shown, hasLength(1));
  });

  test('this app\'s own events and a failing server show nothing', () async {
    final h = await start();
    h.inbox.items.add(note('n1', 'task.assigned', updatedAt: noon));

    await h.hear(origin: 'tag-me');
    expect(h.local.shown, isEmpty);

    h.inbox.failReads = true;
    await h.hear(); // must not throw anywhere
    expect(h.local.shown, isEmpty);
  });

  test('another workspace\'s notification is looked up there', () async {
    final h = await start();
    h.inbox.items.add(
      note('n1', 'task.assigned', workspace: 'w2', updatedAt: noon),
    );

    await h.hear(workspace: 'w2');

    expect(h.inbox.lists.any((l) => l.ws == 'w2'), isTrue);
    expect(h.local.shown, hasLength(1));
  });

  test('tapping a system notification leads to its task', () {
    expect(routeForPayload('p1|a'), '/projects/p1?task=a');
    expect(routeForPayload('p 1|a&b'), '/projects/p%201?task=a%26b');
    expect(routeForPayload('p1|'), isNull);
    expect(routeForPayload('nonsense'), isNull);
    expect(routeForPayload(''), isNull);
  });

  group('the device', () {
    test('is registered for push when there is a token, once', () async {
      final h = await start(token: const PushToken('ios', 'tok-9'));
      await pumpEventQueue();

      expect(h.inbox.registered, [(platform: 'ios', token: 'tok-9')]);

      await h.container.read(pushRegistrarProvider).register();
      expect(h.inbox.registered, hasLength(1)); // not again
    });

    test('is dropped at sign-out', () async {
      final h = await start(token: const PushToken('android', 'tok-1'));
      await pumpEventQueue();

      await h.session.signOut();
      await pumpEventQueue();

      expect(h.inbox.unregistered, ['tok-1']);
    });

    test('with no token source nothing is registered or dropped', () async {
      final h = await start();
      await pumpEventQueue();
      await h.session.signOut();
      await pumpEventQueue();

      expect(h.inbox.registered, isEmpty);
      expect(h.inbox.unregistered, isEmpty);
    });

    test('a refusing server never breaks registering', () async {
      final h = await start(token: const PushToken('ios', 't'));
      final registrar = PushRegistrar(
        _Refusing(),
        FakePushTokenSource(const PushToken('ios', 't')),
      );

      expect(await registrar.register(), isFalse);
      await registrar.unregister(); // nothing was registered: nothing to drop
      expect(h.local.shown, isEmpty);
    });

    test('the system is asked once the person has agreed', () async {
      final h = await start(token: const PushToken('ios', 't'));
      final ok = await h.container.read(pushPermissionProvider.notifier).ask();

      expect(ok, isTrue);
      expect(h.container.read(pushPermissionProvider), isTrue);
      expect(h.local.permissionAsks, 1);
    });

    test('and a "no" is remembered as a no', () async {
      final h = await start();
      h.local.grant = false;

      expect(
        await h.container.read(pushPermissionProvider.notifier).ask(),
        isFalse,
      );
      expect(h.container.read(pushPermissionProvider), isFalse);
    });
  });
}

class _Refusing extends FakeInboxClient {
  @override
  Future<void> registerDevice(String platform, String token) async =>
      throw StateError('no');
}
