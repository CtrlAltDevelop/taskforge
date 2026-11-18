import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskforge/app.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/auth/sign_in_screen.dart';

import '../features/board/fakes.dart';
import '../features/projects/fakes.dart';
import '../features/projects/projects_test_support.dart';
import '../features/tasks/fakes.dart';
import '../features/workspaces/fakes.dart' show MockAuthApi;
import '../features/workflows/fakes.dart';

/// Phase 49 screen-reader pass: on each key screen every tap target has a
/// label (Flutter's own `labeledTapTargetGuideline`), and the page names its
/// main controls.
Future<Pumped> _app(WidgetTester t, {Size size = const Size(1280, 900)}) async {
  final server = FakeTasksClient([task('a', 'Ship it'), task('b', 'Second')]);
  return pumpProjects(
    t,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    board: FakeBoardClient(server.tasks),
    size: size,
  );
}

Future<void> _labelled(WidgetTester t) =>
    expectLater(t, meetsGuideline(labeledTapTargetGuideline));

void main() {
  testWidgets('sign in: fields and button are named', (t) async {
    final handle = t.ensureSemantics();
    final session = AuthSession(api: MockAuthApi(), store: MemoryTokenStore());
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWithValue(session),
          syncClientProvider.overrideWithValue(null),
        ],
        child: const TaskForgeApp(),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('email', caseSensitive: false)),
      findsWidgets,
    );
    expect(
      find.bySemanticsLabel(RegExp('password', caseSensitive: false)),
      findsWidgets,
    );
    await _labelled(t);
    handle.dispose();
  });

  testWidgets('Home: tap targets are labelled', (t) async {
    final handle = t.ensureSemantics();
    await _app(t);
    await _labelled(t);
    handle.dispose();
  });

  testWidgets('list: tap targets are labelled', (t) async {
    final handle = t.ensureSemantics();
    final app = await _app(t);
    await app.go(t, '/projects/p1');
    expect(find.bySemanticsLabel(RegExp('Ship it')), findsWidgets);
    await _labelled(t);
    handle.dispose();
  });

  testWidgets('board: tap targets are labelled', (t) async {
    final handle = t.ensureSemantics();
    final app = await _app(t);
    await app.go(t, '/projects/p1?view=board');
    await _labelled(t);
    handle.dispose();
  });

  testWidgets('task modal: tap targets are labelled', (t) async {
    final handle = t.ensureSemantics();
    final app = await _app(t);
    await app.go(t, '/projects/p1');
    await t.tap(find.byKey(const Key('task-a')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('task-modal')), findsOneWidget);
    await _labelled(t);
    handle.dispose();
  });

  for (final path in [
    '/settings/appearance',
    '/settings/language',
    '/sessions',
  ]) {
    testWidgets('settings $path: tap targets are labelled', (t) async {
      final handle = t.ensureSemantics();
      final app = await _app(t);
      await app.go(t, path);
      await _labelled(t);
      handle.dispose();
    });
  }

  // Phase 44 swept the board at 200 %; this adds Home, My work and the list.
  for (final width in [360.0, 768.0, 1280.0]) {
    for (final path in ['/', '/my-work', '/projects/p1']) {
      testWidgets('200% text on $path at $width wide does not overflow', (
        t,
      ) async {
        t.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        final app = await _app(t, size: Size(width, 900));
        await app.go(t, path);
        expect(t.takeException(), isNull);
      });
    }
  }
}
