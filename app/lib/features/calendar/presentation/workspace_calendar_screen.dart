import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/presentation/calendar_view.dart';
import 'package:taskforge/features/filters/presentation/filter_bar.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// The colour each project is drawn in: the one it chose, else one of the
/// [palette] (the design system's categorical colours) by its place in the list.
Map<String, Color> projectColors(List<Project> projects, List<Color> palette) =>
    {
      for (var i = 0; i < projects.length; i++)
        projects[i].id: projects[i].color.isEmpty
            ? palette[i % palette.length]
            : parseStatusColor(projects[i].color),
    };

/// The calendar of every project the person can open, coloured by project,
/// with chips to hide a project. Choices last for the session.
class WorkspaceCalendarScreen extends ConsumerWidget {
  const WorkspaceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(false));
    final projects = [
      for (final p in catalog.value?.projects ?? const <Project>[])
        if (p.canOpen) p,
    ];
    final colors = projectColors(projects, context.tf.colors.categorical);
    final hidden = ref.watch(hiddenProjectsProvider);
    return Scaffold(
      appBar: TfAppBar(title: Text(context.l10n.calendar)),
      body: CalendarView(
        scope: '',
        projectColor: (t) =>
            colors[t.projectId] ?? context.tf.colors.neutral.fg,
        visible: (t) => !hidden.contains(t.projectId),
        legend: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
              child: FilterBar(
                projectId: '',
                canShare: ref
                    .watch(permissionSetProvider)
                    .can(Perm.workspaceUpdate),
              ),
            ),
            _Legend(projects: projects, colors: colors, hidden: hidden),
          ],
        ),
        onOpen: (Task t) =>
            context.push('/projects/${t.projectId}?task=${t.id}'),
      ),
    );
  }
}

class _Legend extends ConsumerWidget {
  const _Legend({
    required this.projects,
    required this.colors,
    required this.hidden,
  });

  final List<Project> projects;
  final Map<String, Color> colors;
  final Set<String> hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
    key: const Key('project-legend'),
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
    child: Row(
      children: [
        for (final p in projects)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: FilterChip(
              key: Key('legend-${p.id}'),
              avatar: CircleAvatar(backgroundColor: colors[p.id], radius: 6),
              label: Text(p.name),
              selected: !hidden.contains(p.id),
              showCheckmark: false,
              onSelected: (_) =>
                  ref.read(hiddenProjectsProvider.notifier).toggle(p.id),
            ),
          ),
      ],
    ),
  );
}
