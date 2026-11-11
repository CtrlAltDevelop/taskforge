import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/core/sync/sync_coordinator.dart';

class TaskForgeApp extends ConsumerWidget {
  const TaskForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(
      syncCoordinatorProvider,
    ); // live changes read the open screens again
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
