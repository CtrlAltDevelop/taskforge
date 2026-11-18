import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

import '../../i18n/tolerant_golden.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';

/// The frame as pictures: the open sidebar with the top bar, the icon strip,
/// and the phone's More sheet, in light and dark. Flutter tests draw text in
/// a fixed test font, so the images do not depend on the machine's fonts.
void main() {
  setUpAll(useTolerantGoldens);

  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in const [
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
  });

  final projects = [
    project('p1', 'Website'),
    project('p2', 'Billing', favorite: true),
    project('p3', 'Mobile app', private: true),
  ];

  Future<void> capture(
    WidgetTester tester,
    String name, {
    required Size size,
    required ThemeMode mode,
    String at = '/projects/p1',
    Future<void> Function()? before,
  }) async {
    final app = await pumpProjects(tester, projects: projects, size: size);
    app.container.read(themeModeProvider.notifier).choose(mode);
    await app.go(tester, at);
    await before?.call();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/frame_$name.png'),
    );
  }

  for (final (label, mode) in [
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('expanded sidebar and top bar, $label', (tester) async {
      await capture(
        tester,
        'expanded_$label',
        size: const Size(1280, 800),
        mode: mode,
      );
    });

    testWidgets('icon strip, $label', (tester) async {
      await capture(
        tester,
        'strip_$label',
        size: const Size(768, 800),
        mode: mode,
      );
    });

    testWidgets('phone More sheet, $label', (tester) async {
      await capture(
        tester,
        'more_$label',
        size: const Size(390, 844),
        mode: mode,
        before: () async {
          await tester.tap(find.byKey(const Key('more-tab')));
          await tester.pumpAndSettle();
        },
      );
    });
  }
}
