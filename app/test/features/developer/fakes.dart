import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/developer/application/developer_providers.dart';
import 'package:taskforge/features/developer/data/developer_client.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import '../projects/fakes.dart';

const devCatalog = DeveloperCatalog(
  scopes: [
    CatalogItem('tasks:read', 'Read tasks'),
    CatalogItem('tasks:write', 'Write tasks'),
  ],
  events: [
    CatalogItem('task.created', 'A task is created'),
    CatalogItem('task.deleted', 'A task is deleted'),
  ],
);

ApiToken tokenRow(String id, {List<String> scopes = const ['tasks:read']}) =>
    ApiToken(
      id: id,
      name: 'CI',
      prefix: 'tf_ab12',
      scopes: scopes,
      status: 'active',
      expiresAt: '',
      lastUsedAt: '',
      createdAt: '2026-11-01T00:00:00Z',
    );

Webhook hookRow({String projectId = ''}) => Webhook(
  id: 'h1',
  name: 'Build bot',
  url: 'https://example.com/hook',
  secret: 'whsec_1',
  events: const ['task.created'],
  active: true,
  disabledReason: '',
  version: 3,
  lastStatus: '',
  lastAt: '',
  projectId: projectId,
);

Delivery deliveryRow(String id, {DeliveryStatus? status}) => Delivery(
  id: id,
  webhookId: 'h1',
  event: 'task.created',
  eventId: 'e1',
  status: status ?? DeliveryStatus.failed,
  statusCode: 500,
  attempt: 1,
  error: '',
  responseSnippet: 'boom',
  payload: '{}',
  requestHeaders: '',
  nextRetryAt: '',
  createdAt: '2026-11-01T00:00:00Z',
  at: '2026-11-01T00:00:00Z',
  durationMs: 12,
  isResend: false,
);

class FakeDeveloperClient implements DeveloperClient {
  FakeDeveloperClient({
    this.hooks = const [],
    this.deliveryRows = const [],
    this.tokenRows = const [],
  });

  List<Webhook> hooks;
  List<Delivery> deliveryRows;
  List<ApiToken> tokenRows;
  final created = <WebhookDraft>[];
  final updated = <WebhookDraft>[];
  final resent = <String>[];
  final tokenCalls =
      <({String name, List<String> scopes, int expiresInDays})>[];
  DeveloperException? failToken;

  @override
  Future<DeveloperCatalog> catalog(String workspaceId) async => devCatalog;

  @override
  Future<List<ApiToken>> tokens(String workspaceId) async => tokenRows;

  @override
  Future<IssuedToken> createToken(
    String workspaceId, {
    required String name,
    required List<String> scopes,
    required int expiresInDays,
  }) async {
    final fail = failToken;
    if (fail != null) throw fail;
    tokenCalls.add((name: name, scopes: scopes, expiresInDays: expiresInDays));
    return IssuedToken(tokenRow('t9', scopes: scopes), 'tf_secret_once');
  }

  @override
  Future<List<Webhook>> webhooks(String workspaceId) async => hooks;

  @override
  Future<Webhook> createWebhook(String workspaceId, WebhookDraft draft) async {
    created.add(draft);
    return hookRow(projectId: draft.projectId);
  }

  @override
  Future<Webhook> updateWebhook(
    String workspaceId,
    Webhook hook,
    WebhookDraft draft, {
    bool? active,
  }) async {
    updated.add(draft);
    return hook;
  }

  @override
  Future<DeliveryPage> deliveries(
    String workspaceId,
    String webhookId, {
    String before = '',
  }) async => DeliveryPage(deliveryRows, '');

  @override
  Future<Delivery> redeliver(
    String workspaceId,
    String webhookId,
    String deliveryId,
  ) async {
    resent.add(deliveryId);
    return deliveryRow('d-new', status: DeliveryStatus.delivered);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakeDeveloperClient.${invocation.memberName}');
}

/// Pumps [home] with the fakes in place and a roomy window.
Future<void> pumpDeveloper(
  WidgetTester tester,
  Widget home,
  FakeDeveloperClient client, {
  FakeProjectsClient? projects,
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        workspaceScopeProvider.overrideWithValue('w1'),
        developerClientProvider.overrideWithValue(client),
        projectsClientProvider.overrideWithValue(
          projects ?? FakeProjectsClient(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
