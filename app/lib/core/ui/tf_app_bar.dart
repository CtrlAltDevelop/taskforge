import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';

/// The app bar every page uses: an [AppBar] that always has a way back (the
/// previous page, else home) and, inside the router, a profile menu.
/// Pass [leading] to override the way back; the drawer button of shell pages
/// is kept.
class TfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TfAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    final atHome = _path(router) == '/';
    return AppBar(
      title: title,
      bottom: bottom,
      leading: leading ?? _back(context, router, atHome),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        ...?actions,
        if (router != null && !atHome) const _ProfileMenu(),
      ],
    );
  }

  Widget? _back(BuildContext context, GoRouter? router, bool atHome) {
    if (!automaticallyImplyLeading || router == null || atHome) return null;
    if (Navigator.canPop(context)) return null; // the default back button
    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) return null; // menu
    return BackButton(
      key: const Key('app-bar-home'),
      onPressed: () => router.go('/'),
    );
  }

  /// A phone-width bar with several actions has no room for one more icon.
  bool roomForProfile(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 400 || (actions?.length ?? 0) < 2;

  static String _path(GoRouter? router) =>
      router?.routeInformationProvider.value.uri.path ?? '';
}

class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final router = GoRouter.of(context);
    return PopupMenuButton<String>(
      key: const Key('profile-menu'),
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: t.grpKGroupAccount,
      onSelected: (path) => path.isEmpty
          ? ref.read(authSessionProvider).signOut()
          : router.go(path),
      itemBuilder: (_) => [
        PopupMenuItem(value: '/', child: Text(t.grpKGroupAccount)),
        PopupMenuItem(
          value: '/settings/language',
          child: Text(t.languageAndRegion),
        ),
        PopupMenuItem(value: '/settings/security', child: Text(t.secTitle)),
        PopupMenuItem(value: '/sessions', child: Text(t.sessions)),
        PopupMenuItem(value: '', child: Text(t.signOut)),
      ],
    );
  }
}
