import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/ping/ping_client.dart';
import 'package:taskforge/features/debug/debug_screen.dart';
import 'package:taskforge/features/debug/ping_providers.dart';

class _FakePing implements PingClient {
  _FakePing(this.label, {this.reply, this.error});

  @override
  final String label;
  final String? reply;
  final Object? error;

  @override
  Future<String> ping() async {
    if (error != null) throw error!;
    return reply!;
  }
}

Widget _app(List<PingClient> clients) => ProviderScope(
  overrides: [pingClientsProvider.overrideWithValue(clients)],
  child: const MaterialApp(home: DebugScreen()),
);

void main() {
  testWidgets('shows one button per transport', (tester) async {
    await tester.pumpWidget(
      _app([
        _FakePing('REST', reply: 'ok'),
        _FakePing('gRPC', reply: 'ok'),
        _FakePing('WebSocket', reply: 'pong'),
      ]),
    );

    expect(find.text('REST ping'), findsOneWidget);
    expect(find.text('gRPC ping'), findsOneWidget);
    expect(find.text('WebSocket ping'), findsOneWidget);
  });

  testWidgets('shows the server reply after a successful ping', (tester) async {
    await tester.pumpWidget(_app([_FakePing('WebSocket', reply: 'pong')]));

    await tester.tap(find.text('WebSocket ping'));
    await tester.pumpAndSettle();

    expect(find.text('pong'), findsOneWidget);
  });

  testWidgets('shows the error when a ping fails', (tester) async {
    await tester.pumpWidget(
      _app([_FakePing('REST', error: 'connection refused')]),
    );

    await tester.tap(find.text('REST ping'));
    await tester.pumpAndSettle();

    expect(find.textContaining('connection refused'), findsOneWidget);
  });
}
