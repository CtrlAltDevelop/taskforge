import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Gives [child] (usually a Column with an Expanded part) at least
/// [minHeight]; when the window is shorter the page scrolls instead of
/// overflowing.
class ScrollIfShort extends StatelessWidget {
  const ScrollIfShort({
    super.key,
    required this.minHeight,
    required this.child,
  });

  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => SingleChildScrollView(
      child: SizedBox(height: math.max(box.maxHeight, minHeight), child: child),
    ),
  );
}
