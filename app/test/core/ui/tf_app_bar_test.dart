import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

Widget _app(String start) => ProviderScope(
  child: MaterialApp.router(
    localizationsDelegates: const [AppLocalizations.delegate],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: GoRouter(
      initialLocation: start,
      routes: [
        for (final p in ['/', '/page'])
          GoRoute(
            path: p,
            builder: (_, _) => Scaffold(appBar: const TfAppBar()),
          ),
      ],
    ),
  ),
);

void main() {
  testWidgets('a page reached with go() has a way home and a profile menu', (
    tester,
  ) async {
    await tester.pumpWidget(_app('/page'));
    expect(find.byKey(const Key('app-bar-home')), findsOneWidget);
    expect(find.byKey(const Key('profile-menu')), findsOneWidget);
  });

  testWidgets('home has neither: it is the profile page', (tester) async {
    await tester.pumpWidget(_app('/'));
    expect(find.byKey(const Key('app-bar-home')), findsNothing);
    expect(find.byKey(const Key('profile-menu')), findsNothing);
  });
}
