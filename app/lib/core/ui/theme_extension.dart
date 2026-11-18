import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tokens/typography.dart';

/// The design tokens on the theme: `context.tf.colors`, `.density`, `.typography`.
@immutable
class TfTheme extends ThemeExtension<TfTheme> {
  const TfTheme({
    required this.colors,
    this.density = TfDensity.comfortable,
    this.typography = TfType.instance,
  });

  final TfColors colors;
  final TfDensity density;
  final TfType typography;

  @override
  TfTheme copyWith({TfColors? colors, TfDensity? density}) => TfTheme(
    colors: colors ?? this.colors,
    density: density ?? this.density,
    typography: typography,
  );

  // Palettes are shared constants, so identity is value equality. Without
  // this every rebuilt ThemeData differs and MaterialApp animates a "change".
  @override
  bool operator ==(Object other) =>
      other is TfTheme &&
      identical(other.colors, colors) &&
      other.density == density &&
      other.typography == typography;

  @override
  int get hashCode =>
      Object.hash(identityHashCode(colors), density, typography);

  /// Looks switch at once; there is nothing to blend between.
  @override
  TfTheme lerp(TfTheme? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension TfThemeContext on BuildContext {
  TfTheme get tf =>
      Theme.of(this).extension<TfTheme>() ??
      const TfTheme(colors: TfColors.light);
}
