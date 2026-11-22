import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// An API token as listed. The secret is never part of it (see [IssuedToken]).
@immutable
class ApiToken {
  const ApiToken({
    required this.id,
    required this.name,
    required this.prefix,
    required this.scopes,
    required this.status,
    required this.expiresAt,
    required this.lastUsedAt,
    required this.createdAt,
    this.serviceAccountId = '',
  });

  final String id;
  final String name;
  final String prefix;
  final List<String> scopes;

  /// `active`, `expired` or `revoked`.
  final String status;
  final String expiresAt;
  final String lastUsedAt;
  final String createdAt;

  /// The service account this token acts as; empty for a personal token.
  final String serviceAccountId;

  bool get isActive => status == 'active';
}

/// A non-person identity of the workspace whose tokens act with its [roleName].
@immutable
class ServiceAccount {
  const ServiceAccount({
    required this.id,
    required this.name,
    required this.userId,
    required this.roleId,
    required this.roleName,
    required this.active,
    required this.tokenCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String userId;
  final String roleId;
  final String roleName;
  final bool active;
  final int tokenCount;
  final String createdAt;
}

/// A token just made: [secret] exists here and nowhere else, once.
@immutable
class IssuedToken {
  const IssuedToken(this.token, this.secret);

  final ApiToken token;
  final String secret;
}

@immutable
class Webhook {
  const Webhook({
    required this.id,
    required this.name,
    required this.url,
    required this.secret,
    required this.events,
    required this.active,
    required this.disabledReason,
    required this.version,
    required this.lastStatus,
    required this.lastAt,
    this.projectId = '',
  });

  final String id;
  final String name;
  final String url;
  final String secret;
  final List<String> events;
  final bool active;
  final String disabledReason;
  final int version;
  final String lastStatus;
  final String lastAt;

  /// The one project this hook is limited to; empty means the whole workspace.
  final String projectId;

  String get title => name.isEmpty ? url : name;
}

enum DeliveryStatus {
  delivered,
  pending,
  failed,
  gaveUp,
  other;

  static DeliveryStatus parse(String raw) => switch (raw) {
    'delivered' => delivered,
    'pending' => pending,
    'failed' => failed,
    'gave_up' => gaveUp,
    _ => other,
  };
}

@immutable
class Delivery {
  const Delivery({
    required this.id,
    required this.webhookId,
    required this.event,
    required this.eventId,
    required this.status,
    required this.statusCode,
    required this.attempt,
    required this.error,
    required this.responseSnippet,
    required this.payload,
    required this.requestHeaders,
    required this.nextRetryAt,
    required this.createdAt,
    required this.at,
    required this.durationMs,
    required this.isResend,
  });

  final String id;
  final String webhookId;
  final String event;
  final String eventId;
  final DeliveryStatus status;

  /// The receiver's HTTP status, 0 when it never answered.
  final int statusCode;
  final int attempt;
  final String error;
  final String responseSnippet;
  final String payload;
  final String requestHeaders;
  final String nextRetryAt;
  final String createdAt;
  final String at;
  final int durationMs;
  final bool isResend;
}

@immutable
class DeliveryPage {
  const DeliveryPage(this.deliveries, this.cursor);

  final List<Delivery> deliveries;

  /// Pass as `before` for the next page; empty at the end.
  final String cursor;
}

/// The scopes and events the server knows, in its order.
@immutable
class DeveloperCatalog {
  const DeveloperCatalog({required this.scopes, required this.events});

  final List<CatalogItem> scopes;
  final List<CatalogItem> events;
}

@immutable
class CatalogItem {
  const CatalogItem(this.key, this.label);

  final String key;

  /// The server's English label: the fallback for a key this app has no text for.
  final String label;
}

/// A webhook as the editor builds it.
@immutable
class WebhookDraft {
  const WebhookDraft({
    this.name = '',
    this.url = '',
    this.events = const [],
    this.projectId = '',
  });

  final String name;
  final String url;
  final List<String> events;

  /// Empty means the whole workspace.
  final String projectId;
}

enum DeveloperFailure { network, denied, invalid, notFound, conflict, other }

class DeveloperException implements Exception {
  const DeveloperException(this.failure, {this.detail});

  final DeveloperFailure failure;
  final String? detail;

  @override
  String toString() => 'DeveloperException($failure)';
}

String developerErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! DeveloperException) return t.grpLGeneric;
  final detail = error.detail;
  final hasDetail = detail != null && detail.isNotEmpty;
  return switch (error.failure) {
    DeveloperFailure.network => t.grpLNetCheckShort,
    DeveloperFailure.denied => t.devDenied,
    DeveloperFailure.notFound => t.grpLGone,
    DeveloperFailure.conflict => hasDetail ? detail : t.grpLGeneric,
    DeveloperFailure.invalid => hasDetail ? detail : t.grpLNotValid,
    DeveloperFailure.other => t.grpLGeneric,
  };
}

String scopeLabel(AppLocalizations t, CatalogItem item) => switch (item.key) {
  'workspaces:read' => t.devScopeWorkspacesRead,
  'projects:read' => t.devScopeProjectsRead,
  'projects:write' => t.devScopeProjectsWrite,
  'tasks:read' => t.devScopeTasksRead,
  'tasks:write' => t.devScopeTasksWrite,
  'comments:read' => t.devScopeCommentsRead,
  'comments:write' => t.devScopeCommentsWrite,
  _ => item.label,
};

String eventLabel(AppLocalizations t, String key, [String fallback = '']) =>
    switch (key) {
      'task.created' => t.devEventTaskCreated,
      'task.updated' => t.devEventTaskUpdated,
      'task.status_changed' => t.devEventTaskStatus,
      'task.assigned' => t.devEventTaskAssigned,
      'task.deleted' => t.devEventTaskDeleted,
      'comment.created' => t.devEventCommentCreated,
      'comment.updated' => t.devEventCommentUpdated,
      'comment.deleted' => t.devEventCommentDeleted,
      'webhook.ping' => t.devEventPing,
      _ => fallback.isEmpty ? key : fallback,
    };

String deliveryStatusLabel(AppLocalizations t, DeliveryStatus status) =>
    switch (status) {
      DeliveryStatus.delivered => t.devStatusDelivered,
      DeliveryStatus.pending => t.devStatusPending,
      DeliveryStatus.failed => t.devStatusFailed,
      DeliveryStatus.gaveUp => t.devStatusGaveUp,
      DeliveryStatus.other => '',
    };
