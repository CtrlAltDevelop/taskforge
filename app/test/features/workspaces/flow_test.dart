import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

import 'fakes.dart';

void main() {
  group('onboarding', () {
    testWidgets('a signed-in user with no workspace is sent to onboarding', (
      tester,
    ) async {
      await pumpSignedIn(tester, FakeWorkspaceClient());

      expect(find.text('Create your workspace'), findsOneWidget);
    });

    testWidgets('the slug follows the name until edited', (tester) async {
      await pumpSignedIn(tester, FakeWorkspaceClient());

      await tester.enterText(byKey('workspace-name'), 'Acme Corp');
      expect(
        tester.widget<TextFormField>(byKey('workspace-slug')).controller!.text,
        'acme-corp',
      );

      await tester.enterText(byKey('workspace-slug'), 'mine');
      await tester.enterText(byKey('workspace-name'), 'Other Name');
      expect(
        tester.widget<TextFormField>(byKey('workspace-slug')).controller!.text,
        'mine',
      );
    });

    testWidgets('invalid name and slug are refused before any call', (
      tester,
    ) async {
      final client = FakeWorkspaceClient();
      await pumpSignedIn(tester, client);

      await tester.enterText(byKey('workspace-slug'), 'A');
      await tester.tap(byKey('create-workspace'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a name.'), findsOneWidget);
      expect(find.textContaining('3-40 characters'), findsOneWidget);
      expect(client.items, isEmpty);
    });

    testWidgets('creating lands on the starter step, then home', (
      tester,
    ) async {
      final client = FakeWorkspaceClient();
      await pumpSignedIn(tester, client);

      await tester.enterText(byKey('workspace-name'), 'Acme Corp');
      await tester.tap(byKey('create-workspace'));
      await tester.pumpAndSettle();

      expect(client.items.single.slug, 'acme-corp');
      expect(find.text('Create your workspace'), findsNothing);
      // First run: the starter comes next; leaving it for Home keeps working.
      expect(byKey('starter-create'), findsOneWidget);
      GoRouter.of(tester.element(byKey('starter-create'))).go('/');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Acme Corp'), findsOneWidget);
      expect(byKey('open-workspace-settings'), findsOneWidget);
    });

    testWidgets('a taken URL is reported on the slug field', (tester) async {
      final client = FakeWorkspaceClient()..takenSlugs.add('acme');
      await pumpSignedIn(tester, client);

      await tester.enterText(byKey('workspace-name'), 'Acme');
      await tester.tap(byKey('create-workspace'));
      await tester.pumpAndSettle();

      expect(find.text('That URL is taken'), findsOneWidget);
      expect(find.text('Create your workspace'), findsOneWidget);
    });

    testWidgets('permission denied is shown, not thrown', (tester) async {
      final client = FakeWorkspaceClient()
        ..failNext = const WorkspaceException(WorkspaceFailure.forbidden);
      await pumpSignedIn(tester, client);

      await tester.enterText(byKey('workspace-name'), 'Acme');
      await tester.tap(byKey('create-workspace'));
      await tester.pumpAndSettle();

      expect(find.textContaining('permission'), findsOneWidget);
    });
  });

  group('recently deleted', () {
    testWidgets('onboarding offers restore and sign out', (tester) async {
      final client = FakeWorkspaceClient()..deleted.add(ws('d', 'Gone'));
      await pumpSignedIn(tester, client);

      expect(find.text('Recently deleted'), findsOneWidget);
      await tester.tap(byKey('restore-d'));
      await tester.pumpAndSettle();

      expect(client.items.single.name, 'Gone');
      expect(find.text('Create your workspace'), findsNothing);
    });

    testWidgets('onboarding sign out returns to sign-in', (tester) async {
      await pumpSignedIn(tester, FakeWorkspaceClient());

      await tester.tap(byKey('onboarding-sign-out'));
      await tester.pumpAndSettle();

      expect(find.text('Create your workspace'), findsNothing);
    });

    testWidgets('settings lists deleted workspaces next to live ones', (
      tester,
    ) async {
      final client = FakeWorkspaceClient([ws('a', 'Alpha')])
        ..deleted.add(ws('d', 'Gone'));
      await pumpSignedIn(tester, client);
      await tester.tap(byKey('open-workspace-settings'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(byKey('restore-d'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('restore-d'));
      await tester.pumpAndSettle();

      expect(client.items.map((w) => w.id), ['a', 'd']);
      expect(byKey('restore-d'), findsNothing);
    });

    testWidgets('settings shows retry when the list cannot load', (
      tester,
    ) async {
      final client = FakeWorkspaceClient([ws('a', 'Alpha')])..failList = true;
      await pumpSignedIn(tester, client);
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .go('/workspaces/settings');
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      client.failList = false;
      await tester.tap(byKey('retry-workspaces'));
      await tester.pumpAndSettle();

      expect(byKey('settings-name'), findsOneWidget);
    });
  });

  group('switcher', () {
    final two = [ws('a', 'Alpha'), ws('b', 'Beta')];

    testWidgets('phone: a bottom sheet lists workspaces and switches', (
      tester,
    ) async {
      final container = await pumpSignedIn(tester, FakeWorkspaceClient(two));
      expect(container.read(workspaceScopeProvider), 'a');

      await tester.tap(byKey('workspace-switcher'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('switch-b'));
      await tester.pumpAndSettle();

      expect(container.read(workspaceScopeProvider), 'b');
      expect(find.byTooltip('Beta'), findsOneWidget);
    });

    testWidgets('desktop: a dropdown menu switches', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final container = await pumpSignedIn(tester, FakeWorkspaceClient(two));

      await tester.tap(byKey('workspace-switcher'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('switch-b'));
      await tester.pumpAndSettle();

      expect(container.read(workspaceScopeProvider), 'b');
    });

    testWidgets('the choice is remembered on the device', (tester) async {
      final container = await pumpSignedIn(tester, FakeWorkspaceClient(two));

      await container.read(selectedWorkspaceIdProvider.notifier).select('b');

      expect(await container.read(workspaceStoreProvider).read(), 'b');
    });

    testWidgets('create workspace from the switcher opens the form', (
      tester,
    ) async {
      await pumpSignedIn(tester, FakeWorkspaceClient(two));

      await tester.tap(byKey('workspace-switcher'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('new-workspace'));
      await tester.pumpAndSettle();

      expect(find.text('Create your workspace'), findsOneWidget);
    });
  });

  group('settings', () {
    Future<FakeWorkspaceClient> openSettings(
      WidgetTester tester, {
      bool owner = true,
    }) async {
      final client = FakeWorkspaceClient([ws('a', 'Alpha', owner: owner)]);
      await pumpSignedIn(tester, client);
      await tester.tap(byKey('open-workspace-settings'));
      await tester.pumpAndSettle();
      return client;
    }

    testWidgets('renaming saves and shows the new name', (tester) async {
      final client = await openSettings(tester);

      await tester.enterText(byKey('settings-name'), 'Alpha Two');
      await tester.tap(byKey('save-workspace'));
      await tester.pumpAndSettle();

      expect(client.items.single.name, 'Alpha Two');
      expect(client.items.single.slug, 'alpha');
      expect(find.text('Workspace updated.'), findsOneWidget);
    });

    testWidgets('a taken slug says so', (tester) async {
      final client = await openSettings(tester);
      client.takenSlugs.add('taken');

      await tester.enterText(byKey('settings-slug'), 'taken');
      await tester.tap(byKey('save-workspace'));
      await tester.pumpAndSettle();

      expect(find.text('That URL is taken'), findsOneWidget);
    });

    testWidgets('a stale version offers a refresh that reloads', (
      tester,
    ) async {
      final client = await openSettings(tester);
      client.failNext = const WorkspaceException(WorkspaceFailure.stale);

      await tester.enterText(byKey('settings-name'), 'Alpha Two');
      await tester.tap(byKey('save-workspace'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Refresh to see'), findsOneWidget);

      final before = client.listCalls;
      await tester.tap(byKey('refresh-workspace'));
      await tester.pumpAndSettle();
      expect(client.listCalls, before + 1);
    });

    testWidgets('permission denied is reported', (tester) async {
      final client = await openSettings(tester);
      client.failNext = const WorkspaceException(WorkspaceFailure.forbidden);

      await tester.enterText(byKey('settings-name'), 'Alpha Two');
      await tester.tap(byKey('save-workspace'));
      await tester.pumpAndSettle();

      expect(find.textContaining('permission'), findsOneWidget);
    });

    testWidgets('a non-owner cannot edit or delete', (tester) async {
      await openSettings(tester, owner: false);

      expect(byKey('save-workspace'), findsNothing);
      expect(byKey('delete-workspace'), findsNothing);
    });

    testWidgets('delete needs the exact name, then offers undo', (
      tester,
    ) async {
      final client = await openSettings(tester);

      await tester.tap(byKey('delete-workspace'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(byKey('confirm-delete')).onPressed,
        isNull,
      );

      await tester.enterText(byKey('confirm-name'), 'alpha');
      await tester.pump();
      expect(
        tester.widget<FilledButton>(byKey('confirm-delete')).onPressed,
        isNull,
      );

      await tester.enterText(byKey('confirm-name'), 'Alpha');
      await tester.pump();
      await tester.tap(byKey('confirm-delete'));
      await tester.pumpAndSettle();

      expect(client.items, isEmpty);
      // Zero workspaces left: straight back to onboarding, with the undo offered.
      expect(find.text('Create your workspace'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(client.items.single.name, 'Alpha');
      expect(find.text('Create your workspace'), findsNothing);
    });
  });
}
