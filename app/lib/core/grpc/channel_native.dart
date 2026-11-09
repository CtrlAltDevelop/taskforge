import 'package:grpc/grpc.dart';

import 'package:taskforge/core/config.dart';

/// Mobile and desktop: plain gRPC over HTTP/2.
ClientChannel createGrpcChannel() => ClientChannel(
  AppConfig.grpcHost,
  port: AppConfig.grpcPort,
  options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
);
