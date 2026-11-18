import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

FakeMembersClient _team() => FakeMembersClient(
  members: [
    member('u1', 'Zoe Owner', owner: true),
    member('u2', 'Hank Hill'),
    member('u3', 'Peggy Hill'),
  ],
);

Future<void> _openMembers(
  WidgetTester tester,
  FakeMembersClient members, {
  bool owner = true,
}) async {
  await pumpSignedIn(
    tester,
    FakeWorkspaceClient([ws('w1', 'Acme', owner: owner)]),
    overrides: [membersClientProvider.overrideWithValue(members)],
  );
  await tester.tap(byKey('open-workspace-settings'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(byKey('open-members'));
  await tester.pumpAndSettle();
  await tester.tap(byKey('open-members'));
  await tester.pumpAndSettle();
}

void main() {
  group('members list', () {
    testWidgets('shows initials, joined date and an Owner chip', (
      tester,
    ) async {
      await _openMembers(tester, _team());

      expect(find.text('ZO'), findsOneWidget);
      expect(find.textContaining('Joined 2026-03-04'), findsWidgets);
      expect(
        find.descendant(of: byKey('member-u1'), matching: find.text('Owner')),
        findsOneWidget,
      );
    });

    testWidgets('search filters by name or email', (tester) async {
      await _openMembers(tester, _team());

      await tester.enterText(byKey('member-search'), 'peggy');
      await tester.pumpAndSettle();

      expect(byKey('member-u3'), findsOneWidget);
      expect(byKey('member-u2'), findsNothing);
    });
  });

  group('profile card', () {
    testWidgets('tapping a row shows details and the role', (tester) async {
      await _openMembers(tester, _team());

      await tester.tap(byKey('member-u2'));
      await tester.pumpAndSettle();

      final card = byKey('member-profile');
      expect(
        find.descendant(of: card, matching: find.text('Hank Hill')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('hank.hill@example.com')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Joined 2026-03-04')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Member')),
        findsOneWidget,
      );
    });

    testWidgets('the owner card says Owner and has no remove', (tester) async {
      await _openMembers(tester, _team());

      await tester.tap(byKey('member-u1'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: byKey('member-profile'),
          matching: find.text('Owner'),
        ),
        findsOneWidget,
      );
      expect(byKey('profile-remove'), findsNothing);
    });

    testWidgets('owner can remove from the card, after confirming', (
      tester,
    ) async {
      final client = _team();
      await _openMembers(tester, client);

      await tester.tap(byKey('member-u2'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('profile-remove'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('confirm-action'));
      await tester.pumpAndSettle();

      expect(client.removed, ['u2']);
      expect(byKey('member-profile'), findsNothing);
    });

    testWidgets('a plain member sees no remove on the card', (tester) async {
      await _openMembers(tester, _team(), owner: false);

      await tester.tap(byKey('member-u2'));
      await tester.pumpAndSettle();

      expect(byKey('member-profile'), findsOneWidget);
      expect(byKey('profile-remove'), findsNothing);
    });
  });

  group('as the owner', () {
    testWidgets('removing a member asks first, then removes', (tester) async {
      final client = _team();
      await _openMembers(tester, client);

      expect(byKey('remove-u1'), findsNothing);
      await tester.tap(byKey('remove-u2'));
      await tester.pumpAndSettle();
      expect(client.removed, isEmpty);
      await tester.tap(byKey('confirm-action'));
      await tester.pumpAndSettle();

      expect(client.removed, ['u2']);
      expect(byKey('member-u2'), findsNothing);
    });

    testWidgets('cancelling the confirmation removes nobody', (tester) async {
      final client = _team();
      await _openMembers(tester, client);

      await tester.tap(byKey('remove-u2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(client.removed, isEmpty);
    });

    testWidgets('has no Leave and is told why', (tester) async {
      await _openMembers(tester, _team());

      expect(byKey('leave-workspace'), findsNothing);
      expect(byKey('owner-cannot-leave'), findsOneWidget);
    });

    testWidgets('a refused removal shows the reason', (tester) async {
      final client = _team()
        ..failNext = const InviteException(InviteFailure.ownerProtected);
      await _openMembers(tester, client);

      await tester.tap(byKey('remove-u2'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('confirm-action'));
      await tester.pumpAndSettle();

      expect(find.textContaining('needs at least one owner'), findsOneWidget);
      expect(byKey('member-u2'), findsOneWidget);
    });
  });

  group('as a member', () {
    testWidgets('cannot remove anyone', (tester) async {
      await _openMembers(tester, _team(), owner: false);

      expect(byKey('remove-u2'), findsNothing);
      expect(byKey('leave-workspace'), findsOneWidget);
    });

    testWidgets('leaving switches to another workspace', (tester) async {
      final client = _team();
      final container = await pumpSignedIn(
        tester,
        FakeWorkspaceClient([
          ws('w1', 'Acme', owner: false),
          ws('w2', 'Initech'),
        ]),
        overrides: [membersClientProvider.overrideWithValue(client)],
      );
      await tester.tap(byKey('open-workspace-settings'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(byKey('open-members'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('open-members'));
      await tester.pumpAndSettle();

      await tester.tap(byKey('leave-workspace'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('confirm-action'));
      await tester.pumpAndSettle();

      expect(client.leaves, 1);
      expect(find.text('Initech'), findsWidgets);
      expect(container.read(workspaceScopeProvider), 'w2');
    });

    testWidgets('leaving the only workspace lands on onboarding', (
      tester,
    ) async {
      final client = _team();
      await _openMembers(tester, client, owner: false);

      await tester.tap(byKey('leave-workspace'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('confirm-action'));
      await tester.pumpAndSettle();

      expect(find.text('Create your workspace'), findsOneWidget);
    });
  });
}
