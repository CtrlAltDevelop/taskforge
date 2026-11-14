import 'package:flutter/foundation.dart';

import 'package:taskforge/core/version.dart';

/// What `GET /api/version` says: the server's version and the oldest client it supports.
@immutable
class ServerVersion {
  const ServerVersion({
    required this.version,
    required this.minClientVersion,
    this.commit = '',
  });

  final String version;
  final String minClientVersion;
  final String commit;

  /// The app is older than the server's minimum: it must be updated before use.
  bool isUpdateRequired(String client) =>
      (compareSemVer(client, minClientVersion) ?? 0) < 0;

  /// The server runs a newer release than the app (a gentle notice on desktop).
  bool isNewerThan(String client) => (compareSemVer(version, client) ?? 0) > 0;
}

/// The admin System page: version and the health of the queue.
@immutable
class SystemInfo {
  const SystemInfo({
    required this.version,
    required this.minClientVersion,
    required this.api,
    required this.commit,
    required this.redis,
    required this.broker,
    required this.eager,
    required this.workers,
    required this.backlog,
  });

  final String version;
  final String minClientVersion;
  final String api;
  final String commit;

  /// `ok`, `unavailable` or `not_configured`.
  final String redis;

  /// `ok`, `unavailable` or `in_memory`.
  final String broker;

  /// Tasks run inline (debug): no worker is expected.
  final bool eager;

  /// Celery workers that answered a ping; negative when not applicable.
  final int workers;

  /// Due work whose time has come and is not handled yet, by kind.
  final Map<String, int> backlog;

  int get backlogTotal => backlog.values.fold(0, (a, b) => a + b);
}

enum SystemFailure { denied, network, other }

class SystemException implements Exception {
  const SystemException(this.failure);
  final SystemFailure failure;
}
