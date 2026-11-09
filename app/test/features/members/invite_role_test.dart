import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

Future<void> _openInvite(WidgetTester tester, FakeMembersClient members) async {
  await pumpSignedIn(
    tester,
    FakeWorkspaceClient([ws('w1', 'Acme')]),
    overrides: [membersClientProvider.overrideWithValue(members)],
  );
  await tester.tap(byKey('open-workspace-settings'));
  await tester.pumpAndSettle();
  await tester.tap(byKey('open-members'));
  await tester.pumpAndSettle();
  await tester.tap(byKey('open-invite'));
  await tester.pumpAndSettle();
}

Future<void> _pickRole(WidgetTester tester, String field, String name) async {
  await tester.tap(byKey(field));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

Future<void> _addEmail(WidgetTester tester) async {
  await tester.enterText(byKey('invite-email-input'), 'a@example.com');
  await tester.tap(byKey('add-email'));
  await tester.pumpAndSettle();
}

Future<void> _openLinkTab(WidgetTester tester) async {
  await tester.tap(byKey('invite-tab-link'));
  await tester.pumpAndSettle();
}

void main() {
  group('email tab', () {
    testWidgets('defaults to Member and sends an empty role id', (t) async {
      final client = FakeMembersClient();
      await _openInvite(t, client);
      await _addEmail(t);

      await t.tap(byKey('send-invites'));
      await t.pumpAndSettle();

      expect(client.inviteRoleIds.single, '');
    });

    testWidgets('sends the chosen role id', (t) async {
      final client = FakeMembersClient();
      await _openInvite(t, client);
      await _addEmail(t);
      await _pickRole(t, 'invite-role', 'Viewer');

      await t.tap(byKey('send-invites'));
      await t.pumpAndSettle();

      expect(client.inviteRoleIds.single, builtinRoleIds['Viewer']);
    });

    testWidgets('shows the server reason when the role is refused', (t) async {
      const reason = 'You cannot grant more than you hold.';
      final client = FakeMembersClient()
        ..failNext = const InviteException(InviteFailure.denied, reason);
      await _openInvite(t, client);
      await _addEmail(t);
      await _pickRole(t, 'invite-role', 'Admin');

      await t.tap(byKey('send-invites'));
      await t.pumpAndSettle();

      expect(find.text(reason), findsOneWidget);
    });
  });

  group('link tab', () {
    testWidgets('defaults to Member and sends an empty role id', (t) async {
      final client = FakeMembersClient();
      await _openInvite(t, client);
      await _openLinkTab(t);

      await t.tap(byKey('create-link'));
      await t.pumpAndSettle();

      expect(client.linkRoleIds.single, '');
    });

    testWidgets('sends the chosen role id', (t) async {
      final client = FakeMembersClient();
      await _openInvite(t, client);
      await _openLinkTab(t);
      await _pickRole(t, 'link-role', 'Admin');

      await t.tap(byKey('create-link'));
      await t.pumpAndSettle();

      expect(client.linkRoleIds.single, builtinRoleIds['Admin']);
    });

    testWidgets('shows the server reason when the role is refused', (t) async {
      const reason = 'You cannot grant more than you hold.';
      final client = FakeMembersClient()
        ..failNext = const InviteException(InviteFailure.denied, reason);
      await _openInvite(t, client);
      await _openLinkTab(t);

      await t.tap(byKey('create-link'));
      await t.pumpAndSettle();

      expect(find.text(reason), findsOneWidget);
    });
  });

  testWidgets('pending list shows each invitation role name', (t) async {
    final client = FakeMembersClient(
      invitations: [
        invitation('i1', email: 'a@example.com', roleName: 'Viewer'),
      ],
    );
    await pumpSignedIn(
      t,
      FakeWorkspaceClient([ws('w1', 'Acme')]),
      overrides: [membersClientProvider.overrideWithValue(client)],
    );
    await t.tap(byKey('open-workspace-settings'));
    await t.pumpAndSettle();
    await t.tap(byKey('open-members'));
    await t.pumpAndSettle();
    await t.tap(byKey('tab-pending'));
    await t.pumpAndSettle();

    expect(
      find.descendant(of: byKey('role-i1'), matching: find.text('Viewer')),
      findsOneWidget,
    );
  });
}
