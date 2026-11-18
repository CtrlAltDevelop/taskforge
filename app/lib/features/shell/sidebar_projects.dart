import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/create_project_dialog.dart';
import 'package:taskforge/features/projects/presentation/project_actions.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/shell/nav_prefs.dart';
import 'package:taskforge/features/shell/project_dialogs.dart';
import 'package:taskforge/features/shell/sidebar_item.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

/// The sidebar's project lists as one sliver: Favourites, Recent, Projects.
/// Lists are lazy (500 projects stay smooth) and reorder by press-and-drag.
class SidebarProjects extends ConsumerWidget {
  const SidebarProjects({
    super.key,
    required this.current,
    required this.strip,
    required this.go,
    this.refocus,
  });

  /// The sidebar key that held focus before the page changed.
  final String? refocus;

  /// The open path.
  final String current;
  final bool strip;
  final void Function(String path, [String? focusKey]) go;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(projectCatalogProvider(false));
    final prefs = ref.watch(navPrefsProvider);
    final l = context.l10n;
    final header = strip
        ? null
        : SidebarSection(
            key: const Key('section-projects'),
            title: l.grpEProjects,
            open: prefs.isOpen('projects'),
            onToggle: () =>
                ref.read(navPrefsProvider.notifier).toggleSection('projects'),
            action: _newButton(context),
          );
    final body = switch (catalog) {
      AsyncData(:final value) => _lists(context, ref, value.projects, prefs),
      AsyncError() => [
        SliverToBoxAdapter(
          child: SidebarItem(
            key: const Key('retry-projects'),
            label: l.grpEProjectsLoadRetry,
            leading: const TfIcon(TfIcons.refresh),
            strip: strip,
            onTap: () => ref.invalidate(projectsProvider),
          ),
        ),
      ],
      _ => [
        SliverToBoxAdapter(
          key: const Key('projects-loading'),
          child: Column(
            children: [
              for (var i = 0; i < 4; i++)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: TfSpace.lg,
                    vertical: TfSpace.sm,
                  ),
                  child: TfSkeleton(),
                ),
            ],
          ),
        ),
      ],
    };
    return SliverMainAxisGroup(
      slivers: [
        // With data, the lists bring their own headings.
        if (header != null && catalog is! AsyncData)
          SliverToBoxAdapter(child: header),
        ...body,
      ],
    );
  }

  List<Widget> _lists(
    BuildContext context,
    WidgetRef ref,
    List<Project> all,
    NavPrefs prefs,
  ) {
    final l = context.l10n;
    final active = orderedProjects(
      all.where((p) => !p.isArchived).toList(),
      prefs.projectOrder,
    );
    final order = [for (final p in active) p.id];
    final favorites = active.where((p) => p.isFavorite).toList();
    final others = active.where((p) => !p.isFavorite).toList();
    final byId = {for (final p in active) p.id: p};
    final recent = [
      for (final id in prefs.recent)
        if (byId[id] != null) byId[id]!,
    ];
    final notifier = ref.read(navPrefsProvider.notifier);

    Widget heading(String id, String title, {Widget? action}) =>
        SliverToBoxAdapter(
          // Stable keys: a section that appears (Recent) must not shift the
          // state, and so the keyboard focus, of the lists below it.
          key: ValueKey('head-$id'),
          child: SidebarSection(
            key: Key('section-$id'),
            title: title,
            open: prefs.isOpen(id),
            onToggle: () => notifier.toggleSection(id),
            action: action,
          ),
        );

    List<Widget> group(String id, String title, List<Project> list) => [
      if (!strip) heading(id, title),
      if (strip || prefs.isOpen(id))
        _ProjectList(
          key: ValueKey('list-$id'),
          projects: list,
          keyPrefix: id == 'recent' ? 'recent-' : 'project-',
          reorderable: id != 'recent',
          current: current,
          strip: strip,
          go: go,
          refocus: refocus,
          onReorder: (from, to) =>
              notifier.setOrder(movedOrder(list, from, to, order)),
        ),
    ];

    if (active.isEmpty) {
      return [
        if (!strip)
          heading('projects', l.grpEProjects, action: _newButton(context)),
        if (!strip)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TfSpace.lg),
              child: Column(
                children: [
                  Text(
                    l.grpENoProjects,
                    key: const Key('projects-empty'),
                    textAlign: TextAlign.center,
                    style: context.tf.typography.small.copyWith(
                      color: context.tf.colors.textMuted,
                    ),
                  ),
                  PermissionGate(
                    permission: Perm.projectCreate,
                    child: Padding(
                      padding: const EdgeInsets.only(top: TfSpace.md),
                      child: TfButton(
                        key: const Key('create-first-project'),
                        label: l.grpECreateFirstProject,
                        variant: TfButtonVariant.primary,
                        onPressed: () => createProject(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ];
    }
    return [
      if (favorites.isNotEmpty)
        ...group('favorites', l.grpEFavorites, favorites),
      if (recent.isNotEmpty && !strip)
        ...group('recent', l.shellRecent, recent),
      if (!strip)
        heading('projects', l.grpEProjects, action: _newButton(context)),
      if (strip || prefs.isOpen('projects'))
        _ProjectList(
          key: const ValueKey('list-projects'),
          projects: others,
          keyPrefix: 'project-',
          reorderable: true,
          current: current,
          strip: strip,
          go: go,
          refocus: refocus,
          onReorder: (from, to) =>
              notifier.setOrder(movedOrder(others, from, to, order)),
        ),
    ];
  }

  Widget _newButton(BuildContext context) => PermissionGate(
    permission: Perm.projectCreate,
    child: TfIconButton(
      key: const Key('new-project'),
      icon: TfIcons.plus,
      tooltip: context.l10n.grpENewProject,
      size: TfButtonSize.small,
      onPressed: () => createProject(context),
    ),
  );
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({
    super.key,
    required this.projects,
    required this.keyPrefix,
    required this.reorderable,
    required this.current,
    required this.strip,
    required this.go,
    required this.onReorder,
    this.refocus,
  });

  final String? refocus;

  final List<Project> projects;
  final String keyPrefix;
  final bool reorderable;
  final String current;
  final bool strip;
  final void Function(String path, [String? focusKey]) go;
  final void Function(int from, int to) onReorder;

  @override
  Widget build(BuildContext context) {
    Widget item(int i) {
      final p = projects[i];
      final row = _ProjectItem(
        key: Key('$keyPrefix${p.id}'),
        project: p,
        current: current,
        strip: strip,
        go: go,
        focusKey: '$keyPrefix${p.id}',
        autofocus: refocus == '$keyPrefix${p.id}',
        showPages: keyPrefix == 'project-',
      );
      return reorderable
          ? ReorderableDelayedDragStartListener(
              key: ValueKey('drag-$keyPrefix${p.id}'),
              index: i,
              child: row,
            )
          : KeyedSubtree(key: ValueKey('$keyPrefix${p.id}-row'), child: row);
    }

    if (!reorderable) {
      return SliverList.builder(
        itemCount: projects.length,
        itemBuilder: (_, i) => item(i),
      );
    }
    return SliverReorderableList(
      itemCount: projects.length,
      onReorderItem: onReorder,
      itemBuilder: (_, i) => item(i),
    );
  }
}

class _ProjectItem extends ConsumerWidget {
  const _ProjectItem({
    super.key,
    required this.project,
    required this.current,
    required this.strip,
    required this.go,
    required this.showPages,
    required this.focusKey,
    required this.autofocus,
  });

  /// This row's key, handed to [go] so focus can return to it.
  final String focusKey;
  final bool autofocus;

  final Project project;
  final String current;
  final bool strip;
  final void Function(String path, [String? focusKey]) go;

  /// The open project's own pages (sprints, automations) indent below it.
  final bool showPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = project;
    final l = context.l10n;
    final home = '/projects/${p.id}';
    final permissions = ref.watch(permissionSetProvider);
    final canRename = permissions.can(Perm.projectUpdate);
    void rename() => renameProject(context, ref, p);
    final menu = TfMenu(
      items: [
        TfMenuItem(
          label: p.isFavorite ? l.grpHRemoveFavorite : l.grpHAddFavorite,
          icon: TfIcons.star,
          onSelected: () => runProjectAction(
            context,
            () =>
                ref.read(projectsControllerProvider).favorite(p, !p.isFavorite),
          ),
        ),
        if (canRename)
          TfMenuItem(
            label: l.shellRename,
            icon: TfIcons.edit,
            shortcut: 'F2',
            onSelected: rename,
          ),
        TfMenuItem(
          label: l.grpKTProjectSettings,
          icon: TfIcons.settings,
          onSelected: () => go('$home/settings'),
        ),
        if (permissions.can(Perm.projectArchive))
          TfMenuItem(
            label: l.grpHArchive,
            icon: TfIcons.archive,
            danger: true,
            onSelected: () => archiveProject(context, ref, p),
          ),
      ],
      builder: (context, toggle) => TfIconButton(
        key: Key('project-menu-${p.id}'),
        icon: TfIcons.more,
        tooltip: l.shellMoreFor(p.name),
        size: TfButtonSize.small,
        onPressed: toggle,
      ),
    );
    final item = SidebarItem(
      label: p.name,
      leading: ProjectAvatar(project: p, radius: 10),
      selected: current == home,
      strip: strip,
      trailing: menu,
      hint: p.isPrivate
          ? TfIcon(
              TfIcons.lock,
              key: Key('private-${p.id}'),
              size: 12,
              semanticLabel: l.grpEPrivate,
            )
          : null,
      autofocus: autofocus,
      onTap: () => go(home, focusKey),
      onKey: canRename
          ? (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.f2) {
                rename();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            }
          : null,
    );
    final withPages = !strip && showPages && current.startsWith(home);
    Widget page(String key, String label, TfIconData icon, String path) =>
        Padding(
          padding: const EdgeInsetsDirectional.only(start: TfSpace.lg),
          child: SidebarItem(
            key: Key(key),
            label: label,
            leading: TfIcon(icon),
            selected: current == path,
            onTap: () => go(path),
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        item,
        if (withPages && p.enabledFeatures.contains(sprintsFeature))
          page(
            'open-sprints-${p.id}',
            l.grpESprints,
            TfIcons.clock,
            '$home/sprints',
          ),
        if (withPages) ...[
          page(
            'open-automations-${p.id}',
            l.grpEAutomations,
            TfIcons.bolt,
            '$home/automations',
          ),
          page(
            'open-project-dashboards-${p.id}',
            l.grpEDashboards,
            TfIcons.dashboard,
            '$home/dashboards',
          ),
        ],
      ],
    );
  }
}
