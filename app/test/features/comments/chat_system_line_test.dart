import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:taskforge/features/comments/domain/chat_sentence.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/comments/presentation/chat_system_line.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import '../../i18n/tolerant_golden.dart';

final _at = DateTime.utc(2026, 3, 5, 10);

Comment system({String type = 'user', String id = 'c1'}) => Comment(
  id: id,
  taskId: 't',
  authorId: type == 'user' ? 'u1' : '',
  createdAt: _at,
  kind: 'system',
  event: ChatEvent(
    actorType: type,
    actorId: type == 'user' ? 'u1' : '',
    field: 'priority',
    from: 'low',
    to: 'high',
  ),
);

/// One line, in [language], with the clock at [now].
Widget host(String language, DateTime now, Comment c) => MaterialApp(
  locale: Locale(language),
  debugShowCheckedModeBanner: false,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    FallbackCupertinoDelegate(),
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(12),
      child: Builder(
        builder: (context) {
          final l = AppLocalizations.of(context);
          final e = c.event!;
          return RepaintBoundary(
            key: const Key('boundary'),
            child: ChatSystemLine(
              comment: c,
              now: now,
              actor: e.byPerson ? 'Sara' : chatNonPersonActor(e.actorType, l),
              phrase: chatPhrase(
                e,
                l: l,
                userName: (id) => id,
                statusName: (id) => id,
              ),
            ),
          );
        },
      ),
    ),
  ),
);

String shown(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((r) => r.text.toPlainText())
    .join(' ');

void main() {
  setUpAll(useTolerantGoldens);

  testWidgets('says who, what and how long ago, in English', (tester) async {
    await tester.pumpWidget(
      host('en', _at.add(const Duration(minutes: 38)), system()),
    );

    final text = shown(tester);
    expect(text, contains('@Sara'));
    expect(text, contains('changed priority from Low to High'));
    expect(find.text('38 min ago'), findsOneWidget);
  });

  testWidgets('says it in Persian when the language is Persian', (
    tester,
  ) async {
    await tester.pumpWidget(
      host('fa', _at.add(const Duration(minutes: 38)), system()),
    );

    final text = shown(tester);
    expect(text, contains('@Sara'));
    expect(text, contains('اولویت'));
    expect(text, isNot(contains('changed')));
  });

  testWidgets('the relative time moves on when the clock does', (tester) async {
    await tester.pumpWidget(
      host('en', _at.add(const Duration(minutes: 5)), system()),
    );
    expect(find.text('5 min ago'), findsOneWidget);

    await tester.pumpWidget(
      host('en', _at.add(const Duration(minutes: 6)), system()),
    );
    expect(find.text('6 min ago'), findsOneWidget);
  });

  testWidgets('shows the exact time when held down', (tester) async {
    await tester.pumpWidget(
      host('en', _at.add(const Duration(minutes: 5)), system()),
    );

    await tester.longPress(find.byKey(const Key('system-time-c1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('2026-03-05'), findsOneWidget);
  });

  testWidgets('an automation shows its name, not a person, and no @', (
    tester,
  ) async {
    await tester.pumpWidget(
      host('en', _at.add(const Duration(hours: 2)), system(type: 'automation')),
    );

    final text = shown(tester);
    expect(text, contains('an automation'));
    expect(text, isNot(contains('@')));
    expect(find.text('2 h ago'), findsOneWidget);
  });

  testWidgets('has nothing to tap: no buttons, menus or reactions', (
    tester,
  ) async {
    await tester.pumpWidget(host('en', _at, system()));

    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(PopupMenuButton), findsNothing);
    expect(find.byType(FilterChip), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  for (final language in ['en', 'fa']) {
    testWidgets('the muted line looks the same every run ($language)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 80);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(language, _at.add(const Duration(minutes: 38)), system()),
      );

      await expectLater(
        find.byKey(const Key('boundary')),
        matchesGoldenFile('goldens/chat_system_line_$language.png'),
      );
    });
  }
}
