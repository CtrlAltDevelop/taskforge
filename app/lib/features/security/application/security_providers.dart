import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/security/data/security_client.dart';
import 'package:taskforge/features/security/domain/security.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final securityClientProvider = Provider<SecurityClient>(
  (ref) => GrpcSecurityClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// The signed-in person's own two-step verification.
final secondFactorStatusProvider =
    FutureProvider.autoDispose<SecondFactorStatus>(
      (ref) => ref.watch(securityClientProvider).status(),
    );

/// The current workspace's two-factor requirement and the caller's standing.
/// The router watches it: once `blocked`, only the security screen opens.
final securityPolicyProvider = FutureProvider<SecurityPolicy>((ref) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return SecurityPolicy.none;
  try {
    return await ref.watch(securityClientProvider).policy(ws);
  } on SecurityException {
    return SecurityPolicy.none; // offline or not a member: never lock anyone in
  }
});

/// The workspace's identity provider (needs `security.manage`).
final ssoProviderProvider = FutureProvider.autoDispose<SsoProvider>((ref) {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) throw const SecurityException(SecurityFailure.notFound);
  return ref.watch(securityClientProvider).provider(ws);
});
