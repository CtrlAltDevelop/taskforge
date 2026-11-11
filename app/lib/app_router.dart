import 'package:flutter/foundation.dart';
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
import 'package:taskforge/features/calendar/presentation/workspace_calendar_screen.dart';
import 'package:taskforge/features/inbox/presentation/inbox_screen.dart';
import 'package:taskforge/features/inbox/presentation/prefs_screen.dart';
import 'package:taskforge/features/automations/presentation/automations_screen.dart';
import 'package:taskforge/features/docs/presentation/docs_screen.dart';
import 'package:taskforge/features/sprints/presentation/sprints_screen.dart';
import 'package:taskforge/features/time/presentation/timesheet_screen.dart';
import 'package:taskforge/features/members/presentation/invite_screen.dart';
import 'package:taskforge/features/members/presentation/members_screen.dart';
import 'package:taskforge/features/projects/presentation/archived_screen.dart';
import 'package:taskforge/features/projects/presentation/private_projects_screen.dart';
import 'package:taskforge/features/projects/presentation/project_screen.dart';
import 'package:taskforge/features/projects/presentation/project_settings_screen.dart';
import 'package:taskforge/features/fields/presentation/fields_screen.dart';
import 'package:taskforge/features/workflows/presentation/workflow_screen.dart';
import 'package:taskforge/features/roles/presentation/roles_screen.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/presentation/onboarding_screen.dart';
import 'package:taskforge/features/workspaces/presentation/settings_screen.dart';

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

/// Maps the native link `taskforge://invite/<token>` (host `invite`, path
/// `/<token>`) onto the in-app route; null for every other location.
String? customSchemeRoute(Uri uri) {
  if (uri.scheme != 'taskforge' || uri.host != 'invite') return null;
  final token = uri.pathSegments.where((s) => s.isNotEmpty).firstOrNull;
  return token == null ? '/' : '/invite/${Uri.encodeComponent(token)}';
}

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);
  // Re-run the redirect whenever the workspace list changes (zero-workspace guard).
  final workspacesChanged = ValueNotifier(0);
  ref.listen(workspacesProvider, (_, _) => workspacesChanged.value++);
  ref.onDispose(workspacesChanged.dispose);
  late final GoRouter router;
  // A project belongs to one workspace: leave its pages when the workspace changes.
  ref.listen(workspaceScopeProvider, (previous, next) {
    final path = router.routeInformationProvider.value.uri.path;
    if (previous != null && next != previous && path.startsWith('/projects/')) {
      router.go('/');
    }
  });
  router = GoRouter(
    refreshListenable: Listenable.merge([session, workspacesChanged]),
    redirect: (context, state) {
      final native = customSchemeRoute(state.uri);
      if (native != null) return native;
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
      if (!signedIn) return null;
      // Signed in with no workspace: always onboarding. While the list is still
      // loading (or failed) stay put; the screens show their own progress/retry.
      final workspaces = ref.read(workspacesProvider).value;
      if (workspaces == null) return null;
      final atOnboarding = state.uri.path == '/onboarding';
      // An invitation may be the way into a first workspace, so it stays reachable.
      final atInvite = state.uri.path.startsWith('/invite/');
      if (workspaces.isEmpty && !atOnboarding && !atInvite) {
        return '/onboarding';
      }
      if (workspaces.isNotEmpty && atOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/workspaces/new',
        builder: (_, _) => const OnboardingScreen(firstWorkspace: false),
      ),
      GoRoute(
        path: '/workspaces/settings',
        builder: (_, _) => const WorkspaceSettingsScreen(),
      ),
      GoRoute(
        path: '/workspaces/roles',
        builder: (_, _) => const RolesScreen(),
      ),
      // Fixed paths first: `:id` would otherwise swallow them.
      GoRoute(
        path: '/projects/archived',
        builder: (_, _) => const ArchivedProjectsScreen(),
      ),
      GoRoute(
        path: '/projects/private',
        builder: (_, _) => const PrivateProjectsScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (_, state) => ProjectScreen(
          projectId: state.pathParameters['id']!,
          taskId: state.uri.queryParameters['task'],
          view: state.uri.queryParameters['view'],
        ),
      ),
      GoRoute(
        path: '/projects/:id/settings',
        builder: (_, state) =>
            ProjectSettingsScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/projects/:id/sprints',
        builder: (_, state) =>
            SprintsScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/projects/:id/automations',
        builder: (_, state) =>
            AutomationsScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/projects/:id/workflow',
        builder: (_, state) =>
            WorkflowScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/projects/:id/fields',
        builder: (_, state) =>
            FieldsScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/docs',
        builder: (_, state) =>
            DocsScreen(project: state.uri.queryParameters['project'] ?? ''),
      ),
      GoRoute(
        path: '/docs/:id',
        builder: (_, state) => DocsScreen(
          docId: state.pathParameters['id'],
          project: state.uri.queryParameters['project'] ?? '',
        ),
      ),
      GoRoute(path: '/inbox', builder: (_, _) => const InboxScreen()),
      GoRoute(path: '/timesheet', builder: (_, _) => const TimesheetScreen()),
      GoRoute(
        path: '/inbox/preferences',
        builder: (_, _) => const NotificationPrefsScreen(),
      ),
      GoRoute(path: '/members', builder: (_, _) => const MembersScreen()),
      GoRoute(
        path: '/calendar',
        builder: (_, _) => const WorkspaceCalendarScreen(),
      ),
      GoRoute(
        path: '/invite/:token',
        builder: (_, state) =>
            InviteScreen(token: state.pathParameters['token']!),
      ),
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
  return router;
});
