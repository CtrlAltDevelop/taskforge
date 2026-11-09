import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/config.dart';
import '../../core/grpc/channel.dart';
import '../../core/ping/grpc_ping.dart';
import '../../core/ping/ping_client.dart';
import '../../core/ping/rest_ping.dart';
import '../../core/ping/ws_ping.dart';

/// The three probes shown on the debug screen. Tests override this list.
final pingClientsProvider = Provider<List<PingClient>>((ref) {
  final httpClient = http.Client();
  final channel = createGrpcChannel();
  ref.onDispose(() {
    httpClient.close();
    channel.shutdown();
  });
  return [
    RestPing(AppConfig.restUrl, client: httpClient),
    GrpcPing(channel),
    WsPing(AppConfig.wsUrl),
  ];
});
