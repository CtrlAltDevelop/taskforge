// The main navigation flow through the whole app with fakes: sign in, create a
// project, add and open a task, and read the breadcrumbs at each step. Run
// with `flutter test integration_test`.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';

import '../test/features/tasks/fakes.dart';
import '../test/features/projects/projects_test_support.dart';
import '../test/features/workflows/fakes.dart';
import '../test/features/workspaces/fakes.dart' show MockAuthApi;

const _tokens = AuthTokens(
  accessToken: 'a.b.c',
  refreshToken: 'r',
  sessionId: 's',
);

/// A server that accepts any sign-in.
class _Api extends MockAuthApi {
  @override
  Future<AuthTokens> signIn(String email, String password) async => _tokens;

  @override
  Future<void> logout(String refreshToken) async {}
}

Finder _crumb(String text) =>
    find.descendant(of: byKey('breadcrumbs'), matching: find.text(text));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign in, create a project, open a task: named breadcrumbs', (
    tester,
  ) async {
    final app = await pumpProjects(
      tester,
      authApi: _Api(),
      tasks: FakeTasksClient(),
      workflows: FakeWorkflowsClient(defaultWorkflow()),
    );

    // 1. Sign out and back in through the real sign-in screen.
    await app.container.read(authSessionProvider).signOut();
    await tester.pumpAndSettle();
    await tester.enterText(byKey('email'), 'zoe@example.com');
    await tester.enterText(byKey('password'), 'Xq7-mnbvcz');
    await tester.tap(byKey('submit'));
    await tester.pumpAndSettle();
    expect(byKey('home-greeting'), findsOneWidget);

    // 2. Create a project: the trail names the workspace and the project.
    await tester.tap(byKey('new-project'));
    await tester.pumpAndSettle();
    await tester.enterText(byKey('project-name'), 'Web App');
    await tester.tap(byKey('create-project'));
    await tester.pumpAndSettle();
    expect(_crumb('WS w1'), findsOneWidget);
    expect(_crumb('Web App'), findsOneWidget);

    // 3. Add a task and open it: its title joins the trail.
    await tester.enterText(byKey('quick-add'), 'Fix login');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fix login'));
    await tester.pumpAndSettle();
    expect(_crumb('Fix login'), findsOneWidget);
    expect(_crumb('Web App'), findsOneWidget);

    // 4. Closing the task takes its title out of the trail.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_crumb('Fix login'), findsNothing);
    expect(_crumb('Web App'), findsOneWidget);
  });
}
