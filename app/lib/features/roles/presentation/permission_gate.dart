import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';

/// Shows [child] when the member holds [permission]; otherwise hides it, or with
/// [disabledWhenDenied] keeps it visible but inert with a tooltip giving the
/// reason. Cosmetic only: the server enforces the permission on every call.
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.disabledWhenDenied = false,
  });

  final String permission;
  final Widget child;
  final bool disabledWhenDenied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionSetProvider);
    if (permissions.can(permission)) return child;
    if (!disabledWhenDenied) return const SizedBox.shrink();
    return Tooltip(
      message: denialMessage(permission, permissions.roleName),
      child: ExcludeFocus(
        child: IgnorePointer(child: Opacity(opacity: 0.5, child: child)),
      ),
    );
  }
}
