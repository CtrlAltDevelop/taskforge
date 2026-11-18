import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/roles/presentation/role_actions.dart';
import 'package:taskforge/features/roles/presentation/role_matrix.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// Below this width the matrix gives way to a role-by-role list.
const _matrixMinWidth = 700.0;

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);
    final canManage = ref.watch(permissionSetProvider).can(Perm.roleManage);
    return Scaffold(
      appBar: TfAppBar(
        leading: IconButton(
          key: const Key('back-settings'),
          tooltip: context.l10n.grpJBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.go('/workspaces/settings'),
        ),
        title: Text(context.l10n.grpJRolesAndPermissions),
        actions: [
          PermissionGate(
            permission: Perm.roleManage,
            child: TextButton.icon(
              key: const Key('new-role'),
              icon: const TfIcon(TfIcons.plus),
              label: Text(context.l10n.grpJNewRole),
              onPressed: roles.hasValue
                  ? () => createRoleFlow(context, ref, roles.requireValue)
                  : null,
            ),
          ),
        ],
      ),
      body: roles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => TfError(
          message: roleErrorMessage(e, context.l10n),
          details: '$e',
          retryKey: const Key('retry-roles'),
          onRetry: () => ref.invalidate(rolesProvider),
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
