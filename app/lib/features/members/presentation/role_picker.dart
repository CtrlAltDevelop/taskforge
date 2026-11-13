import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/members/presentation/members_screen.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// The member's role: a menu of the workspace's roles for someone holding
/// `member.set_role`, a plain chip for everyone else. Which roles the caller may
/// actually grant is decided by the server; its reason is shown on a denial.
class RolePicker extends ConsumerWidget {
  const RolePicker({super.key, required this.member, this.onChanged});

  final Member member;

  /// Called after a successful change (the profile card closes itself).
  final VoidCallback? onChanged;

  Future<void> _assign(BuildContext context, WidgetRef ref, Role role) async {
    final workspaceId = ref.read(workspaceScopeProvider);
    if (workspaceId == null || role.id == member.roleId) return;
    final changed = await runWithFeedback(
      context,
      () => ref
          .read(membersClientProvider)
          .setRole(workspaceId, member.userId, role.id)
          .then((_) {}),
    );
    if (!changed) return;
    // The caller's own grants, role counts and the list may all have moved.
    ref
      ..invalidate(membersProvider)
      ..invalidate(rolesProvider)
      ..invalidate(permissionsProvider);
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chip = Chip(label: Text(member.roleName));
    final canSet = ref.watch(permissionSetProvider).can(Perm.memberSetRole);
    final roles = ref.watch(rolesProvider).value?.roles;
    if (!canSet || roles == null) return chip;
    return PopupMenuButton<Role>(
      tooltip: context.l10n.grpJChangeRole,
      onSelected: (role) => _assign(context, ref, role),
      itemBuilder: (_) => [
        for (final role in roles)
          CheckedPopupMenuItem<Role>(
            key: Key('role-option-${role.id}'),
            value: role,
            checked: role.id == member.roleId,
            child: Text(role.name),
          ),
      ],
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(member.roleName),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}
