import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/frame_scope.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/chat/presentation/chat_badge.dart';
import 'package:taskforge/features/inbox/presentation/inbox_badge.dart';
import 'package:taskforge/features/shell/breadcrumbs.dart';
import 'package:taskforge/features/shell/more_sheet.dart';
import 'package:taskforge/features/shell/nav_prefs.dart';
import 'package:taskforge/features/shell/sidebar.dart';
import 'package:taskforge/features/shell/sidebar_item.dart';
import 'package:taskforge/features/shell/top_bar.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_host.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/time/presentation/timer_chip.dart';

/// The frame around every signed-in page (the router's shell): by width, a
/// sidebar that is open or a 56 px strip (desktop, `[` toggles and the
/// choice is remembered), always a strip with the full sidebar as an overlay
/// (tablet), or a bottom bar with a More sheet (phone). The page sits under
/// the top bar and brings only its own title row, tabs and content.
class AppFrame extends ConsumerStatefulWidget {
  const AppFrame({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends ConsumerState<AppFrame>
    with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // The page cuts in and its content fades; none of that with reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _fade.value = 1;
    } else {
      _fade.forward();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  final _scaffold = GlobalKey<ScaffoldState>();
  String? _visited;

  /// The open project is remembered for the Recent list.
  void _remember(String path) {
    final segments = Uri.parse(path).pathSegments;
    final id = segments.length >= 2 && segments.first == 'projects'
        ? segments[1]
        : null;
    if (id == null || const {'archived', 'private'}.contains(id)) return;
    if (id == _visited) return;
    _visited = id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(navPrefsProvider.notifier).visited(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    final prefs = ref.watch(navPrefsProvider);
    final uri = GoRouterState.of(context).uri;
    _remember(uri.path);
    final collapsed = size.isExpanded && prefs.collapsed;
    final toggle = switch (size) {
      ScreenSize.expanded =>
        ref.read(navPrefsProvider.notifier).toggleCollapsed,
      ScreenSize.medium => () => _scaffold.currentState?.openDrawer(),
      ScreenSize.compact => null,
    };
    final l = context.l10n;
    final crumbs = currentCrumbs(ref, uri, l);
    final page = Column(
      children: [
        TopBar(size: size, onMenu: size == ScreenSize.medium ? toggle : null),
        Expanded(
          child: FadeTransition(opacity: _fade, child: widget.child),
        ),
      ],
    );
    final strip = size == ScreenSize.medium || collapsed;
    final timerInSidebar = size.isExpanded && !collapsed;
    return Title(
      title: '${crumbs.last.label} · ${l.appTitle}',
      color: context.tf.colors.accent,
      child: AppFrameScope(
        hasAccountMenu: true,
        toggleSidebar: toggle,
        child: ShortcutHost(
          child: Scaffold(
            key: _scaffold,
            backgroundColor: context.tf.colors.canvas,
            drawer: size == ScreenSize.medium
                ? Drawer(
                    width: sidebarWidth,
                    child: Builder(
                      builder: (context) => Sidebar(
                        onNavigate: () => Scaffold.of(context).closeDrawer(),
                      ),
                    ),
                  )
                : null,
            // No keyboard on a phone: a button opens the actions as a sheet.
            floatingActionButton: timerInSidebar
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const TimerChip(),
                      if (size.isCompact) ...[
                        const SizedBox(height: TfSpace.sm),
                        const QuickActionsButton(),
                      ],
                    ],
                  ),
            bottomNavigationBar: size.isCompact ? const _BottomBar() : null,
            body: size.isCompact
                ? page
                : Row(
                    children: [
                      SizedBox(
                        width: strip ? sidebarStripWidth : sidebarWidth,
                        child: Sidebar(
                          key: const Key('sidebar'),
                          strip: strip,
                          onToggle: size.isExpanded ? toggle : null,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        color: context.tf.colors.border,
                      ),
                      Expanded(child: page),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Home, Inbox, Chat and More: the places a phone goes to most.
class _BottomBar extends StatelessWidget {
  const _BottomBar();

  static const _paths = ['/', '/inbox', '/chat'];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final path = currentPath(context);
    final at = _paths.indexWhere(
      (p) => p == '/' ? path == '/' : path.startsWith(p),
    );
    return NavigationBar(
      key: const Key('bottom-nav'),
      selectedIndex: at < 0 ? _paths.length : at,
      onDestinationSelected: (i) =>
          i == _paths.length ? showMoreSheet(context) : context.go(_paths[i]),
      destinations: [
        NavigationDestination(
          icon: const TfIcon(TfIcons.home, size: 22),
          label: l.grpKTHome,
        ),
        NavigationDestination(
          icon: InboxBadge(child: const TfIcon(TfIcons.inbox, size: 22)),
          label: l.grpEInbox,
        ),
        NavigationDestination(
          icon: ChatBadge(child: const TfIcon(TfIcons.chat, size: 22)),
          label: l.chatTitle,
        ),
        NavigationDestination(
          key: const Key('more-tab'),
          icon: const TfIcon(TfIcons.menu, size: 22),
          label: l.shellMore,
        ),
      ],
    );
  }
}

/// A route's page: [child] inside the frame. The frame is part of each page
/// (not a nested navigator), so dialogs and sheets keep using the one app
/// navigator; the page cuts in and the content fades.
Page<void> framedPage(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(
      key: state.pageKey,
      child: AppFrame(child: child),
    );
