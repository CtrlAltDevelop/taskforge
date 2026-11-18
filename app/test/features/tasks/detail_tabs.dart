import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens a tab of the task window (Links, Attachments, Docs, Time, Fields).
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find
        .descendant(
          of: find.byKey(const Key('task-tabs')),
          matching: find.textContaining(label),
        )
        .first,
  );
  await tester.pumpAndSettle();
}
