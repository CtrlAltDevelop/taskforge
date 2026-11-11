import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/core/sync/sync_coordinator.dart';
import 'package:taskforge/features/inbox/application/icon_badge.dart';
import 'package:taskforge/features/inbox/application/live_alerts.dart';
import 'package:taskforge/features/time/application/timer_notification.dart';

class TaskForgeApp extends ConsumerWidget {
  const TaskForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(
      syncCoordinatorProvider,
    ); // live changes read the open screens again
    ref.watch(liveAlertsProvider); // system notifications while the app runs
    ref.watch(timerNotificationProvider); // a notification while a timer runs
    ref.watch(iconBadgeProvider); // unread count on the app icon
    ref.listen(deepLinksProvider, (_, link) {
      final route = link.value == null ? null : customSchemeRoute(link.value!);
      if (route != null) router.go(route);
    });
    return MaterialApp.router(
      title: 'TaskForge',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
