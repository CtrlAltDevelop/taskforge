import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/archive_zone.dart';
import 'package:taskforge/features/projects/presentation/archived_banner.dart';
import 'package:taskforge/features/projects/presentation/features_section.dart';
import 'package:taskforge/features/projects/presentation/general_section.dart';
import 'package:taskforge/features/projects/presentation/members_section.dart';

class ProjectSettingsScreen extends ConsumerWidget {
  const ProjectSettingsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(true));
    final project = ref.watch(projectProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-to-project'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/projects/$projectId'),
        ),
        title: const Text('Project settings'),
      ),
      body: switch (project) {
        final p? => _Sections(
          project: p,
          featureInfo: catalog.value?.featureInfo ?? const [],
        ),
        null when catalog.hasError => Center(
          child: TextButton(
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

class _Sections extends StatelessWidget {
  const _Sections({required this.project, required this.featureInfo});

  final Project project;
  final List<FeatureInfo> featureInfo;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (project.isArchived) ArchivedBanner(project: project),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Keyed so a save, a refresh or a conflict starts the form afresh.
            GeneralSection(
              key: ValueKey('${project.id}/${project.version}'),
              project: project,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                key: const Key('open-workflow'),
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text('Workflow'),
                subtitle: const Text(
                  'Statuses, their categories and which moves are allowed.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/projects/${project.id}/workflow'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                key: const Key('open-fields'),
                leading: const Icon(Icons.tune),
                title: const Text('Fields'),
                subtitle: const Text(
                  'Custom fields such as Customer, Story points or Environment.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/projects/${project.id}/fields'),
              ),
            ),
            const SizedBox(height: 24),
            FeaturesSection(project: project, info: featureInfo),
            if (project.isPrivate) ...[
              const SizedBox(height: 24),
              MembersSection(project: project),
            ],
            ArchiveZone(project: project),
          ],
        ),
      ),
    ],
  );
}
