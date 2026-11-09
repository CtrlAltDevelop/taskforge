import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/projects/application/project_access.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';

/// Shown above an archived project: read-only, with Restore for those allowed.
class ArchivedBanner extends ConsumerWidget {
  const ArchivedBanner({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialBanner(
    key: const Key('archived-banner'),
    content: const Text('This project is archived and read-only.'),
    actions: [
      if (canManageProject(
        ref.watch(permissionSetProvider),
        Perm.projectArchive,
      ))
        TextButton(
          key: const Key('banner-restore'),
          onPressed: () => runProjectAction(
            context,
            () => ref.read(projectsControllerProvider).restore(project),
          ),
          child: const Text('Restore'),
        ),
    ],
  );
}
