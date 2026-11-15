import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';
import 'projects_test_support.dart';

Future<void> _open(WidgetTester tester) async {
  await tester.tap(byKey('new-project'));
  await tester.pumpAndSettle();
}

String _keyText(WidgetTester tester) => tester
    .widget<TextField>(
      find.descendant(
        of: byKey('project-key'),
        matching: find.byType(TextField),
      ),
    )
    .controller!
    .text;

void main() {
  testWidgets('derives the key from the name until it is edited', (
    tester,
  ) async {
    await pumpProjects(tester);
    await _open(tester);

    await tester.enterText(byKey('project-name'), 'Web App');
    expect(_keyText(tester), 'WA');

    await tester.enterText(byKey('project-key'), 'web');
    await tester.enterText(byKey('project-name'), 'Website Redesign');
    expect(_keyText(tester), 'WEB');
  });

  testWidgets('shows inline key errors', (tester) async {
    await pumpProjects(tester);
    await _open(tester);
    await tester.enterText(byKey('project-name'), 'Web');

    await tester.enterText(byKey('project-key'), 'w');
    await tester.tap(byKey('create-project'));
    await tester.pumpAndSettle();

    expect(find.textContaining('capital letters'), findsOneWidget);
    expect(byKey('project-name'), findsOneWidget);
  });

  testWidgets('creates a private project and opens it', (tester) async {
    final app = await pumpProjects(tester);
    await _open(tester);
    await tester.enterText(byKey('project-name'), 'Web App');
    await tester.tap(find.text('Private'));
    await tester.tap(byKey('icon-🚀'));
    await tester.pumpAndSettle();

    await tester.tap(byKey('create-project'));
    await tester.pumpAndSettle();

    final created = app.projects.projects.single;
    expect(
      (created.name, created.key, created.isPrivate, created.icon),
      ('Web App', 'WA', true, '🚀'),
    );
    expect(byKey('project-title'), findsOneWidget);
    expect(byKey('project-${created.id}'), findsOneWidget);
  });

  testWidgets('shows the server message when the key is taken', (tester) async {
    await pumpProjects(
      tester,
      projects: [project('p1', 'Website', key: 'WEB')],
    );
    await _open(tester);
    await tester.enterText(byKey('project-name'), 'Web');

    await tester.tap(byKey('create-project'));
    await tester.pumpAndSettle();

    expect(find.textContaining('already used'), findsOneWidget);
    expect(byKey('create-project'), findsOneWidget);
  });
}
