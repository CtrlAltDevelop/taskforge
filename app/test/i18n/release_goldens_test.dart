import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/app.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/security/application/security_providers.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../features/security/fakes.dart';
import '../features/system/fakes.dart';
import '../features/workspaces/fakes.dart'
    show FakeAccounts, FakeWorkspaceClient, MockAuthApi;
import 'rtl_screens_test.dart' show ScreenEnv;
import 'tolerant_golden.dart';

/// The release gate (phase 49): a picture of every top-level route of
/// `app_router.dart`. The route list is read from the router's source, so a
/// new route without a picture (or an entry in [_notPictured]) fails
/// `every route has a picture or a reason`.
///
/// Size of the suite: about 50 routes x 8 combinations (phone and desktop,
/// light and dark, English and Persian) would be 400 PNGs of up to 1280x800,
/// too heavy for the repository. So the 12 [_primary] screens get all eight
/// combinations; every other route gets four that between them cover each axis:
/// desktop light en, desktop dark en, phone light en, phone light fa.
///
/// Regenerate with `flutter test --update-goldens
/// test/i18n/release_goldens_test.dart` after a deliberate restyle.

const _phone = Size(390, 844);
const _desktop = Size(1280, 800);

/// Routes that cannot be pictured here, with the reason. Each one is covered
/// elsewhere or needs data the fakes do not seed.
const _notPictured = {
  '/two-factor':
      'needs the server challenge passed as navigation state; '
      'covered by test/features/security',
  '/sso/callback':
      'exchanges a one-time ticket with the live server and only shows '
      'a spinner or an error; covered by test/features/auth',
  '/f/:token': 'public intake form: needs a live form by token (forms tests)',
  '/forms/new': 'form builder opens on a live record (forms tests)',
  '/forms/:id': 'form builder needs a seeded form (forms tests)',
  '/forms/:id/submissions': 'needs a seeded form with answers (forms tests)',
  '/developer/webhooks/:id': 'needs a seeded webhook (developer tests)',
  '/goals/:id': 'needs a seeded goal (goals tests)',
  '/debug/gallery': 'debug-only; its own sweep is test/core/ui/gallery_test',
};

/// Routes that need no one signed in; every other route is opened signed in.
const _signedOut = {
  '/sign-in',
  '/sign-up',
  '/forgot-password',
  '/reset-password',
};

/// The screens people see most: all eight combinations.
const _primary = {
  '/',
  '/my-work',
  '/projects/:id',
  '/inbox',
  '/chat',
  '/docs',
  '/calendar',
  '/dashboards',
  '/goals',
  '/members',
  '/settings/appearance',
  '/sign-in',
};

/// Where a route with parameters is opened.
const _sample = {
  '/projects/:id': '/projects/p1',
  '/projects/:id/settings': '/projects/p1/settings',
  '/projects/:id/sprints': '/projects/p1/sprints',
  '/projects/:id/automations': '/projects/p1/automations',
  '/projects/:id/workflow': '/projects/p1/workflow',
  '/projects/:id/fields': '/projects/p1/fields',
  '/projects/:id/dashboards': '/projects/p1/dashboards',
  '/docs/:id': '/docs/a',
  '/chat/:spaceId': '/chat/gen',
  '/invite/:token': '/invite/tok',
  '/welcome/invite': '/welcome/invite?project=p1',
};

/// Every `path:` of a route in the router's source.
List<String> routerPaths() =>
    RegExp(r"path: '([^']+)'")
        .allMatches(File('lib/app_router.dart').readAsStringSync())
        .map((m) => m.group(1)!)
        .toSet()
        .toList();

String _slug(String path) {
  final s = path.replaceAll(RegExp('[^a-zA-Z0-9]+'), '_');
  return s.replaceAll(RegExp(r'^_+|_+$'), '').isEmpty
      ? 'home'
      : s.replaceAll(RegExp(r'^_+|_+$'), '');
}

typedef _Combo = ({Size size, ThemeMode mode, String language});

List<_Combo> _combos(String path) {
  const modes = [ThemeMode.light, ThemeMode.dark];
  if (_primary.contains(path)) {
    return [
      for (final size in [_phone, _desktop])
        for (final mode in modes)
          for (final language in ['en', 'fa'])
            (size: size, mode: mode, language: language),
    ];
  }
  return [
    (size: _desktop, mode: ThemeMode.light, language: 'en'),
    (size: _desktop, mode: ThemeMode.dark, language: 'en'),
    (size: _phone, mode: ThemeMode.light, language: 'en'),
    (size: _phone, mode: ThemeMode.light, language: 'fa'),
  ];
}

String _name(String path, _Combo c) =>
    'goldens/release/${_slug(path)}_${c.size == _phone ? 'phone' : 'desktop'}_'
    '${c.mode.name}_${c.language}.png';

Future<ProviderContainer> _openSignedOut(
  WidgetTester tester,
  _Combo c,
  String location,
) async {
  tester.view
    ..physicalSize = c.size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final prefs = MemoryPrefs();
  await prefs.write('locale.language', c.language);
  final session = AuthSession(api: MockAuthApi(), store: MemoryTokenStore());
  await session.restore();
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWithValue(session),
      syncClientProvider.overrideWithValue(null),
      accountClientProvider.overrideWithValue(FakeAccounts()),
      workspaceClientProvider.overrideWithValue(FakeWorkspaceClient()),
      localPrefsProvider.overrideWithValue(prefs),
      deepLinksProvider.overrideWith((ref) => const Stream<Uri>.empty()),
      securityClientProvider.overrideWithValue(FakeSecurityClient()),
      systemClientProvider.overrideWithValue(FakeSystemClient()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TaskForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  container.read(routerProvider).go(location, extra: 'ticket');
  await tester.pumpAndSettle();
  return container;
}

Future<ProviderContainer> _open(
  WidgetTester tester,
  String path,
  _Combo c,
) async {
  final location = _sample[path] ?? path;
  if (_signedOut.contains(path)) return _openSignedOut(tester, c, location);
  final env = ScreenEnv(c.size, c.language);
  final pumped = await env.open(
    tester,
    location,
    workspaces: path == '/onboarding' ? const [] : const ['w1'],
    overrides: [
      if (path == '/update-required')
        updateRequiredProvider.overrideWithValue(true),
    ],
  );
  return pumped.container;
}

void main() {
  setUpAll(useTolerantGoldens);

  final paths = routerPaths();

  test('every route has a picture or a reason', () {
    expect(paths.length, greaterThan(50), reason: 'the router was not read');
    for (final reason in _notPictured.entries) {
      expect(paths, contains(reason.key), reason: 'stale: ${reason.key}');
    }
    for (final key in [..._primary, ..._sample.keys, ..._signedOut]) {
      expect(paths, contains(key), reason: 'stale entry: $key');
    }
    final withParams = paths.where((p) => p.contains(':') || p.contains('?'));
    for (final p in withParams) {
      expect(
        _sample.containsKey(p) || _notPictured.containsKey(p),
        isTrue,
        reason: '$p has no sample location and no reason in _notPictured',
      );
    }
  });

  testWidgets('the router source lists the router\'s routes', (tester) async {
    final env = ScreenEnv(_desktop, 'en');
    final pumped = await env.open(tester, '/');
    final router = pumped.container.read(routerProvider);
    final real = <String>{};
    void walk(List<RouteBase> routes, String prefix) {
      for (final r in routes) {
        if (r is! GoRoute) continue;
        real.add(r.path.startsWith('/') ? r.path : '$prefix/${r.path}');
        walk(r.routes, r.path);
      }
    }

    walk(router.configuration.routes, '');
    expect(paths.toSet(), real);
  });

  for (final path in paths.where((p) => !_notPictured.containsKey(p))) {
    for (final combo in _combos(path)) {
      final label =
          '$path ${combo.size == _phone ? 'phone' : 'desktop'} '
          '${combo.mode.name} ${combo.language}';
      testWidgets('$label looks the same every run', (tester) async {
        final container = await _open(tester, path, combo);
        container.read(themeModeProvider.notifier).choose(combo.mode);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(_name(path, combo)),
        );
      });
    }
  }
}
