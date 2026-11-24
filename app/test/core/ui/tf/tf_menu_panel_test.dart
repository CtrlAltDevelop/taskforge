import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';

import '../../../i18n/tolerant_golden.dart';

Widget _host({TextDirection dir = TextDirection.ltr}) => MaterialApp(
  builder: (c, app) => Directionality(textDirection: dir, child: app!),
  debugShowCheckedModeBanner: false,
  theme: buildAppTheme(brightness: Brightness.light),
  home: Scaffold(
    body: Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: TfMenu(
          items: [
            TfMenuItem(label: 'Edit', onSelected: () {}),
            TfMenuItem(label: 'Chosen', selected: true, onSelected: () {}),
          ],
          builder: (c, toggle) =>
              TextButton(onPressed: toggle, child: const Text('open')),
        ),
      ),
    ),
  ),
);

void main() {
  setUpAll(() => useTolerantGoldens('test/core/ui/tf/tf_menu_panel_test.dart'));
  testWidgets('the open menu shows its whole shadow (not clipped)', (t) async {
    // Flutter's test binding draws shadows hard-edged and blurless by default.
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
    t.view.physicalSize = const Size(400, 300);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_host());
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/tf_menu_open.png'),
    );
  });

  testWidgets('the chosen entry is announced as selected', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(_host());
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(
      t.getSemantics(find.widgetWithText(MenuItemButton, 'Chosen')),
      matchesSemantics(
        label: 'Chosen',
        isSelected: true,
        hasSelectedState: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  for (final dir in TextDirection.values) {
    testWidgets('the panel stays at the anchor edge (${dir.name})', (t) async {
      await t.pumpWidget(_host(dir: dir));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      final button = t.getRect(find.widgetWithText(TextButton, 'open'));
      final panel = t.getRect(
        find
            .descendant(
              of: find.byKey(const Key('menu-motion')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      // The painted panel (inside the shadow margin) starts at the anchor's
      // start edge and just under it.
      if (dir == TextDirection.ltr) {
        expect(panel.left, closeTo(button.left, 2));
      } else {
        expect(panel.right, closeTo(button.right, 2));
      }
      expect(panel.top, closeTo(button.bottom, 4));
    });
  }
}
