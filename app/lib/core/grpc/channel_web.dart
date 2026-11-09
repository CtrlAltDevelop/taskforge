import 'package:grpc/grpc_web.dart';

import '../config.dart';

/// Web: gRPC-Web through the Envoy proxy.
GrpcWebClientChannel createGrpcChannel() =>
    GrpcWebClientChannel.xhr(Uri.parse(AppConfig.grpcWebUrl));
