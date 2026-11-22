import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import '../chat/fakes.dart';
import '../docs/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';

Finder _crumb(String text) =>
    find.descendant(of: byKey('breadcrumbs'), matching: find.text(text));

void main() {
  Future<Pumped> open(WidgetTester t, String path) async {
    final app = await pumpProjects(
      t,
      projects: [project('p1', 'Web')],
      tasks: FakeTasksClient([task('t1', 'Fix login')]),
      workflows: FakeWorkflowsClient(defaultWorkflow()),
      docs: FakeDocsClient(nodes: [node('d1', 'Runbook')]),
      chat: FakeChatClient(spaces: [space('s1', 'general')]),
    );
    await app.go(t, path);
    return app;
  }

  testWidgets('an open task is named in the trail', (t) async {
    await open(t, '/projects/p1?task=t1');
    expect(_crumb('Fix login'), findsOneWidget);
  });

  testWidgets('a doc is named in the trail', (t) async {
    await open(t, '/docs/d1');
    expect(_crumb('Runbook'), findsOneWidget);
  });

  testWidgets('a chat space is named in the trail', (t) async {
    await open(t, '/chat/s1');
    expect(_crumb('general'), findsOneWidget);
  });

  testWidgets('an unknown doc keeps the generic word', (t) async {
    await open(t, '/docs/missing');
    final l = AppLocalizations.of(t.element(byKey('breadcrumbs')));
    expect(_crumb(l.shellCrumbDoc), findsOneWidget);
  });
}
