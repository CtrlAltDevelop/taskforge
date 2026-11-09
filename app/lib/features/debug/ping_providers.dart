import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/ping/grpc_ping.dart';
import 'package:taskforge/core/ping/ping_client.dart';
import 'package:taskforge/core/ping/rest_ping.dart';
import 'package:taskforge/core/ping/ws_ping.dart';

/// The three probes shown on the debug screen. Tests override this list.
final pingClientsProvider = Provider<List<PingClient>>((ref) {
  final httpClient = http.Client();
  ref.onDispose(httpClient.close);
  return [
    RestPing(AppConfig.restUrl, client: httpClient),
    GrpcPing(ref.watch(grpcChannelProvider)),
    WsPing(AppConfig.wsUrl),
  ];
});
