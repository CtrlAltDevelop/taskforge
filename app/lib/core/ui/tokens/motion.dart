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
/// scale. Decided once, when it is first built: [enabled] false, or reduced
/// motion, and it simply is there, so cached data never animates on first
/// paint. The wrapper stays in the tree either way, so a row keeps its state
/// when it stops being "fresh".
class TfSettleIn extends StatefulWidget {
  const TfSettleIn({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<TfSettleIn> createState() => _TfSettleInState();
}

class _TfSettleInState extends State<TfSettleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TfDuration.base,
    value: 1,
  );
  late final Animation<double> _eased = CurvedAnimation(
    parent: _controller,
    curve: tfCurve,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.enabled && !TfMotion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  bool _started = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.5, end: 1).animate(_eased),
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.97, end: 1).animate(_eased),
      child: widget.child,
    ),
  );
}

/// Tells which ids of a list appeared after it was first shown. Call
/// [update] with every id on each build (an id is fresh for that build only); ids present on the first settled
/// build (cached data, or rows still streaming in) are never fresh.
class TfFreshIds {
  Set<String>? _seen;
  Set<String> _fresh = const {};

  void update(Iterable<String> ids, {bool settled = true}) {
    final now = ids.toSet();
    final seen = _seen;
    if (seen == null) {
      if (settled) _seen = now;
      return;
    }
    _fresh = now.difference(seen);
    _seen = {...seen, ...now};
  }

  bool isFresh(String id) => _fresh.contains(id);

  /// Forget everything: the list went away (empty state) and comes back as
  /// a first paint.
  void reset() {
    _seen = null;
    _fresh = const {};
  }
}
