import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/dpop/dpop_manager.dart';
import 'package:taskforge/core/grpc/channel.dart';
import 'package:taskforge/core/grpc/dpop_channel.dart';

/// One gRPC channel for the app, closed when the provider is disposed. Every call that carries a
/// token also carries a DPoP proof (see `DpopClientChannel`).
final grpcChannelProvider = Provider<ClientChannelBase>((ref) {
  final channel = DpopClientChannel(createGrpcChannel(), DpopManager.shared);
  ref.onDispose(channel.shutdown);
  return channel;
});
