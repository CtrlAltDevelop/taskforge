import 'package:taskforge/core/ui/tf_icons.dart';

import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/forms/data/forms_client.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/forms/presentation/form_builder_screen.dart';
import 'package:taskforge/features/forms/presentation/submissions_screen.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

class _FakeFormsClient implements FormsClient {
  _FakeFormsClient({this.pages = const SubmissionPage([], '')});

  final SubmissionPage pages;
  final created = <FormDraft>[];

  @override
  Future<IntakeForm> create(
    String workspaceId,
    String projectId,
    FormDraft draft,
  ) async {
    created.add(draft);
    return IntakeForm(
      id: 'f1',
      projectId: projectId,
      name: draft.name,
      description: '',
      token: 'tok',
      questions: draft.questions,
      statusId: '',
      priority: 'none',
      assigneeIds: const [],
      enabled: true,
      requireEmail: false,
      sendConfirmation: true,
      notifyStatus: false,
      brandColor: '',
      logoUrl: '',
      version: 1,
      submissionCount: 0,
      problem: '',
    );
  }

  @override
  Future<List<IntakeForm>> list(
    String workspaceId, {
    String projectId = '',
  }) async => const [];

  @override
  Future<SubmissionPage> submissions(
    String workspaceId,
    String formId, {
    String before = '',
  }) async => pages;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('_FakeFormsClient.${invocation.memberName}');
}

Future<void> _pump(WidgetTester tester, _FakeFormsClient client, String start) {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: start,
    routes: [
      GoRoute(
        path: '/forms/new',
        builder: (_, _) => const FormBuilderScreen(projectId: 'p1'),
      ),
      GoRoute(
        path: '/forms/:id/submissions',
        builder: (_, s) => SubmissionsScreen(formId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/forms', builder: (_, _) => const Text('forms list')),
    ],
  );
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        workspaceScopeProvider.overrideWithValue('w1'),
        formsClientProvider.overrideWithValue(client),
        fieldsProvider.overrideWith((ref, id) async => const []),
        membersProvider.overrideWith((ref) async => const []),
        workflowProvider.overrideWith(
          (ref, id) => Completer<Workflow>().future,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
}

List<String> _labels(WidgetTester tester) => [
  for (final tile in tester.widgetList<ListTile>(
    find.descendant(
      of: find.byType(ReorderableListView),
      matching: find.byType(ListTile),
    ),
  ))
    (tile.title! as Text).data!,
];

void main() {
  group('form builder', () {
    testWidgets('starts with a required summary and a details question', (
      tester,
    ) async {
      await _pump(tester, _FakeFormsClient(), '/forms/new');
      await tester.pumpAndSettle();

      expect(_labels(tester), ['Summary', 'Details']);
      expect(find.textContaining('required'), findsOneWidget);
    });

    testWidgets('adds and removes questions; the summary cannot go', (
      tester,
    ) async {
      await _pump(tester, _FakeFormsClient(), '/forms/new');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add-file')));
      await tester.tap(find.byKey(const Key('add-file')));
      await tester.pumpAndSettle();
      expect(_labels(tester), ['Summary', 'Details', 'Attachment']);

      final removers = find.byWidgetPredicate(
        (w) => w.key.toString().contains('remove-q-'),
      );
      expect(removers, findsNWidgets(2), reason: 'none for the summary');
      await tester.tap(removers.last);
      await tester.pumpAndSettle();
      expect(_labels(tester), ['Summary', 'Details']);
    });

    testWidgets('a question can be made required', (tester) async {
      await _pump(tester, _FakeFormsClient(), '/forms/new');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('question-required')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('question-label')), 'Steps');
      await tester.tap(find.byKey(const Key('question-ok')));
      await tester.pumpAndSettle();

      expect(_labels(tester), ['Summary', 'Steps']);
      expect(find.textContaining('required'), findsNWidgets(2));
    });

    testWidgets('dragging a question changes the order that is saved', (
      tester,
    ) async {
      final client = _FakeFormsClient();
      await _pump(tester, client, '/forms/new');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('add-file')));
      await tester.tap(find.byKey(const Key('add-file')));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byIcon(TfIcons.grip.glyph).last,
        const Offset(0, -60),
      );
      await tester.pumpAndSettle();
      expect(_labels(tester), ['Summary', 'Attachment', 'Details']);

      await tester.enterText(find.byKey(const Key('form-name-field')), 'Bugs');
      await tester.tap(find.byKey(const Key('save-form')));
      await tester.pumpAndSettle();

      final saved = client.created.single;
      expect(saved.name, 'Bugs');
      expect(
        [for (final q in saved.questions) q.label],
        ['Summary', 'Attachment', 'Details'],
      );
      expect(saved.questions.first.required, isTrue);
      expect(find.text('forms list'), findsOneWidget);
    });

    testWidgets('saving needs a name', (tester) async {
      final client = _FakeFormsClient();
      await _pump(tester, client, '/forms/new');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save-form')));
      await tester.pumpAndSettle();

      expect(client.created, isEmpty);
      expect(find.text('Give the form a name.'), findsOneWidget);
    });

    testWidgets('the preview shows the questions as a visitor sees them', (
      tester,
    ) async {
      await _pump(tester, _FakeFormsClient(), '/forms/new');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('form-name-field')), 'Bugs');
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(find.text('Bugs'), findsWidgets);
      expect(find.textContaining('Summary'), findsOneWidget);
      expect(find.textContaining('Details'), findsOneWidget);
    });
  });

  group('submissions list', () {
    testWidgets('says when nothing came in', (tester) async {
      await _pump(tester, _FakeFormsClient(), '/forms/f1/submissions');
      await tester.pumpAndSettle();

      expect(
        find.text('Nothing has been sent through this form yet.'),
        findsOneWidget,
      );
    });

    testWidgets('lists reference, task and sender; a deleted task is marked', (
      tester,
    ) async {
      final client = _FakeFormsClient(
        pages: const SubmissionPage([
          Submission(
            id: 's1',
            reference: 'FRM-7',
            projectId: 'p1',
            taskKey: 'APO-3',
            taskTitle: 'Login broken',
            statusName: 'To do',
            email: 'zoe@example.com',
            at: '2026-11-01T10:00:00Z',
          ),
          Submission(
            id: 's2',
            reference: 'FRM-8',
            projectId: 'p1',
            taskKey: '',
            taskTitle: '',
            statusName: '',
            email: '',
            at: '2026-11-02T10:00:00Z',
          ),
        ], ''),
      );
      await _pump(tester, client, '/forms/f1/submissions');
      await tester.pumpAndSettle();

      expect(find.text('APO-3 Login broken'), findsOneWidget);
      expect(find.textContaining('FRM-7'), findsOneWidget);
      expect(find.textContaining('zoe@example.com'), findsOneWidget);
      expect(find.textContaining('FRM-8'), findsOneWidget);
      expect(
        tester.widget<ListTile>(find.byKey(const Key('submission-s2'))).onTap,
        isNull,
      );
    });
  });
}
