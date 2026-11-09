import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';

/// Admin list of private projects. Those the admin is not in cannot be opened
/// until they add themselves.
class PrivateProjectsScreen extends ConsumerWidget {
  const PrivateProjectsScreen({super.key});

  Future<void> _addMe(BuildContext context, WidgetRef ref, Project p) =>
      runProjectAction(
        context,
        () => ref.read(projectsControllerProvider).addMe(p.id),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(privateProjectsProvider);
    return ShellScaffold(
      appBar: AppBar(title: const Text('Private projects')),
      body: switch (list) {
        AsyncData(:final value) when value.isEmpty => const Center(
          child: Text('No private projects.', key: Key('private-empty')),
        ),
        AsyncData(:final value) => ListView(
          children: [
            for (final p in value)
              ListTile(
                key: Key('private-project-${p.id}'),
                leading: ProjectAvatar(project: p),
                title: Text(p.name),
                subtitle: Text('${p.key} · ${p.memberCount} members'),
                onTap: p.canOpen ? () => context.go('/projects/${p.id}') : null,
                trailing: p.canOpen
                    ? null
                    : OutlinedButton(
                        key: Key('add-me-${p.id}'),
                        onPressed: () => _addMe(context, ref, p),
                        child: const Text('Add me'),
                      ),
              ),
          ],
        ),
        AsyncError() => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(privateProjectsProvider),
            child: const Text('Could not load projects. Retry'),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
