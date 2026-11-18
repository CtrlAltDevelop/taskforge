import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tokens/motion.dart';

Widget _host(Widget child, {bool reduce = false}) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light),
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
    child: app!,
  ),
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

double _underlineLeft(WidgetTester t) =>
    t.getTopLeft(find.byKey(const Key('tab-underline'))).dx;

void main() {
  for (final reduce in [false, true]) {
    final tag = reduce ? 'reduced' : 'normal';

    testWidgets('tab underline slides to the chosen tab ($tag)', (t) async {
      var index = 0;
      await t.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (c, set) => TfTabs(
              labels: const ['One', 'Second tab'],
              index: index,
              onChanged: (i) => set(() => index = i),
            ),
          ),
          reduce: reduce,
        ),
      );
      await t.pump();
      final start = _underlineLeft(t);
      await t.tap(find.text('Second tab'));
      await t.pump();
      await t.pump(); // measured after layout
      await t.pump(const Duration(milliseconds: 30));
      final mid = _underlineLeft(t);
      await t.pumpAndSettle();
      final end = _underlineLeft(t);
      expect(end, greaterThan(start));
      if (reduce) {
        expect(mid, end);
      } else {
        expect(mid, inExclusiveRange(start, end));
      }
    });

    testWidgets('menu fades and scales in ($tag)', (t) async {
      await t.pumpWidget(
        _host(
          TfMenu(
            items: [TfMenuItem(label: 'Edit', onSelected: () {})],
            builder: (c, toggle) =>
                TextButton(onPressed: toggle, child: const Text('open')),
          ),
          reduce: reduce,
        ),
      );
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 30));
      expect(find.text('Edit'), findsOneWidget);
      final motion = find.byKey(const Key('menu-motion'));
      if (reduce) {
        expect(motion, findsNothing);
      } else {
        final opacity = t.widget<Opacity>(
          find.descendant(of: motion, matching: find.byType(Opacity)),
        );
        expect(opacity.opacity, inExclusiveRange(0, 1));
      }
      await t.pumpAndSettle();
      await t.tap(find.text('Edit'));
      await t.pumpAndSettle();
    });

    testWidgets('only rows added after first paint settle in ($tag)', (
      t,
    ) async {
      final fresh = TfFreshIds();
      Widget list(List<String> ids) {
        fresh.update(ids);
        return Column(
          children: [
            for (final id in ids)
              TfSettleIn(
                key: ValueKey(id),
                enabled: fresh.isFresh(id),
                child: Text(id),
              ),
          ],
        );
      }

      double opacityOf(String id) => t
          .widget<FadeTransition>(
            find
                .descendant(
                  of: find.byKey(ValueKey(id)),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value;

      await t.pumpWidget(_host(list(['a', 'b']), reduce: reduce));
      expect(opacityOf('a'), 1);
      expect(opacityOf('b'), 1);

      await t.pumpWidget(_host(list(['a', 'c', 'b']), reduce: reduce));
      await t.pump(const Duration(milliseconds: 30));
      expect(opacityOf('a'), 1);
      expect(opacityOf('b'), 1);
      if (reduce) {
        expect(opacityOf('c'), 1);
      } else {
        expect(opacityOf('c'), lessThan(1));
      }
      await t.pumpAndSettle();
      expect(opacityOf('c'), 1);
    });
  }

  test('rows still streaming in count as first paint', () {
    final fresh = TfFreshIds()
      ..update(['a'], settled: false)
      ..update(['a', 'b'], settled: false)
      ..update(['a', 'b'])
      ..update(['a', 'b', 'c']);
    expect(fresh.isFresh('b'), isFalse);
    expect(fresh.isFresh('c'), isTrue);
  });
}
