import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/presentation/offline_banner.dart';
import 'package:taskforge/core/offline/presentation/offline_screen.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';

class _NoApi implements AuthApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Session extends AuthSession {
  _Session() : super(api: _NoApi(), store: MemoryTokenStore());

  @override
  AuthStatus get status => AuthStatus.signedIn;
}

OutboxEntry _entry(
  String id,
  OutboxOp op,
  Map<String, dynamic> payload, {
  OutboxEntity entity = OutboxEntity.task,
}) => OutboxEntry(
  workspaceId: 'w1',
  projectId: 'p1',
  entity: entity,
  entityId: id,
  op: op,
  payload: payload,
  mutationId: 'm-$id',
  createdAt: DateTime.utc(2026, 11, 12),
  expectedVersion: 1,
);

void main() {
  late Harness h;
  ProviderContainer? shown;

  setUp(() => h = Harness.create());

  /// A widget test that closes what it opened before the checks for stray
  /// timers (the sync controller keeps one).
  void ui(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      // Real time: the database's streams close on a real timer.
      await tester.runAsync(() async {
        shown?.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      shown = null;
    });
  }

  Future<ProviderContainer> show(WidgetTester tester, Widget child) async {
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWithValue(_Session()),
        offlineStoreFutureProvider.overrideWithValue(Future.value(h.store)),
        rawTasksClientProvider.overrideWithValue(h.server.t),
        rawCommentsClientProvider.overrideWithValue(h.server.c),
        workspaceScopeProvider.overrideWithValue('w1'),
        syncClientProvider.overrideWithValue(null),
        reachabilityProbeProvider.overrideWithValue(() async {}),
        projectsProvider.overrideWith(
          (ref, _) async => const ProjectCatalog(
            projects: [Project(id: 'p1', name: 'Apollo', key: 'APO')],
            featureInfo: [],
          ),
        ),
      ],
    );
    shown = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    return container;
  }

  /// Lets the database answer (it is real I/O, outside the fake clock).
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }

  Future<void> seed(WidgetTester tester, Future<void> Function() fill) async {
    await tester.runAsync(fill);
  }

  tearDown(() async {
    // Streams of the database wind down on a timer.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await h.close();
  });

  group('the banner', () {
    ui('says nothing when all is sent and the server is there', (tester) async {
      await show(tester, const OfflineBanner());
      await settle(tester);
      expect(find.byKey(const Key('offline-banner')), findsNothing);
    });

    ui('offline with changes waiting says so and counts them', (tester) async {
      await seed(tester, () async {
        await h.store.enqueue(_entry('a', OutboxOp.update, {'title': 'X'}));
        await h.store.enqueue(_entry('b', OutboxOp.update, {'title': 'Y'}));
      });
      final container = await show(tester, const OfflineBanner());
      container.read(networkProvider.notifier).failed();
      await settle(tester);
      expect(find.textContaining('You are offline'), findsOneWidget);
      expect(find.textContaining('2 waiting'), findsOneWidget);
      expect(find.byKey(const Key('offline-sync-now')), findsNothing);
    });

    ui('back online it offers to send now', (tester) async {
      await seed(
        tester,
        () => h.store.enqueue(_entry('a', OutboxOp.update, {'title': 'X'})),
      );
      await show(tester, const OfflineBanner());
      await settle(tester);
      expect(find.textContaining('1 change waits'), findsOneWidget);
      expect(find.byKey(const Key('offline-sync-now')), findsOneWidget);
    });

    ui('a change that needs a decision offers the review', (tester) async {
      await seed(tester, () async {
        await h.store.enqueue(_entry('a', OutboxOp.update, {'title': 'X'}));
        final id = (await h.store.queue('w1')).single.id;
        await h.store.setState(id, OutboxState.rejected, error: 'No.');
      });
      await show(tester, const OfflineBanner());
      await settle(tester);
      expect(find.textContaining('needs your attention'), findsOneWidget);
      expect(find.byKey(const Key('offline-review')), findsOneWidget);
    });
  });

  group('the pending mark', () {
    ui('shows on what waits and on nothing else', (tester) async {
      await seed(
        tester,
        () => h.store.enqueue(_entry('a', OutboxOp.update, {'title': 'X'})),
      );
      await show(
        tester,
        const Column(
          children: [
            PendingMark(id: 'a'),
            PendingMark(id: 'b'),
          ],
        ),
      );
      await settle(tester);
      expect(find.byKey(const Key('pending-a')), findsOneWidget);
      expect(find.byKey(const Key('pending-b')), findsNothing);
    });
  });

  group('the offline screen', () {
    Future<int> conflictEntry(WidgetTester tester) async {
      late int id;
      await seed(tester, () async {
        await h.store.put(
          'w1',
          Kinds.task,
          'a',
          taskToJson(serverTask('a', 'Alpha')),
        );
        await h.store.enqueue(
          _entry('a', OutboxOp.update, {
            'title': 'Mine',
            'dueDate': '2026-12-01',
          }),
        );
        id = (await h.store.queue('w1')).single.id;
        await h.store.setState(
          id,
          OutboxState.conflict,
          error: 'Someone else changed this task first.',
          theirs: jsonEncode({
            'field': 'title',
            'current': 'Theirs',
            'version': 2,
          }),
        );
      });
      return id;
    }

    ui('a clash shows both values and the three choices', (tester) async {
      final id = await conflictEntry(tester);
      await show(tester, const OfflineScreen());
      await settle(tester);
      expect(find.byKey(Key('clash-$id')), findsOneWidget);
      expect(find.textContaining('Theirs (title): Theirs'), findsOneWidget);
      expect(find.textContaining('Yours: Mine'), findsOneWidget);
      expect(find.byKey(Key('keep-mine-$id')), findsOneWidget);
      expect(find.byKey(Key('take-theirs-$id')), findsOneWidget);
      expect(find.byKey(Key('merge-$id')), findsOneWidget);
    });

    ui('keep mine puts the change back in line', (tester) async {
      final id = await conflictEntry(tester);
      h.server.tasks['a'] = serverTask('a', 'Theirs', version: 2);
      await show(tester, const OfflineScreen());
      await settle(tester);
      await tester.tap(find.byKey(Key('keep-mine-$id')));
      await settle(tester);
      expect(h.server.tasks['a']!.title, 'Mine');
      expect(await tester.runAsync(() => h.store.queue('w1')), isEmpty);
    });

    ui('take theirs drops my change', (tester) async {
      final id = await conflictEntry(tester);
      await show(tester, const OfflineScreen());
      await settle(tester);
      await tester.tap(find.byKey(Key('take-theirs-$id')));
      await settle(tester);
      expect(find.byKey(const Key('nothing-to-decide')), findsOneWidget);
      expect(await tester.runAsync(() => h.store.queue('w1')), isEmpty);
    });

    ui('merge asks which fields to keep', (tester) async {
      final id = await conflictEntry(tester);
      await show(tester, const OfflineScreen());
      await settle(tester);
      await tester.tap(find.byKey(Key('merge-$id')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('merge-field-title')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('merge-confirm')));
      await tester.pumpAndSettle();
      await settle(tester);
      final queue = await tester.runAsync(() => h.store.queue('w1'));
      for (final e in queue!) {
        expect(e.payload.keys, isNot(contains('title')));
      }
    });

    ui('a refused change can be tried again or let go', (tester) async {
      late int id;
      await seed(tester, () async {
        await h.store.enqueue(_entry('a', OutboxOp.delete, {'mode': ''}));
        id = (await h.store.queue('w1')).single.id;
        await h.store.setState(id, OutboxState.rejected, error: 'No access.');
      });
      await show(tester, const OfflineScreen());
      await settle(tester);
      expect(find.text('No access.'), findsOneWidget);
      await tester.tap(find.byKey(Key('discard-$id')));
      await settle(tester);
      expect(find.byKey(const Key('nothing-to-decide')), findsOneWidget);
    });

    ui('it fits a phone without overflowing', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await seed(tester, () async {
        await h.store.enqueue(_entry('a', OutboxOp.update, {'title': 'X'}));
        await h.store.setKeptProjects('w1', {'p1'});
      });
      await show(tester, const OfflineScreen());
      await settle(tester);
      expect(tester.takeException(), isNull);
    });

    ui('storage shows the size and clearing it asks first', (tester) async {
      await seed(
        tester,
        () => h.store.put(
          'w1',
          Kinds.task,
          'a',
          taskToJson(serverTask('a', 'Alpha')),
        ),
      );
      await show(tester, const OfflineScreen());
      await settle(tester);
      expect(find.textContaining('of at most 50 MB'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('clear-cache')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('clear-cache')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('clear-cache-confirm')));
      await tester.pumpAndSettle();
      await settle(tester);
      expect(
        await tester.runAsync(() => h.store.get('w1', Kinds.task, 'a')),
        isNull,
      );
    });
  });

  group('describeEntry', () {
    test('says what each change does', () {
      expect(
        describeEntry(_entry('a', OutboxOp.create, {'title': 'Draft'}), ''),
        'New task “Draft”',
      );
      expect(
        describeEntry(
          _entry('a', OutboxOp.update, {'title': 'X', 'dueDate': 'd'}),
          'Fix',
        ),
        'Edit “Fix”: title, dueDate',
      );
      expect(
        describeEntry(_entry('a', OutboxOp.delete, {}), ''),
        'Delete a task',
      );
      expect(
        describeEntry(
          _entry('c', OutboxOp.create, {
            'taskId': 'a',
          }, entity: OutboxEntity.comment),
          'Fix',
        ),
        'Comment on “Fix”',
      );
    });
  });
}
