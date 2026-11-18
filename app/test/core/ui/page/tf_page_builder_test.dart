import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';

Widget _host(Widget child) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light),
  home: Scaffold(body: child),
);

enum _Pick { a, b }

void main() {
  testWidgets('a pinned field keeps its text while the rows scroll', (t) async {
    t.view.physicalSize = const Size(800, 500);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final built = <int>{};
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await t.pumpWidget(
      _host(
        TfPage.builder(
          pinned: TextField(key: const Key('search'), controller: controller),
          itemCount: 500,
          itemBuilder: (context, i) {
            built.add(i);
            return SizedBox(height: 60, child: Text('row $i'));
          },
        ),
      ),
    );
    await t.enterText(find.byKey(const Key('search')), 'peggy');
    expect(built.length, lessThan(40), reason: 'rows are built lazily');

    await t.drag(find.byType(ListView), const Offset(0, -6000));
    await t.pumpAndSettle();
    expect(find.text('row 0'), findsNothing);
    expect(find.byKey(const Key('search')), findsOneWidget);
    expect(controller.text, 'peggy');
  });

  group('TfRadioTile', () {
    Widget group({bool enabled = true}) => _host(
      RadioGroup<_Pick>(
        groupValue: _Pick.a,
        onChanged: (_) {},
        child: Column(
          children: [
            const TfRadioTile<_Pick>(value: _Pick.a, title: 'Alpha'),
            TfRadioTile<_Pick>(
              value: _Pick.b,
              title: 'Beta',
              subtitle: 'Second',
              enabled: enabled,
            ),
          ],
        ),
      ),
    );

    testWidgets('is one radio, announced once, checked or not', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(group());
      expect(
        t.getSemantics(find.text('Alpha')),
        matchesSemantics(
          label: 'Alpha',
          isChecked: true,
          hasCheckedState: true,
          isSelected: true,
          hasSelectedState: true,
          isInMutuallyExclusiveGroup: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Alpha'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('has one tab stop per row, none when disabled', (t) async {
      await t.pumpWidget(group());
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      // Two rows: the third Tab leaves the group, never stops on a radio twice.
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<Radio<_Pick>>()),
      );

      await t.pumpWidget(group(enabled: false));
      final handle = t.ensureSemantics();
      expect(
        t.getSemantics(find.text('Beta')),
        isNot(isSemantics(isEnabled: true)),
      );
      handle.dispose();
    });
  });
}
