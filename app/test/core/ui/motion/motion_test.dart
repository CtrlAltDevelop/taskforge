import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/ui/tokens/motion.dart';

Widget _host(Widget child, {bool reduce = false}) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light),
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
    child: app!,
  ),
  home: Scaffold(body: Center(child: child)),
);

class _Opener extends StatelessWidget {
  const _Opener(this.open);
  final void Function(BuildContext) open;

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => open(context), child: const Text('open'));
}

void main() {
  test('durations are the 100/160/240 ms spec', () {
    expect(TfDuration.fast.inMilliseconds, 100);
    expect(TfDuration.base.inMilliseconds, 160);
    expect(TfDuration.slow.inMilliseconds, 240);
  });

  test('the curve decelerates and never overshoots', () {
    for (var t = 0.0; t <= 1.0; t += 0.05) {
      expect(tfCurve.transform(t), inInclusiveRange(0, 1));
    }
    expect(tfCurve.transform(0.5), greaterThan(0.5));
  });

  testWidgets('reduced motion gives zero durations, otherwise the asked one', (
    t,
  ) async {
    late Duration normal;
    late Duration reduced;
    await t.pumpWidget(
      _host(
        Builder(
          builder: (c) {
            normal = TfMotion.of(c, TfDuration.base);
            return const SizedBox();
          },
        ),
      ),
    );
    await t.pumpWidget(
      _host(
        Builder(
          builder: (c) {
            reduced = TfMotion.of(c, TfDuration.base);
            return const SizedBox();
          },
        ),
        reduce: true,
      ),
    );
    expect(normal, TfDuration.base);
    expect(reduced, Duration.zero);
  });

  for (final reduce in [false, true]) {
    final tag = reduce ? 'reduced' : 'normal';

    testWidgets('side sheet slide ($tag)', (t) async {
      await t.pumpWidget(
        _host(
          _Opener(
            (c) => showTfSideSheet<void>(
              c,
              title: 'Peek',
              body: const Text('body'),
              closeTooltip: 'Close',
            ),
          ),
          reduce: reduce,
        ),
      );
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 20));
      final slid = t.getTopLeft(find.text('Peek')).dx;
      final settled = await (() async {
        await t.pumpAndSettle();
        return t.getTopLeft(find.text('Peek')).dx;
      })();
      // Mid-flight it is still off its final place; reduced it is already there.
      if (reduce) {
        expect(slid, settled);
      } else {
        expect(slid, greaterThan(settled));
      }
    });

    testWidgets('bottom sheet rises ($tag)', (t) async {
      await t.pumpWidget(
        _host(
          _Opener((c) => showTfBottomSheet<void>(c, body: const Text('sheet'))),
          reduce: reduce,
        ),
      );
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 20));
      final mid = t.getTopLeft(find.text('sheet')).dy;
      await t.pumpAndSettle();
      final end = t.getTopLeft(find.text('sheet')).dy;
      if (reduce) {
        expect(mid, end);
      } else {
        expect(mid, greaterThan(end));
      }
    });

    testWidgets('dialog fades ($tag)', (t) async {
      await t.pumpWidget(
        _host(
          _Opener(
            (c) => showTfDialog<void>(
              c,
              title: 'Hello',
              body: const Text('b'),
              actions: const [],
            ),
          ),
          reduce: reduce,
        ),
      );
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 20));
      final opacity = t
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((f) => f.opacity.value)
          .reduce((a, b) => a < b ? a : b);
      expect(opacity, reduce ? 1 : lessThan(1));
    });

    testWidgets('toast enters ($tag)', (t) async {
      await t.pumpWidget(
        _host(_Opener((c) => showTfToast(c, 'Saved')), reduce: reduce),
      );
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 20));
      final bar = t.widget<SnackBar>(find.byType(SnackBar));
      expect(bar.content, isNotNull);
      final animation = t
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((f) => f.opacity.value);
      if (reduce) {
        expect(animation.every((v) => v == 1), isTrue);
      } else {
        expect(animation.any((v) => v < 1), isTrue);
      }
    });

    testWidgets('skeleton shimmer ($tag)', (t) async {
      await t.pumpWidget(_host(const TfSkeleton(width: 100), reduce: reduce));
      await t.pump(const Duration(milliseconds: 300));
      final shimmer = find.byKey(const Key('tf-skeleton-shimmer'));
      expect(shimmer, reduce ? findsNothing : findsOneWidget);
      // It stops by itself, so waiting for a loading screen to settle ends.
      await t.pumpAndSettle();
    });

    testWidgets('settle-in on a dropped card ($tag)', (t) async {
      await t.pumpWidget(
        _host(
          const TfSettleIn(enabled: true, child: Text('card')),
          reduce: reduce,
        ),
      );
      await t.pump(const Duration(milliseconds: 20));
      final fade = t.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(TfSettleIn),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, reduce ? 1 : lessThan(1));
      await t.pumpAndSettle();
    });
  }

  testWidgets('settle-in disabled paints at once (cached data)', (t) async {
    await t.pumpWidget(
      _host(const TfSettleIn(enabled: false, child: Text('card'))),
    );
    expect(t.hasRunningAnimations, isFalse);
  });
}
