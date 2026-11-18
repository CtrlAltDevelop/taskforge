import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Underlined tabs: switch between views of the same thing.
class TfTabs extends StatelessWidget {
  const TfTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.border, width: tfHairline),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              TfInteractive(
                onTap: () => onChanged(i),
                selected: i == index,
                semanticLabel: labels[i],
                builder: (context, states) => Container(
                  constraints: BoxConstraints(
                    minHeight: tfTarget(
                      context,
                      tf.density.controlHeight + TfSpace.xs,
                    ),
                  ),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: tf.density.padX + TfSpace.xs,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: states.contains(WidgetState.hovered)
                        ? c.hover
                        : null,
                    border: Border(
                      bottom: BorderSide(
                        color: i == index ? c.accent : const Color(0x00000000),
                        width: 2,
                      ),
                    ),
                  ),
                  foregroundDecoration: states.contains(WidgetState.focused)
                      ? BoxDecoration(border: tfFocusRing(c))
                      : null,
                  child: Text(
                    labels[i],
                    style: tf.typography.label.copyWith(
                      color: i == index ? c.text : c.textMuted,
                      fontWeight: i == index
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A pill group where exactly one option is chosen (view switchers, density).
class TfSegmented<T> extends StatelessWidget {
  const TfSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.scrollable = true,
  });

  /// Value to label, in display order.
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  /// Scrolls sideways when too wide; off where the parent wraps or sizes it.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: TfRadius.control,
        border: Border.all(color: c.border, width: tfHairline),
      ),
      child: _MaybeScroll(
        scrollable: scrollable,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in options.entries)
              TfInteractive(
                onTap: () => onChanged(e.key),
                selected: e.key == value,
                semanticLabel: e.value,
                builder: (context, states) => Container(
                  constraints: BoxConstraints(
                    minHeight: tfTarget(context, tf.density.controlHeight - 4),
                  ),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: tf.density.padX,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.key == value
                        ? c.surface
                        : (states.contains(WidgetState.hovered)
                              ? c.hover
                              : null),
                    borderRadius: BorderRadius.circular(TfRadius.sm - 1),
                    border: states.contains(WidgetState.focused)
                        ? tfFocusRing(c)
                        : (e.key == value
                              ? Border.all(color: c.border, width: tfHairline)
                              : null),
                  ),
                  child: Text(
                    e.value,
                    style: tf.typography.label.copyWith(
                      color: e.key == value ? c.text : c.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MaybeScroll extends StatelessWidget {
  const _MaybeScroll({required this.scrollable, required this.child});

  final bool scrollable;
  final Widget child;

  @override
  Widget build(BuildContext context) => scrollable
      ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: child)
      : child;
}
