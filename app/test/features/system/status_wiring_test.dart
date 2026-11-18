import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/system/presentation/status_screens.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../workspaces/fakes.dart';

/// A server that will not show this person any project.
class _Refusing extends FakeProjectsClient {
  @override
  Future<ProjectCatalog> list(
    String workspaceId, {
    bool includeArchived = false,
  }) async => throw const ProjectException(ProjectFailure.forbidden);
}

void main() {
  group('the status pages are shown where the app detects the state', () {
    testWidgets('no connection when the workspaces cannot be reached', (
      t,
    ) async {
      final client = FakeWorkspaceClient([ws('w1', 'WS')])..failList = true;
      await pumpSignedIn(t, client);
      expect(find.byType(NoConnectionScreen), findsOneWidget);

      client.failList = false;
      await t.tap(find.byKey(const Key('status-action')));
      await t.pumpAndSettle();
      expect(find.byType(NoConnectionScreen), findsNothing);
      expect(find.byKey(const Key('home-greeting')), findsOneWidget);
    });

    testWidgets('maintenance when the server says it is down for it', (
      t,
    ) async {
      final client = FakeWorkspaceClient([ws('w1', 'WS')])
        ..listFailure = const WorkspaceException(WorkspaceFailure.maintenance);
      await pumpSignedIn(t, client);
      expect(find.byType(MaintenanceScreen), findsOneWidget);
    });

    testWidgets('another failure keeps the plain error with Retry', (t) async {
      final client = FakeWorkspaceClient([ws('w1', 'WS')])
        ..listFailure = const WorkspaceException(WorkspaceFailure.other);
      await pumpSignedIn(t, client);
      expect(find.byType(NoConnectionScreen), findsNothing);
      expect(find.byKey(const Key('retry-workspaces')), findsOneWidget);
    });

    testWidgets('no access when the project is refused', (t) async {
      final app = await pumpProjects(t, server: _Refusing());
      await app.go(t, '/projects/p1');
      expect(find.byType(NoAccessScreen), findsOneWidget);
    });
  });
}
