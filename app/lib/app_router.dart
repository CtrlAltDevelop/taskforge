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
import 'package:taskforge/features/home/presentation/home_screen.dart';
import 'package:taskforge/features/onboarding/presentation/invite_step.dart';
import 'package:taskforge/features/onboarding/presentation/starter_screen.dart';
import 'package:taskforge/features/home/presentation/my_work_screen.dart';
import 'package:taskforge/features/account/appearance_screen.dart';
import 'package:taskforge/features/account/language_screen.dart';
import 'package:taskforge/features/account/sessions_screen.dart';
import 'package:taskforge/features/auth/change_password_screen.dart';
import 'package:taskforge/features/auth/forgot_password_screen.dart';
import 'package:taskforge/features/auth/reset_password_screen.dart';
import 'package:taskforge/features/auth/sign_in_screen.dart';
import 'package:taskforge/features/auth/sign_up_screen.dart';
import 'package:taskforge/core/ui/gallery/component_gallery.dart';
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
import 'package:taskforge/features/shell/app_frame.dart';
import 'package:taskforge/features/shell/nav_items.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/presentation/system_screen.dart';
import 'package:taskforge/features/system/presentation/status_screens.dart';
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
    if (previous == null || next == previous) return;
    // Same kind of page in the new workspace; its old items do not exist there.
    final target = pageTypeRoot(path);
    if (target != path) router.go(target);
  });
  router = GoRouter(
    errorBuilder: (_, _) => const NotFoundScreen(),
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
      GoRoute(
        path: '/update-required',
        builder: (_, _) => const UpdateRequiredScreen(),
      ),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/welcome/starter',
        builder: (_, _) => const StarterScreen(),
      ),
      GoRoute(
        path: '/welcome/invite',
        builder: (_, state) => InviteStepScreen(
          projectId: state.uri.queryParameters['project'] ?? '',
        ),
      ),
      GoRoute(
        path: '/workspaces/new',
        builder: (_, _) => const OnboardingScreen(firstWorkspace: false),
      ),
      GoRoute(
        path: '/f/:token',
        builder: (_, state) =>
            PublicFormPage(token: state.pathParameters['token']!),
      ),
      GoRoute(
        path: '/invite/:token',
        builder: (_, state) =>
            InviteScreen(token: state.pathParameters['token']!),
      ),
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
      GoRoute(
        path: '/',
        pageBuilder: (_, state) => framedPage(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (_, state) => framedPage(state, const AboutScreen()),
      ),
      GoRoute(
        path: '/system',
        pageBuilder: (_, state) => framedPage(state, const SystemScreen()),
      ),
      GoRoute(
        path: '/workspaces/settings',
        pageBuilder: (_, state) =>
            framedPage(state, const WorkspaceSettingsScreen()),
      ),
      GoRoute(
        path: '/workspaces/roles',
        pageBuilder: (_, state) => framedPage(state, const RolesScreen()),
      ),
      // Fixed paths first: `:id` would otherwise swallow them.
      GoRoute(
        path: '/projects/archived',
        pageBuilder: (_, state) =>
            framedPage(state, const ArchivedProjectsScreen()),
      ),
      GoRoute(
        path: '/projects/private',
        pageBuilder: (_, state) =>
            framedPage(state, const PrivateProjectsScreen()),
      ),
      GoRoute(
        path: '/projects/:id',
        pageBuilder: (_, state) => framedPage(
          state,
          ProjectScreen(
            projectId: state.pathParameters['id']!,
            taskId: state.uri.queryParameters['task'],
            view: state.uri.queryParameters['view'],
          ),
        ),
      ),
      GoRoute(
        path: '/projects/:id/settings',
        pageBuilder: (_, state) => framedPage(
          state,
          ProjectSettingsScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/sprints',
        pageBuilder: (_, state) => framedPage(
          state,
          SprintsScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/automations',
        pageBuilder: (_, state) => framedPage(
          state,
          AutomationsScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/workflow',
        pageBuilder: (_, state) => framedPage(
          state,
          WorkflowScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/fields',
        pageBuilder: (_, state) => framedPage(
          state,
          FieldsScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/docs',
        pageBuilder: (_, state) => framedPage(
          state,
          DocsScreen(project: state.uri.queryParameters['project'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/docs/:id',
        pageBuilder: (_, state) => framedPage(
          state,
          DocsScreen(
            docId: state.pathParameters['id'],
            project: state.uri.queryParameters['project'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/my-work',
        pageBuilder: (_, state) => framedPage(state, const MyWorkScreen()),
      ),
      GoRoute(
        path: '/inbox',
        pageBuilder: (_, state) => framedPage(state, const InboxScreen()),
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (_, state) => framedPage(state, const ChatScreen()),
      ),
      GoRoute(
        path: '/chat/:spaceId',
        pageBuilder: (_, state) => framedPage(
          state,
          ChatScreen(spaceId: state.pathParameters['spaceId']),
        ),
      ),
      GoRoute(
        path: '/timesheet',
        pageBuilder: (_, state) => framedPage(state, const TimesheetScreen()),
      ),
      GoRoute(
        path: '/inbox/preferences',
        pageBuilder: (_, state) =>
            framedPage(state, const NotificationPrefsScreen()),
      ),
      GoRoute(
        path: '/members',
        pageBuilder: (_, state) => framedPage(state, const MembersScreen()),
      ),
      GoRoute(
        path: '/audit',
        pageBuilder: (_, state) => framedPage(state, const AuditScreen()),
      ),
      GoRoute(
        path: '/import',
        pageBuilder: (_, state) => framedPage(state, const ImportScreen()),
      ),
      GoRoute(
        path: '/developer',
        pageBuilder: (_, state) => framedPage(state, const DeveloperScreen()),
      ),
      GoRoute(
        path: '/forms',
        pageBuilder: (_, state) => framedPage(state, const FormsScreen()),
      ),
      // Fixed paths before `:id`.
      GoRoute(
        path: '/forms/new',
        pageBuilder: (_, state) => framedPage(
          state,
          FormBuilderScreen(projectId: state.uri.queryParameters['project']),
        ),
      ),
      GoRoute(
        path: '/forms/:id',
        pageBuilder: (_, state) => framedPage(
          state,
          FormBuilderScreen(formId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/forms/:id/submissions',
        pageBuilder: (_, state) => framedPage(
          state,
          SubmissionsScreen(formId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/developer/webhooks/:id',
        pageBuilder: (_, state) => framedPage(
          state,
          DeliveriesScreen(webhookId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/dashboards',
        pageBuilder: (_, state) => framedPage(state, const DashboardsScreen()),
      ),
      GoRoute(
        path: '/goals',
        pageBuilder: (_, state) => framedPage(state, const GoalsScreen()),
      ),
      GoRoute(
        path: '/workload',
        pageBuilder: (_, state) => framedPage(state, const WorkloadScreen()),
      ),
      GoRoute(
        path: '/workload/settings',
        pageBuilder: (_, state) =>
            framedPage(state, const WorkloadSettingsScreen()),
      ),
      GoRoute(
        path: '/templates',
        pageBuilder: (_, state) => framedPage(
          state,
          TemplatesScreen(
            kind: state.uri.queryParameters['kind'] == 'project'
                ? TemplateKind.project
                : null,
          ),
        ),
      ),
      GoRoute(
        path: '/goals/:id',
        pageBuilder: (_, state) => framedPage(
          state,
          GoalDetailScreen(goalId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/dashboards',
        pageBuilder: (_, state) => framedPage(
          state,
          DashboardsScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/calendar',
        pageBuilder: (_, state) =>
            framedPage(state, const WorkspaceCalendarScreen()),
      ),
      GoRoute(
        path: '/sessions',
        pageBuilder: (_, state) => framedPage(state, const SessionsScreen()),
      ),
      GoRoute(
        path: '/settings/security',
        pageBuilder: (_, state) => framedPage(state, const SecurityScreen()),
      ),
      GoRoute(
        path: '/settings/sso',
        pageBuilder: (_, state) => framedPage(state, const SsoSetupScreen()),
      ),
      GoRoute(
        path: '/settings/appearance',
        pageBuilder: (_, state) => framedPage(state, const AppearanceScreen()),
      ),
      GoRoute(
        path: '/settings/language',
        pageBuilder: (_, state) => framedPage(state, const LanguageScreen()),
      ),
      GoRoute(
        path: '/change-password',
        pageBuilder: (_, state) =>
            framedPage(state, const ChangePasswordScreen()),
      ),
      GoRoute(
        path: '/offline',
        pageBuilder: (_, state) => framedPage(state, const OfflineScreen()),
      ),
      GoRoute(
        path: '/debug',
        pageBuilder: (_, state) => framedPage(state, const DebugScreen()),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/debug/gallery',
          pageBuilder: (_, state) =>
              framedPage(state, const ComponentGallery()),
        ),
    ],
  );
  return router;
});
