import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';

import '../../core/sync/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';

Map<String, dynamic> _event(String type) => {
  'type': 'event',
  'room': 'user:me',
  'event': {
    'type': type,
    'workspace': '',
    'project': '',
    'entity_id': 'me',
    'version': 0,
    'actor': 'me',
    'origin': 'another-device',
    'cursor': 0,
  },
};

void main() {
  testWidgets('a shortcuts event on the socket reads the bindings again', (
    tester,
  ) async {
    final fake = FakeShortcutsClient();
    final connector = FakeConnector();
    final timers = ManualTimers();
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      shortcuts: fake,
      sync: syncClientProvider.overrideWith((ref) {
        final client = SyncClient(
          connector: connector,
          url: Uri.parse('ws://test/ws/sync'),
          token: () async => 'tok',
          head: () async => 10,
          catchUp: (_) async => const CatchUp(),
          timers: timers.call,
        )..subscribe('user:me');
        client.start();
        ref.onDispose(() => unawaited(client.dispose()));
        return client;
      }),
    );
    await pumped.go(tester, '/');
    await tester.pump();
    final connection = connector.last..open();
    await tester.pump();
    connection.say({
      'type': 'ready',
      'user': {'id': 'me'},
      'origin': 'tag-me',
    });
    await tester.pumpAndSettle();
    expect(
      pumped.container.read(bindingsProvider).chordOf('nav.inbox')?.wire,
      'alt+i',
    );

    fake.stored['nav.inbox'] = 'alt+j'; // changed on another device
    connection.say(_event('shortcuts.changed'));
    await tester.pumpAndSettle();

    expect(
      pumped.container.read(bindingsProvider).chordOf('nav.inbox')?.wire,
      'alt+j',
    );
    await tester.pump(const Duration(seconds: 3));
  });
}
