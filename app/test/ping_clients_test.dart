import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskforge/core/ping/rest_ping.dart';
import 'package:taskforge/core/ping/ws_ping.dart';

void main() {
  group('RestPing', () {
    test('reads the status from the response envelope', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), 'http://api.test/api/v1/health/live');
        return http.Response(
          jsonEncode({
            'data': {'status': 'ok'},
          }),
          200,
        );
      });

      expect(await RestPing('http://api.test', client: client).ping(), 'ok');
    });

    test('falls back to a top-level status', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode({'status': 'up'}), 200),
      );

      expect(await RestPing('http://api.test', client: client).ping(), 'up');
    });

    test('throws on a non-200 answer', () async {
      final client = MockClient((_) async => http.Response('nope', 503));

      expect(
        RestPing('http://api.test', client: client).ping(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('WsPing', () {
    late HttpServer server;

    setUp(
      () async =>
          server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    );
    tearDown(() => server.close(force: true));

    test('returns the frame type the server answers with', () async {
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        socket.listen((message) {
          expect(jsonDecode(message as String), {'type': 'ping'});
          socket.add(jsonEncode({'type': 'pong'}));
        });
      });

      expect(
        await WsPing('ws://127.0.0.1:${server.port}/ws/ping/').ping(),
        'pong',
      );
    });

    test('throws when nothing is listening', () async {
      final port = server.port;
      await server.close(force: true);

      expect(WsPing('ws://127.0.0.1:$port/ws/ping/').ping(), throwsA(anything));
    });
  });
}
