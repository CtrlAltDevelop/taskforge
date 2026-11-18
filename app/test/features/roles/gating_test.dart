import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';

import '../members/fakes.dart';
import '../workspaces/fakes.dart';
import 'fakes.dart';

FakeMembersClient _team() => FakeMembersClient(
  members: [
    member('u1', 'Zoe Owner', owner: true),
    member('u2', 'Hank Hill'),
    member('u3', 'Peggy Hill', role: 'Viewer'),
  ],
  invitations: [invitation('i1', email: 'a@example.com')],
);

Future<FakeRolesClient> _openSettings(
  WidgetTester tester,
  String role, {
  FakeMembersClient? members,
}) async {
  final roles = FakeRolesClient(callerRole: (_) => role);
  await pumpSignedIn(
    tester,
    FakeWorkspaceClient([ws('w1', 'Acme')]),
    roles: roles,
    overrides: [membersClientProvider.overrideWithValue(members ?? _team())],
  );
  await tester.tap(byKey('open-workspace-settings'));
  await tester.pumpAndSettle();
  return roles;
}

Future<void> _openMembers(WidgetTester tester) async {
  await tester.ensureVisible(byKey('open-members'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(byKey('open-members'));
  await tester.pumpAndSettle();
  await tester.tap(byKey('open-members'));
  await tester.pumpAndSettle();
}

bool _fieldEnabled(WidgetTester tester, String key) =>
    tester
        .widget<TextField>(
          find.descendant(of: byKey(key), matching: find.byType(TextField)),
        )
        .enabled ??
    true;

void main() {
  group('workspace settings', () {
    testWidgets('a Viewer can read but not edit or delete', (tester) async {
      await _openSettings(tester, 'Viewer');

      expect(_fieldEnabled(tester, 'settings-name'), isFalse);
      expect(byKey('save-workspace'), findsNothing);
      expect(byKey('change-logo'), findsNothing);
      expect(find.text('Danger zone'), findsNothing);
      expect(byKey('open-members'), findsOneWidget);
      expect(byKey('open-roles'), findsOneWidget);
    });

    testWidgets('an Admin edits but cannot delete', (tester) async {
      await _openSettings(tester, 'Admin');

      expect(_fieldEnabled(tester, 'settings-name'), isTrue);
      await tester.enterText(byKey('settings-name'), 'Renamed');
      await tester.pump();
      expect(byKey('save-workspace'), findsOneWidget);
      expect(find.text('Danger zone'), findsNothing);
    });

    testWidgets('an Owner also sees the danger zone', (tester) async {
      await _openSettings(tester, 'Owner');

      expect(_fieldEnabled(tester, 'settings-name'), isTrue);
      expect(find.text('Danger zone'), findsOneWidget);
    });

    testWidgets('a custom role without member.view has no Members link', (
      tester,
    ) async {
      final roles = FakeRolesClient(callerRole: (_) => 'Nobody');
      await roles.create('w1', name: 'Nobody', permissions: {});
      await pumpSignedIn(
        tester,
        FakeWorkspaceClient([ws('w1', 'Acme')]),
        roles: roles,
      );
      await tester.tap(byKey('open-workspace-settings'));
      await tester.pumpAndSettle();

      expect(byKey('open-members'), findsNothing);
      expect(byKey('open-roles'), findsNothing);
    });
  });

  group('members screen', () {
    testWidgets('a Viewer sees chips, a disabled Invite and no actions', (
      tester,
    ) async {
      await _openSettings(tester, 'Viewer');
      await _openMembers(tester);

      expect(
        find.descendant(of: byKey('member-u3'), matching: find.text('Viewer')),
        findsOneWidget,
      );
      expect(byKey('remove-u2'), findsNothing);
      expect(byKey('role-option-3'), findsNothing);
      expect(
        find.byTooltip(
          'You need permission "member.invite" — your role is Viewer',
        ),
        findsOneWidget,
      );

      await tester.tap(byKey('open-invite'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tap(byKey('tab-pending'));
      await tester.pumpAndSettle();
      expect(byKey('revoke-i1'), findsNothing);
      expect(byKey('resend-i1'), findsNothing);
    });

    testWidgets('a Member may invite and manage invitations, not remove', (
      tester,
    ) async {
      await _openSettings(tester, 'Member');
      await _openMembers(tester);
      expect(byKey('remove-u2'), findsNothing);

      await tester.tap(byKey('tab-pending'));
      await tester.pumpAndSettle();
      expect(byKey('revoke-i1'), findsOneWidget);
    });

    testWidgets('an Admin removes members and sees role menus', (tester) async {
      await _openSettings(tester, 'Admin');
      await _openMembers(tester);

      expect(byKey('remove-u2'), findsOneWidget);
      expect(byKey('remove-u1'), findsNothing);
      expect(byKey('role-u2'), findsOneWidget);
    });
  });

  group('role dropdown', () {
    testWidgets('changes a role, refreshes members and permissions', (
      tester,
    ) async {
      final members = _team();
      final roles = await _openSettings(tester, 'Admin', members: members);
      await _openMembers(tester);
      final checks = roles.checks.length;

      await tester.tap(byKey('role-u2'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('role-option-4'));
      await tester.pumpAndSettle();

      expect(members.roleChanges, [(userId: 'u2', roleId: '4')]);
      expect(
        find.descendant(of: byKey('member-u2'), matching: find.text('Viewer')),
        findsOneWidget,
      );
      expect(roles.checks.length, greaterThan(checks));
    });

    testWidgets('works from the profile card', (tester) async {
      final members = _team();
      await _openSettings(tester, 'Owner', members: members);
      await _openMembers(tester);

      await tester.tap(byKey('member-u2'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('profile-role'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('role-option-2'));
      await tester.pumpAndSettle();

      expect(members.roleChanges, [(userId: 'u2', roleId: '2')]);
    });

    testWidgets('a denial shows the server reason and changes nothing', (
      tester,
    ) async {
      final members = _team()
        ..failNext = const InviteException(
          InviteFailure.denied,
          'You need permission "role.manage" — your role is Admin',
        );
      await _openSettings(tester, 'Admin', members: members);
      await _openMembers(tester);

      await tester.tap(byKey('role-u2'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('role-option-1'));
      await tester.pumpAndSettle();

      expect(
        find.text('You need permission "role.manage" — your role is Admin'),
        findsOneWidget,
      );
      expect(
        find.descendant(of: byKey('member-u2'), matching: find.text('Member')),
        findsOneWidget,
      );
    });

    testWidgets('demoting the last owner explains why', (tester) async {
      final members = _team()
        ..failNext = const InviteException(InviteFailure.ownerProtected);
      await _openSettings(tester, 'Owner', members: members);
      await _openMembers(tester);

      await tester.tap(byKey('role-u1'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('role-option-3'));
      await tester.pumpAndSettle();

      expect(
        find.text('A workspace needs at least one owner.'),
        findsOneWidget,
      );
    });
  });
}
