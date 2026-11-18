import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/tokens/spacing.dart';

/// The 7-step type scale: 11/12/13/14/16/20/28.
abstract final class TfFontSize {
  static const double caption = 11;
  static const double small = 12;
  static const double label = 13;
  static const double body = 14;
  static const double lead = 16;
  static const double title = 20;
  static const double display = 28;
}

/// Inter is bundled; Vazirmatn draws Arabic-script text. No runtime download.
const tfFontFamily = 'Inter';
const tfArabicScriptFonts = [
  'Vazirmatn',
  'Noto Naskh Arabic',
  'Noto Sans Arabic',
];
const tfMonoFamilies = ['Menlo', 'Consolas', 'Roboto Mono', 'monospace'];

const _tabular = [FontFeature.tabularFigures()];

/// Text styles read from `context.tf.type`; colour comes from the caller.
class TfType {
  const TfType._(this.scale);

  /// Comfortable density: the scale as written.
  static const instance = TfType._(1);

  /// Compact density: every size a little smaller.
  static const compact = TfType._(0.93);

  /// The type for [density].
  static TfType forDensity(TfDensity density) =>
      density == TfDensity.compact ? compact : instance;

  final double scale;

  TextStyle _s(double size, FontWeight weight, {double? height}) => TextStyle(
    fontFamily: tfFontFamily,
    fontFamilyFallback: tfArabicScriptFonts,
    fontSize: size * scale,
    fontWeight: weight,
    height: height ?? 1.4,
  );

  TextStyle get caption => _s(TfFontSize.caption, FontWeight.w500);
  TextStyle get small => _s(TfFontSize.small, FontWeight.w400);
  TextStyle get label => _s(TfFontSize.label, FontWeight.w500);
  TextStyle get body => _s(TfFontSize.body, FontWeight.w400);
  TextStyle get bodyStrong => _s(TfFontSize.body, FontWeight.w600);
  TextStyle get lead => _s(TfFontSize.lead, FontWeight.w600);
  TextStyle get title => _s(TfFontSize.title, FontWeight.w600, height: 1.3);
  TextStyle get display => _s(TfFontSize.display, FontWeight.w700, height: 1.2);

  /// Ids, counts and times: digits keep their width so columns line up.
  TextStyle get tabular => body.copyWith(fontFeatures: _tabular);

  /// Task keys such as `TF-123`.
  TextStyle get mono => body.copyWith(
    fontFamily: tfMonoFamilies.first,
    fontFamilyFallback: tfMonoFamilies.sublist(1),
    fontSize: TfFontSize.small * scale,
    fontFeatures: _tabular,
  );

  /// The Material text theme built on this scale.
  TextTheme get textTheme => TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: display,
    headlineLarge: title,
    headlineMedium: title,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: lead,
    titleSmall: bodyStrong,
    bodyLarge: lead.copyWith(fontWeight: FontWeight.w400),
    bodyMedium: body,
    bodySmall: small,
    labelLarge: label,
    labelMedium: label,
    labelSmall: caption,
  );
}
