import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/role_actions.dart';

const _labelWidth = 220.0;
const _roleWidth = 120.0;

/// One permission cell. Built-in roles are always read-only; custom ones are
/// editable only for someone holding `role.manage` ([canManage]).
class _Cell extends ConsumerWidget {
  const _Cell({
    required this.role,
    required this.permission,
    required this.canManage,
  });

  final Role role;
  final PermissionInfo permission;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(busyRolesProvider).contains(role.id);
    final editable = canManage && !role.isBuiltin && !busy;
    return Checkbox(
      key: Key('cell-${role.id}-${permission.key}'),
      value: role.permissions.contains(permission.key),
      onChanged: editable
          ? (v) => toggleRolePermission(
              context,
              ref,
              role,
              permission.key,
              v ?? false,
            )
          : null,
    );
  }
}

class _RoleMenu extends ConsumerWidget {
  const _RoleMenu({required this.role, required this.all});

  final Role role;
  final List<Role> all;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<String>(
    key: Key('role-menu-${role.id}'),
    tooltip: context.l10n.grpJRoleActions,
    onSelected: (action) => action == 'rename'
        ? renameRoleFlow(context, ref, role)
        : deleteRoleFlow(context, ref, role, all),
    itemBuilder: (_) => [
      PopupMenuItem(value: 'rename', child: Text(context.l10n.grpJRename)),
      PopupMenuItem(value: 'delete', child: Text(context.l10n.grpJDelete)),
    ],
  );
}

class _RoleHeader extends StatelessWidget {
  const _RoleHeader({
    required this.role,
    required this.all,
    required this.canManage,
  });

  final Role role;
  final List<Role> all;
  final bool canManage;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (role.isBuiltin)
        Icon(
          Icons.lock,
          key: Key('lock-${role.id}'),
          size: 14,
          semanticLabel: context.l10n.grpJBuiltInReadOnly,
        ),
      Flexible(
        child: Text(
          role.name,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      if (canManage && !role.isBuiltin) _RoleMenu(role: role, all: all),
    ],
  );
}

/// Wide layout: rows are permissions grouped by area, columns are roles.
class RoleMatrix extends StatelessWidget {
  const RoleMatrix({super.key, required this.catalog, required this.canManage});

  final RoleCatalog catalog;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final roles = catalog.roles;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          key: const Key('role-matrix'),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: const FixedColumnWidth(_labelWidth),
            for (var i = 0; i < roles.length; i++)
              i + 1: const FixedColumnWidth(_roleWidth),
          },
          children: [
            TableRow(
              children: [
                const SizedBox.shrink(),
                for (final role in roles)
                  _RoleHeader(role: role, all: roles, canManage: canManage),
              ],
            ),
            for (final area in catalog.registry) ...[
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      area.area,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final _ in roles) const SizedBox.shrink(),
                ],
              ),
              for (final p in area.permissions)
                TableRow(
                  children: [
                    Text(p.label),
                    for (final role in roles)
                      Center(
                        child: _Cell(
                          role: role,
                          permission: p,
                          canManage: canManage,
                        ),
                      ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Narrow layout: one expandable card per role.
class RoleList extends StatelessWidget {
  const RoleList({super.key, required this.catalog, required this.canManage});

  final RoleCatalog catalog;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final roles = catalog.roles;
    return ListView(
      key: const Key('role-list'),
      padding: const EdgeInsets.all(8),
      children: [
        for (final role in roles)
          ExpansionTile(
            key: Key('role-tile-${role.id}'),
            title: _RoleHeader(role: role, all: roles, canManage: canManage),
            subtitle: Text('${role.memberCount} member(s)'),
            children: [
              for (final area in catalog.registry) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                    child: Text(
                      area.area,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                for (final p in area.permissions)
                  ListTile(
                    dense: true,
                    title: Text(p.label),
                    trailing: _Cell(
                      role: role,
                      permission: p,
                      canManage: canManage,
                    ),
                  ),
              ],
            ],
          ),
      ],
    );
  }
}
