import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/directional_icon.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/archive_zone.dart';
import 'package:taskforge/features/projects/presentation/archived_banner.dart';
import 'package:taskforge/features/projects/presentation/features_section.dart';
import 'package:taskforge/features/projects/presentation/general_section.dart';
import 'package:taskforge/features/projects/presentation/members_section.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/features/projects/domain/project_access.dart';
import 'package:taskforge/features/system/presentation/status_screens.dart';

class ProjectSettingsScreen extends ConsumerWidget {
  const ProjectSettingsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(true));
    final project = ref.watch(projectProvider(projectId));
    return Scaffold(
      appBar: TfAppBar(
        leading: IconButton(
          key: const Key('back-to-project'),
          tooltip: context.l10n.grpHBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.go('/projects/$projectId'),
        ),
        title: Text(context.l10n.grpHProjectSettings),
      ),
      body: switch (project) {
        final p? => _Sections(
          project: p,
          featureInfo: catalog.value?.featureInfo ?? const [],
        ),
        null when isDenied(catalog.error) => const NoAccessScreen(),
        null when catalog.hasError => TfError(
          message: context.l10n.grpHLoadProjectRetry,
          details: '${catalog.error}',
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

class _Sections extends StatelessWidget {
  const _Sections({required this.project, required this.featureInfo});

  final Project project;
  final List<FeatureInfo> featureInfo;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (project.isArchived) ArchivedBanner(project: project),
      Expanded(
        child: ContentWidth(
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
                  leading: const TfIcon(TfIcons.network),
                  title: Text(context.l10n.grpHWorkflow),
                  subtitle: Text(context.l10n.grpHWorkflowHint),
                  trailing: DirectionalIcon(TfIcons.chevronEnd.glyph),
                  onTap: () => context.go('/projects/${project.id}/workflow'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  key: const Key('open-fields'),
                  leading: const TfIcon(TfIcons.tune),
                  title: Text(context.l10n.grpHFields),
                  subtitle: Text(context.l10n.grpHFieldsHint),
                  trailing: DirectionalIcon(TfIcons.chevronEnd.glyph),
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
      ),
    ],
  );
}
