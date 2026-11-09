import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/roles/data/roles_client.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final rolesClientProvider = Provider<RolesClient>(
  (ref) => GrpcRolesClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
  ),
);

/// The caller's permissions in the current workspace. Watches the workspace
/// scope, so a switch discards the previous answers; call
/// `ref.invalidate(permissionsProvider)` after anything that may change them
/// (a role edit or reassignment).
final permissionsProvider = FutureProvider<Permissions>((ref) async {
  ref.watch(refusalCountProvider);
  final id = ref.watch(workspaceScopeProvider);
  if (id == null) return Permissions.none;
  return ref.watch(rolesClientProvider).check(id, Perm.all);
});

/// [permissionsProvider] as a plain value: nothing is allowed while it loads,
/// fails, or still describes another workspace.
final permissionSetProvider = Provider<Permissions>((ref) {
  final scope = ref.watch(workspaceScopeProvider);
  final current = ref.watch(permissionsProvider).value;
  return current != null && current.workspaceId == scope
      ? current
      : Permissions.none;
});

/// Roles and registry of the current workspace (needs `role.view`).
final rolesProvider = FutureProvider.autoDispose<RoleCatalog>((ref) async {
  ref.watch(refusalCountProvider);
  final id = ref.watch(workspaceScopeProvider);
  if (id == null) return const RoleCatalog(roles: [], registry: []);
  return ref.watch(rolesClientProvider).list(id);
});
