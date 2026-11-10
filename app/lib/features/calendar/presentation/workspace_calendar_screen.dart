import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/presentation/calendar_view.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';

/// Colours for projects that chose none, in order.
const _palette = [
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFF4511E),
  Color(0xFF8E24AA),
  Color(0xFFFDD835),
  Color(0xFF00ACC1),
  Color(0xFFD81B60),
  Color(0xFF6D4C41),
];

/// The colour each project is drawn in: the one it chose, else one of the
/// [_palette] by its place in the list.
Map<String, Color> projectColors(List<Project> projects) => {
  for (var i = 0; i < projects.length; i++)
    projects[i].id: projects[i].color.isEmpty
        ? _palette[i % _palette.length]
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
    final colors = projectColors(projects);
    final hidden = ref.watch(hiddenProjectsProvider);
    return ShellScaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: CalendarView(
        scope: '',
        projectColor: (t) => colors[t.projectId] ?? Colors.blueGrey,
        visible: (t) => !hidden.contains(t.projectId),
        legend: _Legend(projects: projects, colors: colors, hidden: hidden),
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
