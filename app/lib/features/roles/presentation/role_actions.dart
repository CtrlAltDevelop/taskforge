import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/role_dialogs.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';

/// Runs [action] against the current workspace; a failure becomes a snackbar.
/// On success everything a role change can touch is re-read: the matrix, the
/// members' role names and the caller's own permissions.
Future<bool> runRoleAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(String workspaceId) action,
) async {
  final workspaceId = ref.read(workspaceScopeProvider);
  if (workspaceId == null) return false;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await action(workspaceId);
  } on RoleException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(roleErrorMessage(e, l10n))));
    if (e.failure == RoleFailure.conflict) await _reloadRoles(ref);
    return false;
  }
  ref
    ..invalidate(membersProvider)
    ..invalidate(permissionsProvider);
  await _reloadRoles(ref);
  return true;
}

/// Re-reads the roles and waits for them, so a follow-up edit starts from the
/// new versions. A failed reload shows in the screen's own error state.
Future<void> _reloadRoles(WidgetRef ref) async {
  ref.invalidate(rolesProvider);
  try {
    await ref.read(rolesProvider.future);
  } on Object {
    // Surfaced by the screen watching rolesProvider.
  }
}

/// Role ids whose update is in flight; their matrix cells are disabled so a
/// second toggle cannot send a stale full set.
final busyRolesProvider = NotifierProvider<BusyRoles, Set<String>>(
  BusyRoles.new,
);

class BusyRoles extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void mark(String id) => state = {...state, id};

  void clear(String id) => state = {...state}..remove(id);
}

/// Grants or revokes [key] on a custom role (the server replaces name and
/// checklist together, so the whole set is sent). Starts from the freshest
/// loaded copy of the role and is ignored while that role is being updated.
Future<bool> toggleRolePermission(
  BuildContext context,
  WidgetRef ref,
  Role role,
  String key,
  bool granted,
) async {
  final busy = ref.read(busyRolesProvider.notifier);
  if (ref.read(busyRolesProvider).contains(role.id)) return false;
  final loaded = ref.read(rolesProvider).value?.roles ?? const <Role>[];
  final fresh = loaded.where((r) => r.id == role.id).firstOrNull ?? role;
  busy.mark(role.id);
  try {
    return await runRoleAction(
      context,
      ref,
      (id) => ref
          .read(rolesClientProvider)
          .update(
            id,
            fresh.id,
            name: fresh.name,
            expectedVersion: fresh.version,
            permissions: granted
                ? {...fresh.permissions, key}
                : {...fresh.permissions}.difference({key}),
          )
          .then((_) {}),
    );
  } finally {
    busy.clear(role.id);
  }
}

Future<void> createRoleFlow(
  BuildContext context,
  WidgetRef ref,
  RoleCatalog catalog,
) async {
  final draft = await showCreateRoleDialog(context, catalog.registry);
  if (draft == null || !context.mounted) return;
  await runRoleAction(
    context,
    ref,
    (id) => ref
        .read(rolesClientProvider)
        .create(id, name: draft.name, permissions: draft.permissions)
        .then((_) {}),
  );
}

Future<void> renameRoleFlow(
  BuildContext context,
  WidgetRef ref,
  Role role,
) async {
  final name = await showRenameRoleDialog(context, role);
  if (name == null || name == role.name || !context.mounted) return;
  await runRoleAction(
    context,
    ref,
    (id) => ref
        .read(rolesClientProvider)
        .update(
          id,
          role.id,
          name: name,
          permissions: role.permissions,
          expectedVersion: role.version,
        )
        .then((_) {}),
  );
}

Future<void> deleteRoleFlow(
  BuildContext context,
  WidgetRef ref,
  Role role,
  List<Role> all,
) async {
  final others = [
    for (final r in all)
      if (r.id != role.id) r,
  ];
  final reassign = await showDeleteRoleDialog(context, role, others);
  if (reassign == null || !context.mounted) return;
  await runRoleAction(
    context,
    ref,
    (id) => ref
        .read(rolesClientProvider)
        .delete(id, role.id, reassignTo: reassign.isEmpty ? null : reassign),
  );
}
