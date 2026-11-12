import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/search/presentation/search_overlay.dart';
import 'package:taskforge/features/shortcuts/application/more_actions.dart';
import 'package:taskforge/features/shortcuts/application/task_level_actions.dart';
import 'package:taskforge/features/shortcuts/application/view_actions.dart';
import 'package:taskforge/features/shortcuts/presentation/cheat_sheet.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

AppAction _go(
  String id,
  String title,
  String path, {
  String group = 'Go to',
  String keys = '',
  List<String> keywords = const [],
}) => AppAction(
  id: id,
  title: title,
  group: group,
  semanticLabel: 'Go to $title',
  keywords: keywords,
  defaultKeys: keys,
  available: (c) => c.location != path,
  run: (c) => c.router.go(path),
);

/// A page of the project the person is in; only offered inside one.
AppAction _projectPage(
  String id,
  String title,
  String suffix, {
  String keys = '',
  List<String> keywords = const [],
}) => AppAction(
  id: id,
  title: title,
  group: 'This project',
  semanticLabel: '$title of this project',
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
    title: 'Open the command palette',
    group: 'General',
    semanticLabel: 'Open the command palette',
    keywords: const ['actions', 'commands', 'go'],
    defaultKeys: 'mod+k',
    run: (c) => openCommandPalette(c.context),
  ),
  AppAction(
    id: 'search.open',
    title: 'Search',
    group: 'General',
    semanticLabel: 'Search tasks, comments, projects and people',
    keywords: const ['find', 'lookup'],
    defaultKeys: 'slash',
    run: (c) => openSearch(c.context),
  ),
  AppAction(
    id: 'help.shortcuts',
    title: 'Keyboard shortcuts',
    group: 'General',
    semanticLabel: 'Show the keyboard shortcuts',
    keywords: const ['keys', 'cheat sheet', 'help', 'hotkeys', 'rebind'],
    defaultKeys: 'question',
    run: (c) => openCheatSheet(c.context),
  ),
  _go('nav.home', 'Home', '/', keys: 'alt+h', keywords: const ['projects']),
  _go(
    'nav.inbox',
    'Inbox',
    '/inbox',
    keys: 'alt+i',
    keywords: const ['notifications'],
  ),
  _go(
    'nav.calendar',
    'Workspace calendar',
    '/calendar',
    keys: 'alt+c',
    keywords: const ['dates', 'schedule'],
  ),
  _go(
    'nav.docs',
    'Docs',
    '/docs',
    keys: 'alt+d',
    keywords: const ['wiki', 'pages'],
  ),
  _go(
    'nav.dashboards',
    'Dashboards',
    '/dashboards',
    keys: 'alt+b',
    keywords: const ['reports', 'charts', 'metrics', 'widgets'],
  ),
  _go(
    'nav.timesheet',
    'Timesheet',
    '/timesheet',
    keys: 'alt+t',
    keywords: const ['time', 'hours'],
  ),
  _go(
    'nav.members',
    'Members',
    '/members',
    keys: 'alt+m',
    keywords: const ['people', 'invite', 'team'],
  ),
  _go(
    'nav.archived_projects',
    'Archived projects',
    '/projects/archived',
    group: 'Projects',
  ),
  _go(
    'nav.private_projects',
    'Private projects',
    '/projects/private',
    group: 'Projects',
  ),
  _go(
    'nav.workspace_settings',
    'Workspace settings',
    '/workspaces/settings',
    group: 'Workspace',
    keywords: const ['preferences', 'logo'],
  ),
  AppAction(
    id: 'nav.audit',
    title: 'Audit log',
    group: 'Workspace',
    semanticLabel: 'Go to the audit log',
    keywords: const ['history', 'who changed', 'log', 'export'],
    available: (c) =>
        c.location != '/audit' &&
        c.container.read(permissionSetProvider).can(Perm.auditView),
    run: (c) => c.router.go('/audit'),
  ),
  _go(
    'nav.workspace_roles',
    'Roles and permissions',
    '/workspaces/roles',
    group: 'Workspace',
    keywords: const ['access', 'rbac'],
  ),
  _go(
    'workspace.new',
    'Create a workspace',
    '/workspaces/new',
    group: 'Workspace',
    keywords: const ['new'],
  ),
  _go(
    'nav.inbox_preferences',
    'Notification preferences',
    '/inbox/preferences',
    group: 'Account',
    keywords: const ['quiet hours', 'digest', 'mute'],
  ),
  _go(
    'nav.sessions',
    'Signed-in devices',
    '/sessions',
    group: 'Account',
    keywords: const ['sessions', 'security'],
  ),
  _go(
    'account.change_password',
    'Change password',
    '/change-password',
    group: 'Account',
    keywords: const ['security'],
  ),
  _projectPage('project.board', 'Tasks', '', keywords: const ['list', 'board']),
  _projectPage(
    'project.sprints',
    'Sprints',
    '/sprints',
    keywords: const ['backlog', 'burndown', 'velocity'],
  ),
  _projectPage(
    'project.dashboards',
    'Dashboards',
    '/dashboards',
    keywords: const ['reports', 'charts', 'metrics'],
  ),
  _projectPage(
    'project.automations',
    'Automations',
    '/automations',
    keywords: const ['rules', 'triggers'],
  ),
  _projectPage(
    'project.workflow',
    'Workflow',
    '/workflow',
    keywords: const ['statuses', 'transitions'],
  ),
  _projectPage(
    'project.fields',
    'Custom fields',
    '/fields',
    keywords: const ['properties'],
  ),
  _projectPage(
    'project.settings',
    'Project settings',
    '/settings',
    keywords: const ['archive', 'members', 'features'],
  ),
  ...moreActions,
  ...viewActions,
  ...taskLevelActions,
];
