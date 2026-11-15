import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

import 'rtl_screens_test.dart' show ScreenEnv;

/// Pictures of the key screens in English (left to right) and Persian (right
/// to left) on a phone. Fixed size, fixed clock, nothing moving: the same
/// pixels every run. Regenerate with `flutter test --update-goldens
/// test/i18n/rtl_goldens_test.dart` after a deliberate layout change.

const _phone = Size(390, 844);
const _languages = ['en', 'fa'];

Future<void> _picture(WidgetTester tester, String name, String language) =>
    expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/screen_${name}_$language.png'),
    );

void main() {
  final screens = <String, Future<void> Function(WidgetTester, ScreenEnv)>{
    'task_list': (t, e) => e.open(t, '/projects/p1'),
    'board': (t, e) => e.open(t, '/projects/p1?view=board'),
    'task_detail': (t, e) => e.open(t, '/projects/p1?task=a'),
    'inbox': (t, e) => e.open(t, '/inbox'),
    'members': (t, e) => e.open(t, '/members'),
    'workspace_settings': (t, e) => e.open(t, '/workspaces/settings'),
    'command_palette': (t, e) async {
      await e.open(t, '/');
      openCommandPalette(t.element(find.byType(Scaffold).first));
      await t.pumpAndSettle();
    },
  };
  for (final entry in screens.entries) {
    for (final language in _languages) {
      testWidgets('${entry.key} in $language looks the same every run', (
        tester,
      ) async {
        await entry.value(tester, ScreenEnv(_phone, language));
        await _picture(tester, entry.key, language);
      });
    }
  }
}
