import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/gallery/component_gallery.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

import '../../i18n/tolerant_golden.dart';

Widget _page(GalleryLook look) => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(body: GalleryBody(look: look)),
);

Future<void> _size(WidgetTester t, double width) async {
  t.view.physicalSize = Size(width, 9000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  setUpAll(useTolerantGoldens);

  group('gallery sweep: no overflow', () {
    for (final brightness in Brightness.values) {
      for (final language in ['en', 'fa', 'ar']) {
        final rtl = language != 'en';
        for (final scale in [1.0, 2.0]) {
          for (final density in TfDensity.values) {
            final name =
                '${brightness.name} ${rtl ? 'rtl' : 'ltr'} ${scale * 100}% ${density.name}';
            testWidgets(name, (t) async {
              await _size(t, 900);
              await t.pumpWidget(
                _page(
                  GalleryLook(
                    brightness: brightness,
                    rtl: rtl,
                    textScale: scale,
                    density: density,
                  ),
                ),
              );
              await t.pump(
                const Duration(milliseconds: 400),
              ); // the spinner never settles
              expect(t.takeException(), isNull);
            });
          }
        }
      }
    }

    testWidgets('high contrast and a phone width at 200% text', (t) async {
      await _size(t, 390);
      await t.pumpWidget(
        _page(const GalleryLook(highContrast: true, rtl: true, textScale: 2)),
      );
      await t.pump(
        const Duration(milliseconds: 400),
      ); // the spinner never settles
      expect(t.takeException(), isNull);
    });
  });

  testWidgets('the gallery page switches look live', (t) async {
    await _size(t, 1200);
    await t.pumpWidget(const MaterialApp(home: ComponentGallery()));
    await t.tap(find.text('Dark'));
    await t.pump(
      const Duration(milliseconds: 400),
    ); // the spinner never settles
    await t.tap(find.text('RTL'));
    await t.pump(
      const Duration(milliseconds: 400),
    ); // the spinner never settles
    expect(t.takeException(), isNull);
  });

  group('gallery pictures', () {
    for (final (name, look) in [
      ('light', const GalleryLook()),
      ('dark', const GalleryLook(brightness: Brightness.dark)),
      ('rtl', const GalleryLook(rtl: true)),
    ]) {
      testWidgets('$name looks the same every run', (t) async {
        await _size(t, 900);
        await t.pumpWidget(RepaintBoundary(child: _page(look)));
        await t.pump(
          const Duration(milliseconds: 400),
        ); // the spinner never settles
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../core/ui/goldens/gallery_$name.png'),
        );
      });
    }
  });
}
