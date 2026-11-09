import 'package:flutter/material.dart';

import 'package:taskforge/features/projects/presentation/project_sidebar.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_switcher.dart';

const sidebarWidth = 280.0;

/// A page with the project sidebar: persistent on the left from
/// [desktopBreakpoint], otherwise in a drawer opened from the app bar.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.appBar, required this.body});

  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= desktopBreakpoint;
    if (wide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            const SizedBox(width: sidebarWidth, child: ProjectSidebar()),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: SafeArea(
          child: Builder(
            builder: (context) => ProjectSidebar(
              onNavigate: () => Scaffold.of(context).closeDrawer(),
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
