import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:grpc/service_api.dart' show CallOptions;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

import '../../gen/infrastructure/common/grpc/common.pbgrpc.dart';
import 'ping_client.dart';

const _timeout = Duration(seconds: 5);

class GrpcPing implements PingClient {
  GrpcPing(ClientChannelBase channel) : _stub = HealthControllerClient(channel);

  final HealthControllerClient _stub;

  @override
  String get label => 'gRPC';

  @override
  Future<String> ping() async {
    final health = await _stub.liveness(
      Empty(),
      options: CallOptions(timeout: _timeout),
    );
    return health.status;
  }
}
