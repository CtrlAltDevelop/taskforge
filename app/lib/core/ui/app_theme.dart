import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tokens/typography.dart';

/// Builds the light, dark or high-contrast theme from the design tokens.
/// [fontFallback] is kept for callers that pass their own; the tokens already
/// carry the Arabic-script faces.
ThemeData buildAppTheme({
  required Brightness brightness,
  List<String> fontFallback = tfArabicScriptFonts,
  TfDensity density = TfDensity.comfortable,
  bool highContrast = false,
}) {
  final c = TfColors.of(brightness, highContrast: highContrast);
  final type = TfType.forDensity(density);
  final scheme = _scheme(c);
  final shape = RoundedRectangleBorder(borderRadius: TfRadius.control);
  final line = BorderSide(color: c.border);
  final compact = density == TfDensity.compact;
  final textTheme = type.textTheme.apply(
    bodyColor: c.text,
    displayColor: c.text,
    fontFamilyFallback: fontFallback,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: tfFontFamily,
    fontFamilyFallback: fontFallback,
    textTheme: textTheme,
    extensions: [TfTheme(colors: c, density: density, typography: type)],
    visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    splashFactory: NoSplash.splashFactory,
    hoverColor: c.hover,
    focusColor: c.focus.withValues(alpha: 0.16),
    scaffoldBackgroundColor: c.canvas,
    canvasColor: c.canvas,
    pageTransitionsTheme: _pageTransitions,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: c.surface,
      surfaceTintColor: tfClear,
      shape: Border(bottom: line),
      titleTextStyle: type.lead.copyWith(color: c.text),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: TfSpace.xs),
      color: c.surface,
      surfaceTintColor: tfClear,
      shape: RoundedRectangleBorder(borderRadius: TfRadius.panel, side: line),
    ),
    dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
    listTileTheme: ListTileThemeData(
      shape: shape,
      selectedTileColor: c.selected,
      selectedColor: c.accentTone.fg,
      contentPadding: EdgeInsetsDirectional.symmetric(horizontal: density.padX),
    ),
    inputDecorationTheme: _inputs(c, density),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape,
        minimumSize: Size(64, density.controlHeight),
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        textStyle: type.label,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        side: BorderSide(color: c.borderStrong.withValues(alpha: 0.5)),
        minimumSize: Size(64, density.controlHeight),
        foregroundColor: c.text,
        textStyle: type.label,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: shape,
        foregroundColor: c.accent,
        textStyle: type.label,
      ),
    ),
    chipTheme: ChipThemeData(shape: shape, side: line, labelStyle: type.small),
    dialogTheme: DialogThemeData(
      backgroundColor: c.raised,
      surfaceTintColor: tfClear,
      shape: RoundedRectangleBorder(borderRadius: TfRadius.dialog, side: line),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.raised,
      surfaceTintColor: tfClear,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TfRadius.lg)),
        side: line,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(borderRadius: TfRadius.panel, side: line),
      color: c.raised,
      surfaceTintColor: tfClear,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: shape,
      backgroundColor: c.isDark ? c.raised : c.text,
      contentTextStyle: type.body.copyWith(
        color: c.isDark ? c.text : c.surface,
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.selected,
      labelType: NavigationRailLabelType.all,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.selected,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
  );
}

InputDecorationTheme _inputs(TfColors c, TfDensity density) {
  OutlineInputBorder edge(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: TfRadius.control,
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecorationTheme(
    filled: true,
    fillColor: c.surface,
    border: edge(c.border),
    enabledBorder: edge(c.border),
    focusedBorder: edge(c.focus, 2),
    errorBorder: edge(c.danger.fg),
    focusedErrorBorder: edge(c.danger.fg, 2),
    contentPadding: EdgeInsetsDirectional.symmetric(
      horizontal: TfSpace.md,
      vertical: density == TfDensity.compact ? TfSpace.sm : TfSpace.md,
    ),
    hintStyle: TextStyle(color: c.textSubtle),
    isDense: density == TfDensity.compact,
  );
}

/// Material's scheme, filled from the tokens so untouched screens follow them.
ColorScheme _scheme(TfColors c) => ColorScheme(
  brightness: c.brightness,
  primary: c.accent,
  onPrimary: c.onAccent,
  primaryContainer: c.accentTone.bg,
  onPrimaryContainer: c.accentTone.fg,
  secondary: c.textMuted,
  onSecondary: c.surface,
  secondaryContainer: c.selected,
  onSecondaryContainer: c.accentTone.fg,
  tertiary: c.info.fg,
  onTertiary: c.surface,
  tertiaryContainer: c.info.bg,
  onTertiaryContainer: c.info.fg,
  error: c.danger.fg,
  onError: c.surface,
  errorContainer: c.danger.bg,
  onErrorContainer: c.danger.fg,
  surface: c.canvas,
  onSurface: c.text,
  onSurfaceVariant: c.textMuted,
  outline: c.borderStrong,
  outlineVariant: c.border,
  shadow: tfBlack,
  scrim: tfBlack,
  inverseSurface: c.text,
  onInverseSurface: c.surface,
  inversePrimary: c.accentTone.fg,
  surfaceTint: tfClear,
  surfaceContainerLowest: c.surface,
  surfaceContainerLow: c.surface,
  surfaceContainer: c.sunken,
  surfaceContainerHigh: c.hover,
  surfaceContainerHighest: c.raised,
);

/// Route changes fade (opacity only) on every platform.
class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);
}

const _pageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _FadePageTransitionsBuilder(),
    TargetPlatform.iOS: _FadePageTransitionsBuilder(),
    TargetPlatform.macOS: _FadePageTransitionsBuilder(),
    TargetPlatform.windows: _FadePageTransitionsBuilder(),
    TargetPlatform.linux: _FadePageTransitionsBuilder(),
    TargetPlatform.fuchsia: _FadePageTransitionsBuilder(),
  },
);
