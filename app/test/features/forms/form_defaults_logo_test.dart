import 'dart:async';
import 'dart:convert';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grpc/grpc.dart' show ClientChannel;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/forms/data/forms_client.dart';
import 'package:taskforge/features/forms/domain/forms.dart';
import 'package:taskforge/features/forms/presentation/form_builder_screen.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/presentation/logo_picker.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fake_jwt.dart';
import '../fields/fakes.dart';

class _MockAuthApi extends Mock implements AuthApi {}

IntakeForm _form({
  Map<String, String> defaults = const {},
  String logoUrl = '',
  int version = 3,
}) => IntakeForm(
  id: 'f1',
  projectId: 'p1',
  name: 'Bugs',
  description: '',
  token: 'tok',
  questions: const [],
  statusId: '',
  priority: 'none',
  assigneeIds: const [],
  enabled: true,
  requireEmail: false,
  sendConfirmation: true,
  notifyStatus: false,
  brandColor: '',
  logoUrl: logoUrl,
  version: version,
  submissionCount: 0,
  problem: '',
  fieldDefaults: defaults,
);

class _Fake implements FormsClient {
  _Fake(this.form);

  IntakeForm form;
  final updated = <FormDraft>[];
  final logos = <({int version, String filename})>[];

  @override
  Future<List<IntakeForm>> list(String w, {String projectId = ''}) async => [
    form,
  ];

  @override
  Future<IntakeForm> update(String w, IntakeForm existing, FormDraft d) async {
    updated.add(d);
    return existing;
  }

  @override
  Future<({String logoUrl, int version})> uploadLogo(
    String workspaceId,
    IntakeForm form, {
    required List<int> bytes,
    required String filename,
  }) async {
    logos.add((version: form.version, filename: filename));
    return (logoUrl: '/media/forms/logo.png', version: form.version + 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('_Fake.${invocation.memberName}');
}

final _labels = field(
  'f-labels',
  'Labels',
  FieldType.multiselect,
  options: const [
    FieldOption(id: 'o-a', label: 'Urgent'),
    FieldOption(id: 'o-b', label: 'Customer'),
  ],
);
final _kind = field(
  'f-kind',
  'Kind',
  FieldType.select,
  required: true,
  options: const [bug, feature],
);

Future<_Fake> _open(
  WidgetTester tester, {
  IntakeForm? form,
  PickedLogo? picked,
}) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fake = _Fake(form ?? _form());
  final router = GoRouter(
    initialLocation: '/forms/f1',
    routes: [
      GoRoute(
        path: '/forms/:id',
        builder: (_, s) => FormBuilderScreen(formId: s.pathParameters['id']),
      ),
      GoRoute(path: '/forms', builder: (_, _) => const Text('forms list')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workspaceScopeProvider.overrideWithValue('w1'),
        formsClientProvider.overrideWithValue(fake),
        fieldsProvider.overrideWith((ref, id) async => [_labels, _kind]),
        membersProvider.overrideWith((ref) async => const []),
        workflowProvider.overrideWith(
          (ref, id) => Completer<Workflow>().future,
        ),
        logoPickerProvider.overrideWithValue(() async => picked),
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
  await tester.pumpAndSettle();
  return fake;
}

Finder _key(String k) => find.byKey(Key(k));

Future<void> _save(WidgetTester tester) async {
  await tester.tap(_key('save-form'));
  await tester.pumpAndSettle();
}

void main() {
  group('default field values', () {
    testWidgets('offers every project field and sends what was set', (
      tester,
    ) async {
      final fake = await _open(tester);
      await tester.ensureVisible(_key('field-f-labels'));
      expect(_key('field-f-kind'), findsOneWidget);

      await tester.tap(_key('option-o-b'));
      await tester.pumpAndSettle();
      await _save(tester);
      expect(fake.updated.single.fieldDefaults, {'f-labels': 'o-b'});
    });

    testWidgets('opens with the saved defaults and can clear one', (
      tester,
    ) async {
      final fake = await _open(
        tester,
        form: _form(defaults: {'f-labels': 'o-a,o-b'}),
      );
      await tester.ensureVisible(_key('field-f-labels'));
      await tester.tap(_key('option-o-a'));
      await tester.pumpAndSettle();
      await tester.tap(_key('option-o-b'));
      await tester.pumpAndSettle();
      await _save(tester);
      expect(fake.updated.single.fieldDefaults, isEmpty);
    });
  });

  group('logo', () {
    testWidgets('an uploaded image is kept on save, not turned into a link', (
      tester,
    ) async {
      final fake = await _open(
        tester,
        picked: const PickedLogo([1, 2, 3], 'logo.png'),
      );
      await tester.ensureVisible(_key('form-logo-upload'));
      await tester.tap(_key('form-logo-upload'));
      await tester.pumpAndSettle();
      expect(fake.logos.single, (version: 3, filename: 'logo.png'));
      expect(_key('form-logo-clear'), findsOneWidget);
      expect(find.text('Uploaded image'), findsOneWidget);

      await _save(tester);
      expect(fake.updated.single.keepLogo, isTrue);
    });

    testWidgets('a logo nobody touched is not sent back as a link', (
      tester,
    ) async {
      final fake = await _open(
        tester,
        form: _form(logoUrl: '/media/forms/old.png'),
      );
      await _save(tester);
      expect(fake.updated.single.keepLogo, isTrue);
    });

    testWidgets('typing a link replaces the logo with it', (tester) async {
      final fake = await _open(
        tester,
        form: _form(logoUrl: '/media/forms/old.png'),
      );
      await tester.ensureVisible(_key('form-logo'));
      await tester.enterText(_key('form-logo'), 'https://example.com/l.png');
      await _save(tester);
      expect(fake.updated.single.keepLogo, isFalse);
      expect(fake.updated.single.logoUrl, 'https://example.com/l.png');
    });

    testWidgets('a form that is not saved yet cannot take an upload', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/forms/new',
        routes: [
          GoRoute(
            path: '/forms/new',
            builder: (_, _) => const FormBuilderScreen(projectId: 'p1'),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workspaceScopeProvider.overrideWithValue('w1'),
            formsClientProvider.overrideWithValue(_Fake(_form())),
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
      await tester.pumpAndSettle();
      await tester.ensureVisible(_key('form-logo-upload'));
      expect(
        tester.widget<TfButton>(_key('form-logo-upload')).onPressed,
        isNull,
      );
      expect(
        find.text('Save the form first to upload a logo.'),
        findsOneWidget,
      );
    });

    testWidgets('removing the logo saves an empty link', (tester) async {
      final fake = await _open(
        tester,
        form: _form(logoUrl: '/media/forms/old.png'),
      );
      await tester.ensureVisible(_key('form-logo-clear'));
      await tester.tap(_key('form-logo-clear'));
      await tester.pumpAndSettle();
      await _save(tester);
      expect(fake.updated.single.logoUrl, '');
      expect(fake.updated.single.keepLogo, isFalse);
      expect(_key('form-logo-clear'), findsNothing);
    });

    testWidgets('cancelling the picker changes nothing', (tester) async {
      final fake = await _open(tester);
      await tester.ensureVisible(_key('form-logo-upload'));
      await tester.tap(_key('form-logo-upload'));
      await tester.pumpAndSettle();
      expect(fake.logos, isEmpty);
    });
  });

  group('uploadLogo over REST', () {
    late AuthSession session;
    setUp(() async {
      final store = MemoryTokenStore();
      await store.write(
        AuthTokens(
          accessToken: fakeJwt(DateTime.now().add(const Duration(minutes: 10))),
          refreshToken: 'r',
          sessionId: 's',
        ),
      );
      session = AuthSession(api: _MockAuthApi(), store: store);
      await session.restore();
    });

    GrpcFormsClient clientWith(http.Client httpClient) => GrpcFormsClient(
      ClientChannel('127.0.0.1', port: 1),
      session,
      restUrl: 'http://api.test',
      httpClient: httpClient,
    );

    test('posts multipart with the version and the workspace', () async {
      late http.BaseRequest seen;
      final api = MockClient.streaming((request, body) async {
        seen = request;
        final reply = jsonEncode({
          'data': {'id': 'f1', 'logo_url': '/media/l.png', 'version': 4},
        });
        return http.StreamedResponse(Stream.value(utf8.encode(reply)), 200);
      });

      final r = await clientWith(api)
          .uploadLogo('w1', _form(), bytes: [1, 2], filename: 'l.png');

      expect(seen.url.toString(), 'http://api.test/api/v1/forms/f1/logo');
      expect(seen.headers['X-Workspace'], 'w1');
      expect(seen.headers['Authorization'], startsWith('Bearer '));
      expect(r, (logoUrl: '/media/l.png', version: 4));
    });

    test('a stale version is a conflict, a bad image says why', () async {
      final stale = MockClient.streaming(
        (_, _) async => http.StreamedResponse(const Stream.empty(), 409),
      );
      await expectLater(
        clientWith(stale).uploadLogo('w1', _form(), bytes: [1], filename: 'l'),
        throwsA(
          isA<FormsException>().having(
            (e) => e.failure,
            'failure',
            FormsFailure.conflict,
          ),
        ),
      );
      final bad = MockClient.streaming(
        (_, _) async => http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'errors': ['Not an image'],
              }),
            ),
          ),
          400,
        ),
      );
      await expectLater(
        clientWith(bad).uploadLogo('w1', _form(), bytes: [1], filename: 'l'),
        throwsA(
          isA<FormsException>()
              .having((e) => e.failure, 'failure', FormsFailure.invalid)
              .having((e) => e.detail, 'detail', 'Not an image'),
        ),
      );
    });
  });

  test(
    'the changed fields leave the logo link alone while an upload stays',
    () {
      FormDraft draft({bool keep = false}) => FormDraft(
        name: 'n',
        description: '',
        questions: const [],
        statusId: '',
        priority: 'none',
        assigneeIds: const [],
        enabled: true,
        requireEmail: false,
        sendConfirmation: true,
        notifyStatus: false,
        brandColor: '',
        logoUrl: '/media/x.png',
        keepLogo: keep,
      );
      expect(formChangedFields(draft()), contains('logo_url'));
      expect(formChangedFields(draft(keep: true)), isNot(contains('logo_url')));
      expect(formChangedFields(draft(keep: true)), contains('defaults'));
    },
  );
}
