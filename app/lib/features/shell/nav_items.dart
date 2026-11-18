import 'package:flutter/foundation.dart';

import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Where an entry sits in the frame.
enum NavSection {
  /// Fixed entries at the top of the sidebar (and the phone's bottom bar).
  main,

  /// Collapsed "Workspace" group.
  workspace,

  /// Collapsed "Admin" group, permitted entries only.
  admin,

  /// The avatar menu.
  account,

  /// Under the projects list.
  projects,
}

/// Extra gates beyond a role permission.
enum NavGate {
  none,

  /// Only when the server answers the system page (administrators).
  systemAdmin,

  /// Only in debug builds (the route does not exist in release).
  debugBuild,
}

/// One place the frame links to. The sidebar, the phone's More sheet, the
/// avatar menu and the breadcrumbs all read [navItems].
@immutable
class NavItem {
  const NavItem({
    required this.id,
    required this.path,
    required this.icon,
    required this.labelOf,
    required this.section,
    this.permission,
    this.gate = NavGate.none,
  });

  final String id;
  final String path;
  final TfIconData icon;
  final String Function(AppLocalizations) labelOf;
  final NavSection section;

  /// Absent (not disabled) without this workspace permission.
  final String? permission;
  final NavGate gate;
}

final List<NavItem> navItems = [
  NavItem(
    id: 'home',
    path: '/',
    icon: TfIcons.home,
    labelOf: (l) => l.grpKTHome,
    section: NavSection.main,
  ),
  NavItem(
    id: 'my-work',
    path: '/my-work',
    icon: TfIcons.checkAll,
    labelOf: (l) => l.mwTitle,
    section: NavSection.main,
  ),
  NavItem(
    id: 'inbox',
    path: '/inbox',
    icon: TfIcons.inbox,
    labelOf: (l) => l.grpEInbox,
    section: NavSection.main,
  ),
  NavItem(
    id: 'chat',
    path: '/chat',
    icon: TfIcons.chat,
    labelOf: (l) => l.chatTitle,
    section: NavSection.main,
  ),
  NavItem(
    id: 'dashboards',
    path: '/dashboards',
    icon: TfIcons.dashboard,
    labelOf: (l) => l.grpEDashboards,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'goals',
    path: '/goals',
    icon: TfIcons.target,
    labelOf: (l) => l.goalsTitle,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'docs',
    path: '/docs',
    icon: TfIcons.file,
    labelOf: (l) => l.grpEDocs,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'calendar',
    path: '/calendar',
    icon: TfIcons.calendar,
    labelOf: (l) => l.calendar,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'workload',
    path: '/workload',
    icon: TfIcons.chart,
    labelOf: (l) => l.wlTitle,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'timesheet',
    path: '/timesheet',
    icon: TfIcons.clock,
    labelOf: (l) => l.grpETimesheet,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'forms',
    path: '/forms',
    icon: TfIcons.form,
    labelOf: (l) => l.formsTitle,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'templates',
    path: '/templates',
    icon: TfIcons.copy,
    labelOf: (l) => l.tplTitle,
    section: NavSection.workspace,
  ),
  NavItem(
    id: 'members',
    path: '/members',
    icon: TfIcons.users,
    labelOf: (l) => l.grpKTMembers,
    section: NavSection.admin,
    permission: Perm.memberView,
  ),
  NavItem(
    id: 'roles',
    path: '/workspaces/roles',
    icon: TfIcons.shield,
    labelOf: (l) => l.grpKTRoles,
    section: NavSection.admin,
    permission: Perm.roleView,
  ),
  NavItem(
    id: 'import',
    path: '/import',
    icon: TfIcons.upload,
    labelOf: (l) => l.grpKTImportExport,
    section: NavSection.admin,
    permission: Perm.dataManage,
  ),
  NavItem(
    id: 'audit',
    path: '/audit',
    icon: TfIcons.history,
    labelOf: (l) => l.grpKAuditLog,
    section: NavSection.admin,
    permission: Perm.auditView,
  ),
  NavItem(
    id: 'developer',
    path: '/developer',
    icon: TfIcons.code,
    labelOf: (l) => l.devTitle,
    section: NavSection.admin,
  ),
  NavItem(
    id: 'settings',
    path: '/workspaces/settings',
    icon: TfIcons.settings,
    labelOf: (l) => l.grpKTWorkspaceSettings,
    section: NavSection.admin,
  ),
  NavItem(
    id: 'system',
    path: '/system',
    icon: TfIcons.server,
    labelOf: (l) => l.sysTitle,
    section: NavSection.admin,
    gate: NavGate.systemAdmin,
  ),
  NavItem(
    id: 'archived',
    path: '/projects/archived',
    icon: TfIcons.archive,
    labelOf: (l) => l.grpEArchivedProjects,
    section: NavSection.projects,
  ),
  NavItem(
    id: 'private-projects',
    path: '/projects/private',
    icon: TfIcons.lock,
    labelOf: (l) => l.grpEPrivateProjects,
    section: NavSection.projects,
    permission: Perm.projectViewPrivate,
  ),
  NavItem(
    id: 'appearance',
    path: '/settings/appearance',
    icon: TfIcons.sun,
    labelOf: (l) => l.appearance,
    section: NavSection.account,
  ),
  NavItem(
    id: 'language',
    path: '/settings/language',
    icon: TfIcons.globe,
    labelOf: (l) => l.languageAndRegion,
    section: NavSection.account,
  ),
  NavItem(
    id: 'notifications',
    path: '/inbox/preferences',
    icon: TfIcons.bell,
    labelOf: (l) => l.grpENotifSettings,
    section: NavSection.account,
  ),
  NavItem(
    id: 'security',
    path: '/settings/security',
    icon: TfIcons.shield,
    labelOf: (l) => l.secTitle,
    section: NavSection.account,
  ),
  NavItem(
    id: 'sessions',
    path: '/sessions',
    icon: TfIcons.devices,
    labelOf: (l) => l.grpISessions,
    section: NavSection.account,
  ),
  NavItem(
    id: 'password',
    path: '/change-password',
    icon: TfIcons.lock,
    labelOf: (l) => l.changePassword,
    section: NavSection.account,
  ),
  NavItem(
    id: 'offline',
    path: '/offline',
    icon: TfIcons.cloudOff,
    labelOf: (l) => l.grpKTOffline,
    section: NavSection.account,
  ),
  NavItem(
    id: 'connectivity',
    path: '/debug',
    icon: TfIcons.wifi,
    labelOf: (l) => l.connectivity,
    section: NavSection.account,
  ),
  NavItem(
    id: 'about',
    path: '/about',
    icon: TfIcons.info,
    labelOf: (l) => l.sysAboutTitle,
    section: NavSection.account,
  ),
  NavItem(
    id: 'gallery',
    path: '/debug/gallery',
    icon: TfIcons.palette,
    labelOf: (l) => l.shellGallery,
    section: NavSection.account,
    gate: NavGate.debugBuild,
  ),
];

Iterable<NavItem> navSection(NavSection section) =>
    navItems.where((i) => i.section == section);

/// The entry the open [path] belongs to: the longest matching path, so a
/// deep link (`/goals/g1`) lights its family and `/inbox/preferences` lights
/// itself, not Inbox. Null for project pages and anything unlisted.
NavItem? activeNavItem(String path) {
  NavItem? best;
  for (final item in navItems) {
    final p = item.path;
    final matches = p == '/'
        ? path == '/'
        : path == p || path.startsWith('$p/');
    if (matches && (best == null || p.length > best.path.length)) best = item;
  }
  return best;
}

/// Pages opened from another page rather than from the frame, by route
/// pattern, with the page that links to them. The route-coverage test
/// accepts a route listed here or in [navItems].
const childRoutes = {
  '/workspaces/new': '/',
  '/settings/sso': '/settings/security',
  '/workload/settings': '/workload',
  '/forms/new': '/forms',
  '/forms/:id': '/forms',
  '/forms/:id/submissions': '/forms',
  '/developer/webhooks/:id': '/developer',
  '/docs/:id': '/docs',
  '/goals/:id': '/goals',
  '/chat/:spaceId': '/chat',
  '/projects/:id': 'sidebar',
  '/projects/:id/settings': '/projects/:id',
  '/projects/:id/sprints': '/projects/:id',
  '/projects/:id/automations': '/projects/:id',
  '/projects/:id/workflow': '/projects/:id',
  '/projects/:id/fields': '/projects/:id',
  '/projects/:id/dashboards': '/projects/:id',
};

/// Routes that are not part of the signed-in app: sign-in, public forms,
/// links from email, gates the router sends people to.
const outsideFrameRoutes = {
  '/sign-in',
  '/sign-up',
  '/forgot-password',
  '/reset-password',
  '/two-factor',
  '/sso/callback',
  '/f/:token',
  '/invite/:token',
  '/onboarding',
  '/welcome/starter',
  '/welcome/invite',
  '/update-required',
};

/// Where to land after switching workspace: the same kind of page, without
/// the item that belonged to the old workspace (`/docs/d1` → `/docs`).
/// Project pages have no list of their own, so they go home.
String pageTypeRoot(String path) {
  if (path.startsWith('/projects/')) {
    const lists = {'/projects/archived', '/projects/private'};
    return lists.contains(path) ? path : '/';
  }
  for (final family in const ['/docs', '/goals', '/chat', '/forms']) {
    if (path.startsWith('$family/')) return family;
  }
  if (path.startsWith('/developer/')) return '/developer';
  return path;
}
