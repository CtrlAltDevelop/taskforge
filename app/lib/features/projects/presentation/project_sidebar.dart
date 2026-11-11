import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/inbox/presentation/inbox_badge.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/create_project_dialog.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title, style: theme.textTheme.labelLarge),
        ),
        for (final p in items)
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
                    semanticLabel: 'Private',
                  )
                : null,
            onTap: () => _go(context, '/projects/${p.id}'),
          ),
      ],
    );

    return Column(
      children: [
        ListTile(
          key: const Key('open-inbox'),
          dense: true,
          selected: current.startsWith('/inbox'),
          leading: const InboxBadge(child: Icon(Icons.inbox_outlined)),
          title: const Text('Inbox'),
          onTap: () => _go(context, '/inbox'),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text('Projects', style: theme.textTheme.titleMedium),
              ),
              PermissionGate(
                permission: Perm.projectCreate,
                child: IconButton(
                  key: const Key('new-project'),
                  tooltip: 'New project',
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
                if (favorites.isNotEmpty) section('Favorites', favorites),
                if (others.isNotEmpty) section('Projects', others),
              ],
            ),
            AsyncError() => Center(
              child: TextButton(
                key: const Key('retry-projects'),
                onPressed: () => ref.invalidate(projectsProvider),
                child: const Text('Could not load projects. Retry'),
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
          title: const Text('Archived projects'),
          onTap: () => _go(context, '/projects/archived'),
        ),
        PermissionGate(
          permission: Perm.projectViewPrivate,
          child: ListTile(
            key: const Key('open-private-projects'),
            dense: true,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Private projects'),
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
        const Text('No projects yet', key: Key('projects-empty')),
        PermissionGate(
          permission: Perm.projectCreate,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FilledButton(
              key: const Key('create-first-project'),
              onPressed: onCreate,
              child: const Text('Create your first project'),
            ),
          ),
        ),
      ],
    ),
  );
}
