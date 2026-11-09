import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';

class ArchivedProjectsScreen extends ConsumerWidget {
  const ArchivedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(true));
    final archived = [
      for (final p in catalog.value?.projects ?? const <Project>[])
        if (p.isArchived) p,
    ];
    return ShellScaffold(
      appBar: AppBar(title: const Text('Archived projects')),
      body: switch (catalog) {
        AsyncData() when archived.isEmpty => const Center(
          child: Text('No archived projects.', key: Key('archived-empty')),
        ),
        AsyncData() => ListView(
          children: [
            for (final p in archived)
              ListTile(
                key: Key('archived-${p.id}'),
                leading: ProjectAvatar(project: p),
                title: Text(p.name),
                subtitle: Text(p.key),
                onTap: () => context.go('/projects/${p.id}'),
                trailing: PermissionGate(
                  permission: Perm.projectArchive,
                  child: TextButton(
                    key: Key('restore-${p.id}'),
                    onPressed: () => runProjectAction(
                      context,
                      () => ref.read(projectsControllerProvider).restore(p),
                    ),
                    child: const Text('Restore'),
                  ),
                ),
              ),
          ],
        ),
        AsyncError() => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(projectsProvider),
            child: const Text('Could not load projects. Retry'),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
