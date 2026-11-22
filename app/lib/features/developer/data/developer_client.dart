import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/gen/infrastructure/developer/grpc/developer.pbgrpc.dart'
    as pb;

abstract interface class DeveloperClient {
  Future<DeveloperCatalog> catalog(String workspaceId);
  Future<List<ApiToken>> tokens(
    String workspaceId, {
    String serviceAccountId = '',
  });
  Future<IssuedToken> createToken(
    String workspaceId, {
    required String name,
    required List<String> scopes,
    required int expiresInDays,
    String serviceAccountId = '',
  });
  Future<ApiToken> revokeToken(String workspaceId, String tokenId);

  Future<List<ServiceAccount>> serviceAccounts(String workspaceId);
  Future<ServiceAccount> createServiceAccount(
    String workspaceId, {
    required String name,
    required String roleId,
  });
  Future<ServiceAccount> setServiceAccountRole(
    String workspaceId,
    String accountId,
    String roleId,
  );
  Future<void> deleteServiceAccount(String workspaceId, String accountId);

  Future<List<Webhook>> webhooks(String workspaceId);
  Future<Webhook> createWebhook(String workspaceId, WebhookDraft draft);
  Future<Webhook> updateWebhook(
    String workspaceId,
    Webhook hook,
    WebhookDraft draft, {
    bool? active,
  });
  Future<void> deleteWebhook(String workspaceId, String webhookId);
  Future<Delivery> sendTest(String workspaceId, String webhookId);
  Future<DeliveryPage> deliveries(
    String workspaceId,
    String webhookId, {
    String before = '',
  });
  Future<Delivery> redeliver(
    String workspaceId,
    String webhookId,
    String deliveryId,
  );
}

DeveloperException mapDeveloperError(Object error) {
  if (error is DeveloperException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => DeveloperException(
        DeveloperFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists || StatusCode.aborted => DeveloperException(
        DeveloperFailure.conflict,
        detail: message,
      ),
      StatusCode.permissionDenied => const DeveloperException(
        DeveloperFailure.denied,
      ),
      StatusCode.notFound => const DeveloperException(
        DeveloperFailure.notFound,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const DeveloperException(DeveloperFailure.network),
      _ => const DeveloperException(DeveloperFailure.other),
    };
  }
  return const DeveloperException(DeveloperFailure.other);
}

ApiToken tokenFromPb(pb.ApiToken t) => ApiToken(
  id: t.id,
  name: t.name,
  prefix: t.prefix,
  scopes: List.unmodifiable(t.scopes),
  status: t.status,
  expiresAt: t.expiresAt,
  lastUsedAt: t.lastUsedAt,
  createdAt: t.createdAt,
  serviceAccountId: t.serviceAccountId,
);

ServiceAccount serviceAccountFromPb(pb.ServiceAccount a) => ServiceAccount(
  id: a.id,
  name: a.name,
  userId: a.userId,
  roleId: a.roleId,
  roleName: a.roleName,
  active: a.active,
  tokenCount: a.tokenCount,
  createdAt: a.createdAt,
);

Webhook webhookFromPb(pb.Webhook w) => Webhook(
  id: w.id,
  name: w.name,
  url: w.url,
  secret: w.secret,
  events: List.unmodifiable(w.events),
  active: w.active,
  disabledReason: w.disabledReason,
  version: w.version,
  lastStatus: w.lastStatus,
  lastAt: w.lastAt,
);

Delivery deliveryFromPb(pb.Delivery d) => Delivery(
  id: d.id,
  webhookId: d.webhookId,
  event: d.event,
  eventId: d.eventId,
  status: DeliveryStatus.parse(d.status),
  statusCode: d.statusCode,
  attempt: d.attempt,
  error: d.error,
  responseSnippet: d.responseSnippet,
  payload: d.payloadJson,
  requestHeaders: d.requestHeadersJson,
  nextRetryAt: d.nextRetryAt,
  createdAt: d.createdAt,
  at: d.at,
  durationMs: d.durationMs,
  isResend: d.resendOf.isNotEmpty,
);

class GrpcDeveloperClient implements DeveloperClient {
  GrpcDeveloperClient(ClientChannelBase channel, this._session)
    : _tokens = pb.ApiTokenControllerClient(channel),
      _hooks = pb.WebhookControllerClient(channel),
      _accounts = pb.ServiceAccountControllerClient(channel);

  final pb.ApiTokenControllerClient _tokens;
  final pb.ServiceAccountControllerClient _accounts;
  final pb.WebhookControllerClient _hooks;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapDeveloperError(e);
    }
  }

  @override
  Future<DeveloperCatalog> catalog(String workspaceId) => _run(() async {
    final c = await _tokens.catalog(
      pb.CatalogRequest(workspaceId: workspaceId),
      options: _options,
    );
    List<CatalogItem> items(Iterable<pb.CatalogItem> rows) =>
        List.unmodifiable(rows.map((i) => CatalogItem(i.key, i.label)));
    return DeveloperCatalog(scopes: items(c.scopes), events: items(c.events));
  });

  @override
  Future<List<ApiToken>> tokens(
    String workspaceId, {
    String serviceAccountId = '',
  }) => _run(() async {
    final r = await _tokens.list(
      pb.ApiTokenListRequest(
        workspaceId: workspaceId,
        serviceAccountId: serviceAccountId,
      ),
      options: _options,
    );
    return List.unmodifiable(r.tokens.map(tokenFromPb));
  });

  @override
  Future<IssuedToken> createToken(
    String workspaceId, {
    required String name,
    required List<String> scopes,
    required int expiresInDays,
    String serviceAccountId = '',
  }) => _run(() async {
    final r = await _tokens.create(
      pb.ApiTokenCreateRequest(
        workspaceId: workspaceId,
        name: name.trim(),
        scopes: scopes,
        expiresInDays: expiresInDays,
        serviceAccountId: serviceAccountId,
      ),
      options: _options,
    );
    return IssuedToken(tokenFromPb(r.token), r.secret);
  });

  @override
  Future<ApiToken> revokeToken(String workspaceId, String tokenId) =>
      _run(() async {
        final r = await _tokens.revoke(
          pb.ApiTokenRevokeRequest(workspaceId: workspaceId, tokenId: tokenId),
          options: _options,
        );
        return tokenFromPb(r.token);
      });

  @override
  Future<List<ServiceAccount>> serviceAccounts(String workspaceId) =>
      _run(() async {
        final r = await _accounts.list(
          pb.ServiceAccountListRequest(workspaceId: workspaceId),
          options: _options,
        );
        return List.unmodifiable(r.accounts.map(serviceAccountFromPb));
      });

  @override
  Future<ServiceAccount> createServiceAccount(
    String workspaceId, {
    required String name,
    required String roleId,
  }) => _run(() async {
    final r = await _accounts.create(
      pb.ServiceAccountCreateRequest(
        workspaceId: workspaceId,
        name: name.trim(),
        roleId: roleId,
      ),
      options: _options,
    );
    return serviceAccountFromPb(r.account);
  });

  @override
  Future<ServiceAccount> setServiceAccountRole(
    String workspaceId,
    String accountId,
    String roleId,
  ) => _run(() async {
    final r = await _accounts.setRole(
      pb.ServiceAccountSetRoleRequest(
        workspaceId: workspaceId,
        accountId: accountId,
        roleId: roleId,
      ),
      options: _options,
    );
    return serviceAccountFromPb(r.account);
  });

  @override
  Future<void> deleteServiceAccount(String workspaceId, String accountId) =>
      _run(() async {
        await _accounts.delete(
          pb.ServiceAccountDeleteRequest(
            workspaceId: workspaceId,
            accountId: accountId,
          ),
          options: _options,
        );
      });

  @override
  Future<List<Webhook>> webhooks(String workspaceId) => _run(() async {
    final r = await _hooks.list(
      pb.WebhookListRequest(workspaceId: workspaceId),
      options: _options,
    );
    return List.unmodifiable(r.webhooks.map(webhookFromPb));
  });

  @override
  Future<Webhook> createWebhook(String workspaceId, WebhookDraft draft) =>
      _run(() async {
        final r = await _hooks.create(
          pb.WebhookCreateRequest(
            workspaceId: workspaceId,
            name: draft.name.trim(),
            url: draft.url.trim(),
            events: draft.events,
            projectId: draft.projectId,
          ),
          options: _options,
        );
        return webhookFromPb(r.webhook);
      });

  @override
  Future<Webhook> updateWebhook(
    String workspaceId,
    Webhook hook,
    WebhookDraft draft, {
    bool? active,
  }) => _run(() async {
    final r = await _hooks.update(
      pb.WebhookUpdateRequest(
        workspaceId: workspaceId,
        webhookId: hook.id,
        expectedVersion: hook.version,
        fields: [
          if (active != null)
            'active'
          else ...[
            'name',
            'url',
            'events',
            'project',
          ],
        ],
        name: draft.name.trim(),
        url: draft.url.trim(),
        events: draft.events,
        projectId: draft.projectId,
        active: active ?? hook.active,
      ),
      options: _options,
    );
    return webhookFromPb(r.webhook);
  });

  @override
  Future<void> deleteWebhook(String workspaceId, String webhookId) => _run(
    () async {
      await _hooks.delete(
        pb.WebhookDeleteRequest(workspaceId: workspaceId, webhookId: webhookId),
        options: _options,
      );
    },
  );

  @override
  Future<Delivery> sendTest(String workspaceId, String webhookId) =>
      _run(() async {
        final r = await _hooks.test(
          pb.WebhookTestRequest(workspaceId: workspaceId, webhookId: webhookId),
          options: _options,
        );
        return deliveryFromPb(r.delivery);
      });

  @override
  Future<DeliveryPage> deliveries(
    String workspaceId,
    String webhookId, {
    String before = '',
  }) => _run(() async {
    final r = await _hooks.deliveries(
      pb.DeliveriesRequest(
        workspaceId: workspaceId,
        webhookId: webhookId,
        before: before,
        limit: 30,
      ),
      options: _options,
    );
    return DeliveryPage(
      List.unmodifiable(r.deliveries.map(deliveryFromPb)),
      r.cursor,
    );
  });

  @override
  Future<Delivery> redeliver(
    String workspaceId,
    String webhookId,
    String deliveryId,
  ) => _run(() async {
    final r = await _hooks.redeliver(
      pb.RedeliverRequest(
        workspaceId: workspaceId,
        webhookId: webhookId,
        deliveryId: deliveryId,
      ),
      options: _options,
    );
    return deliveryFromPb(r.delivery);
  });
}
