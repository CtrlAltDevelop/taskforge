import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
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
      appBar: TfAppBar(title: Text(context.l10n.grpHPrivateProjects)),
      body: switch (list) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(
            context.l10n.grpHNoPrivate,
            key: const Key('private-empty'),
          ),
        ),
        AsyncData(:final value) => ListView(
          children: [
            for (final p in value)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  key: Key('private-project-${p.id}'),
                  leading: ProjectAvatar(project: p),
                  title: Text(p.name),
                  subtitle: Text(
                    context.l10n.grpHKeyAndMembers(p.key, p.memberCount),
                  ),
                  onTap: p.canOpen
                      ? () => context.go('/projects/${p.id}')
                      : null,
                  trailing: p.canOpen
                      ? null
                      : OutlinedButton(
                          key: Key('add-me-${p.id}'),
                          onPressed: () => _addMe(context, ref, p),
                          child: Text(context.l10n.grpHAddMe),
                        ),
                ),
              ),
          ],
        ),
        AsyncError() => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(privateProjectsProvider),
            child: Text(context.l10n.grpHLoadProjectsRetry),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
