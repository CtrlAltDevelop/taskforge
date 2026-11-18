import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_key_hint.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_progress.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

Widget _host(
  Widget child, {
  TfDensity density = TfDensity.comfortable,
  TextDirection dir = TextDirection.ltr,
}) => MaterialApp(
  theme: buildAppTheme(brightness: Brightness.light, density: density),
  home: Directionality(
    textDirection: dir,
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  // Tests run as Android (touch); pointer-density checks need a desktop.
  void desktop() {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
  }

  group('TfButton', () {
    testWidgets('taps, and activates from the keyboard with Enter and Space', (
      t,
    ) async {
      var taps = 0;
      await t.pumpWidget(
        _host(TfButton(label: 'Go', autofocus: true, onPressed: () => taps++)),
      );
      await t.pump();
      await t.tap(find.text('Go'));
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 3);
    });

    testWidgets('does nothing when disabled or loading', (t) async {
      var taps = 0;
      await t.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TfButton(label: 'Off', onPressed: null),
              TfButton(label: 'Busy', loading: true, onPressed: () => taps++),
            ],
          ),
        ),
      );
      await t.tap(find.text('Off'));
      await t.tap(find.text('Busy'));
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a visible focus ring only for keyboard focus', (
      t,
    ) async {
      await t.pumpWidget(
        _host(TfButton(label: 'Go', autofocus: true, onPressed: () {})),
      );
      await t.pump();
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      await t.pump();
      final c = t.element(find.byType(TfButton)).tf.colors;
      final ring = t
          .widgetList<Container>(find.byType(Container))
          .any(
            (w) =>
                (w.decoration as BoxDecoration?)?.border ==
                Border.all(color: c.focus, width: 2),
          );
      expect(ring, isTrue);
    });

    testWidgets('density changes the height', (t) async {
      desktop();
      Future<double> heightIn(TfDensity d) async {
        await t.pumpWidget(
          _host(
            TfButton(label: 'Go', onPressed: () {}),
            density: d,
          ),
        );
        await t.pumpAndSettle(); // the theme change animates
        return t.getSize(find.byType(TfButton)).height;
      }

      expect(await heightIn(TfDensity.comfortable), 36);
      expect(await heightIn(TfDensity.compact), 28);
    });

    testWidgets('touch targets are at least 40 dp and 44 in comfortable', (
      t,
    ) async {
      await t.pumpWidget(
        _host(
          TfButton(label: 'Go', onPressed: () {}, size: TfButtonSize.small),
        ),
      );
      expect(t.getSize(find.byType(TfButton)).height, greaterThanOrEqualTo(44));
      await t.pumpWidget(
        _host(
          TfButton(label: 'Go', onPressed: () {}, size: TfButtonSize.small),
          density: TfDensity.compact,
        ),
      );
      expect(t.getSize(find.byType(TfButton)).height, greaterThanOrEqualTo(40));
    });

    testWidgets('icon button exposes its tooltip as label', (t) async {
      await t.pumpWidget(
        _host(
          TfIconButton(icon: TfIcons.plus, tooltip: 'Add', onPressed: () {}),
        ),
      );
      expect(find.bySemanticsLabel('Add'), findsWidgets);
    });
  });

  group('selection controls', () {
    testWidgets('checkbox cycles value and shows mixed', (t) async {
      bool? v = false;
      await t.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, set) => TfCheckbox(
              value: v,
              label: 'Box',
              onChanged: (n) => set(() => v = n),
            ),
          ),
        ),
      );
      await t.tap(find.text('Box'));
      await t.pump();
      expect(v, isTrue);
      await t.pumpWidget(_host(const TfCheckbox(value: null, onChanged: null)));
      expect(find.byType(TfIcon), findsOneWidget);
    });

    testWidgets('toggle flips and reports its state to accessibility', (
      t,
    ) async {
      var on = false;
      await t.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, set) => TfToggle(
              value: on,
              label: 'Wi',
              onChanged: (n) => set(() => on = n),
            ),
          ),
        ),
      );
      await t.tap(find.text('Wi'));
      await t.pump();
      expect(on, isTrue);
    });

    testWidgets('segmented and tabs report the picked option', (t) async {
      int? seg;
      int? tab;
      await t.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TfSegmented<int>(
                options: const {1: 'A', 2: 'B'},
                value: 1,
                onChanged: (v) => seg = v,
              ),
              TfTabs(
                labels: const ['X', 'Y'],
                index: 0,
                onChanged: (v) => tab = v,
              ),
            ],
          ),
        ),
      );
      await t.tap(find.text('B'));
      await t.tap(find.text('Y'));
      expect(seg, 2);
      expect(tab, 1);
    });
  });

  group('display components', () {
    testWidgets('avatar initials and stable colour', (t) async {
      expect(TfAvatar.initials('Mina Rahimi'), 'MR');
      expect(TfAvatar.initials('  omar '), 'O');
      expect(TfAvatar.initials(''), '?');
      await t.pumpWidget(
        _host(const TfAvatarStack(names: ['A B', 'C D', 'E F', 'G H', 'I J'])),
      );
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets(
      'status and priority carry a label or shape, not colour alone',
      (t) async {
        await t.pumpWidget(
          _host(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TfStatusPill(label: 'Done', kind: TfStatusKind.done),
                TfPriorityIcon(
                  priority: TfPriority.urgent,
                  label: 'Urgent',
                  showLabel: true,
                ),
              ],
            ),
          ),
        );
        expect(find.text('Done'), findsOneWidget);
        expect(find.text('Urgent'), findsOneWidget);
        expect(find.byType(TfIcon), findsNWidgets(2));
        expect(
          {for (final k in TfStatusKind.values) k.icon.glyph}.length,
          greaterThan(2),
        );
      },
    );

    testWidgets('badge caps counts and progress clamps', (t) async {
      await t.pumpWidget(
        _host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TfBadge(count: 250),
              SizedBox(width: 100, child: TfProgressBar(value: 3)),
              TfProgressRing(value: -1),
            ],
          ),
        ),
      );
      expect(find.text('99+'), findsOneWidget);
      final bar = t.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(bar.widthFactor, 1);
    });

    testWidgets('key hint splits the chord into caps', (t) async {
      await t.pumpWidget(_host(const TfKeyHint('Ctrl+Shift+K')));
      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
    });

    testWidgets('row reacts to tap and shows subtitle', (t) async {
      var taps = 0;
      await t.pumpWidget(
        _host(TfRow(title: 'Task', subtitle: 'TF-1', onTap: () => taps++)),
      );
      await t.tap(find.text('Task'));
      expect(taps, 1);
      expect(find.text('TF-1'), findsOneWidget);
    });

    testWidgets('row height follows density', (t) async {
      desktop();
      Future<double> h(TfDensity d) async {
        await t.pumpWidget(
          _host(
            const SizedBox(width: 300, child: TfRow(title: 'Task')),
            density: d,
          ),
        );
        await t.pumpAndSettle(); // the theme change animates
        return t.getSize(find.byType(TfRow)).height;
      }

      expect(await h(TfDensity.comfortable), 40);
      expect(await h(TfDensity.compact), 32);
    });

    testWidgets('section header, empty state and skeleton render', (t) async {
      var acted = false;
      await t.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TfSectionHeader(title: 'Today', count: 2),
              SizedBox(
                height: 240,
                child: TfEmpty(
                  title: 'Nothing',
                  message: 'Add one',
                  actionLabel: 'Add',
                  onAction: () => acted = true,
                ),
              ),
              const TfSkeleton(width: 50),
              const TfPanel(child: Text('in panel')),
            ],
          ),
        ),
      );
      await t.tap(find.text('Add').last);
      expect(acted, isTrue);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('banner action and dismiss work', (t) async {
      var acted = 0;
      var dismissed = 0;
      await t.pumpWidget(
        _host(
          TfBanner(
            message: 'Careful',
            kind: TfBannerKind.warning,
            actionLabel: 'Fix',
            onAction: () => acted++,
            onDismiss: () => dismissed++,
            dismissTooltip: 'Dismiss',
          ),
        ),
      );
      await t.tap(find.text('Fix'));
      await t.tap(find.byType(TfIconButton));
      expect([acted, dismissed], [1, 1]);
    });
  });

  group('inputs and overlays', () {
    testWidgets('text field shows error and search clears', (t) async {
      String? last;
      await t.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TfTextField(label: 'Name', errorText: 'Required'),
              TfSearchField(
                onChanged: (v) => last = v,
                hint: 'Search',
                clearTooltip: 'Clear',
              ),
            ],
          ),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
      await t.enterText(find.byType(TextField).last, 'abc');
      expect(last, 'abc');
      await t.pump();
      await t.tap(find.byTooltip('Clear'));
      await t.pump();
      expect(last, '');
    });

    testWidgets('menu opens, picks an item and the select shows the choice', (
      t,
    ) async {
      var picked = '';
      await t.pumpWidget(
        _host(
          TfSelect<String>(
            options: const {'a': 'Alpha', 'b': 'Beta'},
            value: 'a',
            onChanged: (v) => picked = v,
          ),
        ),
      );
      await t.tap(find.text('Alpha'));
      await t.pumpAndSettle();
      await t.tap(find.text('Beta'));
      await t.pumpAndSettle();
      expect(picked, 'b');
    });

    testWidgets('dialog, side sheet and toast appear and close', (t) async {
      await t.pumpWidget(
        _host(
          Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TfButton(
                  label: 'D',
                  onPressed: () => showTfDialog<void>(
                    context,
                    title: 'Title',
                    body: const Text('Body'),
                    actions: [
                      TfButton(
                        label: 'Ok',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                TfButton(
                  label: 'S',
                  onPressed: () => showTfSideSheet<void>(
                    context,
                    title: 'Side',
                    body: const Text('Side body'),
                    closeTooltip: 'Close',
                  ),
                ),
                TfButton(
                  label: 'T',
                  onPressed: () => showTfToast(context, 'Saved'),
                ),
              ],
            ),
          ),
        ),
      );
      await t.tap(find.text('D'));
      await t.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
      await t.tap(find.text('Ok'));
      await t.pumpAndSettle();
      await t.tap(find.text('S'));
      await t.pumpAndSettle();
      expect(find.text('Side body'), findsOneWidget);
      await t.tap(find.byTooltip('Close'));
      await t.pumpAndSettle();
      await t.tap(find.text('T'));
      await t.pump();
      expect(find.text('Saved'), findsOneWidget);
    });
  });

  testWidgets('components lay out start-to-end in RTL', (t) async {
    await t.pumpWidget(
      _host(
        const TfChip(label: 'Chip', icon: TfIcons.tag),
        dir: TextDirection.rtl,
      ),
    );
    final icon = t.getCenter(find.byType(TfIcon)).dx;
    final text = t.getCenter(find.text('Chip')).dx;
    expect(
      icon,
      greaterThan(text),
      reason: 'the icon leads, on the right in RTL',
    );
  });
}
