import 'package:flutter/material.dart';

import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/features/shortcuts/application/action_groups.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart' as d;
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/members/presentation/invite_dialog.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/presentation/create_project_dialog.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/shortcuts/presentation/prompt_dialog.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

/// How long a sprint made from the palette lasts; its page changes the dates.
const quickSprintDays = 14;

bool _can(ActionContext c, String permission) =>
    c.container.read(permissionSetProvider).can(permission);

List<Workspace> _workspaces(ActionContext c) =>
    c.container.read(workspacesProvider).value ?? const [];

void _say(ActionContext c, String message) {
  if (!c.context.mounted) return;
  ScaffoldMessenger.maybeOf(c.context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _guarded(ActionContext c, Future<void> Function() act) async {
  try {
    await act();
  } on Object catch (e) {
    if (!c.context.mounted) return;
    _say(c, c.context.l10n.grpDActionFailed(e.toString()));
  }
}

Future<void> _switchWorkspace(ActionContext c) async {
  final all = _workspaces(c);
  final current = c.container.read(currentWorkspaceProvider);
  final pick = await showDialog<Workspace>(
    context: c.context,
    builder: (dialog) => SimpleDialog(
      title: Text(dialog.l10n.grpDSwitchWorkspace),
      children: [
        for (final w in all)
          SimpleDialogOption(
            key: Key('pick-workspace-${w.id}'),
            onPressed: () => Navigator.of(dialog).pop(w),
            child: Text(
              w.id == current?.id
                  ? dialog.l10n.grpDWorkspaceHere(w.name)
                  : w.name,
            ),
          ),
      ],
    ),
  );
  if (pick == null || pick.id == current?.id) return;
  await c.container.read(selectedWorkspaceIdProvider.notifier).select(pick.id);
  c.router.go('/');
}

Future<void> _createDoc(ActionContext c) async {
  final title = await promptText(
    c.context,
    title: c.context.l10n.grpDNewDoc,
    label: c.context.l10n.grpDTitle,
    initial: c.context.l10n.grpDUntitled,
  );
  if (title == null) return;
  await _guarded(c, () async {
    final page = await c.container
        .read(docsActionsProvider)
        .create(projectId: c.projectId ?? '', title: title);
    c.router.go('/docs/${page.node.id}');
  });
}

Future<void> _createDashboard(ActionContext c) async {
  final name = await promptText(
    c.context,
    title: c.context.l10n.grpDNewDashboard,
  );
  if (name == null) return;
  await _guarded(c, () async {
    await c.container
        .read(dashboardActionsProvider)
        .save(
          d.Dashboard(
            id: '',
            name: name,
            visibility: d.DashVisibility.personal,
            projectId: c.projectId ?? '',
            widgets: const [],
            layout: const [],
          ),
        );
    c.router.go(
      c.projectId == null
          ? '/dashboards'
          : '/projects/${c.projectId}/dashboards',
    );
  });
}

Future<void> _createSprint(ActionContext c) async {
  final project = c.projectId;
  if (project == null) return;
  final name = await promptText(c.context, title: c.context.l10n.grpDNewSprint);
  if (name == null) return;
  await _guarded(c, () async {
    final today = DateTime.now();
    await c.container
        .read(sprintActionsProvider)
        .create(
          project,
          name: name,
          start: today,
          end: today.add(const Duration(days: quickSprintDays)),
        );
    c.router.go('/projects/$project/sprints');
  });
}

AppAction _go(
  String id,
  String Function(AppLocalizations) title,
  String path, {
  String Function(AppLocalizations) group = groupWorkspace,
  List<String> keywords = const [],
  bool Function(ActionContext)? allowed,
}) => AppAction(
  id: id,
  titleOf: title,
  groupOf: group,
  semanticOf: (l) => l.grpKGoTo(title(l)),
  keywords: keywords,
  available: (c) => c.location != path && (allowed?.call(c) ?? true),
  run: (c) => c.router.go(path),
);

/// Making things, switching and leaving, and the screens added after the
/// first set: the rest of what a person does every day, so the palette can
/// reach all of it.
final List<AppAction> moreActions = [
  AppAction(
    id: 'workspace.switch',
    titleOf: (l) => l.grpKSwitchWs,
    groupOf: groupWorkspace,
    semanticOf: (l) => l.grpKSwitchWsSem,
    keywords: const ['change', 'company', 'team'],
    available: (c) => _workspaces(c).length > 1,
    run: _switchWorkspace,
  ),
  AppAction(
    id: 'theme.toggle',
    titleOf: (l) => l.grpKToggleDark,
    groupOf: groupGeneral,
    semanticOf: (l) => l.grpKToggleDarkSem,
    keywords: const ['theme', 'light', 'dark', 'appearance'],
    run: (c) => c.container
        .read(themeModeProvider.notifier)
        .toggle(Theme.of(c.context).brightness),
  ),
  AppAction(
    id: 'project.create',
    titleOf: (l) => l.grpKCreateProject,
    groupOf: groupProjects,
    semanticOf: (l) => l.grpKCreateProject,
    keywords: const ['new', 'add'],
    available: (c) => _can(c, Perm.projectCreate),
    run: (c) => createProject(c.context),
  ),
  AppAction(
    id: 'doc.create',
    titleOf: (l) => l.grpKCreateDoc,
    groupOf: groupDocs,
    semanticOf: (l) => l.grpKCreateDoc,
    keywords: const ['new', 'page', 'wiki', 'write'],
    available: (c) => _can(c, Perm.docEdit),
    run: _createDoc,
  ),
  AppAction(
    id: 'dashboard.create',
    titleOf: (l) => l.grpKCreateDashboard,
    groupOf: groupDashboards,
    semanticOf: (l) => l.grpKCreateDashboard,
    keywords: const ['new', 'report', 'chart'],
    run: _createDashboard,
  ),
  AppAction(
    id: 'sprint.create',
    titleOf: (l) => l.grpKCreateSprint,
    groupOf: groupThisProject,
    semanticOf: (l) => l.grpKCreateSprintSem,
    keywords: const ['new', 'iteration', 'plan'],
    available: (c) {
      final id = c.projectId;
      final project = id == null ? null : c.container.read(projectProvider(id));
      return project != null &&
          !project.isArchived &&
          project.enabledFeatures.contains(sprintsFeature) &&
          _can(c, Perm.sprintManage);
    },
    run: _createSprint,
  ),
  AppAction(
    id: 'member.invite',
    titleOf: (l) => l.grpKInviteMember,
    groupOf: groupWorkspace,
    semanticOf: (l) => l.grpKInviteMemberSem,
    keywords: const ['add', 'people', 'email', 'team'],
    available: (c) => _can(c, Perm.memberInvite),
    run: (c) => showDialog<void>(
      context: c.context,
      builder: (_) => const InviteDialog(),
    ),
  ),
  _go(
    'nav.import',
    (l) => l.grpKTImportExport,
    '/import',
    keywords: const ['jira', 'clickup', 'csv', 'backup', 'download'],
    allowed: (c) => _can(c, Perm.dataManage),
  ),
  _go(
    'nav.offline',
    (l) => l.grpKTOffline,
    '/offline',
    group: groupAccount,
    keywords: const ['sync', 'cache', 'pending', 'conflicts'],
  ),
  AppAction(
    id: 'account.sign_out',
    titleOf: (l) => l.grpKSignOut,
    groupOf: groupAccount,
    semanticOf: (l) => l.grpKSignOutSem,
    keywords: const ['log out', 'logout', 'leave'],
    run: (c) => c.container.read(authSessionProvider).signOut(),
  ),
];
