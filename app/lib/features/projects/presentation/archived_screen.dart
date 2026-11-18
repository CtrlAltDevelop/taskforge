import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

class ArchivedProjectsScreen extends ConsumerWidget {
  const ArchivedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(true));
    final archived = [
      for (final p in catalog.value?.projects ?? const <Project>[])
        if (p.isArchived) p,
    ];
    return Scaffold(
      appBar: TfAppBar(title: Text(context.l10n.grpHArchivedProjects)),
      body: switch (catalog) {
        AsyncData() when archived.isEmpty => TfEmpty(
          key: const Key('archived-empty'),
          illustration: TfIllustrationKind.tasks,
          title: context.l10n.grpHNoArchived,
        ),
        AsyncData() => ListView(
          children: [
            for (final p in archived)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
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
                      child: Text(context.l10n.grpHRestore),
                    ),
                  ),
                ),
              ),
          ],
        ),
        AsyncError() => TfError(
          message: context.l10n.grpHLoadProjectsRetry,
          onRetry: () => ref.invalidate(projectsProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
