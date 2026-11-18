import 'package:material_ui/material_ui.dart';

/// A foreground on its own soft background (a chip, a banner, a status pill).
class TfTone {
  const TfTone(this.fg, this.bg);

  final Color fg;
  final Color bg;
}

/// Every colour the app uses, for one look (light, dark, or high contrast).
/// Screens read it through `context.tf.colors`; nothing else holds a hex value.
class TfColors {
  const TfColors({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.raised,
    required this.sunken,
    required this.hover,
    required this.selected,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.accent,
    required this.onAccent,
    required this.accentTone,
    required this.focus,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.neutral,
    required this.categorical,
  });

  final Brightness brightness;

  /// Page background, the panel on it, a popover/dialog above that, a
  /// recessed well (inputs, code). Dark mode shows height by lightness.
  final Color canvas, surface, raised, sunken;

  /// Row fills for pointer-over and selection.
  final Color hover, selected;

  /// Hairline and the stronger line a control needs to be seen (3:1).
  final Color border, borderStrong;

  /// Body, secondary and tertiary (placeholder) text; all pass AA on [surface].
  final Color text, textMuted, textSubtle;

  /// The one accent (ember), the text on it, and its soft fill with text.
  final Color accent, onAccent;
  final TfTone accentTone;

  /// Keyboard focus ring.
  final Color focus;

  final TfTone success, warning, danger, info, neutral;

  /// Ten hues for projects, labels and chart series (3:1 on [surface]).
  final List<Color> categorical;

  bool get isDark => brightness == Brightness.dark;

  /// Status categories: to do, in progress, done. Always paired with a label
  /// or shape by the component, never colour alone.
  TfTone get statusTodo => neutral;
  TfTone get statusActive => info;
  TfTone get statusDone => success;

  Color category(int index) => categorical[index % categorical.length];

  TfColors copyWith({
    Color? text,
    Color? textMuted,
    Color? textSubtle,
    Color? border,
    Color? borderStrong,
    Color? accent,
    Color? onAccent,
    Color? focus,
    TfTone? accentTone,
  }) => TfColors(
    brightness: brightness,
    canvas: canvas,
    surface: surface,
    raised: raised,
    sunken: sunken,
    hover: hover,
    selected: selected,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    textSubtle: textSubtle ?? this.textSubtle,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    accentTone: accentTone ?? this.accentTone,
    focus: focus ?? this.focus,
    success: success,
    warning: warning,
    danger: danger,
    info: info,
    neutral: neutral,
    categorical: categorical,
  );

  static TfColors of(Brightness brightness, {bool highContrast = false}) {
    final base = brightness == Brightness.dark ? dark : light;
    if (!highContrast) return base;
    return brightness == Brightness.dark ? _highDark : _highLight;
  }

  static const light = TfColors(
    brightness: Brightness.light,
    canvas: Color(0xFFF7F7F5),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFFFFFFF),
    sunken: Color(0xFFF1F1EE),
    hover: Color(0xFFF1F1EE),
    selected: Color(0xFFFFF1E6),
    border: Color(0xFFE4E4DF),
    borderStrong: Color(0xFF8A8A84),
    text: Color(0xFF171716),
    textMuted: Color(0xFF55554F),
    textSubtle: Color(0xFF6B6B66),
    accent: Color(0xFFC2410C),
    onAccent: Color(0xFFFFFFFF),
    accentTone: TfTone(Color(0xFF9A3412), Color(0xFFFFEDD5)),
    focus: Color(0xFF1D4ED8),
    success: TfTone(Color(0xFF15803D), Color(0xFFDCFCE7)),
    warning: TfTone(Color(0xFF92400E), Color(0xFFFEF3C7)),
    danger: TfTone(Color(0xFFB91C1C), Color(0xFFFEE2E2)),
    info: TfTone(Color(0xFF1D4ED8), Color(0xFFDBEAFE)),
    neutral: TfTone(Color(0xFF4B4B47), Color(0xFFECECE9)),
    categorical: [
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFFC026D3),
      Color(0xFFDB2777),
      Color(0xFFDC2626),
      Color(0xFFD97706),
      Color(0xFF4D7C0F),
      Color(0xFF059669),
      Color(0xFF0891B2),
      Color(0xFF475569),
    ],
  );

  static const dark = TfColors(
    brightness: Brightness.dark,
    canvas: Color(0xFF0E0E0F),
    surface: Color(0xFF161618),
    raised: Color(0xFF1E1E21),
    sunken: Color(0xFF0A0A0B),
    hover: Color(0xFF1F1F22),
    selected: Color(0xFF2B1B10),
    border: Color(0xFF2C2C30),
    borderStrong: Color(0xFF6A6A72),
    text: Color(0xFFF4F4F6),
    textMuted: Color(0xFFB4B4BC),
    textSubtle: Color(0xFF93939B),
    accent: Color(0xFFFB923C),
    onAccent: Color(0xFF1A0B02),
    accentTone: TfTone(Color(0xFFFDBA74), Color(0xFF3A1F0E)),
    focus: Color(0xFF93C5FD),
    success: TfTone(Color(0xFF4ADE80), Color(0xFF0F2E1A)),
    warning: TfTone(Color(0xFFFBBF24), Color(0xFF33260A)),
    danger: TfTone(Color(0xFFF87171), Color(0xFF3A1414)),
    info: TfTone(Color(0xFF60A5FA), Color(0xFF11264A)),
    neutral: TfTone(Color(0xFFBDBDC4), Color(0xFF26262A)),
    categorical: [
      Color(0xFF60A5FA),
      Color(0xFFA78BFA),
      Color(0xFFE879F9),
      Color(0xFFF472B6),
      Color(0xFFF87171),
      Color(0xFFFBBF24),
      Color(0xFFA3E635),
      Color(0xFF34D399),
      Color(0xFF22D3EE),
      Color(0xFF94A3B8),
    ],
  );

  static final _highLight = light.copyWith(
    text: const Color(0xFF000000),
    textMuted: const Color(0xFF26261F),
    textSubtle: const Color(0xFF3A3A35),
    border: const Color(0xFF55554F),
    borderStrong: const Color(0xFF26261F),
    accent: const Color(0xFF9A3412),
    focus: const Color(0xFF1E3A8A),
    accentTone: const TfTone(Color(0xFF7C2D12), Color(0xFFFFEDD5)),
  );

  static final _highDark = dark.copyWith(
    text: const Color(0xFFFFFFFF),
    textMuted: const Color(0xFFE4E4E8),
    textSubtle: const Color(0xFFCFCFD6),
    border: const Color(0xFF9393A0),
    borderStrong: const Color(0xFFCFCFD6),
    accent: const Color(0xFFFDBA74),
    focus: const Color(0xFFBFDBFE),
    accentTone: const TfTone(Color(0xFFFED7AA), Color(0xFF3A1F0E)),
  );
}

/// WCAG 2 contrast ratio between two opaque colours (1 to 21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// The few colours that are not part of a theme.
const Color tfBlack = Color(0xFF000000);
const Color tfWhite = Color(0xFFFFFFFF);

/// Fully transparent (an unset fill or tint).
const Color tfClear = Color(0x00000000);

/// The dim behind a modal layer.
const Color tfScrim = Color(0x66000000);
