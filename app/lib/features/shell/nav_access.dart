import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/shell/nav_items.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// Which entries the person may see. Until the permission answer for the
/// current workspace is in, [ready] is false and gated entries stay hidden,
/// so the frame never shows an item and then removes it.
@immutable
class NavAccess {
  const NavAccess({
    required this.permissions,
    required this.ready,
    required this.systemAdmin,
  });

  final Permissions permissions;
  final bool ready;
  final bool systemAdmin;

  bool allows(NavItem item) {
    if (item.gate == NavGate.debugBuild && !kDebugMode) return false;
    if (item.gate == NavGate.systemAdmin && !systemAdmin) return false;
    final needs = item.permission;
    return needs == null || (ready && permissions.can(needs));
  }

  Iterable<NavItem> visible(NavSection section) =>
      navSection(section).where(allows);
}

final navAccessProvider = Provider<NavAccess>((ref) {
  final scope = ref.watch(workspaceScopeProvider);
  final answer = ref.watch(permissionsProvider).value;
  return NavAccess(
    permissions: ref.watch(permissionSetProvider),
    ready: answer != null && answer.workspaceId == scope,
    // The call fails for everyone but administrators.
    systemAdmin: ref.watch(systemInfoProvider).hasValue,
  );
});
