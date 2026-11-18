/// 4-point spacing scale. Screens use these names, not literals.
abstract final class TfSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 48;
}

/// Comfortable (roomy, touch-first) or compact (dense, pointer-first).
enum TfDensity {
  comfortable(rowHeight: 40, padX: 12, controlHeight: 36),
  compact(rowHeight: 32, padX: 8, controlHeight: 28);

  const TfDensity({
    required this.rowHeight,
    required this.padX,
    required this.controlHeight,
  });

  final double rowHeight;
  final double padX;
  final double controlHeight;

  /// Touch targets never shrink below this, whatever the density.
  static const double minTouchTarget = 40;
}
