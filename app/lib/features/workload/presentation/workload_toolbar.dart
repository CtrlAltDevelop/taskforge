import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/workload/application/workload_providers.dart';
import 'package:taskforge/features/workload/domain/workload.dart';
import 'package:taskforge/features/workload/presentation/workload_cell.dart';

String zoomLabel(BuildContext context, WorkloadZoom zoom) => switch (zoom) {
  WorkloadZoom.day => context.l10n.wlZoomDay,
  WorkloadZoom.week => context.l10n.wlZoomWeek,
  WorkloadZoom.month => context.l10n.wlZoomMonth,
};

/// Zoom, paging and the project / people filters.
class WorkloadToolbar extends ConsumerWidget {
  const WorkloadToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final query = ref.watch(workloadQueryProvider);
    final notifier = ref.read(workloadQueryProvider.notifier);
    final projects = ref.watch(projectCatalogProvider(false)).value;
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<WorkloadZoom>(
            key: const Key('workload-zoom'),
            showSelectedIcon: false,
            segments: [
              for (final z in WorkloadZoom.values)
                ButtonSegment(value: z, label: Text(zoomLabel(context, z))),
            ],
            selected: {query.zoom},
            onSelectionChanged: (s) => notifier.setZoom(s.first),
          ),
          IconButton(
            key: const Key('workload-prev'),
            tooltip: t.wlPrevious,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => notifier.page(-1),
          ),
          TextButton(
            key: const Key('workload-today'),
            onPressed: notifier.today,
            child: Text(t.wlToday),
          ),
          IconButton(
            key: const Key('workload-next'),
            tooltip: t.wlNext,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => notifier.page(1),
          ),
          Text(
            context.localDate(query.anchor),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          _FilterMenu(
            key: const Key('workload-projects'),
            icon: Icons.folder_outlined,
            label: t.wlProjects,
            options: {
              for (final p in projects?.projects ?? const []) p.id: p.name,
            },
            selected: query.projectIds,
            onChanged: notifier.setProjects,
          ),
          _FilterMenu(
            key: const Key('workload-people'),
            icon: Icons.people_outline,
            label: t.wlPeople,
            options: {for (final m in members) m.userId: m.label},
            selected: query.userIds,
            onChanged: notifier.setPeople,
          ),
        ],
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    super.key,
    required this.icon,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final Map<String, String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final count = selected.length;
    return MenuAnchor(
      menuChildren: [
        for (final e in options.entries)
          CheckboxMenuButton(
            closeOnActivate: false,
            value: selected.contains(e.key),
            onChanged: (on) => onChanged([
              for (final id in selected)
                if (id != e.key) id,
              if (on ?? false) e.key,
            ]),
            child: Text(e.value),
          ),
        if (count > 0)
          MenuItemButton(
            onPressed: () => onChanged(const []),
            child: Text(context.l10n.wlClearFilter),
          ),
      ],
      builder: (context, controller, _) => OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(
          count == 0 ? label : '$label (${context.localDigits('$count')})',
        ),
        onPressed: options.isEmpty
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// What the colours mean.
class WorkloadLegend extends StatelessWidget {
  const WorkloadLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    Widget item(LoadLevel level, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: levelColor(theme, level),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        key: const Key('workload-legend'),
        spacing: 16,
        runSpacing: 4,
        children: [
          item(LoadLevel.under, t.wlLegendUnder),
          item(LoadLevel.ok, t.wlLegendOk),
          item(LoadLevel.over, t.wlLegendOver),
          item(LoadLevel.severe, t.wlLegendSevere),
        ],
      ),
    );
  }
}
