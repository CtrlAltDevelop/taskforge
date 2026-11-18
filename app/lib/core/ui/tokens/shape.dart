import 'package:material_ui/material_ui.dart';

/// Corner radii: chips and keys, controls, panels, dialogs.
abstract final class TfRadius {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;

  static BorderRadius get chip => BorderRadius.circular(xs);
  static BorderRadius get control => BorderRadius.circular(sm);
  static BorderRadius get panel => BorderRadius.circular(md);
  static BorderRadius get dialog => BorderRadius.circular(lg);
}

/// Hairline border width.
const double tfHairline = 1;

/// The only two shadows: a popover/menu, and a modal.
abstract final class TfShadow {
  static const popover = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const modal = [
    BoxShadow(color: Color(0x33000000), blurRadius: 32, offset: Offset(0, 12)),
  ];
}
