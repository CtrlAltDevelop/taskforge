import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/features/account/home_screen.dart';
import 'package:taskforge/features/account/sessions_screen.dart';
import 'package:taskforge/features/auth/change_password_screen.dart';
import 'package:taskforge/features/auth/forgot_password_screen.dart';
import 'package:taskforge/features/auth/reset_password_screen.dart';
import 'package:taskforge/features/auth/sign_in_screen.dart';
import 'package:taskforge/features/auth/sign_up_screen.dart';
import 'package:taskforge/features/debug/debug_screen.dart';

/// Pages a signed-out user may see (and a signed-in one is sent away from).
const _authPaths = {
  '/sign-in',
  '/sign-up',
  '/forgot-password',
  '/reset-password',
};

/// Signed-in pages that make no sense to return to after signing in again.
const _noReturnPaths = {'/change-password'};

/// Where to go after signing in. Only an in-app path is accepted: a `from` that
/// is absolute, protocol-relative or one of the sign-in pages is ignored.
String safeReturnPath(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return '/';
  }
  final path = Uri.tryParse(from)?.path;
  return path == null ||
          _authPaths.contains(path) ||
          _noReturnPaths.contains(path)
      ? '/'
      : from;
}

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);
  return GoRouter(
    refreshListenable: session,
    redirect: (context, state) {
      final signedIn = session.status == AuthStatus.signedIn;
      final atAuthPage = _authPaths.contains(state.uri.path);
      if (!signedIn && !atAuthPage) {
        // Remember where the user was headed so signing in can bring them back.
        final target = state.uri.toString();
        return target == '/' || _noReturnPaths.contains(state.uri.path)
            ? '/sign-in'
            : '/sign-in?from=${Uri.encodeComponent(target)}';
      }
      if (signedIn && atAuthPage) {
        return safeReturnPath(state.uri.queryParameters['from']);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/sessions', builder: (_, _) => const SessionsScreen()),
      GoRoute(
        path: '/change-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        // The ticket is passed as navigation state; without it, start over.
        redirect: (_, state) =>
            state.extra is String ? null : '/forgot-password',
        builder: (_, state) =>
            ResetPasswordScreen(ticket: state.extra as String),
      ),
      GoRoute(path: '/debug', builder: (_, _) => const DebugScreen()),
      GoRoute(
        path: '/sign-in',
        builder: (_, state) =>
            SignInScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (_, state) =>
            SignUpScreen(from: state.uri.queryParameters['from']),
      ),
    ],
  );
});
