import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/projects/presentation/archived_banner.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/presentation/task_trash_screen.dart';
import 'package:taskforge/features/tasks/presentation/task_section.dart';

/// A project's page: its header and its tasks.
class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({
    super.key,
    required this.projectId,
    this.taskId,
    this.view,
  });

  final String projectId;

  /// A task to open at once (a link to a task of another project).
  final String? taskId;

  /// The view of the tasks to open in (`board`, ...); the list by default.
  final String? view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(true));
    final project = ref.watch(projectProvider(projectId));
    return ShellScaffold(
      appBar: AppBar(
        title: Text(project?.name ?? 'Project'),
        actions: [
          if (project != null) ...[
            IconButton(
              key: const Key('favorite-toggle'),
              tooltip: project.isFavorite ? 'Remove favorite' : 'Add favorite',
              icon: Icon(project.isFavorite ? Icons.star : Icons.star_border),
              // The server refuses starring an archived project.
              onPressed: project.isArchived
                  ? null
                  : () => runProjectAction(
                      context,
                      () => ref
                          .read(projectsControllerProvider)
                          .favorite(project, !project.isFavorite),
                    ),
            ),
            if (ref.watch(permissionSetProvider).can(Perm.taskDelete))
              IconButton(
                key: const Key('open-task-trash'),
                tooltip: 'Trash',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => TaskTrashScreen(project: project),
                  ),
                ),
              ),
            IconButton(
              key: const Key('open-project-settings'),
              tooltip: 'Project settings',
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/projects/${project.id}/settings'),
            ),
          ],
        ],
      ),
      body: switch (project) {
        final p? => _Body(project: p, taskId: taskId, view: view),
        null when catalog.hasError => Center(
          child: TextButton(
            key: const Key('retry-projects'),
            onPressed: () => ref.invalidate(projectsProvider),
            child: const Text('Could not load the project. Retry'),
          ),
        ),
        null when catalog.hasValue => const Center(
          child: Text('Project not found.', key: Key('project-missing')),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.project, this.taskId, this.view});

  final String? taskId;
  final String? view;

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (project.isArchived) ArchivedBanner(project: project),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProjectAvatar(project: project, radius: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      key: const Key('project-title'),
                      style: theme.textTheme.headlineSmall,
                    ),
                    Text(project.key, key: const Key('project-key-label')),
                    if (project.description.isNotEmpty)
                      Text(project.description, key: const Key('project-desc')),
                  ],
                ),
              ),
              if (project.isPrivate) const Icon(Icons.lock),
            ],
          ),
        ),
        Expanded(
          child: TaskSection(
            project: project,
            initialTask: taskId,
            initialView: view,
          ),
        ),
      ],
    );
  }
}
