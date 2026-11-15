// The main offline flow through the whole app with a fake network: browse,
// lose the connection, create, edit and comment, come back, and find it all on
// the server. Run with `flutter test integration_test`.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/data/offline_comments_client.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../test/core/offline/fakes.dart';
import '../test/features/projects/fakes.dart' show project;
import '../test/features/projects/projects_test_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'browse, go offline, create, edit and comment, come back: synced',
    (tester) async {
      final h = Harness.create();
      addTearDown(() async {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await h.close();
        });
      });
      h.server.tasks['a'] = serverTask('a', 'Alpha');

      final pumped = await pumpProjects(
        tester,
        projects: [project('p1', 'Web')],
        overrides: [
          offlineStoreFutureProvider.overrideWithValue(Future.value(h.store)),
          reachabilityProbeProvider.overrideWithValue(() async {}),
          rawTasksClientProvider.overrideWithValue(h.server.t),
          rawCommentsClientProvider.overrideWithValue(h.server.c),
        ],
        tasksProvider: tasksClientProvider.overrideWith(
          (ref) => OfflineTasksClient(
            ref.watch(rawTasksClientProvider),
            ref.watch(offlineEnvProvider),
          ),
        ),
        commentsProvider: commentsClientProvider.overrideWith(
          (ref) => OfflineCommentsClient(
            ref.watch(rawCommentsClientProvider),
            ref.watch(offlineEnvProvider),
          ),
        ),
      );
      final container = pumped.container;
      container.read(offlineSyncProvider); // what the app root watches

      // 1. Browse while online: the list is read and kept.
      await pumped.go(tester, '/projects/p1');
      expect(find.text('Alpha'), findsOneWidget);

      // 2. The connection drops.
      h.server.reachable = false;
      container.read(networkProvider.notifier).failed();
      await tester.pump();

      // 3. Create a task from the list, rename another, write a comment.
      await tester.enterText(
        find.byKey(const Key('quick-add')),
        'Written offline',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Written offline'), findsOneWidget);
      final tasks = container.read(tasksClientProvider);
      final alpha = await tasks.get('w1', 'p1', 'a');
      await tester.runAsync(
        () =>
            tasks.update('w1', alpha, const TaskPatch(title: 'Alpha renamed')),
      );
      final made = await tester.runAsync(
        () => container
            .read(commentsClientProvider)
            .create('w1', 'p1', 'a', '{"type":"doc","content":[]}'),
      );
      expect(made, isNotNull);
      expect(h.server.tasks.length, 1); // nothing has reached the server yet
      final waiting = await tester.runAsync(() => h.store.queue('w1'));
      expect(waiting, hasLength(3));

      // 4. The connection is back: it all goes up, in order, once.
      h.server.reachable = true;
      container.read(networkProvider.notifier).worked();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();

      expect(
        h.server.tasks.values.map((t) => t.title),
        containsAll(['Alpha renamed', 'Written offline']),
      );
      expect(h.server.tasks, hasLength(2));
      expect(await tester.runAsync(() => h.store.queue('w1')), isEmpty);
      expect(find.text('Pending'), findsNothing);
    },
  );
}
