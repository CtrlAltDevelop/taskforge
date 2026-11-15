import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/offline/presentation/offline_screen.dart';
import 'package:taskforge/core/public_routes.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/features/dashboards/presentation/dashboards_screen.dart';
import 'package:taskforge/features/goals/presentation/goal_detail_screen.dart';
import 'package:taskforge/features/goals/presentation/goals_screen.dart';
import 'package:taskforge/features/workload/presentation/workload_screen.dart';
import 'package:taskforge/features/workload/presentation/workload_settings.dart';
import 'package:taskforge/features/templates/domain/templates.dart';
import 'package:taskforge/features/templates/presentation/templates_screen.dart';
import 'package:taskforge/features/audit/presentation/audit_screen.dart';
import 'package:taskforge/features/imports/presentation/import_screen.dart';
import 'package:taskforge/features/account/home_screen.dart';
import 'package:taskforge/features/account/language_screen.dart';
import 'package:taskforge/features/account/sessions_screen.dart';
import 'package:taskforge/features/auth/change_password_screen.dart';
import 'package:taskforge/features/auth/forgot_password_screen.dart';
import 'package:taskforge/features/auth/reset_password_screen.dart';
import 'package:taskforge/features/auth/sign_in_screen.dart';
import 'package:taskforge/features/auth/sign_up_screen.dart';
import 'package:taskforge/features/debug/debug_screen.dart';
import 'package:taskforge/features/calendar/presentation/workspace_calendar_screen.dart';
import 'package:taskforge/features/chat/presentation/chat_screen.dart';
import 'package:taskforge/features/inbox/presentation/inbox_screen.dart';
import 'package:taskforge/features/inbox/presentation/prefs_screen.dart';
import 'package:taskforge/features/automations/presentation/automations_screen.dart';
import 'package:taskforge/features/developer/presentation/deliveries_screen.dart';
import 'package:taskforge/features/developer/presentation/developer_screen.dart';
import 'package:taskforge/features/docs/presentation/docs_screen.dart';
import 'package:taskforge/features/forms/presentation/form_builder_screen.dart';
import 'package:taskforge/features/forms/presentation/forms_screen.dart';
import 'package:taskforge/features/forms/presentation/public_form_page.dart';
import 'package:taskforge/features/forms/presentation/submissions_screen.dart';
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
import 'package:taskforge/features/security/application/security_providers.dart';
import 'package:taskforge/features/security/presentation/security_screen.dart';
import 'package:taskforge/features/security/presentation/sso_callback_screen.dart';
import 'package:taskforge/features/security/presentation/sso_setup_screen.dart';
import 'package:taskforge/features/security/presentation/two_factor_screen.dart';
import 'package:taskforge/core/auth/auth_api.dart' show SecondFactorRequired;
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/presentation/system_screen.dart';
import 'package:taskforge/features/system/presentation/version_screens.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/presentation/onboarding_screen.dart';
import 'package:taskforge/features/workspaces/presentation/settings_screen.dart';

/// Pages a signed-out user may see (and a signed-in one is sent away from).
const _authPaths = {
  '/sign-in',
  '/sign-up',
  '/forgot-password',
  '/reset-password',
  '/two-factor',
  '/sso/callback',
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

/// Maps the native links onto in-app routes: `taskforge://invite/<token>`
/// (host `invite`, path `/<token>`) and `taskforge://sso/callback?ticket=...`;
/// null for every other location.
String? customSchemeRoute(Uri uri) {
  if (uri.scheme == 'taskforge' && uri.host == 'sso') {
    // The system browser coming back from single sign-on: keep ticket/error.
    return Uri(
      path: '/sso/callback',
      query: uri.query.isEmpty ? null : uri.query,
    ).toString();
  }
  if (uri.scheme != 'taskforge' || uri.host != 'invite') return null;
  final token = uri.pathSegments.where((s) => s.isNotEmpty).firstOrNull;
  return token == null ? '/' : '/invite/${Uri.encodeComponent(token)}';
}

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);
  // Re-run the redirect whenever the workspace list changes (zero-workspace guard).
  final workspacesChanged = ValueNotifier(0);
  ref.listen(workspacesProvider, (_, _) => workspacesChanged.value++);
  // The two-factor gate: re-run the redirect when the policy answer changes.
  ref.listen(securityPolicyProvider, (_, _) => workspacesChanged.value++);
  // An app older than the server's minimum is held on one screen until it is updated.
  ref.listen(updateRequiredProvider, (_, _) => workspacesChanged.value++);
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
      final mustUpdate = ref.read(updateRequiredProvider);
      final atUpdate = state.uri.path == '/update-required';
      if (mustUpdate && !atUpdate) return '/update-required';
      if (!mustUpdate && atUpdate) return '/';
      // Public pages (an intake form) need no account and no redirect.
      if (isPublicAppPath(state.uri.path)) return null;
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
      // A workspace that requires two-factor and a member who has not turned
      // it on (grace over): only the security screen opens until they do.
      final policy = ref.read(securityPolicyProvider).value;
      if (policy != null &&
          policy.blocked &&
          !state.uri.path.startsWith('/settings/security')) {
        return '/settings/security';
      }
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
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
      GoRoute(path: '/system', builder: (_, _) => const SystemScreen()),
      GoRoute(
        path: '/update-required',
        builder: (_, _) => const UpdateRequiredScreen(),
      ),
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
      GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),
      GoRoute(
        path: '/chat/:spaceId',
        builder: (_, state) =>
            ChatScreen(spaceId: state.pathParameters['spaceId']),
      ),
      GoRoute(path: '/timesheet', builder: (_, _) => const TimesheetScreen()),
      GoRoute(
        path: '/inbox/preferences',
        builder: (_, _) => const NotificationPrefsScreen(),
      ),
      GoRoute(path: '/members', builder: (_, _) => const MembersScreen()),
      GoRoute(path: '/audit', builder: (_, _) => const AuditScreen()),
      GoRoute(path: '/import', builder: (_, _) => const ImportScreen()),
      GoRoute(path: '/developer', builder: (_, _) => const DeveloperScreen()),
      GoRoute(
        path: '/f/:token',
        builder: (_, state) =>
            PublicFormPage(token: state.pathParameters['token']!),
      ),
      GoRoute(path: '/forms', builder: (_, _) => const FormsScreen()),
      // Fixed paths before `:id`.
      GoRoute(
        path: '/forms/new',
        builder: (_, state) =>
            FormBuilderScreen(projectId: state.uri.queryParameters['project']),
      ),
      GoRoute(
        path: '/forms/:id',
        builder: (_, state) =>
            FormBuilderScreen(formId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/forms/:id/submissions',
        builder: (_, state) =>
            SubmissionsScreen(formId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/developer/webhooks/:id',
        builder: (_, state) =>
            DeliveriesScreen(webhookId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/dashboards', builder: (_, _) => const DashboardsScreen()),
      GoRoute(path: '/goals', builder: (_, _) => const GoalsScreen()),
      GoRoute(path: '/workload', builder: (_, _) => const WorkloadScreen()),
      GoRoute(
        path: '/workload/settings',
        builder: (_, _) => const WorkloadSettingsScreen(),
      ),
      GoRoute(
        path: '/templates',
        builder: (_, state) => TemplatesScreen(
          kind: state.uri.queryParameters['kind'] == 'project'
              ? TemplateKind.project
              : null,
        ),
      ),
      GoRoute(
        path: '/goals/:id',
        builder: (_, state) =>
            GoalDetailScreen(goalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/projects/:id/dashboards',
        builder: (_, state) =>
            DashboardsScreen(projectId: state.pathParameters['id']!),
      ),
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
        path: '/settings/security',
        builder: (_, _) => const SecurityScreen(),
      ),
      GoRoute(path: '/settings/sso', builder: (_, _) => const SsoSetupScreen()),
      GoRoute(
        path: '/two-factor',
        // The challenge is passed as navigation state; without it, start over.
        redirect: (_, state) =>
            state.extra is SecondFactorRequired ? null : '/sign-in',
        builder: (_, state) => TwoFactorScreen(
          challenge: state.extra as SecondFactorRequired,
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: '/sso/callback',
        builder: (_, state) => SsoCallbackScreen(
          ticket: state.uri.queryParameters['ticket'],
          error: state.uri.queryParameters['sso_error'],
        ),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (_, _) => const LanguageScreen(),
      ),
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
      GoRoute(path: '/offline', builder: (_, _) => const OfflineScreen()),
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
