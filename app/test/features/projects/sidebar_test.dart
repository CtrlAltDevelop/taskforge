import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';
import 'projects_test_support.dart';

void main() {
  testWidgets('lists favorites first and hides archived projects', (
    tester,
  ) async {
    await pumpProjects(
      tester,
      projects: [
        project('p1', 'Zulu'),
        project('p2', 'Beta', favorite: true),
        project('p3', 'Gone', archived: true),
        project('p4', 'Secret', private: true),
      ],
    );

    expect(find.text('Favorites'), findsOneWidget);
    expect(byKey('project-p3'), findsNothing);
    expect(top(tester, 'project-p2'), lessThan(top(tester, 'project-p1')));
    expect(byKey('private-p4'), findsOneWidget);
    expect(byKey('private-p1'), findsNothing);
    expect(find.text('ZUL'), findsOneWidget);
  });

  testWidgets('tapping a project opens its page', (tester) async {
    await pumpProjects(tester, projects: [project('p1', 'Website')]);

    await tester.tap(byKey('project-p1'));
    await tester.pumpAndSettle();

    expect(find.text('Website'), findsWidgets);
    expect(byKey('project-title'), findsOneWidget);
    expect(byKey('open-project-settings'), findsOneWidget);
  });

  testWidgets('favorite star moves a project to the top', (tester) async {
    await pumpProjects(
      tester,
      projects: [project('p1', 'Alpha'), project('p2', 'Beta')],
    );
    await tester.tap(byKey('project-p2'));
    await tester.pumpAndSettle();

    await tester.tap(byKey('favorite-toggle'));
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
    expect(top(tester, 'project-p2'), lessThan(top(tester, 'project-p1')));
  });

  group('empty state', () {
    testWidgets('invites an Owner to create the first project', (tester) async {
      await pumpProjects(tester);

      expect(find.text('Create your first project'), findsOneWidget);
    });

    testWidgets('a Viewer sees the empty state without the button', (
      tester,
    ) async {
      await pumpProjects(tester, role: 'Viewer');

      expect(byKey('projects-empty'), findsOneWidget);
      expect(find.text('Create your first project'), findsNothing);
      expect(byKey('new-project'), findsNothing);
    });
  });

  testWidgets('a workspace switch reloads the projects', (tester) async {
    final app = await pumpProjects(
      tester,
      projects: [project('p1', 'Website')],
      workspaces: ['w1', 'w2'],
    );
    expect(app.projects.workspaces.toSet(), {'w1'});

    await app.container.read(selectedWorkspaceIdProvider.notifier).select('w2');
    await tester.pumpAndSettle();

    expect(app.projects.workspaces.last, 'w2');
  });

  testWidgets('on a narrow screen the sidebar lives in a drawer', (
    tester,
  ) async {
    await pumpProjects(
      tester,
      projects: [project('p1', 'Website')],
      size: const Size(800, 900),
    );
    expect(byKey('project-p1'), findsNothing);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(byKey('project-p1'), findsOneWidget);

    await tester.tap(byKey('project-p1'));
    await tester.pumpAndSettle();

    expect(byKey('project-title'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
  });

  testWidgets('the roles matrix lists the project permissions', (tester) async {
    final app = await pumpProjects(tester);

    await app.go(tester, '/workspaces/roles');

    expect(find.text('Create projects'), findsOneWidget);
    expect(find.text('See private projects'), findsOneWidget);
  });
}
