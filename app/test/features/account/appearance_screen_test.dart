import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/account/appearance_screen.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AppearanceScreen(),
  ),
);

void main() {
  testWidgets('choices apply at once and are saved on the device', (t) async {
    final prefs = MemoryPrefs();
    final container = ProviderContainer(
      overrides: [localPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    await t.pumpWidget(_app(container));

    await t.tap(find.text('Dark'));
    await t.tap(find.text('Compact'));
    await t.tap(find.text('High contrast'));
    await t.pump();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(densityProvider), TfDensity.compact);
    expect(container.read(contrastProvider), isTrue);
    expect(await prefs.read('theme.mode'), 'dark');
    expect(await prefs.read('theme.density'), 'compact');
    expect(await prefs.read('theme.contrast'), 'high');
  });

  testWidgets('the reduce-motion switch turns reduced motion on and off', (
    t,
  ) async {
    final prefs = MemoryPrefs();
    final container = ProviderContainer(
      overrides: [localPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    await t.pumpWidget(_app(container));
    expect(container.read(reduceMotionProvider), isFalse);

    await t.tap(find.byKey(const Key('reduce-motion')));
    await t.pump();
    expect(container.read(reduceMotionProvider), isTrue);

    await t.tap(find.byKey(const Key('reduce-motion')));
    await t.pump();
    expect(container.read(reduceMotionProvider), isFalse);
  });

  test('saved choices come back on the next start', () async {
    final prefs = MemoryPrefs();
    await prefs.write('theme.density', 'compact');
    await prefs.write('theme.contrast', 'high');
    await prefs.write('theme.mode', 'light');
    final container = ProviderContainer(
      overrides: [localPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    container.read(densityProvider);
    container.read(contrastProvider);
    container.read(themeModeProvider);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(densityProvider), TfDensity.compact);
    expect(container.read(contrastProvider), isTrue);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
