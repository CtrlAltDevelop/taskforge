import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

import '../../core/sync/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'docs_ui_test.dart' show key, taskId, workspace;
import 'fakes.dart';

Map<String, dynamic> _event(
  String type, {
  required String entity,
  int version = 2,
}) => {
  'type': 'event',
  'room': 'proj:p1',
  'event': {
    'type': type,
    'workspace': 'w1',
    'project': 'p1',
    'entity_id': entity,
    'version': version,
    'actor': 'u2',
    'origin': 'someone-else',
    'cursor': 11,
  },
};

/// The app with a live socket (the production sync path), page `a` open.
Future<({FakeDocsClient docs, FakeConnection connection})> _open(
  WidgetTester tester,
) async {
  final docs = workspace();
  docs.bodies['a'] = [taskCard('c1', taskId), para('p1', 'First line')];
  docs.cards[taskId] = const TaskCardInfo(
    taskId: taskId,
    projectId: 'p1',
    key: 'WEB-1',
    title: 'Fix login',
    statusName: 'To do',
  );
  final connector = FakeConnector();
  final timers = ManualTimers();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    docs: docs,
    sync: syncClientProvider.overrideWith((ref) {
      final client = SyncClient(
        connector: connector,
        url: Uri.parse('ws://test/ws/sync'),
        token: () async => 'tok',
        head: () async => 10,
        catchUp: (_) async => const CatchUp(),
        timers: timers.call,
      )..subscribe('ws:w1');
      client.start();
      ref.onDispose(() => unawaited(client.dispose()));
      return client;
    }),
  );
  await pumped.go(tester, '/docs/a');
  await tester.pump();
  final connection = connector.last..open();
  await tester.pump();
  connection.say({
    'type': 'ready',
    'user': {'id': 'me'},
    'origin': 'tag-me',
  });
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  return (docs: docs, connection: connection);
}

void main() {
  testWidgets('a task.updated event refreshes the status on an open card', (
    tester,
  ) async {
    final live = await _open(tester);
    expect(find.text('To do'), findsOneWidget);

    live.docs.cards[taskId] = const TaskCardInfo(
      taskId: taskId,
      projectId: 'p1',
      key: 'WEB-1',
      title: 'Fix login',
      statusName: 'Done',
      statusCategory: 'done',
    );
    live.connection.say(_event('task.updated', entity: taskId));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('To do'), findsNothing);
    expect(key('task-card-status-$taskId'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('a doc.updated event reads the open page again', (tester) async {
    final live = await _open(tester);

    live.docs.externalSave('a', [
      taskCard('c1', taskId),
      para('p1', 'Changed elsewhere'),
    ]);
    live.connection.say(_event('doc.updated', entity: 'a', version: 2));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Changed elsewhere'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
