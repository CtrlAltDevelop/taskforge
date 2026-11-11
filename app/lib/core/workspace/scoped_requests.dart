import 'package:grpc/service_api.dart' show CallOptions;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/sync/client_id.dart';

const workspaceMetadataKey = 'x-workspace';
const workspaceHeaderName = 'X-Workspace';

/// Tells the server which client is calling, so the live feed can mark a
/// change as this client's own (see `core/sync`).
const clientIdMetadataKey = 'x-client-id';

/// gRPC call options carrying the bearer token and, when one is selected, the
/// workspace id. [workspaceId] is read per call so a switch is picked up at once.
CallOptions scopedCallOptions(
  AuthSession session,
  String? Function() workspaceId,
) => CallOptions(
  timeout: const Duration(seconds: 10),
  providers: [
    (metadata, uri) async {
      final token = await session.accessToken();
      if (token != null) metadata['authorization'] = 'Bearer $token';
      final id = workspaceId();
      if (id != null) metadata[workspaceMetadataKey] = id;
      metadata[clientIdMetadataKey] = appClientId;
    },
  ],
);

/// REST headers for a signed-in, workspace-scoped request.
Map<String, String> scopedHeaders(String token, String? workspaceId) => {
  'Authorization': 'Bearer $token',
  'X-Workspace': ?workspaceId,
};
