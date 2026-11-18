import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/tf_icons.dart';

void main() {
  test(
    'every declared icon is in the by-name map, so the gallery shows it',
    () {
      final declared = RegExp(r'static const (\w+) = TfIconData\(')
          .allMatches(File('lib/core/ui/tf_icons.dart').readAsStringSync())
          .map((m) => m.group(1)!)
          .toSet();
      expect(TfIcons.all.keys.toSet(), declared);
    },
  );

  test('only direction-bound icons mirror in right-to-left', () {
    final mirrored = {
      for (final e in TfIcons.all.entries)
        if (e.value.mirrorsInRtl) e.key,
    };
    expect(mirrored, {
      'chevronStart',
      'chevronEnd',
      'arrowStart',
      'arrowEnd',
      'send',
      'undo',
      'sidebar',
      'signOut',
      'cornerDownRight',
    });
  });

  testWidgets('a mirroring icon is flipped in RTL and not in LTR', (
    tester,
  ) async {
    Future<void> pump(TextDirection d) => tester.pumpWidget(
      Directionality(textDirection: d, child: const TfIcon(TfIcons.arrowEnd)),
    );
    await pump(TextDirection.ltr);
    expect(find.byType(Transform), findsNothing);
    await pump(TextDirection.rtl);
    expect(find.byType(Transform), findsOneWidget);
  });
}
