import 'dart:async';
import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

Widget _host(
  Widget child, {
  double scale = 1,
  TfDensity density = TfDensity.comfortable,
}) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light, density: density),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Scaffold(body: Center(child: child)),
  ),
);

SemanticsData _data(WidgetTester t, Finder f) =>
    t.getSemantics(f).getSemanticsData();

void main() {
  testWidgets('a button is announced once, as an enabled button', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(_host(TfButton(label: 'Save', onPressed: () {})));
    final d = _data(t, find.byType(TfButton));
    expect(d.label, 'Save');
    expect(d.flagsCollection.isButton, isTrue);
    expect(d.flagsCollection.isEnabled, Tristate.isTrue);
    expect(d.flagsCollection.isSelected, Tristate.none);
    handle.dispose();
  });

  testWidgets('a disabled button says so; a plain chip is not a button', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TfButton(label: 'Off', onPressed: null),
            TfChip(label: 'Todo'),
          ],
        ),
      ),
    );
    final off = _data(t, find.byType(TfButton));
    expect(off.flagsCollection.isButton, isTrue);
    expect(off.flagsCollection.isEnabled, Tristate.isFalse);
    final chip = _data(t, find.byType(TfChip));
    expect(chip.label, 'Todo');
    expect(chip.flagsCollection.isButton, isFalse);
    expect(chip.flagsCollection.isEnabled, Tristate.none);
    handle.dispose();
  });

  testWidgets('checkbox and toggle expose their state', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TfCheckbox(value: true, label: 'On', onChanged: null),
            TfCheckbox(value: null, label: 'Mixed', onChanged: null),
            TfToggle(value: true, label: 'Toggle', onChanged: null),
          ],
        ),
      ),
    );
    final on = _data(t, find.byType(TfCheckbox).first);
    expect(on.flagsCollection.isChecked, CheckedState.isTrue);
    expect(on.label, 'On');
    expect(
      _data(t, find.byType(TfCheckbox).last).flagsCollection.isChecked,
      CheckedState.mixed,
    );
    expect(
      _data(t, find.byType(TfToggle)).flagsCollection.isToggled,
      Tristate.isTrue,
    );
    handle.dispose();
  });

  testWidgets('the remove x of a chip is its own button with a tooltip', (
    t,
  ) async {
    var removed = 0;
    await t.pumpWidget(
      _host(
        TfChip(
          label: 'Bug',
          onRemove: () => removed++,
          removeTooltip: 'Remove Bug',
        ),
      ),
    );
    await t.tap(find.byTooltip('Remove Bug'));
    expect(removed, 1);
    expect(find.byType(TfIconButton), findsOneWidget);
  });

  group('no clipping at 200% text', () {
    // The painted box must be at least as tall as its text needs.
    for (final density in TfDensity.values) {
      testWidgets(
        'button, chip and status pill grow with the text (${density.name})',
        (t) async {
          await t.pumpWidget(
            _host(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TfButton(label: 'Save', onPressed: () {}),
                  const TfChip(label: 'Todo'),
                  const TfStatusPill(label: 'Done', kind: TfStatusKind.done),
                ],
              ),
              scale: 2,
              density: density,
            ),
          );
          for (final label in ['Save', 'Todo', 'Done']) {
            final text = t.renderObject<RenderParagraph>(find.text(label));
            final box = t.getSize(
              find
                  .ancestor(
                    of: find.text(label),
                    matching: find.byType(Container),
                  )
                  .first,
            );
            expect(
              box.height,
              greaterThanOrEqualTo(text.size.height),
              reason: label,
            );
          }
        },
      );
    }
  });

  group('avatar text', () {
    test('initials read at AA on every categorical colour in every look', () {
      for (final b in Brightness.values) {
        for (final k in TfColors.of(b).categorical) {
          expect(
            contrastRatio(tfOnColor(k), k),
            greaterThanOrEqualTo(4.5),
            reason: '$k',
          );
        }
      }
    });
  });

  test(
    'a tap before the saved density arrives is not overwritten by it',
    () async {
      final prefs = _SlowPrefs({'theme.density': 'compact'});
      final container = ProviderContainer(
        overrides: [localPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(densityProvider);
      container.read(densityProvider.notifier).choose(TfDensity.comfortable);
      prefs.release();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(densityProvider), TfDensity.comfortable);
    },
  );
}

class _SlowPrefs implements LocalPrefs {
  _SlowPrefs(this._values);

  final Map<String, String> _values;
  final _gate = _Gate();

  void release() => _gate.open();

  @override
  Future<String?> read(String key) async {
    await _gate.future;
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

class _Gate {
  final _c = Completer<void>();
  Future<void> get future => _c.future;
  void open() => _c.complete();
}
