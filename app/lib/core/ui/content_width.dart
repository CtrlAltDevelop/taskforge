import 'package:material_ui/material_ui.dart';

/// Widest a reading column (settings, forms, lists) gets: on a wide window the
/// content stays a comfortable column instead of stretching edge to edge.
const contentMaxWidth = 760.0;

/// Centres [child] at the top and caps its width at [maxWidth].
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
