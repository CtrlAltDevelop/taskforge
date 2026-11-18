import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/system/presentation/whats_new.dart';

import '../home/fakes.dart';
import '../workspaces/fakes.dart';

Finder _key(String k) => find.byKey(Key(k));

Future<FakeHomeClient> _firstRun(WidgetTester t, {FakeHomeClient? home}) async {
  final client = home ?? FakeHomeClient();
  await pumpSignedIn(
    t,
    FakeWorkspaceClient(),
    home: client,
    overrides: [localPrefsProvider.overrideWithValue(MemoryPrefs())],
  );
  await t.enterText(byKey('workspace-name'), 'Acme');
  await t.tap(byKey('create-workspace'));
  await t.pumpAndSettle();
  return client;
}

void main() {
  group('first run', () {
    testWidgets('after the workspace: four starters, software team first', (
      t,
    ) async {
      await _firstRun(t);
      expect(find.text('Pick a starter'), findsOneWidget);
      expect(find.text('Step 2 of 3'), findsOneWidget);
      for (final k in ['software-team', 'marketing', 'bug-tracker', 'blank']) {
        expect(_key('starter-$k'), findsOneWidget, reason: k);
      }
    });

    testWidgets(
      'picking a starter creates it, invites, then opens the project',
      (t) async {
        final home = await _firstRun(t);
        await t.tap(_key('starter-marketing'));
        await t.pumpAndSettle();
        await t.tap(_key('starter-create'));
        await t.pumpAndSettle();
        expect(home.calls, ['starter marketing']);

        expect(find.text('Invite your team'), findsOneWidget);
        expect(find.text('Step 3 of 3'), findsOneWidget);
        await t.tap(_key('onboarding-skip'));
        await t.pumpAndSettle();
        expect(
          GoRouter.of(t.element(find.byType(Scaffold).first)).state.uri.path,
          '/projects/p-new',
        );
      },
    );

    testWidgets('inviting opens the invite dialog and can still continue', (
      t,
    ) async {
      await _firstRun(t);
      await t.tap(_key('starter-create'));
      await t.pumpAndSettle();
      await t.tap(_key('onboarding-invite'));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('invite-tab-email')), findsOneWidget);
    });

    testWidgets('a failing starter says so and can retry', (t) async {
      final home = FakeHomeClient()
        ..starterError = const HomeException(HomeFailure.network);
      await _firstRun(t, home: home);
      await t.tap(_key('starter-create'));
      await t.pumpAndSettle();
      expect(_key('starter-error'), findsOneWidget);
      expect(find.text('Pick a starter'), findsOneWidget);

      home.starterError = null;
      await t.tap(_key('starter-retry'));
      await t.pumpAndSettle();
      expect(find.text('Invite your team'), findsOneWidget);
    });

    testWidgets('the starter and invite steps work at phone width', (t) async {
      t.view.physicalSize = const Size(360, 700);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await _firstRun(t);
      expect(t.takeException(), isNull);
      await t.tap(_key('starter-create'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  group("what's new", () {
    Future<MemoryPrefs> pumpWith(
      WidgetTester t, {
      String? seen,
      String version = '1.1.0',
    }) async {
      final prefs = MemoryPrefs();
      if (seen != null) await prefs.write('app.lastSeenVersion', seen);
      await pumpSignedIn(
        t,
        FakeWorkspaceClient([ws('w1', 'WS')]),
        overrides: <Override>[
          localPrefsProvider.overrideWithValue(prefs),
          appVersionProvider.overrideWithValue(version),
        ],
      );
      return prefs;
    }

    testWidgets('shows once after an upgrade, then never for that version', (
      t,
    ) async {
      final prefs = await pumpWith(t, seen: '1.0.0');
      expect(_key('whats-new'), findsOneWidget);
      expect(find.text("What's new in 1.1.0"), findsOneWidget);
      expect(await prefs.read('app.lastSeenVersion'), '1.1.0');

      await t.tap(_key('whats-new-close'));
      await t.pumpAndSettle();
      expect(_key('whats-new'), findsNothing);

      // Opened again with the same version: nothing.
      await pumpWith(t, seen: '1.1.0');
      expect(_key('whats-new'), findsNothing);
    });

    testWidgets('never on a first install, but remembers the version', (
      t,
    ) async {
      final prefs = await pumpWith(t);
      expect(_key('whats-new'), findsNothing);
      expect(await prefs.read('app.lastSeenVersion'), '1.1.0');
    });
  });
}
