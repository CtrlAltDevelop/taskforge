import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/core/ui/frame_scope.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/search/presentation/search_overlay.dart';
import 'package:taskforge/features/shortcuts/application/action_groups.dart';
import 'package:taskforge/features/shortcuts/application/more_actions.dart';
import 'package:taskforge/features/shortcuts/application/task_level_actions.dart';
import 'package:taskforge/features/shortcuts/application/view_actions.dart';
import 'package:taskforge/features/shortcuts/presentation/cheat_sheet.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

AppAction _go(
  String id,
  String Function(AppLocalizations) title,
  String path, {
  String Function(AppLocalizations) group = groupGoTo,
  String keys = '',
  String? goKey,
  List<String> keywords = const [],
}) => AppAction(
  id: id,
  titleOf: title,
  groupOf: group,
  semanticOf: (l) => l.grpKGoTo(title(l)),
  keywords: keywords,
  defaultKeys: keys,
  goKey: goKey,
  available: (c) => c.location != path,
  run: (c) => c.router.go(path),
);

/// A page of the project the person is in; only offered inside one.
AppAction _projectPage(
  String id,
  String Function(AppLocalizations) title,
  String suffix, {
  String keys = '',
  List<String> keywords = const [],
}) => AppAction(
  id: id,
  titleOf: title,
  groupOf: groupThisProject,
  semanticOf: (l) => l.grpKProjectPageOf(title(l)),
  keywords: keywords,
  defaultKeys: keys,
  available: (c) => c.projectId != null,
  run: (c) => c.router.go('/projects/${c.projectId}$suffix'),
);

/// Every action the app offers, registered once. The palette, the keys, the
/// cheat sheet and the phone quick-actions sheet all read this list. Actions
/// on the open task or the timer live in [taskLevelActions].
final List<AppAction> builtInActions = [
  AppAction(
    id: 'palette.open',
    titleOf: (l) => l.grpKPaletteOpen,
    groupOf: groupGeneral,
    semanticOf: (l) => l.grpKPaletteOpen,
    keywords: const ['actions', 'commands', 'go'],
    defaultKeys: 'mod+k',
    run: (c) => openCommandPalette(c.context),
  ),
  AppAction(
    id: 'search.open',
    titleOf: (l) => l.grpKSearch,
    groupOf: groupGeneral,
    semanticOf: (l) => l.grpKSearchSem,
    keywords: const ['find', 'lookup'],
    defaultKeys: 'slash',
    run: (c) => openSearch(c.context),
  ),
  AppAction(
    id: 'help.shortcuts',
    titleOf: (l) => l.grpKShortcuts,
    groupOf: groupGeneral,
    semanticOf: (l) => l.grpKShortcutsSem,
    keywords: const ['keys', 'cheat sheet', 'help', 'hotkeys', 'rebind'],
    defaultKeys: 'question',
    run: (c) => openCheatSheet(c.context),
  ),
  _go(
    'nav.home',
    (l) => l.grpKTHome,
    '/',
    keys: 'alt+h',
    keywords: const ['projects'],
    goKey: 'h',
  ),
  _go(
    'nav.inbox',
    (l) => l.grpKTInbox,
    '/inbox',
    keys: 'alt+i',
    keywords: const ['notifications'],
    goKey: 'i',
  ),
  _go(
    'nav.calendar',
    (l) => l.grpKTCalendar,
    '/calendar',
    keys: 'alt+c',
    keywords: const ['dates', 'schedule'],
    goKey: 'k',
  ),
  _go(
    'nav.docs',
    (l) => l.grpKTDocs,
    '/docs',
    keys: 'alt+d',
    keywords: const ['wiki', 'pages'],
    goKey: 'd',
  ),
  _go(
    'nav.dashboards',
    (l) => l.grpKTDashboards,
    '/dashboards',
    keys: 'alt+b',
    keywords: const ['reports', 'charts', 'metrics', 'widgets'],
    goKey: 'b',
  ),
  _go(
    'nav.timesheet',
    (l) => l.grpKTTimesheet,
    '/timesheet',
    keys: 'alt+t',
    keywords: const ['time', 'hours'],
    goKey: 't',
  ),
  _go(
    'nav.members',
    (l) => l.grpKTMembers,
    '/members',
    keys: 'alt+m',
    keywords: const ['people', 'invite', 'team'],
    goKey: 'm',
  ),
  _go(
    'nav.chat',
    (l) => l.chatTitle,
    '/chat',
    goKey: 'c',
    keywords: const ['messages', 'channels', 'dm'],
  ),
  _go(
    'nav.forms',
    (l) => l.formsTitle,
    '/forms',
    goKey: 'f',
    keywords: const ['intake', 'submissions'],
  ),
  _go(
    'nav.developer',
    (l) => l.devTitle,
    '/developer',
    group: groupAccount,
    goKey: 'v',
    keywords: const ['api', 'tokens', 'webhooks'],
  ),
  _go(
    'nav.goals',
    (l) => l.goalsTitle,
    '/goals',
    goKey: 'g',
    keywords: const ['okr', 'objectives', 'key results'],
  ),
  _go(
    'nav.workload',
    (l) => l.wlTitle,
    '/workload',
    goKey: 'w',
    keywords: const ['capacity', 'time off'],
  ),
  AppAction(
    id: 'nav.sidebar',
    titleOf: (l) => l.shellToggleSidebar,
    groupOf: groupGeneral,
    semanticOf: (l) => l.shellToggleSidebar,
    keywords: const ['menu', 'panel', 'collapse'],
    defaultKeys: 'bracketleft',
    sharesKeyWith: const {'task.prev'},
    available: (c) => c.taskId == null,
    run: (c) => AppFrameScope.maybeOf(c.context)?.toggleSidebar?.call(),
  ),
  _go(
    'nav.archived_projects',
    (l) => l.grpKTArchivedProjects,
    '/projects/archived',
    group: groupProjects,
  ),
  _go(
    'nav.private_projects',
    (l) => l.grpKTPrivateProjects,
    '/projects/private',
    group: groupProjects,
  ),
  _go(
    'nav.workspace_settings',
    (l) => l.grpKTWorkspaceSettings,
    '/workspaces/settings',
    group: groupWorkspace,
    keywords: const ['preferences', 'logo'],
    goKey: 's',
  ),
  AppAction(
    id: 'nav.audit',
    titleOf: (l) => l.grpKAuditLog,
    groupOf: groupWorkspace,
    semanticOf: (l) => l.grpKAuditSem,
    keywords: const ['history', 'who changed', 'log', 'export'],
    available: (c) =>
        c.location != '/audit' &&
        c.container.read(permissionSetProvider).can(Perm.auditView),
    run: (c) => c.router.go('/audit'),
  ),
  _go(
    'nav.workspace_roles',
    (l) => l.grpKTRoles,
    '/workspaces/roles',
    group: groupWorkspace,
    keywords: const ['access', 'rbac'],
  ),
  _go(
    'workspace.new',
    (l) => l.grpKTCreateWorkspace,
    '/workspaces/new',
    group: groupWorkspace,
    keywords: const ['new'],
  ),
  _go(
    'nav.inbox_preferences',
    (l) => l.grpKTNotifPrefs,
    '/inbox/preferences',
    group: groupAccount,
    keywords: const ['quiet hours', 'digest', 'mute'],
  ),
  _go(
    'nav.sessions',
    (l) => l.grpKTDevices,
    '/sessions',
    group: groupAccount,
    keywords: const ['sessions', 'security'],
  ),
  _go(
    'account.change_password',
    (l) => l.grpKTChangePassword,
    '/change-password',
    group: groupAccount,
    keywords: const ['security'],
  ),
  _projectPage(
    'project.board',
    (l) => l.grpKTTasks,
    '',
    keywords: const ['list', 'board'],
  ),
  _projectPage(
    'project.sprints',
    (l) => l.grpKTSprints,
    '/sprints',
    keywords: const ['backlog', 'burndown', 'velocity'],
  ),
  _projectPage(
    'project.dashboards',
    (l) => l.grpKTDashboards,
    '/dashboards',
    keywords: const ['reports', 'charts', 'metrics'],
  ),
  _projectPage(
    'project.automations',
    (l) => l.grpKTAutomations,
    '/automations',
    keywords: const ['rules', 'triggers'],
  ),
  _projectPage(
    'project.workflow',
    (l) => l.grpKTWorkflow,
    '/workflow',
    keywords: const ['statuses', 'transitions'],
  ),
  _projectPage(
    'project.fields',
    (l) => l.grpKTCustomFields,
    '/fields',
    keywords: const ['properties'],
  ),
  _projectPage(
    'project.settings',
    (l) => l.grpKTProjectSettings,
    '/settings',
    keywords: const ['archive', 'members', 'features'],
  ),
  ...moreActions,
  ...viewActions,
  ...taskLevelActions,
];
