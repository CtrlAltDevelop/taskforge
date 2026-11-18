import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/app.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/home_screen.dart';
import 'package:taskforge/features/account/sessions_api.dart';
import 'package:taskforge/features/security/application/security_providers.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/auth/sign_in_screen.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../security/fakes.dart';
import '../system/fakes.dart';
import '../workspaces/fakes.dart' show FakeWorkspaceClient, ws;

class _FakeApi implements AuthApi {
  AuthApiException? failWith;
  NetworkUnavailable? offline;
  AuthApiException? refreshFails;
  Exception? revokeFails;
  final revoked = <String>[];
  final signUps = <(String, String)>[];

  AuthTokens get _tokens =>
      const AuthTokens(accessToken: 'a.b.c', refreshToken: 'r', sessionId: 's');

  @override
  Future<AuthTokens> signIn(String email, String password) async {
    if (offline != null) throw offline!;
    if (failWith != null) throw failWith!;
    return _tokens;
  }

  @override
  Future<AuthTokens> signUp(String email, String password) async {
    signUps.add((email, password));
    return _tokens;
  }

  @override
  Future<AuthTokens> refresh(String refreshToken, {String? requestId}) async {
    if (refreshFails != null) throw refreshFails!;
    return _tokens;
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> revokeSession(String accessToken, String sessionId) async {
    if (revokeFails != null) throw revokeFails!;
    revoked.add(sessionId);
  }

  final changed = <(String, String)>[];
  final resetRequests = <String>[];
  final resets = <(String, String, String)>[];
  AuthApiException? resetFails;

  @override
  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  ) async {
    changed.add((currentPassword, newPassword));
  }

  @override
  Future<String> requestPasswordReset(String email) async {
    resetRequests.add(email);
    return 'ticket-1';
  }

  @override
  Future<void> resetPassword({
    required String ticket,
    required String code,
    required String newPassword,
  }) async {
    if (resetFails != null) throw resetFails!;
    resets.add((ticket, code, newPassword));
  }
}

class _FakeAccounts implements AccountClient {
  @override
  Future<void> updatePreferences(LocalePrefs prefs) async {}

  @override
  Future<Account> me() async =>
      const Account(email: 'zoe@example.com', displayName: 'Zoe');

  @override
  Future<List<SessionInfo>> sessions() async => const [
    SessionInfo(
      id: 's',
      userAgent: 'TaskForge macOS',
      ipAddress: '127.0.0.1',
      lastUsedAt: '',
      current: true,
    ),
    SessionInfo(
      id: 'other',
      userAgent: 'Firefox',
      ipAddress: '10.0.0.2',
      lastUsedAt: '',
      current: false,
    ),
  ];
}

/// The session list is REST now; it answers the same two sessions.
class _FakeSessionsApi implements SessionsApi {
  @override
  Future<List<SessionInfo>> list() => _FakeAccounts().sessions();

  @override
  Future<String> rename(String sessionId, String name) async => name;
}

Future<(AuthSession, _FakeApi)> _pump(
  WidgetTester tester, {
  AuthTokens? signedInAs,
}) async {
  final api = _FakeApi();
  final store = MemoryTokenStore();
  if (signedInAs != null) await store.write(signedInAs);
  final session = AuthSession(api: api, store: store);
  await session.restore();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWithValue(session),
        syncClientProvider.overrideWithValue(null),
        accountClientProvider.overrideWithValue(_FakeAccounts()),
        sessionsApiProvider.overrideWithValue(_FakeSessionsApi()),
        securityClientProvider.overrideWithValue(FakeSecurityClient()),
        systemClientProvider.overrideWithValue(FakeSystemClient()),
        workspaceClientProvider.overrideWithValue(
          FakeWorkspaceClient([ws('w1', 'Acme')]),
        ),
      ],
      child: const TaskForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (session, api);
}

void main() {
  testWidgets('a signed-out user is sent to the sign-in screen', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Sign in'), findsWidgets);
    expect(find.byKey(const Key('email')), findsOneWidget);
  });

  testWidgets('signing in lands on the home screen showing the account', (
    tester,
  ) async {
    await _pump(tester);

    await tester.enterText(find.byKey(const Key('email')), 'zoe@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'Xq7-mnbvcz');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(find.text('zoe@example.com'), findsOneWidget);
  });

  testWidgets(
    'wrong credentials show a message and stay on the sign-in screen',
    (tester) async {
      final (_, api) = await _pump(tester);
      api.failWith = const AuthApiException(
        status: 401,
        title: 'INVALID_CREDENTIALS',
        message: 'x',
      );

      await tester.enterText(find.byKey(const Key('email')), 'zoe@example.com');
      await tester.enterText(find.byKey(const Key('password')), 'Xq7-mnbvcz');
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();

      expect(find.text('Wrong email or password.'), findsOneWidget);
      expect(find.byKey(const Key('email')), findsOneWidget);
    },
  );

  testWidgets('sign-in while offline says so and stays on sign-in', (
    tester,
  ) async {
    final (_, api) = await _pump(tester);
    api.offline = const NetworkUnavailable('socket closed');

    await tester.enterText(find.byKey(const Key('email')), 'zoe@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'Xq7-mnbvcz');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cannot reach the server'), findsOneWidget);
    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  for (final screen in ['sign-in', 'sign-up']) {
    testWidgets('$screen password can be shown and hidden', (tester) async {
      await _pump(tester);
      if (screen == 'sign-up') {
        await tester.tap(find.byKey(const Key('go-sign-up')));
        await tester.pumpAndSettle();
      }
      bool obscured() => tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('password')),
              matching: find.byType(TextField),
            ),
          )
          .obscureText;
      expect(obscured(), isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(obscured(), isFalse);

      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(obscured(), isTrue);
    });
  }

  testWidgets('a short password is rejected before any request is made', (
    tester,
  ) async {
    final (_, api) = await _pump(tester);
    await tester.tap(find.byKey(const Key('go-sign-up')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email')), 'zoe@example.com');
    await tester.enterText(find.byKey(const Key('password')), '123456789');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('at least 10'), findsOneWidget);
    expect(api.signUps, isEmpty);
  });

  testWidgets('a valid sign-up creates the account and signs in', (
    tester,
  ) async {
    final (session, api) = await _pump(tester);
    await tester.tap(find.byKey(const Key('go-sign-up')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email')), 'zoe@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'Xq7-mnbvcz');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(api.signUps, [('zoe@example.com', 'Xq7-mnbvcz')]);
    expect(session.status, AuthStatus.signedIn);
  });

  testWidgets(
    'a stored session opens straight on the home screen and can sign out',
    (tester) async {
      final (session, _) = await _pump(
        tester,
        signedInAs: const AuthTokens(
          accessToken: 'a.b.c',
          refreshToken: 'r',
          sessionId: 's',
        ),
      );
      expect(find.text('zoe@example.com'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(session.status, AuthStatus.signedOut);
      expect(find.byKey(const Key('email')), findsOneWidget);
    },
  );

  testWidgets('the sessions screen lists devices and marks the current one', (
    tester,
  ) async {
    await _pump(
      tester,
      signedInAs: const AuthTokens(
        accessToken: 'a.b.c',
        refreshToken: 'r',
        sessionId: 's',
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('open-sessions')));

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-sessions')));
    await tester.pumpAndSettle();

    expect(find.text('TaskForge macOS'), findsOneWidget);
    expect(find.text('This device'), findsOneWidget);
    expect(find.text('Firefox'), findsOneWidget);
  });

  testWidgets(
    'revoking another device calls the server for that session only',
    (tester) async {
      final (_, api) = await _pump(
        tester,
        signedInAs: const AuthTokens(
          accessToken: 'a.b.c',
          refreshToken: 'r',
          sessionId: 's',
        ),
      );
      await tester.ensureVisible(find.byKey(const Key('open-sessions')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-sessions')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('revoke-other')));
      await tester.pumpAndSettle();

      expect(api.revoked, ['other']);
    },
  );

  testWidgets(
    '"sign out other devices" revokes every session except this one',
    (tester) async {
      final (_, api) = await _pump(
        tester,
        signedInAs: const AuthTokens(
          accessToken: 'a.b.c',
          refreshToken: 'r',
          sessionId: 's',
        ),
      );
      await tester.ensureVisible(find.byKey(const Key('open-sessions')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-sessions')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('revoke-others')));
      await tester.pumpAndSettle();

      expect(api.revoked, ['other']);
      expect(api.revoked, isNot(contains('s')));
    },
  );

  testWidgets(
    'an expired session returns to sign-in and remembers where the user was',
    (tester) async {
      final (session, api) = await _pump(
        tester,
        signedInAs: const AuthTokens(
          accessToken: 'a.b.c',
          refreshToken: 'r',
          sessionId: 's',
        ),
      );
      GoRouter.of(tester.element(find.byType(HomeScreen)))
          .go('/sessions'); // as a reload or deep link would
      await tester.pumpAndSettle();
      api.refreshFails = const AuthApiException(
        status: 401,
        title: 'SESSION_ENDED',
        message: 'ended',
      );

      await session.accessToken(); // the stored token is unreadable, so this tries to refresh
      await tester.pumpAndSettle();

      expect(session.status, AuthStatus.signedOut);
      expect(
        tester.widget<SignInScreen>(find.byType(SignInScreen)).from,
        '/sessions',
      );
    },
  );

  testWidgets('a failed revoke shows a message instead of failing silently', (
    tester,
  ) async {
    final (_, api) = await _pump(
      tester,
      signedInAs: const AuthTokens(
        accessToken: 'a.b.c',
        refreshToken: 'r',
        sessionId: 's',
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('open-sessions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-sessions')));
    await tester.pumpAndSettle();
    api.revokeFails = const NetworkUnavailable('offline');

    await tester.tap(find.byKey(const Key('revoke-other')));
    await tester.pumpAndSettle();

    expect(find.textContaining('reach the server'), findsOneWidget);
  });

  testWidgets('changing the password signs the user out and says so', (
    tester,
  ) async {
    final (session, api) = await _pump(
      tester,
      signedInAs: const AuthTokens(
        accessToken: 'a.b.c',
        refreshToken: 'r',
        sessionId: 's',
      ),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('open-change-password')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-change-password')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('current-password')),
      'Xq7-mnbvcz',
    );
    await tester.enterText(
      find.byKey(const Key('new-password')),
      'N3w-passphrase',
    );
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(api.changed, [('Xq7-mnbvcz', 'N3w-passphrase')]);
    expect(session.status, AuthStatus.signedOut);
    expect(find.text('Password changed. Sign in again.'), findsOneWidget);
    expect(find.byKey(const Key('email')), findsOneWidget);
  });

  testWidgets('a too-short new password is rejected before any request', (
    tester,
  ) async {
    final (_, api) = await _pump(
      tester,
      signedInAs: const AuthTokens(
        accessToken: 'a.b.c',
        refreshToken: 'r',
        sessionId: 's',
      ),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('open-change-password')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-change-password')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('current-password')),
      'Xq7-mnbvcz',
    );
    await tester.enterText(find.byKey(const Key('new-password')), 'short');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('at least 10'), findsOneWidget);
    expect(api.changed, isEmpty);
  });

  testWidgets(
    'forgot password: request a code, then set a new password with it',
    (tester) async {
      final (_, api) = await _pump(tester);
      await tester.tap(find.byKey(const Key('go-forgot')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email')), 'zoe@example.com');
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      expect(api.resetRequests, ['zoe@example.com']);

      await tester.enterText(find.byKey(const Key('reset-code')), '418239');
      await tester.enterText(
        find.byKey(const Key('new-password')),
        'N3w-passphrase',
      );
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();

      expect(api.resets, [('ticket-1', '418239', 'N3w-passphrase')]);
      expect(find.text('Password updated. Sign in with it.'), findsOneWidget);
      expect(find.byKey(const Key('email')), findsOneWidget);
    },
  );

  testWidgets(
    'a wrong or expired reset code shows the server message and stays put',
    (tester) async {
      final (_, api) = await _pump(tester);
      api.resetFails = const AuthApiException(
        status: 400,
        title: 'CODE_INVALID',
        message: 'That code is not right.',
      );
      await tester.tap(find.byKey(const Key('go-forgot')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('email')), 'zoe@example.com');
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('reset-code')), '000000');
      await tester.enterText(
        find.byKey(const Key('new-password')),
        'N3w-passphrase',
      );
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();

      expect(find.text('That code is not right.'), findsOneWidget);
      expect(find.byKey(const Key('reset-code')), findsOneWidget);
    },
  );

  testWidgets(
    'opening Sessions from Home keeps the return path if the session then expires',
    (tester) async {
      final (session, api) = await _pump(
        tester,
        signedInAs: const AuthTokens(
          accessToken: 'a.b.c',
          refreshToken: 'r',
          sessionId: 's',
        ),
      );
      await tester.ensureVisible(find.byKey(const Key('open-sessions')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-sessions')));
      await tester.pumpAndSettle();
      api.refreshFails = const AuthApiException(
        status: 401,
        title: 'SESSION_ENDED',
        message: 'ended',
      );

      await session.accessToken();
      await tester.pumpAndSettle();

      expect(
        tester.widget<SignInScreen>(find.byType(SignInScreen)).from,
        '/sessions',
      );
    },
  );

  testWidgets('the Sessions screen has a way back to Home', (tester) async {
    await _pump(
      tester,
      signedInAs: const AuthTokens(
        accessToken: 'a.b.c',
        refreshToken: 'r',
        sessionId: 's',
      ),
    );
    await tester.ensureVisible(find.byKey(const Key('open-sessions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-sessions')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('back-home')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-sessions')), findsOneWidget);
  });
}
