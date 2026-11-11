import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';

import '../../core/sync/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';

Map<String, dynamic> _event(String type, {String entity = 'a1'}) => {
  'type': 'event',
  'room': 'proj:p1',
  'event': {
    'type': type,
    'workspace': 'w1',
    'project': 'p1',
    'entity_id': entity,
    'version': 2,
    'actor': 'u2',
    'origin': 'someone-else',
    'cursor': 11,
  },
};

Future<({FakeAutomationsClient fake, FakeConnection connection})> _open(
  WidgetTester tester,
  String path,
) async {
  final fake = FakeAutomationsClient(rules: [rule('a1', 'Rule one')]);
  final connector = FakeConnector();
  final timers = ManualTimers();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    automations: fake,
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
  await pumped.go(tester, path);
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
  return (fake: fake, connection: connection);
}

void main() {
  testWidgets('an automation event reads the rules again', (tester) async {
    final live = await _open(tester, '/projects/p1/automations');
    expect(find.text('Rule one'), findsOneWidget);

    live.fake.rules[0] = rule('a1', 'Renamed elsewhere', version: 2);
    live.fake.rules.add(rule('a2', 'Made elsewhere'));
    live.connection.say(_event('automation.updated'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Renamed elsewhere'), findsOneWidget);
    expect(find.text('Made elsewhere'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('a run event reads the run history again', (tester) async {
    final live = await _open(tester, '/projects/p1/automations');
    await tester.tap(find.text('Run history'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('runs-empty')), findsOneWidget);

    live.fake.allRuns.add(run('r1', status: RunStatus.failed));
    live.connection.say(_event('automation.run', entity: 'r1'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('run-r1')), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
