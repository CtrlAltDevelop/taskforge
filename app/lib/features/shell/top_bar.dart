import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/sync/presentation/connection_status.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/search/presentation/search_overlay.dart';
import 'package:taskforge/features/shell/breadcrumbs.dart';
import 'package:taskforge/features/shell/create_menu.dart';
import 'package:taskforge/features/shell/project_switcher.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_host.dart';

/// Height of the top bar.
const topBarHeight = 48.0;

/// The bar above every page: where you are (breadcrumbs), search, "+ Create",
/// the live/offline dot and notifications. On a phone it shows the page title
/// (tap it inside a project to switch project) and the two buttons.
class TopBar extends ConsumerWidget {
  const TopBar({super.key, required this.size, this.onMenu});

  final ScreenSize size;

  /// Opens the sidebar as an overlay (tablets); null where it is always there.
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.tf.colors;
    final uri = GoRouterState.of(context).uri;
    final crumbs = currentCrumbs(ref, uri, l);
    final compact = size.isCompact;
    final inProject =
        uri.pathSegments.firstOrNull == 'projects' &&
        uri.pathSegments.length >= 2 &&
        !const {'archived', 'private'}.contains(uri.pathSegments[1]);
    final title = Text(
      crumbs.last.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.tf.typography.lead.copyWith(color: c.text),
    );
    // On iOS the status bar / Dynamic Island sits over the app: the bar's
    // background extends under it and its content starts below.
    final inset = MediaQuery.paddingOf(context).top;
    return Container(
      height: topBarHeight + inset,
      padding: EdgeInsets.fromLTRB(TfSpace.sm, inset, TfSpace.sm, 0),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          if (onMenu != null)
            TfIconButton(
              key: const Key('open-sidebar'),
              icon: TfIcons.menu,
              tooltip: l.grpENavMenu,
              onPressed: onMenu,
            ),
          Expanded(
            child: compact
                ? Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: inProject
                        ? TextButton(
                            key: const Key('project-switcher'),
                            onPressed: () => showProjectSwitcher(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: title),
                                const TfIcon(TfIcons.chevronDown),
                              ],
                            ),
                          )
                        : title,
                  )
                : Breadcrumbs(crumbs: crumbs),
          ),
          if (compact)
            TfIconButton(
              key: const Key('open-search'),
              icon: TfIcons.search,
              tooltip: l.grpESearch,
              onPressed: () => openSearch(context),
            )
          else
            TfButton(
              key: const Key('top-search'),
              label: l.grpESearch,
              icon: TfIcons.search,
              size: TfButtonSize.small,
              onPressed: () => openSearch(context),
            ),
          if (compact) const QuickActionsButton(),
          const SizedBox(width: TfSpace.sm),
          const LiveIndicator(),
          const SizedBox(width: TfSpace.sm),
          CreateMenu(compact: compact),
          if (!compact)
            TfIconButton(
              key: const Key('open-inbox-bell'),
              icon: TfIcons.bell,
              tooltip: l.inbox,
              onPressed: () => context.go('/inbox'),
            ),
        ],
      ),
    );
  }
}
