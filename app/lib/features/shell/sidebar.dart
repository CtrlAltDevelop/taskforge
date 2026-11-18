import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/chat/presentation/chat_badge.dart';
import 'package:taskforge/features/inbox/presentation/inbox_badge.dart';
import 'package:taskforge/features/search/presentation/search_overlay.dart';
import 'package:taskforge/features/shell/account_menu.dart';
import 'package:taskforge/features/shell/nav_access.dart';
import 'package:taskforge/features/shell/nav_items.dart';
import 'package:taskforge/features/shell/nav_prefs.dart';
import 'package:taskforge/features/shell/sidebar_item.dart';
import 'package:taskforge/features/shell/sidebar_projects.dart';
import 'package:taskforge/features/shortcuts/presentation/cheat_sheet.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_hint.dart';
import 'package:taskforge/features/time/presentation/timer_chip.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_switcher.dart';

/// The workspace sidebar: switcher, fixed places, projects, the collapsed
/// Workspace and Admin groups, and the timer, help and account at the foot.
/// With [strip] it is the 56 px icon column. [onNavigate] runs after a link
/// is followed (an overlay closes itself).
class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({
    super.key,
    this.strip = false,
    this.onNavigate,
    this.onToggle,
  });

  final bool strip;
  final VoidCallback? onNavigate;

  /// Collapses or expands the sidebar; null where it cannot (an overlay).
  final VoidCallback? onToggle;

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  late final _scroll = ScrollController(
    initialScrollOffset: ref.read(sidebarScrollProvider).offset,
  )..addListener(_remember);

  void _remember() {
    if (_scroll.hasClients) {
      ref.read(sidebarScrollProvider).offset = _scroll.offset;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// The item that held focus on the page we came from, if any.
  late final String? _refocus = ref.read(sidebarFocusProvider);

  @override
  void initState() {
    super.initState();
    if (_refocus != null) {
      // Used once: a later page change must not pull focus back.
      Future(() {
        if (mounted) ref.read(sidebarFocusProvider.notifier).remember(null);
      });
    }
  }

  bool get strip => widget.strip;
  VoidCallback? get onNavigate => widget.onNavigate;
  VoidCallback? get onToggle => widget.onToggle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tf = context.tf;
    final current = currentPath(context);
    final access = ref.watch(navAccessProvider);
    final prefs = ref.watch(navPrefsProvider);
    final notifier = ref.read(navPrefsProvider.notifier);
    void go(String path, [String? focusKey]) {
      ref.read(sidebarFocusProvider.notifier).remember(focusKey);
      context.go(path);
      onNavigate?.call();
    }

    Widget entry(NavItem item) {
      final icon = TfIcon(item.icon);
      return SidebarItem(
        key: Key(sidebarKey(item)),
        label: item.labelOf(l),
        leading: switch (item.id) {
          'inbox' => InboxBadge(child: icon),
          'chat' => ChatBadge(child: icon),
          _ => icon,
        },
        selected: activeNavItem(current)?.id == item.id,
        strip: strip,
        hint: switch (_hintActions[item.id]) {
          final id? when !strip => ShortcutHint(id),
          _ => null,
        },
        autofocus: _refocus == sidebarKey(item),
        onTap: () => go(item.path, sidebarKey(item)),
      );
    }

    List<Widget> group(NavSection section, String id, String title) {
      final items = access.visible(section).toList();
      if (items.isEmpty) return const [];
      if (strip) return [for (final i in items) entry(i)];
      // The group of the open page stays open, so you can see where you are.
      final activeId = activeNavItem(current)?.id;
      final open = prefs.isOpen(id) || items.any((i) => i.id == activeId);
      return [
        SidebarSection(
          key: Key('section-$id'),
          title: title,
          open: open,
          onToggle: () => notifier.toggleSection(id),
        ),
        if (open)
          for (final i in items) entry(i),
      ];
    }

    final main = access.visible(NavSection.main).toList();
    final projectTail = access.visible(NavSection.projects).toList();
    // Tab and the arrows walk the whole sidebar before they reach the page.
    return FocusTraversalGroup(
      child: Container(
        color: tf.colors.surface,
        child: SafeArea(
          child: Column(
            children: [
              _Header(strip: strip, onToggle: onToggle),
              Expanded(
                child: CustomScrollView(
                  key: const Key('sidebar-scroll'),
                  controller: _scroll,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          for (final item in main) entry(item),
                          SidebarItem(
                            key: const Key('open-search'),
                            label: l.grpESearch,
                            leading: const TfIcon(TfIcons.search),
                            strip: strip,
                            hint: strip
                                ? null
                                : const ShortcutHint('search.open'),
                            onTap: () {
                              onNavigate?.call();
                              openSearch(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    SidebarProjects(
                      current: current,
                      strip: strip,
                      go: go,
                      refocus: _refocus,
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          for (final item in projectTail) entry(item),
                          ...group(
                            NavSection.workspace,
                            'workspace',
                            l.shellWorkspaceGroup,
                          ),
                          ...group(
                            NavSection.admin,
                            'admin',
                            l.shellAdminGroup,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _Footer(strip: strip, onNavigate: onNavigate),
            ],
          ),
        ),
      ),
    );
  }
}

/// Entries the old sidebar had keep their `open-` key (tests and docs know
/// them); the rest are `nav-`, which cannot clash with a page's own tiles.
const _legacyKeys = {
  'inbox',
  'chat',
  'timesheet',
  'dashboards',
  'goals',
  'workload',
  'docs',
  'templates',
  'archived',
  'private-projects',
};

String sidebarKey(NavItem item) =>
    _legacyKeys.contains(item.id) ? 'open-${item.id}' : 'nav-${item.id}';

/// Entries whose action has keys worth showing next to the name.
const _hintActions = {
  'inbox': 'nav.inbox',
  'timesheet': 'nav.timesheet',
  'dashboards': 'nav.dashboards',
  'docs': 'nav.docs',
};

/// The path of the open page; a page that is being replaced can rebuild after
/// its route state is gone, so fall back to asking the router.
String currentPath(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.path;
  } on GoError {
    return GoRouter.maybeOf(context)?.routeInformationProvider.value.uri.path ??
        '';
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.strip, required this.onToggle});

  final bool strip;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = navItems.firstWhere((i) => i.id == 'settings');
    final canOpenSettings = ref.watch(navAccessProvider).allows(settings);
    final gear = canOpenSettings
        ? TfIconButton(
            key: const Key('open-workspace-settings'),
            icon: TfIcons.settings,
            tooltip: l.workspaceSettings,
            onPressed: () => context.go(settings.path),
          )
        : null;
    if (strip) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: TfSpace.sm),
        child: Column(
          children: [
            const WorkspaceSwitcher(compact: true),
            const SizedBox(height: TfSpace.sm),
            TfIconButton(
              key: const Key('sidebar-toggle'),
              icon: TfIcons.sidebar,
              tooltip: l.shellExpandSidebar,
              onPressed: onToggle,
            ),
            ?gear,
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        TfSpace.md,
        TfSpace.sm,
        TfSpace.sm,
        TfSpace.sm,
      ),
      child: Row(
        children: [
          const Expanded(child: WorkspaceSwitcher()),
          ?gear,
          if (onToggle != null)
            TfIconButton(
              key: const Key('sidebar-toggle'),
              icon: TfIcons.sidebar,
              tooltip: l.shellCollapseSidebar,
              onPressed: onToggle,
            ),
        ],
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.strip, required this.onNavigate});

  final bool strip;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.tf.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TfSpace.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!strip)
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: FittedBox(fit: BoxFit.scaleDown, child: TimerChip()),
              ),
            const SizedBox(height: TfSpace.xs),
            if (strip)
              Column(
                children: [
                  TfIconButton(
                    key: const Key('open-help'),
                    icon: TfIcons.help,
                    tooltip: l.grpKShortcuts,
                    onPressed: () => openCheatSheet(context),
                  ),
                  AccountMenu(onNavigate: onNavigate),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AccountMenu(onNavigate: onNavigate, wide: true),
                  ),
                  TfIconButton(
                    key: const Key('open-help'),
                    icon: TfIcons.help,
                    tooltip: l.grpKShortcuts,
                    onPressed: () => openCheatSheet(context),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
