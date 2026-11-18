import 'package:material_ui/material_ui.dart';

/// The motion spec: three durations, nothing slower.
abstract final class TfDuration {
  /// Hover, press, small fades, tab underline.
  static const fast = Duration(milliseconds: 100);

  /// Menus, dialogs, toasts, peek, card settle.
  static const base = Duration(milliseconds: 160);

  /// Sheets sliding across the screen.
  static const slow = Duration(milliseconds: 240);
}

/// The one curve: decelerates into place and never overshoots (no bounce).
const Curve tfCurve = Curves.easeOutCubic;

/// Reduced motion: the system flag, or the app's Appearance choice, which
/// the app root folds into [MediaQueryData.disableAnimations].
abstract final class TfMotion {
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [wanted], or zero (instant) when motion is reduced.
  static Duration of(BuildContext context, Duration wanted) =>
      reduced(context) ? Duration.zero : wanted;

  /// For routes and sheets that take an [AnimationStyle].
  static AnimationStyle style(BuildContext context, Duration wanted) {
    final d = of(context, wanted);
    return AnimationStyle(
      duration: d,
      reverseDuration: d,
      curve: tfCurve,
      reverseCurve: tfCurve,
    );
  }
}

/// A freshly dropped or inserted thing eases into place: fade and a hair of
/// scale. Off ([enabled] false) or with reduced motion it simply is there, so
/// cached data never animates on first paint.
class TfSettleIn extends StatelessWidget {
  const TfSettleIn({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = enabled
        ? TfMotion.of(context, TfDuration.base)
        : Duration.zero;
    if (duration == Duration.zero) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: tfCurve,
      builder: (context, v, child) => Opacity(
        opacity: 0.5 + 0.5 * v,
        child: Transform.scale(scale: 0.97 + 0.03 * v, child: child),
      ),
      child: child,
    );
  }
}
