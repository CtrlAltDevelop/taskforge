import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/version.dart';
import 'package:taskforge/features/system/data/system_client.dart';
import 'package:taskforge/features/system/domain/system.dart';

final systemClientProvider = Provider<SystemClient>(
  (ref) => GrpcSystemClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    AppConfig.restUrl,
  ),
);

/// The server's version and minimum supported client. A failed read is treated as "unknown"
/// by callers: being offline must never lock anyone out.
final serverVersionProvider = FutureProvider<ServerVersion>(
  (ref) => ref.watch(systemClientProvider).serverVersion(),
);

/// Admin only: errors with [SystemFailure.denied] for everyone else.
final systemInfoProvider = FutureProvider.autoDispose<SystemInfo>(
  (ref) => ref.watch(systemClientProvider).info(),
);

/// True when this app is older than the server's minimum (the blocking screen).
final updateRequiredProvider = Provider<bool>(
  (ref) =>
      ref.watch(serverVersionProvider).value?.isUpdateRequired(clientVersion) ??
      false,
);

/// A newer server release exists and this is a desktop app: show the update notice.
final desktopUpdateNoticeProvider = Provider<ServerVersion?>((ref) {
  final server = ref.watch(serverVersionProvider).value;
  if (server == null || !server.isNewerThan(clientVersion)) return null;
  const desktop = {
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  };
  return !kIsWeb && desktop.contains(defaultTargetPlatform) ? server : null;
});
