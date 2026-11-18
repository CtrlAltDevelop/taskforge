import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/features/system/presentation/status_screens.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

Widget _app(Widget home, {Locale locale = const Locale('en')}) => ProviderScope(
  child: MaterialApp.router(
    theme: buildAppTheme(brightness: Brightness.light),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      FallbackCupertinoDelegate(),
    ],
    routerConfig: GoRouter(
      errorBuilder: (_, _) => const NotFoundScreen(),
      routes: [
        GoRoute(path: '/', builder: (_, _) => home),
        GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
      ],
    ),
  ),
);

void main() {
  final screens = <String, (Widget, TfIllustrationKind)>{
    'not found': (const NotFoundScreen(), TfIllustrationKind.notFound),
    'no access': (const NoAccessScreen(), TfIllustrationKind.noAccess),
    'no connection': (
      NoConnectionScreen(onRetry: () {}),
      TfIllustrationKind.offline,
    ),
    'maintenance': (const MaintenanceScreen(), TfIllustrationKind.maintenance),
  };

  for (final MapEntry(key: name, value: (screen, kind)) in screens.entries) {
    for (final lang in ['en', 'fa', 'ar', 'ps']) {
      testWidgets('$name draws its picture and action in $lang', (t) async {
        await t.pumpWidget(_app(screen, locale: Locale(lang)));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(
          find.byWidgetPredicate((w) => w is TfIllustration && w.kind == kind),
          findsOneWidget,
        );
        expect(find.byKey(const Key('status-action')), findsOneWidget);
      });
    }
  }

  testWidgets('an unknown route shows the 404 page', (t) async {
    await t.pumpWidget(_app(const SizedBox()));
    await t.pumpAndSettle();
    final ctx = t.element(find.byType(SizedBox).first);
    GoRouter.of(ctx).go('/nowhere');
    await t.pumpAndSettle();
    expect(find.byType(NotFoundScreen), findsOneWidget);
  });

  testWidgets('the 404 action goes home', (t) async {
    await t.pumpWidget(_app(const SizedBox()));
    GoRouter.of(t.element(find.byType(SizedBox).first)).go('/nowhere');
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('status-action')));
    await t.pumpAndSettle();
    expect(find.byType(SizedBox), findsWidgets);
    expect(find.byType(NotFoundScreen), findsNothing);
  });

  testWidgets('no connection retry calls back', (t) async {
    var n = 0;
    await t.pumpWidget(_app(NoConnectionScreen(onRetry: () => n++)));
    await t.tap(find.byKey(const Key('status-action')));
    expect(n, 1);
  });
}
