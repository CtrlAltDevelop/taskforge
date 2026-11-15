import 'package:material_ui/material_ui.dart';

/// An icon that points along the reading direction (a chevron to "next", an
/// arrow to "forward") and so turns around in right-to-left layouts.
///
/// Logos, media controls and symbols with no direction stay plain [Icon]s.
class DirectionalIcon extends StatelessWidget {
  const DirectionalIcon(this.icon, {super.key, this.size, this.color});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Transform.flip(
    flipX: Directionality.of(context) == TextDirection.rtl,
    child: Icon(icon, size: size, color: color),
  );
}
