import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import '../../../i18n/tolerant_golden.dart';

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  double width = 420,
}) => MaterialApp(
  theme: buildAppTheme(brightness: brightness),
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    FallbackCupertinoDelegate(),
  ],
  home: Scaffold(
    body: RepaintBoundary(
      key: const Key('shot'),
      child: SizedBox(width: width, height: 360, child: child),
    ),
  ),
);

void main() {
  setUpAll(useTolerantGoldens);

  group('TfIllustration', () {
    testWidgets('every kind paints in light and dark with a label', (t) async {
      for (final b in Brightness.values) {
        for (final kind in TfIllustrationKind.values) {
          await t.pumpWidget(_host(TfIllustration(kind), brightness: b));
          expect(t.takeException(), isNull, reason: '${kind.name} ${b.name}');
          expect(
            find.bySemanticsLabel(RegExp('.+')),
            findsWidgets,
            reason: kind.name,
          );
        }
      }
    });

    testWidgets('uses the given semantic label over the default', (t) async {
      await t.pumpWidget(
        _host(
          const TfIllustration(TfIllustrationKind.chat, semanticLabel: 'X'),
        ),
      );
      expect(find.bySemanticsLabel('X'), findsOneWidget);
    });

    testWidgets('has a distinct non-empty label for every kind', (t) async {
      await t.pumpWidget(_host(const SizedBox()));
      final l = AppLocalizations.of(t.element(find.byType(SizedBox).first));
      final labels = TfIllustrationKind.values.map((k) => k.label(l)).toSet();
      expect(labels.length, TfIllustrationKind.values.length);
      expect(labels.every((s) => s.isNotEmpty), isTrue);
    });
  });

  test('each scene is a bundled SVG with no text inside', () {
    final files = Directory('assets/illustrations')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .toList();
    expect(files.length, TfIllustrationKind.values.length);
    for (final f in files) {
      expect(f.readAsStringSync(), isNot(contains('<text')), reason: f.path);
    }
  });

  group('TfEmpty', () {
    testWidgets('shows illustration, title, sentence, action and docs link', (
      t,
    ) async {
      var acted = false, docs = false;
      await t.pumpWidget(
        _host(
          TfEmpty(
            illustration: TfIllustrationKind.tasks,
            title: 'No tasks',
            message: 'Add one.',
            actionLabel: 'Add',
            onAction: () => acted = true,
            docsLabel: 'Learn more',
            onDocs: () => docs = true,
          ),
        ),
      );
      expect(find.byType(TfIllustration), findsOneWidget);
      await t.tap(find.text('Add'));
      await t.tap(find.text('Learn more'));
      expect(acted && docs, isTrue);
    });

    testWidgets('keeps the icon parameter working', (t) async {
      await t.pumpWidget(_host(const TfEmpty(title: 'Plain')));
      expect(find.byType(TfIllustration), findsNothing);
      expect(find.text('Plain'), findsOneWidget);
    });
  });

  group('TfError', () {
    testWidgets('retry calls back and copy puts the details on the clipboard', (
      t,
    ) async {
      String? copied;
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      var retried = false;
      await t.pumpWidget(
        _host(
          TfError(
            message: 'Could not load tasks.',
            details: 'GrpcError(14)',
            onRetry: () => retried = true,
          ),
        ),
      );
      expect(find.text('Could not load tasks.'), findsOneWidget);
      await t.tap(find.byKey(const Key('error-retry')));
      await t.tap(find.byKey(const Key('error-copy')));
      await t.pump();
      expect(retried, isTrue);
      expect(copied, 'GrpcError(14)');
    });

    testWidgets('hides Retry when there is nothing to retry', (t) async {
      await t.pumpWidget(_host(const TfError(message: 'x')));
      expect(find.byKey(const Key('error-retry')), findsNothing);
    });
  });

  group('empty state goldens', () {
    for (final (name, b, locale) in [
      ('light', Brightness.light, const Locale('en')),
      ('dark', Brightness.dark, const Locale('en')),
      ('fa', Brightness.light, const Locale('fa')),
    ]) {
      testWidgets('three empty states $name', (t) async {
        final l = lookupAppLocalizations(locale);
        await t.pumpWidget(
          _host(
            Row(
              children: [
                for (final k in [
                  TfIllustrationKind.tasks,
                  TfIllustrationKind.inbox,
                  TfIllustrationKind.search,
                ])
                  Expanded(
                    child: TfEmpty(
                      illustration: k,
                      title: k.label(l),
                      message: l.errTitle,
                      actionLabel: l.errRetry,
                      onAction: () {},
                    ),
                  ),
              ],
            ),
            brightness: b,
            locale: locale,
            width: 1260,
          ),
        );
        await t.binding.setSurfaceSize(const Size(1260, 360));
        addTearDown(() => t.binding.setSurfaceSize(null));
        await t.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../core/ui/goldens/empty_states_$name.png'),
        );
      });
    }
  });
}
