import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/frame_scope.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Width of the open sidebar and of its icon strip.
const sidebarWidth = 264.0;
const sidebarStripWidth = 56.0;

/// One row of the sidebar: an accent bar and tinted fill when [selected],
/// a "…" on hover or focus when [trailing] is given. In the [strip] only the
/// [leading] shows, with the label as tooltip.
class SidebarItem extends StatefulWidget {
  const SidebarItem({
    super.key,
    required this.label,
    required this.leading,
    required this.onTap,
    this.selected = false,
    this.strip = false,
    this.trailing,
    this.hint,
    this.onKey,
    this.autofocus = false,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onTap;
  final bool selected;
  final bool strip;

  /// Shown on hover or focus only (an item's "…" menu).
  final Widget? trailing;

  /// Always shown at the end (a shortcut hint).
  final Widget? hint;

  /// Extra keys while the item has focus (F2 to rename).
  final KeyEventResult Function(KeyEvent event)? onKey;

  /// Takes keyboard focus when it appears (focus handed back after a page opens).
  final bool autofocus;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  final _node = FocusNode(debugLabel: 'sidebar item');
  bool _hovered = false;
  bool _focused = false;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  /// Up and Down walk the sidebar; anything else goes to [SidebarItem.onKey].
  KeyEventResult _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        return FocusScope.of(context).nextFocus()
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        return FocusScope.of(context).previousFocus()
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
    }
    return widget.onKey?.call(event) ?? KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final item = TfInteractive(
      focusNode: _node,
      autofocus: widget.autofocus,
      onTap: widget.onTap == null
          ? null
          : () {
              // A click also starts keyboard traversal from this row.
              _node.requestFocus();
              widget.onTap!();
            },
      selected: widget.selected ? true : null,
      semanticLabel: widget.strip ? widget.label : null,
      builder: (context, states) {
        final fill = widget.selected
            ? c.selected
            : states.contains(WidgetState.hovered)
            ? c.hover
            : Colors.transparent;
        return Container(
          constraints: BoxConstraints(
            minHeight: tfTarget(context, tf.density.rowHeight - TfSpace.xs),
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: TfRadius.control,
            border: states.contains(WidgetState.focused)
                ? tfFocusRing(c)
                : null,
          ),
          child: Row(
            children: [
              // The accent bar of the open page.
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: widget.selected ? c.accent : null,
                  borderRadius: TfRadius.chip,
                ),
              ),
              SizedBox(width: widget.strip ? TfSpace.sm : TfSpace.sm - 1),
              widget.leading,
              if (!widget.strip) ...[
                const SizedBox(width: TfSpace.sm),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (widget.selected
                                ? tf.typography.bodyStrong
                                : tf.typography.body)
                            .copyWith(
                              color: widget.selected ? c.text : c.textMuted,
                            ),
                  ),
                ),
                if (widget.trailing != null && (_hovered || _focused))
                  widget.trailing!,
                if (widget.hint != null) widget.hint!,
                const SizedBox(width: TfSpace.xs),
              ],
            ],
          ),
        );
      },
    );
    final claimed = widget.onKey == null
        ? item
        : KeyClaim(chords: const {'f2'}, child: item);
    final wrapped = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (_, event) => _onKey(event),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: claimed,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TfSpace.sm, vertical: 1),
      child: widget.strip
          ? TfTooltip(message: widget.label, child: wrapped)
          : Tooltip(
              // Long names are cut: the whole name on hover.
              message: widget.label,
              waitDuration: const Duration(milliseconds: 600),
              // Hover only: a long press belongs to drag-to-reorder.
              triggerMode: TooltipTriggerMode.manual,
              excludeFromSemantics: true,
              child: wrapped,
            ),
    );
  }
}

/// A sidebar group heading that opens and closes its group.
class SidebarSection extends StatelessWidget {
  const SidebarSection({
    super.key,
    required this.title,
    required this.open,
    required this.onToggle,
    this.action,
  });

  final String title;
  final bool open;
  final VoidCallback onToggle;

  /// A button at the end of the heading ("+" to create).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        TfSpace.sm,
        TfSpace.md,
        TfSpace.sm,
        TfSpace.xxs,
      ),
      child: Row(
        children: [
          Expanded(
            child: TfInteractive(
              onTap: onToggle,
              toggled: open,
              semanticLabel: title,
              builder: (context, states) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TfSpace.sm,
                  vertical: TfSpace.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: TfRadius.control,
                  border: states.contains(WidgetState.focused)
                      ? tfFocusRing(c)
                      : null,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tf.typography.caption.copyWith(
                          color: states.contains(WidgetState.hovered)
                              ? c.text
                              : c.textSubtle,
                        ),
                      ),
                    ),
                    const SizedBox(width: TfSpace.xs),
                    TfIcon(
                      open ? TfIcons.chevronDown : TfIcons.chevronEnd,
                      size: 12,
                      color: c.textSubtle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
