import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/grpc/channel.dart';

/// One gRPC channel for the app, closed when the provider is disposed.
final grpcChannelProvider = Provider<ClientChannelBase>((ref) {
  final channel = createGrpcChannel();
  ref.onDispose(channel.shutdown);
  return channel;
});
