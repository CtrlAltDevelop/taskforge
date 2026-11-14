import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/inbox/presentation/inbox_badge.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/create_project_dialog.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/search/presentation/search_overlay.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_hint.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

/// Projects of the current workspace: favorites on top, then the others.
/// [onNavigate] runs after a link is followed (the drawer closes itself).
class ProjectSidebar extends ConsumerWidget {
  const ProjectSidebar({super.key, this.onNavigate});

  final VoidCallback? onNavigate;

  void _go(BuildContext context, String location) {
    context.go(location);
    onNavigate?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(false));
    final theme = Theme.of(context);
    final projects = sidebarOrder(catalog.value?.projects ?? const []);
    final favorites = projects.where((p) => p.isFavorite).toList();
    final others = projects.where((p) => !p.isFavorite).toList();
    final current = GoRouterState.of(context).uri.path;

    Widget section(String title, List<Project> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          child: Text(title, style: theme.textTheme.labelLarge),
        ),
        for (final p in items) ...[
          ListTile(
            key: Key('project-${p.id}'),
            dense: true,
            selected: current == '/projects/${p.id}',
            leading: ProjectAvatar(project: p),
            title: Text(p.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(p.key),
            trailing: p.isPrivate
                ? Icon(
                    Icons.lock,
                    key: Key('private-${p.id}'),
                    size: 16,
                    semanticLabel: context.l10n.grpEPrivate,
                  )
                : null,
            onTap: () => _go(context, '/projects/${p.id}'),
          ),
          if (p.enabledFeatures.contains(sprintsFeature) &&
              current.startsWith('/projects/${p.id}'))
            ListTile(
              key: Key('open-sprints-${p.id}'),
              dense: true,
              contentPadding: const EdgeInsetsDirectional.only(
                start: 40,
                end: 16,
              ),
              selected: current == '/projects/${p.id}/sprints',
              leading: const Icon(Icons.timelapse, size: 20),
              title: Text(context.l10n.grpESprints),
              onTap: () => _go(context, '/projects/${p.id}/sprints'),
            ),
          if (current.startsWith('/projects/${p.id}'))
            ListTile(
              key: Key('open-automations-${p.id}'),
              dense: true,
              contentPadding: const EdgeInsetsDirectional.only(
                start: 40,
                end: 16,
              ),
              selected: current == '/projects/${p.id}/automations',
              leading: const Icon(Icons.bolt, size: 20),
              title: Text(context.l10n.grpEAutomations),
              onTap: () => _go(context, '/projects/${p.id}/automations'),
            ),
        ],
      ],
    );

    return Column(
      children: [
        ListTile(
          key: const Key('open-search'),
          dense: true,
          leading: const Icon(Icons.search),
          title: Text(context.l10n.grpESearch),
          trailing: const ShortcutHint('search.open'),
          onTap: () {
            onNavigate?.call();
            openSearch(context);
          },
        ),
        ListTile(
          key: const Key('open-inbox'),
          dense: true,
          selected: current.startsWith('/inbox'),
          leading: const InboxBadge(child: Icon(Icons.inbox_outlined)),
          title: Text(context.l10n.grpEInbox),
          trailing: const ShortcutHint('nav.inbox'),
          onTap: () => _go(context, '/inbox'),
        ),
        ListTile(
          key: const Key('open-timesheet'),
          dense: true,
          selected: current.startsWith('/timesheet'),
          leading: const Icon(Icons.schedule),
          title: Text(context.l10n.grpETimesheet),
          trailing: const ShortcutHint('nav.timesheet'),
          onTap: () => _go(context, '/timesheet'),
        ),
        ListTile(
          key: const Key('open-dashboards'),
          dense: true,
          selected: current.startsWith('/dashboards'),
          leading: const Icon(Icons.dashboard_outlined),
          title: Text(context.l10n.grpEDashboards),
          trailing: const ShortcutHint('nav.dashboards'),
          onTap: () => _go(context, '/dashboards'),
        ),
        ListTile(
          key: const Key('open-goals'),
          dense: true,
          selected: current.startsWith('/goals'),
          leading: const Icon(Icons.flag_outlined),
          title: Text(context.l10n.goalsTitle),
          onTap: () => _go(context, '/goals'),
        ),
        ListTile(
          key: const Key('open-docs'),
          dense: true,
          selected: current.startsWith('/docs'),
          leading: const Icon(Icons.description_outlined),
          title: Text(context.l10n.grpEDocs),
          trailing: const ShortcutHint('nav.docs'),
          onTap: () => _go(context, '/docs'),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.grpEProjects,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              PermissionGate(
                permission: Perm.projectCreate,
                child: IconButton(
                  key: const Key('new-project'),
                  tooltip: context.l10n.grpENewProject,
                  icon: const Icon(Icons.add),
                  onPressed: () => createProject(context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (catalog) {
            AsyncData() when projects.isEmpty => _Empty(
              onCreate: () => createProject(context),
            ),
            AsyncData() => ListView(
              children: [
                if (favorites.isNotEmpty)
                  section(context.l10n.grpEFavorites, favorites),
                if (others.isNotEmpty)
                  section(context.l10n.grpEProjects, others),
              ],
            ),
            AsyncError() => Center(
              child: TextButton(
                key: const Key('retry-projects'),
                onPressed: () => ref.invalidate(projectsProvider),
                child: Text(context.l10n.grpEProjectsLoadRetry),
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
        const Divider(height: 1),
        ListTile(
          key: const Key('open-archived'),
          dense: true,
          leading: const Icon(Icons.archive_outlined),
          title: Text(context.l10n.grpEArchivedProjects),
          onTap: () => _go(context, '/projects/archived'),
        ),
        PermissionGate(
          permission: Perm.projectViewPrivate,
          child: ListTile(
            key: const Key('open-private-projects'),
            dense: true,
            leading: const Icon(Icons.lock_outline),
            title: Text(context.l10n.grpEPrivateProjects),
            onTap: () => _go(context, '/projects/private'),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.l10n.grpENoProjects, key: Key('projects-empty')),
        PermissionGate(
          permission: Perm.projectCreate,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FilledButton(
              key: const Key('create-first-project'),
              onPressed: onCreate,
              child: Text(context.l10n.grpECreateFirstProject),
            ),
          ),
        ),
      ],
    ),
  );
}
