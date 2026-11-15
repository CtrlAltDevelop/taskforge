import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/templates/application/templates_providers.dart';
import 'package:taskforge/features/templates/data/templates_client.dart';
import 'package:taskforge/features/templates/domain/templates.dart';
import 'package:taskforge/features/templates/presentation/template_dialogs.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import '../projects/fakes.dart';

class _FakeTemplates implements TemplatesClient {
  final applied = <ApplyDraft>[];

  @override
  Future<ApplyResult> apply(String workspaceId, ApplyDraft draft) async {
    applied.add(draft);
    return const ApplyResult(projectId: 'p9', taskIds: ['t1'], warnings: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('_FakeTemplates.${invocation.memberName}');
}

const _template = Template(
  id: 'tpl1',
  kind: TemplateKind.project,
  name: 'Client onboarding',
  description: '',
  visibility: TemplateVisibility.workspace,
  builtin: false,
  version: 1,
  taskCount: 2,
  variables: ['client', 'owner'],
  includes: [],
  statusNames: [],
  canEdit: true,
  contentJson: '',
);

Future<_FakeTemplates> _open(
  WidgetTester tester,
  ApplyResult? Function(ApplyResult?) onResult,
) async {
  final fake = _FakeTemplates();
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workspaceScopeProvider.overrideWithValue('w1'),
        templatesClientProvider.overrideWithValue(fake),
        projectsClientProvider.overrideWithValue(FakeProjectsClient()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            key: const Key('open'),
            onPressed: () async =>
                onResult(await showApplyDialog(context, _template)),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('asks for one field per template variable', (tester) async {
    await _open(tester, (r) => r);
    expect(find.byKey(const Key('tpl-var-client')), findsOneWidget);
    expect(find.byKey(const Key('tpl-var-owner')), findsOneWidget);
    expect(find.byKey(const Key('tpl-project-name')), findsOneWidget);
  });

  testWidgets('an empty variable blocks the apply', (tester) async {
    final fake = await _open(tester, (r) => r);
    await tester.enterText(find.byKey(const Key('tpl-var-client')), 'Acme');
    await tester.tap(find.byKey(const Key('tpl-apply')));
    await tester.pumpAndSettle();
    expect(find.text('Required.'), findsOneWidget);
    expect(fake.applied, isEmpty);
  });

  testWidgets('applying sends trimmed variables, the name and a start date', (
    tester,
  ) async {
    ApplyResult? result;
    final fake = await _open(tester, (r) => result = r);
    await tester.enterText(find.byKey(const Key('tpl-var-client')), ' Acme ');
    await tester.enterText(find.byKey(const Key('tpl-var-owner')), 'Zoe');
    await tester.tap(find.byKey(const Key('tpl-apply')));
    await tester.pumpAndSettle();

    final draft = fake.applied.single;
    expect(draft.templateId, 'tpl1');
    expect(draft.variables, {'client': 'Acme', 'owner': 'Zoe'});
    expect(draft.projectName, 'Client onboarding');
    expect(draft.projectKey, isNotEmpty);
    expect(draft.startDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(result?.projectId, 'p9');
  });
}
