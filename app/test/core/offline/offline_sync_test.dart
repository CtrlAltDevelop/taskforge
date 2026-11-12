import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/offline/read_cache.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/core/offline/keep_offline.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../../features/fields/fakes.dart' show FakeFieldsClient;
import '../../features/members/fakes.dart' show FakeMembersClient;
import '../../features/projects/fakes.dart' show FakeProjectsClient;
import '../../features/workflows/fakes.dart' show FakeWorkflowsClient;
import 'fakes.dart';

class _NoApi implements AuthApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Session extends AuthSession {
  _Session() : super(api: _NoApi(), store: MemoryTokenStore());

  var _status = AuthStatus.signedIn;

  @override
  AuthStatus get status => _status;

  void end() {
    _status = AuthStatus.signedOut;
    notifyListeners();
  }
}

void main() {
  late Harness h;
  late _Session session;
  late ProviderContainer container;

  setUp(() {
    h = Harness.create();
    session = _Session();
    container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWithValue(session),
        offlineStoreFutureProvider.overrideWithValue(Future.value(h.store)),
        rawTasksClientProvider.overrideWithValue(h.server.t),
        rawCommentsClientProvider.overrideWithValue(h.server.c),
        workspaceScopeProvider.overrideWithValue('w1'),
        syncClientProvider.overrideWithValue(null),
        workflowsClientProvider.overrideWithValue(FakeWorkflowsClient()),
        fieldsClientProvider.overrideWithValue(FakeFieldsClient()),
        membersClientProvider.overrideWithValue(FakeMembersClient()),
        projectsClientProvider.overrideWithValue(FakeProjectsClient()),
        reachabilityProbeProvider.overrideWithValue(() async {}),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await h.close();
  });

  group('the sync controller', () {
    test(
      'sends what waits when asked, and tells lists to read again',
      () async {
        final tasks = container.read(tasksClientProvider);
        h.server.reachable = false;
        container.read(networkProvider.notifier).failed();
        await tasks.create('w1', 'p1', title: 'Offline');
        expect(await h.store.queue('w1'), hasLength(1));

        h.server.reachable = true;
        final before = container.read(outboxDrainedProvider);
        final result = await container
            .read(offlineSyncProvider.notifier)
            .syncNow();

        expect(result.sent, 1);
        expect(h.server.sent, hasLength(1));
        expect(container.read(outboxDrainedProvider), before + 1);
        expect(container.read(networkProvider), isTrue); // it answered
      },
    );

    test('an empty outbox is a quiet pass', () async {
      final before = container.read(outboxDrainedProvider);
      final result = await container
          .read(offlineSyncProvider.notifier)
          .syncNow();
      expect(result.changedSomething, isFalse);
      expect(container.read(outboxDrainedProvider), before);
    });

    test('signing out empties the local copy and the outbox', () async {
      container.read(offlineSyncProvider);
      await h.store.put('w1', Kinds.task, 't', '{}');
      session.end();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await h.store.get('w1', Kinds.task, 't'), isNull);
    });
  });

  group('catching up after being offline', () {
    test('a kept project is read again when the connection is back', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      final keeper = container.read(keepOfflineProvider.notifier);
      container.read(offlineSyncProvider);
      await keeper.keep('p1');
      expect(await h.store.keptProjects('w1'), {'p1'});
      // The server goes away; somebody else renames the task meanwhile.
      container.read(networkProvider.notifier).failed();
      h.server.tasks['a'] = serverTask('a', 'Renamed', version: 2);

      final before = container.read(outboxDrainedProvider);
      container.read(networkProvider.notifier).worked(); // it is back
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(container.read(outboxDrainedProvider), greaterThan(before));
      final json = await h.store.get('w1', Kinds.task, 'a');
      expect(taskFromJson(json!).title, 'Renamed');
    });

    test(
      'open screens are told to read again even with nothing to send',
      () async {
        container.read(offlineSyncProvider);
        container.read(networkProvider.notifier).failed();
        final before = container.read(outboxDrainedProvider);
        container.read(networkProvider.notifier).worked();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(container.read(outboxDrainedProvider), greaterThan(before));
      },
    );
  });

  group('sign-out', () {
    test('a session that is signed out at launch is wiped', () async {
      await h.store.put('w1', Kinds.task, 't', '{}');
      session.end();
      container.read(offlineSyncProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await h.store.get('w1', Kinds.task, 't'), isNull);
      expect(h.store.sealed, isTrue); // late writes from before are refused
      await h.store.put('w1', Kinds.task, 'late', '{}');
      expect(await h.store.get('w1', Kinds.task, 'late'), isNull);
    });

    test('nothing is sent for a signed-out session', () async {
      await container.read(tasksClientProvider).create('w1', 'p1', title: 'x');
      session.end();
      final r = await container.read(offlineSyncProvider.notifier).syncNow();
      expect(r.changedSomething, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 50)); // the wipe
    });
  });

  group('client ids', () {
    test('are canonical UUIDs, as the server writes them back', () {
      final id = newClientId();
      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(newClientId(), isNot(id));
    });
  });

  group('the network monitor', () {
    test('starts online, goes offline on a failure, back on an answer', () {
      final net = container.read(networkProvider.notifier);
      expect(container.read(networkProvider), isTrue);
      net.failed();
      expect(container.read(networkProvider), isFalse);
      net.worked();
      expect(container.read(networkProvider), isTrue);
    });
  });

  group('the read cache', () {
    ReadCache cache({required bool Function() online}) => ReadCache(
      store: () async => h.store,
      online: online,
      failed: () => h.online = false,
      worked: () => h.online = true,
    );

    StringValue parse(List<int> b) => StringValue.fromBuffer(b);

    test('keeps an answer and shows it when the server is gone', () async {
      final c = cache(online: () => true);
      await c.through('w1', 'k', () async => StringValue(value: 'one'), parse);
      final again = await c.through(
        'w1',
        'k',
        () async => throw const SocketException('down'),
        parse,
      );
      expect(again.value, 'one');
      expect(h.online, isFalse);
    });

    test('answers from the copy without trying while offline', () async {
      final c = cache(online: () => false);
      await h.store.put(
        'w1',
        readCacheKind,
        'k',
        'CgNvbmU=', // StringValue(value: 'one')
      );
      var called = false;
      final r = await c.through('w1', 'k', () async {
        called = true;
        return StringValue(value: 'two');
      }, parse);
      expect(r.value, 'one');
      expect(called, isFalse);
    });

    test('nothing kept: the failure stands', () async {
      final c = cache(online: () => true);
      expect(
        c.through(
          'w1',
          'k',
          () async => throw const SocketException('down'),
          parse,
        ),
        throwsA(isA<SocketException>()),
      );
    });

    test('a refusal is not hidden by an old copy', () async {
      final c = cache(online: () => true);
      await c.through('w1', 'k', () async => StringValue(value: 'one'), parse);
      expect(
        c.through('w1', 'k', () async => throw StateError('refused'), parse),
        throwsStateError,
      );
    });

    test('clearing the cache forgets what was kept', () async {
      final c = cache(online: () => true);
      await c.through('w1', 'k', () async => StringValue(value: 'one'), parse);
      await h.store.clearCache();
      expect(await h.store.get('w1', readCacheKind, 'k'), isNull);
    });
  });
}
