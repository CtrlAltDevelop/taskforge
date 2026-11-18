import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
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
          TfSegmented<WorkloadZoom>(
            key: const Key('workload-zoom'),
            options: {
              for (final z in WorkloadZoom.values) z: zoomLabel(context, z),
            },
            value: query.zoom,
            onChanged: notifier.setZoom,
          ),
          TfIconButton(
            key: const Key('workload-prev'),
            icon: TfIcons.chevronStart,
            tooltip: t.wlPrevious,
            onPressed: () => notifier.page(-1),
          ),
          TfButton(
            key: const Key('workload-today'),
            label: t.wlToday,
            variant: TfButtonVariant.ghost,
            onPressed: notifier.today,
          ),
          TfIconButton(
            key: const Key('workload-next'),
            icon: TfIcons.chevronEnd,
            tooltip: t.wlNext,
            onPressed: () => notifier.page(1),
          ),
          Text(
            context.localDate(query.anchor),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          _FilterMenu(
            key: const Key('workload-projects'),
            icon: TfIcons.folder,
            label: t.wlProjects,
            options: {
              for (final p in projects?.projects ?? const []) p.id: p.name,
            },
            selected: query.projectIds,
            onChanged: notifier.setProjects,
          ),
          _FilterMenu(
            key: const Key('workload-people'),
            icon: TfIcons.users,
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

  final TfIconData icon;
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
      builder: (context, controller, _) => TfButton(
        icon: icon,
        label: count == 0 ? label : '$label (${context.localDigits('$count')})',
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
            borderRadius: TfRadius.chip,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: theme.textTheme.bodySmall)),
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
