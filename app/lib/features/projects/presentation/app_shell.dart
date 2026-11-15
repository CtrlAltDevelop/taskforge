import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/features/projects/presentation/project_sidebar.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_host.dart';
import 'package:taskforge/features/time/presentation/timer_chip.dart';

const sidebarWidth = 280.0;

/// A top-level place, shown in the bottom bar (phones) and the rail (tablets).
/// A null [path] is the projects menu: it opens the drawer.
class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.path);

  final IconData icon;
  final IconData selectedIcon;
  final String? path;
}

const _destinations = [
  _Destination(Icons.inbox_outlined, Icons.inbox, '/inbox'),
  _Destination(Icons.dashboard_outlined, Icons.dashboard, '/dashboards'),
  _Destination(Icons.flag_outlined, Icons.flag, '/goals'),
  _Destination(Icons.description_outlined, Icons.description, '/docs'),
  _Destination(Icons.folder_outlined, Icons.folder, null),
];

/// A page with the project sidebar. By window width:
/// - [ScreenSize.expanded]: the sidebar is persistent on the left;
/// - [ScreenSize.medium]: a navigation rail, the full menu in a drawer;
/// - [ScreenSize.compact]: a bottom bar, the full menu in a drawer.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.appBar, required this.body});

  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) =>
      ShortcutHost(child: _scaffold(context, ScreenSize.of(context)));

  Widget _scaffold(BuildContext context, ScreenSize size) {
    if (size.isExpanded) {
      return Scaffold(
        appBar: appBar,
        floatingActionButton: const TimerChip(),
        body: Row(
          children: [
            const SizedBox(width: sidebarWidth, child: ProjectSidebar()),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }
    final compact = size.isCompact;
    return Scaffold(
      appBar: appBar,
      // No keyboard on a phone: a button opens the actions as a sheet.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const TimerChip(),
          if (compact) ...[
            const SizedBox(height: 8),
            const QuickActionsButton(),
          ],
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Builder(
            builder: (context) => ProjectSidebar(
              onNavigate: () => Scaffold.of(context).closeDrawer(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: compact ? const _BottomBar() : null,
      body: compact
          ? body
          : Row(
              children: [
                const _Rail(),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
    );
  }
}

String _openPath(BuildContext context) =>
    GoRouter.maybeOf(context)?.routeInformationProvider.value.uri.path ?? '';

/// Index of the destination the open page belongs to; projects otherwise.
int _selected(BuildContext context) {
  final path = _openPath(context);
  final at = _destinations.indexWhere(
    (d) => d.path != null && path.startsWith(d.path!),
  );
  return at < 0 ? _destinations.length - 1 : at;
}

void _open(BuildContext context, int index) {
  final path = _destinations[index].path;
  if (path == null) {
    Scaffold.of(context).openDrawer();
  } else {
    context.go(path);
  }
}

List<String> _labels(BuildContext context) => [
  context.l10n.grpEInbox,
  context.l10n.grpEDashboards,
  context.l10n.goalsTitle,
  context.l10n.grpEDocs,
  context.l10n.grpEProjects,
];

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final labels = _labels(context);
    return NavigationBar(
      key: const Key('bottom-nav'),
      selectedIndex: _selected(context),
      onDestinationSelected: (i) => _open(context, i),
      destinations: [
        for (final (i, d) in _destinations.indexed)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: labels[i],
          ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail();

  @override
  Widget build(BuildContext context) {
    final labels = _labels(context);
    return NavigationRail(
      key: const Key('side-rail'),
      selectedIndex: _selected(context),
      onDestinationSelected: (i) => _open(context, i),
      destinations: [
        for (final (i, d) in _destinations.indexed)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(labels[i]),
          ),
      ],
    );
  }
}
