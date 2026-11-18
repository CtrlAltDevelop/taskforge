import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The scenes of the illustration set (phase 48).
enum TfIllustrationKind {
  tasks,
  board,
  calendar,
  timeline,
  docs,
  chat,
  inbox,
  search,
  goals,
  time,
  noAccess,
  offline,
  notFound,
  maintenance,
  generic;

  /// What the picture shows, in the language on screen.
  String label(AppLocalizations t) => switch (this) {
    tasks => t.illusTasks,
    board => t.illusBoard,
    calendar => t.illusCalendar,
    timeline => t.illusTimeline,
    docs => t.illusDocs,
    chat => t.illusChat,
    inbox => t.illusInbox,
    search => t.illusSearch,
    goals => t.illusGoals,
    time => t.illusTime,
    noAccess => t.illusNoAccess,
    offline => t.illusOffline,
    notFound => t.illusNotFound,
    maintenance => t.illusMaintenance,
    generic => t.illusGeneric,
  };
}

/// A small flat scene with no text in it, bundled as an SVG in
/// `assets/illustrations/`. The files use placeholder colours that are mapped
/// to the theme's at draw time, so it is right in light, dark and high
/// contrast, and it never animates (the same picture for reduced motion).
/// [semanticLabel] defaults to the scene's own description.
class TfIllustration extends StatelessWidget {
  const TfIllustration(
    this.kind, {
    super.key,
    this.semanticLabel,
    this.height = 96,
  });

  final TfIllustrationKind kind;
  final String? semanticLabel;
  final double height;

  static const double _w = 120, _h = 96;

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel ?? kind.label(context.l10n);
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(
        child: SvgPicture.asset(
          kind.asset,
          width: height * _w / _h,
          height: height,
          excludeFromSemantics: true,
          colorMapper: _ThemeColors(context.tf.colors),
        ),
      ),
    );
  }
}

extension on TfIllustrationKind {
  String get asset =>
      'assets/illustrations/${switch (this) {
        TfIllustrationKind.noAccess => 'no_access',
        TfIllustrationKind.notFound => 'not_found',
        _ => name,
      }}.svg';
}

/// The placeholder colours the SVG files are drawn with (see
/// `assets/illustrations/*.svg`), by their value.
final Map<int, Color Function(TfColors)> _placeholders = {
  0xffff0001: (c) => c.accent,
  0xffff0002: (c) => c.onAccent,
  0xffff0003: (c) => c.accentTone.bg,
  0xffff0004: (c) => c.accentTone.fg,
  0xffff0005: (c) => c.surface,
  0xffff0006: (c) => c.sunken,
  0xffff0007: (c) => c.border,
  0xffff0008: (c) => c.borderStrong,
  0xffff0009: (c) => c.text,
  0xffff000a: (c) => c.textMuted,
  0xffff000b: (c) => c.textSubtle,
  0xffff000c: (c) => c.danger.fg,
  0xffff000d: (c) => c.warning.fg,
  0xffff000e: (c) => c.success.fg,
  0xffff000f: (c) => c.category(0),
  0xffff0010: (c) => c.category(2),
};

class _ThemeColors extends ColorMapper {
  const _ThemeColors(this.colors);

  final TfColors colors;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => _placeholders[color.toARGB32()]?.call(colors) ?? color;

  @override
  bool operator ==(Object other) =>
      other is _ThemeColors && identical(other.colors, colors);

  @override
  int get hashCode => identityHashCode(colors);
}
