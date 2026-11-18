import 'package:material_ui/material_ui.dart';

/// The colours of a chart's series, the same in every chart and in both
/// themes (picked to stay apart for the common kinds of colour blindness).
List<Color> chartPalette(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return dark
      ? const [
          Color(0xFF6CA6FF),
          Color(0xFFFFB454),
          Color(0xFF5FD3A5),
          Color(0xFFE88AB8),
          Color(0xFFB8A2FF),
          Color(0xFFE5E066),
          Color(0xFF63D5E6),
          Color(0xFFFF8A75),
        ]
      : const [
          Color(0xFF1F6FEB),
          Color(0xFFD97706),
          Color(0xFF0E9F6E),
          Color(0xFFC2417A),
          Color(0xFF7C5CE6),
          Color(0xFF9A8F00),
          Color(0xFF0891B2),
          Color(0xFFD9482B),
        ];
}
