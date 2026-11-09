import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'ping_client.dart';

class WsPing implements PingClient {
  WsPing(this.url);

  final String url;

  @override
  String get label => 'WebSocket';

  @override
  Future<String> ping() async {
    final channel = WebSocketChannel.connect(Uri.parse(url));
    try {
      await channel.ready.timeout(const Duration(seconds: 5));
      channel.sink.add(jsonEncode({'type': 'ping'}));
      final first = await channel.stream.first.timeout(
        const Duration(seconds: 5),
      );
      final frame = jsonDecode(first as String) as Map<String, dynamic>;
      return frame['type'] as String;
    } finally {
      // Not awaited: on a failed connection `close()` never completes, which
      // would hide the real error behind a hang.
      unawaited(channel.sink.close());
    }
  }
}
