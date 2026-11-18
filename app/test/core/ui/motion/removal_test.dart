import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_list_motion.dart';

Widget _host(Widget child, {bool reduce = false}) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light),
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
    child: app!,
  ),
  home: Scaffold(body: child),
);

/// A list that keeps its rows through [TfRemovals], like the task lists do.
class _List extends StatefulWidget {
  const _List(this.ids, {this.settled = true});
  final List<String> ids;
  final bool settled;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final removals = TfRemovals<String>((id) => id);

  @override
  Widget build(BuildContext context) {
    final items = removals.update(
      widget.ids,
      settled: widget.settled,
      reduced: MediaQuery.disableAnimationsOf(context),
    );
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => switch (items[i]) {
        final TfGhost g => removals.ghostRow(g, () => setState(() {})),
        final String id => removals.remember(
          id,
          SizedBox(height: 40, child: Text(id)),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

void main() {
  for (final reduce in [false, true]) {
    final tag = reduce ? 'reduced' : 'normal';

    testWidgets('a row removed after first paint plays out ($tag)', (t) async {
      await t.pumpWidget(_host(const _List(['a', 'b', 'c']), reduce: reduce));
      await t.pumpWidget(_host(const _List(['a', 'c']), reduce: reduce));
      await t.pump(const Duration(milliseconds: 30));
      if (reduce) {
        expect(find.text('b'), findsNothing);
      } else {
        expect(find.text('b'), findsOneWidget);
        final fade = t.widget<FadeTransition>(
          find
              .ancestor(
                of: find.text('b'),
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        expect(fade.opacity.value, lessThan(1));
        // It stays in its place between its neighbours.
        expect(
          t.getTopLeft(find.text('b')).dy,
          greaterThan(t.getTopLeft(find.text('a')).dy),
        );
        expect(
          t.getTopLeft(find.text('b')).dy,
          lessThan(t.getTopLeft(find.text('c')).dy),
        );
      }
      await t.pumpAndSettle();
      expect(find.text('b'), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });
  }

  testWidgets('rows still streaming in are not ghosted', (t) async {
    await t.pumpWidget(_host(const _List(['a', 'b'], settled: false)));
    await t.pumpWidget(_host(const _List(['a'], settled: false)));
    await t.pump(const Duration(milliseconds: 30));
    expect(find.text('b'), findsNothing);
  });

  testWidgets('a list that went away and came back leaves no ghost', (t) async {
    final removals = TfRemovals<String>((id) => id);
    removals.update(['a', 'b']);
    removals.remember('a', const SizedBox());
    removals.remember('b', const SizedBox());
    removals.reset();
    expect(removals.update(['c']), ['c']);
  });
}
