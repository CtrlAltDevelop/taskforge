import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';
import 'projects_test_support.dart';

bool _enabled(WidgetTester tester, String key) =>
    tester.widget<FilledButton>(byKey(key)).onPressed != null;

Future<Pumped> _settings(
  WidgetTester tester,
  Project p, {
  String role = 'Owner',
}) async {
  final app = await pumpProjects(tester, role: role, projects: [p]);
  await app.go(tester, '/projects/${p.id}/settings');
  return app;
}

void main() {
  group('save button', () {
    testWidgets('a save with no changes re-enables the button', (tester) async {
      await _settings(tester, project('p1', 'Website'));

      await tester.tap(byKey('save-project'));
      await tester.pumpAndSettle();

      expect(_enabled(tester, 'save-project'), isTrue);
    });

    testWidgets('a conflict followed by a failed refresh re-enables it', (
      tester,
    ) async {
      final app = await _settings(tester, project('p1', 'Website'));
      app.projects.editElsewhere('p1');
      app.projects.failListNext = const ProjectException(ProjectFailure.other);

      await tester.enterText(byKey('settings-name'), 'Web');
      await tester.tap(byKey('save-project'));
      await tester.pumpAndSettle();

      expect(_enabled(tester, 'save-project'), isTrue);
    });
  });

  testWidgets('Add me sends an empty user id and the server adds the caller', (
    tester,
  ) async {
    final app = await pumpProjects(
      tester,
      role: 'Admin',
      projects: [project('p1', 'Secret', private: true, isMember: false)],
    );

    await tester.tap(byKey('open-private-projects'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('add-me-p1'));
    await tester.pumpAndSettle();

    expect(app.projects.added.single, (project: 'p1', user: ''));
    expect(app.projects.members['p1']!.single.userId, 'u1');
    expect(byKey('add-me-p1'), findsNothing);
  });

  group('workspace switch', () {
    testWidgets('on a project page lands on Home without stale data', (
      tester,
    ) async {
      final app = await pumpProjects(
        tester,
        projects: [project('p1', 'Website')],
        workspaces: ['w1', 'w2'],
      );
      await app.go(tester, '/projects/p1');
      expect(byKey('project-title'), findsOneWidget);

      await app.container
          .read(selectedWorkspaceIdProvider.notifier)
          .select('w2');
      await tester.pumpAndSettle();

      expect(byKey('project-title'), findsNothing);
      expect(
        app.container
            .read(routerProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        '/',
      );
    });

    testWidgets('the project is not shown while the new catalog loads', (
      tester,
    ) async {
      final app = await pumpProjects(
        tester,
        projects: [project('p1', 'Website')],
        workspaces: ['w1', 'w2'],
      );
      await app.go(tester, '/projects/p1/settings');
      app.projects.holdLists();

      await app.container
          .read(selectedWorkspaceIdProvider.notifier)
          .select('w2');
      await tester.pump();

      expect(byKey('settings-name'), findsNothing);
      app.projects.releaseLists();
    });
  });

  testWidgets('the star is disabled on an archived project', (tester) async {
    final app = await pumpProjects(
      tester,
      projects: [project('p1', 'Old', archived: true)],
    );

    await app.go(tester, '/projects/p1');

    expect(
      tester.widget<IconButton>(byKey('favorite-toggle')).onPressed,
      isNull,
    );
  });

  group('creator rule', () {
    testWidgets('a Member sees the settings controls on their project', (
      tester,
    ) async {
      await _settings(tester, project('p1', 'Website'), role: 'Member');

      expect(byKey('save-project'), findsOneWidget);
      await tester.ensureVisible(byKey('archive-project'));
      expect(byKey('archive-project'), findsOneWidget);
    });

    testWidgets('a Viewer still sees none', (tester) async {
      await _settings(tester, project('p1', 'Website'), role: 'Viewer');

      expect(byKey('save-project'), findsNothing);
      expect(byKey('archive-project'), findsNothing);
    });

    testWidgets('when the server refuses, its reason is shown', (tester) async {
      final app = await _settings(
        tester,
        project('p1', 'Website'),
        role: 'Member',
      );
      app.projects.failNext = const ProjectException(
        ProjectFailure.denied,
        'Only the creator can change this project.',
      );

      await tester.enterText(byKey('settings-name'), 'Web');
      await tester.tap(byKey('save-project'));
      await tester.pumpAndSettle();

      expect(
        find.text('Only the creator can change this project.'),
        findsOneWidget,
      );
      expect(_enabled(tester, 'save-project'), isTrue);
    });

    testWidgets('a Member can manage members of a private project', (
      tester,
    ) async {
      final server = FakeProjectsClient([
        project('p1', 'Secret', private: true),
      ]);
      server.members['p1'] = [
        const ProjectMember(userId: 'u1', displayName: 'Zoe', email: ''),
      ];
      final app = await pumpProjects(tester, role: 'Member', server: server);
      await app.go(tester, '/projects/p1/settings');

      expect(byKey('add-project-member'), findsOneWidget);
    });
  });
}
