import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

Future<ProviderContainer> _openRoles(
  WidgetTester tester,
  FakeRolesClient roles, {
  Size size = const Size(1600, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = await pumpSignedIn(
    tester,
    FakeWorkspaceClient([ws('w1', 'Acme')]),
    roles: roles,
  );
  container.read(routerProvider).go('/workspaces/roles');
  await tester.pumpAndSettle();
  return container;
}

Future<FakeRolesClient> _withSupport({
  String caller = 'Owner',
  int members = 0,
}) async {
  final roles = FakeRolesClient(callerRole: (_) => caller);
  await roles.create('w1', name: 'Support', permissions: {Perm.memberView});
  final i = roles.roles.indexWhere((r) => r.name == 'Support');
  roles.roles[i] = Role(
    id: roles.roles[i].id,
    name: 'Support',
    isBuiltin: false,
    permissions: roles.roles[i].permissions,
    memberCount: members,
  );
  return roles;
}

bool _enabled(WidgetTester tester, String key) =>
    tester.widget<Checkbox>(find.byKey(Key(key))).onChanged != null;

void main() {
  group('matrix', () {
    testWidgets('lists permissions by area and a column per role', (
      tester,
    ) async {
      await _openRoles(tester, await _withSupport());

      expect(find.text('Workspace'), findsOneWidget);
      expect(find.text('Invite members'), findsOneWidget);
      for (final role in ['Owner', 'Admin', 'Member', 'Viewer', 'Support']) {
        expect(find.text(role), findsOneWidget);
      }
      // Built-ins carry a lock, the custom role does not.
      expect(find.byKey(const Key('lock-1')), findsOneWidget);
      expect(find.byKey(const Key('lock-100')), findsNothing);
    });

    testWidgets('shows the Automations area with automation.manage', (
      tester,
    ) async {
      final roles = await _withSupport();
      await _openRoles(tester, roles);

      expect(find.text('Automations'), findsOneWidget);
      expect(
        find.text(
          'Create, edit, switch on and off, test and delete automations',
        ),
        findsOneWidget,
      );
      bool checked(String key) =>
          tester.widget<Checkbox>(find.byKey(Key(key))).value ?? false;
      expect(checked('cell-1-${Perm.automationManage}'), isTrue); // Owner
      expect(checked('cell-2-${Perm.automationManage}'), isTrue); // Admin
      expect(checked('cell-3-${Perm.automationManage}'), isFalse); // Member
      expect(checked('cell-100-${Perm.automationManage}'), isFalse);

      // A custom role can be given it.
      await tester.ensureVisible(
        find.byKey(const Key('cell-100-${Perm.automationManage}')),
      );
      await tester.tap(
        find.byKey(const Key('cell-100-${Perm.automationManage}')),
      );
      await tester.pumpAndSettle();
      expect(
        roles.roleNamed('Support').permissions,
        contains(Perm.automationManage),
      );
    });

    testWidgets('built-in cells are read-only, custom ones toggle', (
      tester,
    ) async {
      final roles = await _withSupport();
      await _openRoles(tester, roles);

      expect(_enabled(tester, 'cell-3-${Perm.memberInvite}'), isFalse);
      expect(_enabled(tester, 'cell-100-${Perm.memberInvite}'), isTrue);

      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberInvite}')));
      await tester.pumpAndSettle();

      expect(roles.roleNamed('Support').permissions, {
        Perm.memberView,
        Perm.memberInvite,
      });
      expect(
        tester
            .widget<Checkbox>(
              find.byKey(const Key('cell-100-${Perm.memberInvite}')),
            )
            .value,
        isTrue,
      );

      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberView}')));
      await tester.pumpAndSettle();
      expect(roles.roleNamed('Support').permissions, {Perm.memberInvite});
    });

    testWidgets('without role.manage nothing is editable', (tester) async {
      await _openRoles(tester, await _withSupport(caller: 'Viewer'));

      expect(_enabled(tester, 'cell-100-${Perm.memberInvite}'), isFalse);
      expect(find.byKey(const Key('new-role')), findsNothing);
      expect(find.byKey(const Key('role-menu-100')), findsNothing);
    });

    testWidgets('a server refusal is shown and the cell stays as it was', (
      tester,
    ) async {
      final roles = await _withSupport();
      await _openRoles(tester, roles);
      roles.failNext = const RoleException(
        RoleFailure.denied,
        'You need permission "role.manage" — your role is Admin',
      );

      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberInvite}')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('You need permission "role.manage"'),
        findsOneWidget,
      );
      expect(roles.roleNamed('Support').permissions, {Perm.memberView});
    });
  });

  group('optimistic lock', () {
    testWidgets('cells stay disabled while the role updates, then chain', (
      tester,
    ) async {
      final roles = await _withSupport();
      final gate = Completer<void>();
      roles.hold = gate.future;
      await _openRoles(tester, roles);

      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberInvite}')));
      await tester.pump();
      expect(_enabled(tester, 'cell-100-${Perm.memberRemove}'), isFalse);
      await tester.tap(
        find.byKey(const Key('cell-100-${Perm.memberRemove}')),
        warnIfMissed: false,
      );
      gate.complete();
      roles.hold = null;
      await tester.pumpAndSettle();

      expect(roles.updates.length, 1);
      expect(_enabled(tester, 'cell-100-${Perm.memberRemove}'), isTrue);

      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberRemove}')));
      await tester.pumpAndSettle();

      expect(roles.updates.map((u) => u.expectedVersion), [1, 2]);
      expect(roles.roleNamed('Support').permissions, {
        Perm.memberView,
        Perm.memberInvite,
        Perm.memberRemove,
      });
    });

    testWidgets('a stale version explains itself and reloads the role', (
      tester,
    ) async {
      final roles = await _withSupport();
      await _openRoles(tester, roles);
      roles.editElsewhere('100');

      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberInvite}')));
      await tester.pumpAndSettle();

      expect(
        find.text('This role changed in the meantime. Reloaded — try again.'),
        findsOneWidget,
      );
      expect(roles.roleNamed('Support').permissions, {Perm.memberView});

      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberInvite}')));
      await tester.pumpAndSettle();

      expect(roles.updates.map((u) => u.expectedVersion), [1, 2]);
      expect(
        roles.roleNamed('Support').permissions,
        contains(Perm.memberInvite),
      );
    });
  });

  group('narrow screens', () {
    testWidgets('show a role-by-role list instead of the table', (
      tester,
    ) async {
      final roles = await _withSupport();
      await _openRoles(tester, roles, size: const Size(400, 900));

      expect(find.byKey(const Key('role-matrix')), findsNothing);
      expect(find.byKey(const Key('role-list')), findsOneWidget);

      await tester.tap(find.byKey(const Key('role-tile-100')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cell-100-${Perm.memberInvite}')));
      await tester.pumpAndSettle();

      expect(
        roles.roleNamed('Support').permissions,
        contains(Perm.memberInvite),
      );
    });
  });

  group('creating a role', () {
    testWidgets('sends the name and the ticked permissions', (tester) async {
      final roles = FakeRolesClient();
      await _openRoles(tester, roles);

      await tester.tap(find.byKey(const Key('new-role')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('create-role-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('role-name')), '  Billing ');
      await tester.tap(find.byKey(const Key('new-perm-${Perm.memberInvite}')));
      await tester.tap(find.byKey(const Key('create-role-submit')));
      await tester.pumpAndSettle();

      final created = roles.roleNamed('Billing');
      expect(created.permissions, {Perm.memberInvite});
      expect(find.text('Billing'), findsOneWidget);
    });

    testWidgets('a taken name is explained', (tester) async {
      await _openRoles(tester, FakeRolesClient());

      await tester.tap(find.byKey(const Key('new-role')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('role-name')), 'admin');
      await tester.tap(find.byKey(const Key('create-role-submit')));
      await tester.pumpAndSettle();

      expect(
        find.text('A role with that name already exists.'),
        findsOneWidget,
      );
    });
  });

  group('rename and delete', () {
    testWidgets('renames a custom role', (tester) async {
      final roles = await _withSupport();
      await _openRoles(tester, roles);

      await tester.tap(find.byKey(const Key('role-menu-100')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('role-name')), 'Helpdesk');
      await tester.tap(find.byKey(const Key('rename-role-submit')));
      await tester.pumpAndSettle();

      expect(roles.roleNamed('Helpdesk').permissions, {Perm.memberView});
    });

    testWidgets('deleting an unused role needs no target', (tester) async {
      final roles = await _withSupport();
      await _openRoles(tester, roles);

      await tester.tap(find.byKey(const Key('role-menu-100')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete-role-submit')));
      await tester.pumpAndSettle();

      expect(roles.deletes, [(id: '100', reassignTo: null)]);
      expect(find.text('Support'), findsNothing);
    });

    testWidgets('deleting a role with members asks where to move them', (
      tester,
    ) async {
      final roles = await _withSupport(members: 2);
      await _openRoles(tester, roles);

      await tester.tap(find.byKey(const Key('role-menu-100')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      FilledButton submit() => tester.widget<FilledButton>(
        find.byKey(const Key('delete-role-submit')),
      );
      expect(submit().onPressed, isNull);

      await tester.tap(find.byKey(const Key('reassign-to')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Member').last);
      await tester.pumpAndSettle();
      expect(submit().onPressed, isNotNull);
      await tester.tap(find.byKey(const Key('delete-role-submit')));
      await tester.pumpAndSettle();

      expect(roles.deletes, [(id: '100', reassignTo: '3')]);
    });
  });

  testWidgets('a role change re-reads the caller permissions', (tester) async {
    final roles = await _withSupport();
    await _openRoles(tester, roles);
    final before = roles.checks.length;

    await tester.tap(find.byKey(const Key('cell-100-${Perm.memberInvite}')));
    await tester.pumpAndSettle();

    expect(roles.checks.length, greaterThan(before));
  });
}
