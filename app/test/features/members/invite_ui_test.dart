import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

Future<void> _openMembers(
  WidgetTester tester,
  FakeMembersClient members,
) async {
  await pumpSignedIn(
    tester,
    FakeWorkspaceClient([ws('w1', 'Acme')]),
    overrides: [membersClientProvider.overrideWithValue(members)],
  );
  await tester.tap(byKey('open-workspace-settings'));
  await tester.pumpAndSettle();
  await tester.tap(byKey('open-members'));
  await tester.pumpAndSettle();
}

Future<void> _openInvite(WidgetTester tester) async {
  await tester.tap(byKey('open-invite'));
  await tester.pumpAndSettle();
}

Future<void> _addEmail(WidgetTester tester, String text) async {
  await tester.enterText(byKey('invite-email-input'), text);
  await tester.tap(byKey('add-email'));
  await tester.pumpAndSettle();
}

void main() {
  group('email tab', () {
    testWidgets('refuses an invalid address', (tester) async {
      await _openMembers(tester, FakeMembersClient());
      await _openInvite(tester);

      await _addEmail(tester, 'nope');

      expect(find.textContaining('not a valid email'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(byKey('send-invites')).onPressed,
        isNull,
      );
    });

    testWidgets('caps the list at 20 addresses', (tester) async {
      await _openMembers(tester, FakeMembersClient());
      await _openInvite(tester);

      await _addEmail(
        tester,
        [for (var i = 0; i < 21; i++) 'p$i@example.com'].join(','),
      );

      expect(find.textContaining('at most 20'), findsOneWidget);
    });

    testWidgets('sends the chips and reports skipped', (tester) async {
      final client = FakeMembersClient()..skipped = ['old@example.com'];
      await _openMembers(tester, client);
      await _openInvite(tester);

      await _addEmail(tester, 'a@example.com, b@example.com A@example.com');
      expect(find.byType(InputChip), findsNWidgets(2));
      await tester.tap(byKey('send-invites'));
      await tester.pumpAndSettle();

      expect(client.invitedBatches.single, ['a@example.com', 'b@example.com']);
      expect(find.text('Invited 2.'), findsOneWidget);
      expect(find.textContaining('old@example.com'), findsOneWidget);
    });

    testWidgets('shows a rate-limit failure', (tester) async {
      final client = FakeMembersClient()
        ..failNext = const InviteException(InviteFailure.rateLimited);
      await _openMembers(tester, client);
      await _openInvite(tester);
      await _addEmail(tester, 'a@example.com');

      await tester.tap(byKey('send-invites'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Too many invitations'), findsOneWidget);
    });
  });

  group('link tab', () {
    testWidgets('creates a link with the chosen expiry and uses, with copy', (
      tester,
    ) async {
      final client = FakeMembersClient();
      await _openMembers(tester, client);
      await _openInvite(tester);
      await tester.tap(byKey('invite-tab-link'));
      await tester.pumpAndSettle();

      await tester.tap(byKey('link-expiry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30 days').last);
      await tester.pumpAndSettle();
      await tester.enterText(byKey('link-max-uses'), '5');
      await tester.tap(byKey('create-link'));
      await tester.pumpAndSettle();

      expect(client.links.single, (expiresIn: 30 * 86400, maxUses: 5));
      expect(find.textContaining('/invite/linktok'), findsOneWidget);

      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.tap(byKey('copy-link'));
      await tester.pumpAndSettle();
      expect(copied, endsWith('/invite/linktok'));
    });

    testWidgets('rejects a bad max uses before any call', (tester) async {
      final client = FakeMembersClient();
      await _openMembers(tester, client);
      await _openInvite(tester);
      await tester.tap(byKey('invite-tab-link'));
      await tester.pumpAndSettle();

      await tester.enterText(byKey('link-max-uses'), '5000');
      await tester.tap(byKey('create-link'));
      await tester.pumpAndSettle();

      expect(find.textContaining('1 to 1000'), findsOneWidget);
      expect(client.links, isEmpty);
    });
  });

  group('pending tab', () {
    FakeMembersClient pending() => FakeMembersClient(
      invitations: [
        invitation('i1', email: 'a@example.com'),
        invitation('i2', email: 'b@example.com', state: InviteState.expired),
        invitation('i3'),
      ],
    );

    testWidgets('lists invitations with state chips', (tester) async {
      await _openMembers(tester, pending());
      await tester.tap(byKey('tab-pending'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: byKey('state-i1'), matching: find.text('Pending')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: byKey('state-i2'), matching: find.text('Expired')),
        findsOneWidget,
      );
      expect(byKey('resend-i3'), findsNothing); // links cannot be resent
      expect(byKey('copy-i1'), findsNothing); // token not known this session
    });

    testWidgets('revoke marks the invitation revoked', (tester) async {
      await _openMembers(tester, pending());
      await tester.tap(byKey('tab-pending'));
      await tester.pumpAndSettle();

      await tester.tap(byKey('revoke-i1'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: byKey('state-i1'), matching: find.text('Revoked')),
        findsOneWidget,
      );
    });

    testWidgets('email invitations never offer a copyable link', (
      tester,
    ) async {
      final client = pending();
      await _openMembers(tester, client);
      await tester.tap(byKey('tab-pending'));
      await tester.pumpAndSettle();

      await tester.tap(byKey('resend-i1'));
      await tester.pumpAndSettle();

      expect(client.resent, ['i1']);
      expect(find.text('Invitation resent.'), findsOneWidget);
      expect(byKey('copy-i1'), findsNothing);
      expect(byKey('revoke-i1'), findsOneWidget);
    });

    testWidgets('a link invitation with a known token is copyable', (
      tester,
    ) async {
      final client = FakeMembersClient(
        invitations: [invitation('l1', token: 'tok')],
      );
      await _openMembers(tester, client);
      await tester.tap(byKey('tab-pending'));
      await tester.pumpAndSettle();

      expect(byKey('copy-l1'), findsOneWidget);
    });
  });
}
