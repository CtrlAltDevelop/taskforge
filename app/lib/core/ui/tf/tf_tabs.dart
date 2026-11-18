import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Underlined tabs: switch between views of the same thing. The underline
/// slides to the chosen tab (instantly when motion is reduced, and on the
/// first paint).
class TfTabs extends StatefulWidget {
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
  State<TfTabs> createState() => _TfTabsState();
}

class _TfTabsState extends State<TfTabs> {
  final _rowKey = GlobalKey();
  List<GlobalKey> _tabKeys = const [];

  /// The chosen tab's left edge and width inside the row, once measured.
  ({double left, double width})? _span;
  var _animate = false;

  void _measure() {
    if (!mounted || widget.index >= _tabKeys.length) return;
    final row = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    final tab =
        _tabKeys[widget.index].currentContext?.findRenderObject() as RenderBox?;
    if (row == null || !row.attached || tab == null || !tab.attached) return;
    final left = row.globalToLocal(tab.localToGlobal(Offset.zero)).dx;
    final next = (left: left, width: tab.size.width);
    if (next == _span) return;
    setState(() {
      _animate = _span != null;
      _span = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    if (_tabKeys.length != widget.labels.length) {
      _tabKeys = [for (final _ in widget.labels) GlobalKey()];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final span = _span;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.border, width: tfHairline),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          children: [
            Row(
              key: _rowKey,
              children: [
                for (var i = 0; i < widget.labels.length; i++)
                  TfInteractive(
                    key: _tabKeys[i],
                    onTap: () => widget.onChanged(i),
                    selected: i == widget.index,
                    semanticLabel: widget.labels[i],
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
                      ),
                      foregroundDecoration: states.contains(WidgetState.focused)
                          ? BoxDecoration(border: tfFocusRing(c))
                          : null,
                      child: Text(
                        widget.labels[i],
                        style: tf.typography.label.copyWith(
                          color: i == widget.index ? c.text : c.textMuted,
                          fontWeight: i == widget.index
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (span != null)
              AnimatedPositioned(
                key: const Key('tab-underline'),
                duration: _animate
                    ? TfMotion.of(context, TfDuration.base)
                    : Duration.zero,
                curve: tfCurve,
                left: span.left,
                width: span.width,
                bottom: 0,
                height: 2,
                child: ColoredBox(color: c.accent),
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
                    borderRadius: TfRadius.inset,
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
