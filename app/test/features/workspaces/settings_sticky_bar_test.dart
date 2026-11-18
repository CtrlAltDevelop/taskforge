import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

void main() {
  testWidgets('the save bar stays on screen while the page scrolls', (t) async {
    t.view.physicalSize = const Size(900, 420);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await pumpSignedIn(t, FakeWorkspaceClient([ws('a', 'Alpha')]));
    await t.tap(byKey('open-workspace-settings'));
    await t.pumpAndSettle();
    expect(byKey('save-workspace'), findsNothing);

    await t.enterText(byKey('settings-name'), 'Alpha Two');
    await t.pump();
    expect(byKey('save-workspace'), findsOneWidget);

    // Scroll the form away: the bar is still there, inside the window.
    await t.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -1500),
    );
    await t.pumpAndSettle();
    final bar = t.getRect(byKey('save-workspace'));
    expect(bar.bottom, lessThanOrEqualTo(420));
    expect(bar.top, greaterThanOrEqualTo(0));
    await t.tap(byKey('save-workspace'));
    await t.pumpAndSettle();
    expect(byKey('save-workspace'), findsNothing);
  });
}
