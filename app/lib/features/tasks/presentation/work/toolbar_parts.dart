import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';

/// A toolbar control that opens a menu: icon and current choice. The [key]
/// sits on the button, so a tap on it opens the menu.
class ToolbarMenu extends StatelessWidget {
  const ToolbarMenu({
    super.key,
    required this.icon,
    required this.label,
    required this.items,
    this.active = false,
  });

  final TfIconData icon;
  final String label;
  final List<TfMenuItem> items;

  /// Something other than the default is chosen: drawn as the accent.
  final bool active;

  @override
  Widget build(BuildContext context) {
    // A phone has no room for the words: an icon, with the choice as tooltip.
    final iconOnly = ScreenSize.of(context).isCompact && !active;
    return TfMenu(
      items: items,
      builder: (context, toggle) => iconOnly
          ? TfIconButton(
              icon: icon,
              tooltip: label,
              size: TfButtonSize.small,
              onPressed: toggle,
            )
          : TfButton(
              label: label,
              icon: icon,
              size: TfButtonSize.small,
              variant: active
                  ? TfButtonVariant.secondary
                  : TfButtonVariant.ghost,
              onPressed: toggle,
            ),
    );
  }
}

/// A toolbar's single-key action (refresh and the like).
class ToolbarIcon extends StatelessWidget {
  const ToolbarIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final TfIconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TfIconButton(
    icon: icon,
    tooltip: tooltip,
    size: TfButtonSize.small,
    onPressed: onPressed,
  );
}

/// Shown beside the controls when the layout could not be saved: the choice
/// holds for this session only.
class SaveFailedMark extends StatelessWidget {
  const SaveFailedMark({
    super.key,
    required this.message,
    required this.markKey,
  });

  final String message;

  /// The key of the icon itself (the views are found by it).
  final Key markKey;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: message,
    child: TfIcon(
      TfIcons.warning,
      key: markKey,
      size: 20,
      color: context.tf.colors.warning.fg,
    ),
  );
}

/// A toggle in a toolbar (hide finished, critical path, current sprint).
class ToolbarToggle extends StatelessWidget {
  const ToolbarToggle({
    super.key,
    required this.label,
    required this.on,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;
  final TfIconData? icon;

  @override
  Widget build(BuildContext context) => TfChip(
    label: label,
    icon: icon,
    selected: on,
    onTap: () => onChanged(!on),
  );
}
