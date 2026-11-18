import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/archived_banner.dart';
import 'package:taskforge/features/projects/presentation/project_header.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/presentation/task_trash_screen.dart';
import 'package:taskforge/features/templates/presentation/template_dialogs.dart';
import 'package:taskforge/features/tasks/presentation/task_section.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/features/projects/domain/project_access.dart';
import 'package:taskforge/features/system/presentation/status_screens.dart';

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
    return Scaffold(
      appBar: TfAppBar(
        title: Text(project?.name ?? context.l10n.grpHProject),
        actions: [
          if (project != null) ...[
            if (ref.watch(permissionSetProvider).can(Perm.taskDelete))
              IconButton(
                key: const Key('open-task-trash'),
                tooltip: context.l10n.grpHTrash,
                icon: const TfIcon(TfIcons.trash, size: 24),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => TaskTrashScreen(project: project),
                  ),
                ),
              ),
            if (ref.watch(permissionSetProvider).can(Perm.templateCreate))
              IconButton(
                key: const Key('save-project-template'),
                tooltip: context.l10n.tplSaveProject,
                icon: const TfIcon(TfIcons.copy, size: 24),
                onPressed: () async {
                  final saved = await showSaveTemplateSheet(
                    context,
                    projectId: project.id,
                    initialName: project.name,
                  );
                  if (saved != null && context.mounted) {
                    sayTemplates(context, context.l10n.tplSaved);
                  }
                },
              ),
            IconButton(
              key: const Key('open-project-settings'),
              tooltip: context.l10n.grpHProjectSettings,
              icon: const TfIcon(TfIcons.settings, size: 24),
              onPressed: () => context.push('/projects/${project.id}/settings'),
            ),
          ],
        ],
      ),
      body: switch (project) {
        final p? => _Body(project: p, taskId: taskId, view: view),
        null when isDenied(catalog.error) => const NoAccessScreen(),
        null when catalog.hasError => TfError(
          message: context.l10n.grpHLoadProjectRetry,
          details: '${catalog.error}',
          retryKey: const Key('retry-projects'),
          onRetry: () => ref.invalidate(projectsProvider),
        ),
        null when catalog.hasValue => TfEmpty(
          key: const Key('project-missing'),
          illustration: TfIllustrationKind.notFound,
          title: context.l10n.grpHProjectNotFound,
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
    return Column(
      children: [
        if (project.isArchived) ArchivedBanner(project: project),
        ProjectHeader(project: project),
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
