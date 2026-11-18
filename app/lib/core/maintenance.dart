import 'package:grpc/grpc.dart' show GrpcError, StatusCode;

import 'package:taskforge/core/auth/auth_api.dart';

/// The word the server puts in its "unavailable" answer when it is down for
/// maintenance (gRPC `UNAVAILABLE`), and the flag in its REST 503 body
/// (`{"maintenance": true}`).
const maintenanceWord = 'maintenance';

/// Whether [error] is the server saying it is down for maintenance, over gRPC
/// or REST (the auth calls). A plain unreachable server is not.
bool isMaintenance(Object error) => switch (error) {
  GrpcError(:final code, :final message) =>
    code == StatusCode.unavailable &&
        (message ?? '').toLowerCase().contains(maintenanceWord),
  AuthApiException(:final maintenance) => maintenance,
  _ => false,
};
