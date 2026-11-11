import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskforge/app.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/auth/sign_in_screen.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../workspaces/fakes.dart';
import 'fakes.dart';

const _link = '/invite/abc123';

Future<ProviderContainer> _pumpSignedOut(
  WidgetTester tester,
  FakeMembersClient members,
  FakeWorkspaceClient workspaces,
) async {
  final api = MockAuthApi();
  when(() => api.signIn(any(), any())).thenAnswer(
    (_) async => const AuthTokens(
      accessToken: 'a.b.c',
      refreshToken: 'r',
      sessionId: 's',
    ),
  );
  final session = AuthSession(api: api, store: MemoryTokenStore());
  await session.restore();
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWithValue(session),
      syncClientProvider.overrideWithValue(null),
      accountClientProvider.overrideWithValue(FakeAccounts()),
      workspaceClientProvider.overrideWithValue(workspaces),
      membersClientProvider.overrideWithValue(members),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TaskForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<ProviderContainer> _pumpIn(
  WidgetTester tester,
  FakeMembersClient members, {
  FakeWorkspaceClient? workspaces,
}) async {
  final container = await pumpSignedIn(
    tester,
    workspaces ?? FakeWorkspaceClient([ws('w1', 'Acme')]),
    overrides: [membersClientProvider.overrideWithValue(members)],
  );
  container.read(routerProvider).go(_link);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('signed out: sign in, then land on the invitation', (
    tester,
  ) async {
    final container = await _pumpSignedOut(
      tester,
      FakeMembersClient(),
      FakeWorkspaceClient([ws('w1', 'Acme')]),
    );

    container.read(routerProvider).go(_link);
    await tester.pumpAndSettle();
    expect(tester.widget<SignInScreen>(find.byType(SignInScreen)).from, _link);

    await tester.enterText(byKey('email'), 'zoe@example.com');
    await tester.enterText(byKey('password'), 'Xq7-mnbvcz');
    await tester.tap(byKey('submit'));
    await tester.pumpAndSettle();

    expect(find.text('Globex'), findsOneWidget);
    expect(byKey('join-workspace'), findsOneWidget);
  });

  testWidgets('signed in: shows workspace and inviter', (tester) async {
    await _pumpIn(tester, FakeMembersClient());

    expect(find.text('Globex'), findsOneWidget);
    expect(find.textContaining('Hank invited you'), findsOneWidget);
  });

  testWidgets('accepting selects that workspace and lands on home', (
    tester,
  ) async {
    final members = FakeMembersClient();
    final workspaces = FakeWorkspaceClient([ws('w1', 'Acme')]);
    final container = await _pumpIn(tester, members, workspaces: workspaces);

    await tester.tap(byKey('join-workspace'));
    await tester.pumpAndSettle();

    expect(members.accepted, ['abc123']);
    expect(container.read(workspaceScopeProvider), 'wG');
    expect(find.text('Globex'), findsOneWidget);
    expect(byKey('open-workspace-settings'), findsOneWidget);
  });

  testWidgets('a user with no workspace can still open an invitation', (
    tester,
  ) async {
    final container = await _pumpIn(
      tester,
      FakeMembersClient(),
      workspaces: FakeWorkspaceClient(),
    );
    expect(byKey('join-workspace'), findsOneWidget);

    await tester.tap(byKey('join-workspace'));
    await tester.pumpAndSettle();

    expect(container.read(workspaceScopeProvider), 'wG');
  });

  testWidgets('declining returns home without joining', (tester) async {
    final members = FakeMembersClient();
    await _pumpIn(tester, members);

    await tester.tap(byKey('decline-invite'));
    await tester.pumpAndSettle();

    expect(members.declined, ['abc123']);
    expect(byKey('open-workspace-settings'), findsOneWidget);
  });

  group('failure messages', () {
    for (final (state, text) in [
      (InviteState.expired, 'This invitation has expired'),
      (InviteState.revoked, 'This invitation was revoked'),
      (InviteState.usedUp, 'already been used up'),
    ]) {
      testWidgets('preview state ${state.name}', (tester) async {
        final members = FakeMembersClient()
          ..previewResult = InvitePreview(
            workspaceName: 'Globex',
            inviterName: 'Hank',
            emailBound: false,
            state: state,
          );
        await _pumpIn(tester, members);

        expect(find.textContaining(text), findsOneWidget);
        expect(byKey('join-workspace'), findsNothing);
      });
    }

    testWidgets('unknown token', (tester) async {
      final members = FakeMembersClient()
        ..previewFails = const InviteException(InviteFailure.notFound);
      await _pumpIn(tester, members);

      expect(find.textContaining('does not exist'), findsOneWidget);
    });

    testWidgets('unknown token shows at once, no silent retries', (
      tester,
    ) async {
      final members = FakeMembersClient()
        ..previewFails = const InviteException(InviteFailure.notFound);
      final container = await pumpSignedIn(
        tester,
        FakeWorkspaceClient([ws('w1', 'Acme')]),
        overrides: [membersClientProvider.overrideWithValue(members)],
      );
      container.read(routerProvider).go(_link);
      // Shorter than Riverpod's first retry delay (200 ms).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('does not exist'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('email mismatch on accept', (tester) async {
      final members = FakeMembersClient()
        ..acceptFails = const InviteException(InviteFailure.emailMismatch);
      await _pumpIn(tester, members);

      await tester.tap(byKey('join-workspace'));
      await tester.pumpAndSettle();

      expect(
        find.text('This invitation is for another email address.'),
        findsOneWidget,
      );
    });

    testWidgets('expired between preview and accept', (tester) async {
      final members = FakeMembersClient()
        ..acceptFails = const InviteException(InviteFailure.expired);
      await _pumpIn(tester, members);

      await tester.tap(byKey('join-workspace'));
      await tester.pumpAndSettle();

      expect(find.textContaining('has expired'), findsOneWidget);
      expect(byKey('join-workspace'), findsNothing);
    });
  });

  testWidgets('the custom scheme opens the same invitation', (tester) async {
    final container = await pumpSignedIn(
      tester,
      FakeWorkspaceClient([ws('w1', 'Acme')]),
      overrides: [membersClientProvider.overrideWithValue(FakeMembersClient())],
    );

    container.read(routerProvider).go('taskforge://invite/abc123');
    await tester.pumpAndSettle();

    expect(byKey('join-workspace'), findsOneWidget);
  });
}
