import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// True on phones and tablets, where targets must be finger-sized.
bool get tfIsTouch => const {
  TargetPlatform.android,
  TargetPlatform.iOS,
  TargetPlatform.fuchsia,
}.contains(defaultTargetPlatform);

/// Smallest tappable height: 44 dp on touch (never below 40), none on pointers.
double tfMinTarget(TfDensity density) => tfIsTouch
    ? (density == TfDensity.comfortable ? 44 : TfDensity.minTouchTarget)
    : 0;

/// Black or white, whichever reads better on [background] (text on a hue
/// from the categorical palette).
Color tfOnColor(Color background) =>
    contrastRatio(tfBlack, background) >= contrastRatio(tfWhite, background)
    ? tfBlack
    : tfWhite;

/// [base] pushed toward black (light) or white (dark) for hover / pressed.
Color tfShade(TfColors c, Color base, double amount) => Color.alphaBlend(
  (c.isDark ? Colors.white : Colors.black).withValues(alpha: amount),
  base,
);

/// The visible keyboard-focus ring every interactive component draws.
Border tfFocusRing(TfColors c) => Border.all(color: c.focus, width: 2);

/// Makes every [TfInteractive] below draw as if in [states]: the gallery uses
/// it to show hover, focus and pressed without a pointer.
class TfForcedStates extends InheritedWidget {
  const TfForcedStates({super.key, required this.states, required super.child});

  final Set<WidgetState> states;

  static Set<WidgetState> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TfForcedStates>()?.states ??
      const {};

  @override
  bool updateShouldNotify(TfForcedStates old) => !setEquals(old.states, states);
}

/// What a component receives to draw itself: hovered, focused (keyboard only),
/// pressed, disabled and selected, as [WidgetState]s.
typedef TfStateBuilder = Widget Function(
  BuildContext context,
  Set<WidgetState> states,
);

/// Hover, focus, press and keyboard activation (Enter / Space) in one place.
/// No Material ripple: components draw a subtle fill from the states instead.
class TfInteractive extends StatefulWidget {
  const TfInteractive({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.selected,
    this.checked,
    this.mixed,
    this.toggled,
    this.padTarget = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.button = true,
    this.cursor,
  });

  final TfStateBuilder builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Null when the component cannot be selected (no "not selected" announced).
  final bool? selected;
  final bool? checked;
  final bool? mixed;
  final bool? toggled;

  /// Grow the hit area to the touch minimum (components with no painted box).
  final bool padTarget;

  /// A complete spoken label; hides the children's own text so it is read once.
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Announced as a button; false for rows that are only selectable.
  final bool button;
  final MouseCursor? cursor;

  @override
  State<TfInteractive> createState() => _TfInteractiveState();
}

class _TfInteractiveState extends State<TfInteractive> {
  bool _hovered = false;
  bool _focusVisible = false;
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _set(void Function() change) {
    if (mounted) setState(change);
  }

  @override
  Widget build(BuildContext context) {
    final forced = TfForcedStates.of(context);
    final states = <WidgetState>{
      ...forced,
      if (!_enabled) WidgetState.disabled,
      if (_enabled && _hovered) WidgetState.hovered,
      if (_enabled && _focusVisible) WidgetState.focused,
      if (_enabled && _pressed) WidgetState.pressed,
      if (widget.selected ?? false) WidgetState.selected,
    };
    final min = tfMinTarget(context.tf.density);
    Widget child = widget.builder(context, states);
    if (widget.padTarget && min > 0) {
      child = ConstrainedBox(
        constraints: BoxConstraints(minHeight: min, minWidth: min),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      );
    }
    return Semantics(
      button: widget.button,
      selected: widget.selected,
      checked: widget.checked,
      mixed: widget.mixed,
      toggled: widget.toggled,
      enabled: widget.button ? _enabled : null,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      child: FocusableActionDetector(
        enabled: _enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mouseCursor:
            widget.cursor ??
            (_enabled ? SystemMouseCursors.click : MouseCursor.defer),
        onShowHoverHighlight: (v) => _set(() => _hovered = v),
        onShowFocusHighlight: (v) => _set(() => _focusVisible = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: _enabled ? (_) => _set(() => _pressed = true) : null,
          onTapUp: (_) => _set(() => _pressed = false),
          onTapCancel: () => _set(() => _pressed = false),
          child: child,
        ),
      ),
    );
  }
}

/// A rounded box with the standard fill, hairline border and focus ring.
class TfSurface extends StatelessWidget {
  const TfSurface({
    super.key,
    required this.child,
    this.fill,
    this.border,
    this.focused = false,
    this.radius,
    this.padding,
    this.height,
    this.touchTarget = true,
  });

  final Widget child;
  final Color? fill;
  final Color? border;
  final bool focused;
  final BorderRadius? radius;
  final EdgeInsetsGeometry? padding;
  final double? height;

  /// Grow to the touch minimum on phones; false for small parts such as a checkbox box.
  final bool touchTarget;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    final min = math.max(
      height ?? 0,
      touchTarget ? tfMinTarget(context.tf.density) : 0.0,
    );
    return Container(
      constraints: min > 0 ? BoxConstraints(minHeight: min) : null,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius ?? TfRadius.control,
        border: focused
            ? tfFocusRing(c)
            : (border == null
                  ? null
                  : Border.all(color: border!, width: tfHairline)),
      ),
      child: child,
    );
  }
}

/// [height] grown to the touch minimum on phones: for painted boxes that are
/// not [TfSurface] (rows, tabs).
double tfTarget(BuildContext context, double height) =>
    math.max(height, tfMinTarget(context.tf.density));
