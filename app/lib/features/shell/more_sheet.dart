import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/shell/nav_access.dart';
import 'package:taskforge/features/shell/nav_items.dart';
import 'package:taskforge/features/shell/project_switcher.dart';
import 'package:taskforge/features/shortcuts/presentation/cheat_sheet.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_switcher.dart';

/// The phone's "More": everything the bottom bar has no room for, grouped
/// like the sidebar, then account and sign out.
Future<void> showMoreSheet(BuildContext context) =>
    showTfBottomSheet<void>(context, body: const MoreSheet());

class MoreSheet extends ConsumerWidget {
  const MoreSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final access = ref.watch(navAccessProvider);
    final c = context.tf.colors;
    void open(String path) {
      Navigator.of(context).pop();
      context.go(path);
    }

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        TfSpace.md,
        TfSpace.lg,
        TfSpace.md,
        TfSpace.xs,
      ),
      child: Text(
        text.toUpperCase(),
        style: context.tf.typography.caption.copyWith(color: c.textSubtle),
      ),
    );

    Widget row(NavItem i) => TfRow(
      key: Key('more-${i.id}'),
      title: i.labelOf(l),
      leading: TfIcon(i.icon, size: 18),
      onTap: () => open(i.path),
    );

    List<Widget> section(NavSection s, String? title) {
      final items = access.visible(s).toList();
      if (items.isEmpty) return const [];
      return [if (title != null) heading(title), for (final i in items) row(i)];
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        key: const Key('more-sheet'),
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(TfSpace.md),
            child: WorkspaceSwitcher(),
          ),
          TfRow(
            key: const Key('more-projects'),
            title: l.grpEProjects,
            leading: const TfIcon(TfIcons.folder, size: 18),
            onTap: () {
              Navigator.of(context).pop();
              showProjectSwitcher(context);
            },
          ),
          // The phone's bar holds Home, Inbox and Chat; My work lives here.
          row(navItems.firstWhere((i) => i.id == 'my-work')),
          ...section(NavSection.projects, null),
          ...section(NavSection.workspace, l.shellWorkspaceGroup),
          ...section(NavSection.admin, l.shellAdminGroup),
          heading(l.grpKGroupAccount),
          ...section(NavSection.account, null),
          TfRow(
            key: const Key('more-shortcuts'),
            title: l.grpKShortcuts,
            leading: const TfIcon(TfIcons.keyboard, size: 18),
            onTap: () {
              Navigator.of(context).pop();
              openCheatSheet(context);
            },
          ),
          TfRow(
            key: const Key('more-sign-out'),
            title: l.signOut,
            leading: const TfIcon(TfIcons.signOut, size: 18),
            onTap: ref.read(authSessionProvider).signOut,
          ),
        ],
      ),
    );
  }
}
