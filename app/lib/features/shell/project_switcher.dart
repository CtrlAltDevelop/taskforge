import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/actions/fuzzy.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';

/// A searchable sheet of the projects, opened from a phone's title.
Future<void> showProjectSwitcher(BuildContext context) =>
    showTfBottomSheet<void>(context, body: const ProjectSwitcher());

class ProjectSwitcher extends ConsumerStatefulWidget {
  const ProjectSwitcher({super.key});

  @override
  ConsumerState<ProjectSwitcher> createState() => _ProjectSwitcherState();
}

class _ProjectSwitcherState extends ConsumerState<ProjectSwitcher> {
  String _query = '';

  List<Project> _matches(List<Project> all) {
    final active = sidebarOrder(all);
    final q = _query.trim();
    if (q.isEmpty) return active;
    return active
        .where((p) => fuzzyScore(q, '${p.name} ${p.key}') != null)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final catalog = ref.watch(projectCatalogProvider(false));
    final projects = _matches(catalog.value?.projects ?? const []);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: Column(
        children: [
          TfSearchField(
            key: const Key('switcher-search'),
            hint: l.shellFindProject,
            clearTooltip: l.grpGClose,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: TfSpace.sm),
          Expanded(
            child: projects.isEmpty
                ? TfEmpty(title: l.shellNoProjectMatch)
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (_, i) {
                      final p = projects[i];
                      return TfRow(
                        key: Key('switch-project-${p.id}'),
                        title: p.name,
                        subtitle: p.key,
                        leading: ProjectAvatar(project: p, radius: 12),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/projects/${p.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
