import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/sync/sync_coordinator.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/features/inbox/application/icon_badge.dart';
import 'package:taskforge/features/inbox/application/live_alerts.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/time/application/timer_notification.dart';

/// Arabic-script faces tried after the platform font. Vazirmatn is bundled
/// (assets/fonts, see docs/translating.md) so no platform depends on system fonts.
const _arabicScriptFonts = [
  'Vazirmatn',
  'Noto Naskh Arabic',
  'Noto Sans Arabic',
];

/// `--dart-define=PSEUDO_LOCALE=true` runs the app in the pseudo-language
/// (docs/translating.md): accented, padded English that shows clipped layouts
/// and any text that is still hardcoded.
const _pseudoLocale = bool.fromEnvironment('PSEUDO_LOCALE');

/// Pointer platforms get tighter rows; touch platforms keep 48dp targets.
final _desktopPlatform = const {
  TargetPlatform.macOS,
  TargetPlatform.windows,
  TargetPlatform.linux,
}.contains(defaultTargetPlatform);

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
    void applyDefault(Workspace? workspace) => ref
        .read(localePrefsProvider.notifier)
        .applyWorkspaceDefault(workspace?.defaultLocale ?? '');
    ref.listen(
      currentWorkspaceProvider,
      (_, workspace) => applyDefault(workspace),
    );
    // `listen` skips the value already there; start from it too.
    final current = ref.read(currentWorkspaceProvider);
    Future.microtask(() => applyDefault(current));
    final prefs = ref.watch(localePrefsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: _pseudoLocale ? const Locale('en', 'XA') : prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoDelegate(),
      ],
      themeMode: ref.watch(themeModeProvider),
      theme: buildAppTheme(
        brightness: Brightness.light,
        fontFallback: _arabicScriptFonts,
        compactDensity: _desktopPlatform,
      ),
      darkTheme: buildAppTheme(
        brightness: Brightness.dark,
        fontFallback: _arabicScriptFonts,
        compactDensity: _desktopPlatform,
      ),
      routerConfig: router,
    );
  }
}
