import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/roles/presentation/role_actions.dart';
import 'package:taskforge/features/roles/presentation/role_matrix.dart';

/// Below this width the matrix gives way to a role-by-role list.
const _matrixMinWidth = 700.0;

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);
    final canManage = ref.watch(permissionSetProvider).can(Perm.roleManage);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-settings'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/workspaces/settings'),
        ),
        title: const Text('Roles and permissions'),
        actions: [
          PermissionGate(
            permission: Perm.roleManage,
            child: TextButton.icon(
              key: const Key('new-role'),
              icon: const Icon(Icons.add),
              label: const Text('New role'),
              onPressed: roles.hasValue
                  ? () => createRoleFlow(context, ref, roles.requireValue)
                  : null,
            ),
          ),
        ],
      ),
      body: roles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            key: const Key('retry-roles'),
            onPressed: () => ref.invalidate(rolesProvider),
            child: Text('${roleErrorMessage(e)} Retry'),
          ),
        ),
        data: (catalog) => LayoutBuilder(
          builder: (_, box) => box.maxWidth >= _matrixMinWidth
              ? RoleMatrix(catalog: catalog, canManage: canManage)
              : RoleList(catalog: catalog, canManage: canManage),
        ),
      ),
    );
  }
}
