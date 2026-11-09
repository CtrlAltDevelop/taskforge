import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

Future<void> _pumpGate(
  WidgetTester tester,
  Permissions permissions, {
  bool disabled = false,
  VoidCallback? onTap,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [permissionSetProvider.overrideWithValue(permissions)],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: PermissionGate(
            permission: Perm.memberInvite,
            disabledWhenDenied: disabled,
            child: ElevatedButton(
              onPressed: onTap,
              child: const Text('Invite'),
            ),
          ),
        ),
      ),
    ),
  ),
);

const _viewer = Permissions(
  workspaceId: 'w1',
  allowed: {Perm.memberView},
  roleName: 'Viewer',
);

void main() {
  group('PermissionGate', () {
    testWidgets('shows the child when allowed', (tester) async {
      var taps = 0;
      await _pumpGate(
        tester,
        const Permissions(workspaceId: 'w1', allowed: {Perm.memberInvite}),
        onTap: () => taps++,
      );

      await tester.tap(find.text('Invite'));
      expect(taps, 1);
    });

    testWidgets('hides the child when denied', (tester) async {
      await _pumpGate(tester, _viewer);

      expect(find.text('Invite'), findsNothing);
    });

    testWidgets('disabled mode keeps the child inert with the reason', (
      tester,
    ) async {
      var taps = 0;
      await _pumpGate(tester, _viewer, disabled: true, onTap: () => taps++);

      expect(find.text('Invite'), findsOneWidget);
      await tester.tap(find.text('Invite'), warnIfMissed: false);
      expect(taps, 0);
      expect(
        find.byTooltip(
          'You need permission "member.invite" — your role is Viewer',
        ),
        findsOneWidget,
      );
    });
  });

  group('permissionsProvider', () {
    testWidgets('resets on a workspace switch', (tester) async {
      final roles = FakeRolesClient(
        callerRole: (id) => id == 'w1' ? 'Owner' : 'Viewer',
      );
      final container = await pumpSignedIn(
        tester,
        FakeWorkspaceClient([ws('w1', 'Acme'), ws('w2', 'Initech')]),
        roles: roles,
      );
      await container.read(permissionsProvider.future);
      expect(
        container.read(permissionSetProvider).can(Perm.roleManage),
        isTrue,
      );

      await container.read(selectedWorkspaceIdProvider.notifier).select('w2');
      await container.read(permissionsProvider.future);

      final now = container.read(permissionSetProvider);
      expect(now.workspaceId, 'w2');
      expect(now.can(Perm.roleManage), isFalse);
      expect(now.roleName, 'Viewer');
    });

    testWidgets('re-reads after invalidation (a role change)', (tester) async {
      final roles = FakeRolesClient(callerRole: (_) => 'Admin');
      final container = await pumpSignedIn(
        tester,
        FakeWorkspaceClient([ws('w1', 'Acme')]),
        roles: roles,
      );
      await container.read(permissionsProvider.future);
      expect(
        container.read(permissionSetProvider).can(Perm.workspaceDelete),
        isFalse,
      );

      roles.callerRoleFor = (_) => 'Owner';
      container.invalidate(permissionsProvider);
      await container.read(permissionsProvider.future);

      final now = container.read(permissionSetProvider);
      expect(now.can(Perm.workspaceDelete), isTrue);
      expect(now.roleName, 'Owner');
    });
  });
}
