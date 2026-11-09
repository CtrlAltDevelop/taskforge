import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/projects/domain/projects.dart';

import 'fakes.dart';
import 'projects_test_support.dart';

bool _fieldEnabled(WidgetTester tester, String key) =>
    tester
        .widget<TextField>(
          find.descendant(of: byKey(key), matching: find.byType(TextField)),
        )
        .enabled ??
    true;

bool _switchOn(WidgetTester tester, String key) =>
    tester.widget<SwitchListTile>(byKey(key)).value;

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
  group('general', () {
    testWidgets('saves only what changed', (tester) async {
      final app = await _settings(tester, project('p1', 'Website'));

      await tester.enterText(byKey('settings-name'), 'Web');
      await tester.tap(byKey('save-project'));
      await tester.pumpAndSettle();

      expect(app.projects.projects.single.name, 'Web');
      expect(app.projects.projects.single.version, 2);
      expect(find.text('Project updated.'), findsOneWidget);
    });

    testWidgets('the key is disabled once tasks exist', (tester) async {
      await _settings(tester, project('p1', 'Website', taskCounter: 3));

      expect(_fieldEnabled(tester, 'settings-key'), isFalse);
      expect(_fieldEnabled(tester, 'settings-name'), isTrue);
      expect(find.textContaining('already use it'), findsOneWidget);
    });

    testWidgets('the key is editable before the first task', (tester) async {
      await _settings(tester, project('p1', 'Website'));

      expect(_fieldEnabled(tester, 'settings-key'), isTrue);
    });
  });

  group('features', () {
    testWidgets('lists each feature with its explanation', (tester) async {
      await _settings(tester, project('p1', 'Website', enabled: {'sprints'}));

      expect(find.text('Sprints'), findsOneWidget);
      expect(find.text('Log time spent on tasks.'), findsOneWidget);
      expect(_switchOn(tester, 'feature-sprints'), isTrue);
      expect(_switchOn(tester, 'feature-time_tracking'), isFalse);
    });

    testWidgets('a toggle persists with the loaded version', (tester) async {
      final app = await _settings(tester, project('p1', 'Website'));

      await tester.tap(byKey('feature-time_tracking'));
      await tester.pumpAndSettle();

      expect(app.projects.featureCalls.single.keys, {'time_tracking'});
      expect(app.projects.featureCalls.single.expectedVersion, 1);
      expect(_switchOn(tester, 'feature-time_tracking'), isTrue);
    });

    testWidgets('a stale version shows the conflict message and reloads', (
      tester,
    ) async {
      final app = await _settings(tester, project('p1', 'Website'));
      app.projects.editElsewhere('p1');

      await tester.tap(byKey('feature-sprints'));
      await tester.pumpAndSettle();

      expect(find.textContaining('changed in the meantime'), findsOneWidget);
      expect(_switchOn(tester, 'feature-sprints'), isFalse);

      await tester.tap(byKey('feature-sprints'));
      await tester.pumpAndSettle();
      expect(app.projects.featureCalls.last.expectedVersion, 2);
      expect(_switchOn(tester, 'feature-sprints'), isTrue);
    });
  });

  group('private members', () {
    Future<Pumped> privateProject(WidgetTester tester) async {
      final server = FakeProjectsClient([
        project('p1', 'Secret', private: true),
      ]);
      server.members['p1'] = [
        const ProjectMember(
          userId: 'u1',
          displayName: 'Zoe',
          email: 'zoe@example.com',
        ),
      ];
      final app = await pumpProjects(tester, server: server);
      await app.go(tester, '/projects/p1/settings');
      return app;
    }

    testWidgets('open projects have no members section', (tester) async {
      await _settings(tester, project('p1', 'Website'));

      expect(byKey('add-project-member'), findsNothing);
    });

    testWidgets('adds a workspace member, then removes them', (tester) async {
      final app = await privateProject(tester);

      await tester.ensureVisible(byKey('add-project-member'));
      await tester.tap(byKey('add-project-member'));
      await tester.pumpAndSettle();
      expect(byKey('pick-member-u1'), findsNothing);
      await tester.tap(byKey('pick-member-u2'));
      await tester.pumpAndSettle();

      expect(app.projects.added.single.user, 'u2');
      expect(byKey('project-member-u2'), findsOneWidget);

      await tester.tap(byKey('remove-project-member-u2'));
      await tester.pumpAndSettle();

      expect(app.projects.removed.single.user, 'u2');
      expect(byKey('project-member-u2'), findsNothing);
    });

    testWidgets('removing the last member shows the server rule', (
      tester,
    ) async {
      await privateProject(tester);

      await tester.tap(byKey('remove-project-member-u1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('at least one member'), findsOneWidget);
      expect(byKey('project-member-u1'), findsOneWidget);
    });
  });

  group('archive and restore', () {
    testWidgets('archiving makes the project read-only; restoring undoes it', (
      tester,
    ) async {
      final app = await _settings(tester, project('p1', 'Website'));

      await tester.ensureVisible(byKey('archive-project'));
      await tester.tap(byKey('archive-project'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('confirm-archive'));
      await tester.pumpAndSettle();

      expect(app.projects.projects.single.isArchived, isTrue);
      expect(byKey('archived-banner'), findsOneWidget);
      expect(_fieldEnabled(tester, 'settings-name'), isFalse);
      expect(byKey('save-project'), findsNothing);
      expect(
        tester.widget<SwitchListTile>(byKey('feature-sprints')).onChanged,
        isNull,
      );

      await tester.tap(byKey('banner-restore'));
      await tester.pumpAndSettle();

      expect(app.projects.projects.single.isArchived, isFalse);
      expect(byKey('archived-banner'), findsNothing);
    });

    testWidgets('the archived list opens a project and restores it', (
      tester,
    ) async {
      final app = await pumpProjects(
        tester,
        projects: [project('p1', 'Old', archived: true)],
      );

      await tester.tap(byKey('open-archived'));
      await tester.pumpAndSettle();
      expect(byKey('archived-p1'), findsOneWidget);
      await tester.tap(byKey('restore-p1'));
      await tester.pumpAndSettle();

      expect(app.projects.projects.single.isArchived, isFalse);
      expect(byKey('archived-empty'), findsOneWidget);
    });

    testWidgets('an archived project opens read-only with a banner', (
      tester,
    ) async {
      final app = await pumpProjects(
        tester,
        projects: [project('p1', 'Old', archived: true)],
      );

      await app.go(tester, '/projects/p1');

      expect(byKey('archived-banner'), findsOneWidget);
      expect(byKey('banner-restore'), findsOneWidget);
    });
  });

  group('gating', () {
    Future<void> check(
      WidgetTester tester,
      String role, {
      required bool update,
      required bool archive,
    }) async {
      await _settings(tester, project('p1', 'Website'), role: role);
      expect(byKey('save-project'), update ? findsOneWidget : findsNothing);
      expect(_fieldEnabled(tester, 'settings-name'), update);
      expect(
        tester.widget<SwitchListTile>(byKey('feature-sprints')).onChanged !=
            null,
        update,
      );
      expect(byKey('archive-project'), archive ? findsOneWidget : findsNothing);
    }

    testWidgets('a Viewer cannot edit or archive', (tester) async {
      await check(tester, 'Viewer', update: false, archive: false);
    });

    // Members hold project.create, so they may manage projects they created;
    // the server decides (see review_fixes_test.dart).
    testWidgets('a Member sees the controls', (tester) async {
      await check(tester, 'Member', update: true, archive: true);
    });

    testWidgets('an Admin can edit and archive', (tester) async {
      await check(tester, 'Admin', update: true, archive: true);
    });

    testWidgets('an Owner can edit and archive', (tester) async {
      await check(tester, 'Owner', update: true, archive: true);
    });

    testWidgets('only members and up can create projects', (tester) async {
      await pumpProjects(tester, role: 'Member');
      expect(byKey('new-project'), findsOneWidget);
    });
  });

  group('private projects list', () {
    Future<Pumped> adminList(WidgetTester tester, String role) async {
      return pumpProjects(
        tester,
        role: role,
        projects: [
          project('p1', 'Secret', private: true, isMember: false),
          project('p2', 'Mine', private: true),
        ],
      );
    }

    testWidgets('shows what cannot be opened and adds the admin', (
      tester,
    ) async {
      final app = await adminList(tester, 'Admin');
      expect(byKey('project-p1'), findsNothing);

      await tester.tap(byKey('open-private-projects'));
      await tester.pumpAndSettle();
      expect(byKey('add-me-p2'), findsNothing);
      await tester.tap(byKey('add-me-p1'));
      await tester.pumpAndSettle();

      expect(app.projects.added.single, (project: 'p1', user: ''));
      expect(byKey('add-me-p1'), findsNothing);
      expect(byKey('project-p1'), findsOneWidget);
    });

    testWidgets('a Member has no link to it', (tester) async {
      await adminList(tester, 'Member');

      expect(byKey('open-private-projects'), findsNothing);
    });
  });
}
