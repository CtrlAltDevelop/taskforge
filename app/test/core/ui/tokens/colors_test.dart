import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';

const _text = 4.5; // WCAG AA, normal text
const _graphic = 3.0; // WCAG AA, UI components and graphics

Iterable<(String, TfColors)> _looks() => [
  for (final b in Brightness.values)
    for (final hc in [false, true])
      ('${b.name}${hc ? '-high' : ''}', TfColors.of(b, highContrast: hc)),
];

void main() {
  for (final (name, c) in _looks()) {
    group('contrast $name', () {
      test('text, muted and subtle text pass AA on every surface', () {
        for (final bg in [
          c.canvas,
          c.surface,
          c.raised,
          c.sunken,
          c.hover,
          c.selected,
        ]) {
          for (final fg in [c.text, c.textMuted, c.textSubtle]) {
            expect(
              contrastRatio(fg, bg),
              greaterThanOrEqualTo(_text),
              reason: '$fg on $bg',
            );
          }
        }
      });

      test('accent text and the text on the accent pass AA', () {
        expect(
          contrastRatio(c.onAccent, c.accent),
          greaterThanOrEqualTo(_text),
        );
        expect(contrastRatio(c.accent, c.surface), greaterThanOrEqualTo(_text));
        expect(
          contrastRatio(c.accentTone.fg, c.accentTone.bg),
          greaterThanOrEqualTo(_text),
        );
      });

      test(
        'every tone passes AA on its own fill and its text on the surface',
        () {
          for (final t in [c.success, c.warning, c.danger, c.info, c.neutral]) {
            expect(
              contrastRatio(t.fg, t.bg),
              greaterThanOrEqualTo(_text),
              reason: '${t.fg}',
            );
            expect(
              contrastRatio(t.fg, c.surface),
              greaterThanOrEqualTo(_graphic),
            );
          }
        },
      );

      test('strong border and focus ring are visible (3:1)', () {
        expect(
          contrastRatio(c.borderStrong, c.surface),
          greaterThanOrEqualTo(_graphic),
        );
        expect(
          contrastRatio(c.focus, c.surface),
          greaterThanOrEqualTo(_graphic),
        );
        expect(
          contrastRatio(c.focus, c.canvas),
          greaterThanOrEqualTo(_graphic),
        );
      });

      test('all ten categorical colours are visible on the surface', () {
        expect(c.categorical, hasLength(10));
        for (final k in c.categorical) {
          expect(
            contrastRatio(k, c.surface),
            greaterThanOrEqualTo(_graphic),
            reason: '$k',
          );
        }
      });
    });
  }

  test('contrast of black on white is 21', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
  });
}
