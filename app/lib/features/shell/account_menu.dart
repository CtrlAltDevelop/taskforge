import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/shell/nav_access.dart';
import 'package:taskforge/features/shell/nav_items.dart';

/// The avatar menu: every account page, then sign out. [wide] shows the
/// person's name next to the avatar (the open sidebar); otherwise only the
/// avatar (the strip, the top bar).
class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key, this.onNavigate, this.wide = false});

  final VoidCallback? onNavigate;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final account = ref.watch(accountProvider).value;
    final name = account == null
        ? l.grpKGroupAccount
        : (account.displayName.isEmpty ? account.email : account.displayName);
    final items = ref.watch(navAccessProvider).visible(NavSection.account);
    final tf = context.tf;
    return TfMenu(
      items: [
        for (final item in items)
          TfMenuItem(
            label: item.labelOf(l),
            icon: item.icon,
            onSelected: () {
              context.go(item.path);
              onNavigate?.call();
            },
          ),
        TfMenuItem(
          label: l.signOut,
          icon: TfIcons.signOut,
          danger: true,
          onSelected: ref.read(authSessionProvider).signOut,
        ),
      ],
      builder: (context, toggle) => TfInteractive(
        key: const Key('profile-menu'),
        onTap: toggle,
        semanticLabel: l.grpKGroupAccount,
        builder: (context, states) => Container(
          padding: const EdgeInsets.all(TfSpace.xs),
          decoration: BoxDecoration(
            color: states.contains(WidgetState.hovered)
                ? tf.colors.hover
                : null,
            borderRadius: TfRadius.control,
            border: states.contains(WidgetState.focused)
                ? tfFocusRing(tf.colors)
                : null,
          ),
          child: Row(
            mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
            children: [
              TfAvatar(name: name, colorSeed: account?.email),
              if (wide) ...[
                const SizedBox(width: TfSpace.sm),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tf.typography.body.copyWith(color: tf.colors.text),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
