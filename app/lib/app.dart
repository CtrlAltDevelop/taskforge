import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/sync/sync_coordinator.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/features/inbox/application/icon_badge.dart';
import 'package:taskforge/features/inbox/application/live_alerts.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/time/application/timer_notification.dart';

/// Arabic-script faces tried after the platform font. Bundle one (see
/// docs/phases/phase-31-i18n-rtl.md) so the web build does not depend on system fonts.
const _arabicScriptFonts = [
  'Vazirmatn',
  'Noto Naskh Arabic',
  'Noto Sans Arabic',
];

class TaskForgeApp extends ConsumerWidget {
  const TaskForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(
      syncCoordinatorProvider,
    ); // live changes read the open screens again
    ref.watch(offlineSyncProvider); // changes made offline go out when back
    ref.watch(liveAlertsProvider); // system notifications while the app runs
    ref.watch(timerNotificationProvider); // a notification while a timer runs
    ref.watch(iconBadgeProvider); // unread count on the app icon
    ref.listen(deepLinksProvider, (_, link) {
      final route = link.value == null ? null : customSchemeRoute(link.value!);
      if (route != null) router.go(route);
    });
    ref.listen(accountProvider, (_, account) {
      final loaded = account.value;
      if (loaded != null) {
        ref.read(localePrefsProvider.notifier).adopt(loaded);
      }
    });
    final prefs = ref.watch(localePrefsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoDelegate(),
      ],
      themeMode: ref.watch(themeModeProvider),
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        fontFamilyFallback: _arabicScriptFonts,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamilyFallback: _arabicScriptFonts,
      ),
      routerConfig: router,
    );
  }
}
