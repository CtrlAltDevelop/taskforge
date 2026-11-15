import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/shortcuts/application/builtin_actions.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

void main() {
  final fa = lookupAppLocalizations(const Locale('fa'));
  final inbox = builtInActions.firstWhere((a) => a.id == 'nav.inbox');

  test('keeps the English title and group on the plain getters', () {
    expect(inbox.title, 'Inbox');
    expect(inbox.group, 'Go to');
  });

  test('localizes the title, group and screen-reader label', () {
    expect(inbox.titleIn(fa), isNot('Inbox'));
    expect(inbox.titleIn(fa), fa.grpKTInbox);
    expect(inbox.groupIn(fa), fa.grpKGroupGoTo);
    expect(inbox.semanticLabelIn(fa), isNotEmpty);
  });

  test('every registry entry has a Persian title and group', () {
    for (final a in builtInActions) {
      expect(a.titleIn(fa).trim(), isNotEmpty, reason: a.id);
      expect(a.groupIn(fa).trim(), isNotEmpty, reason: a.id);
    }
  });

  test('search finds an action by its Persian and English title', () {
    final byFa = rankActions(builtInActions, fa.grpKTInbox, l10n: fa);
    expect(byFa.first.id, 'nav.inbox');
    final byEn = rankActions(builtInActions, 'Inbox', l10n: fa);
    expect(byEn.first.id, 'nav.inbox');
  });

  testWidgets('a registry action title renders in Persian', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) => Text(inbox.titleIn(context.l10n))),
      ),
    );
    expect(find.text(fa.grpKTInbox), findsOneWidget);
    expect(find.text('Inbox'), findsNothing);
  });
}
