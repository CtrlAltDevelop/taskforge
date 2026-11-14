import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/version.dart';
import 'package:taskforge/features/system/data/system_client.dart';
import 'package:taskforge/features/system/domain/system.dart';
import 'package:taskforge/features/system/domain/update_feed.dart';

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

/// The newest release the update feed names; null without a feed, off
/// desktop, or when the feed cannot be read (never an error: it is a courtesy).
final latestReleaseProvider = FutureProvider<ReleaseInfo?>((ref) async {
  if (updateFeedUrl.isEmpty || !_isDesktop) return null;
  try {
    final response = await ref
        .watch(updateFeedClientProvider)
        .get(
          Uri.parse(updateFeedUrl),
          headers: const {'Accept': 'application/vnd.github+json'},
        )
        .timeout(const Duration(seconds: 8));
    return response.statusCode == 200
        ? ReleaseInfo.fromJson(response.body)
        : null;
  } on Object {
    return null;
  }
});

final updateFeedClientProvider = Provider<http.Client>((ref) => http.Client());

bool get _isDesktop =>
    !kIsWeb &&
    const {
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    }.contains(defaultTargetPlatform);

/// The version whose notice the user closed this session.
class DismissedUpdate extends Notifier<String> {
  @override
  String build() => '';

  void dismiss(String version) => state = version;
}

final dismissedUpdateProvider = NotifierProvider<DismissedUpdate, String>(
  DismissedUpdate.new,
);

/// A newer release exists and this is a desktop app: show the update notice.
/// The server's own version counts too; the feed adds the download link.
final desktopUpdateNoticeProvider = Provider<UpdateNotice?>((ref) {
  if (!_isDesktop) return null;
  final server = ref.watch(serverVersionProvider).value;
  final release = ref.watch(latestReleaseProvider).value;
  final serverNewer = server != null && server.isNewerThan(clientVersion);
  final releaseNewer = release != null && release.isNewerThan(clientVersion);
  if (!serverNewer && !releaseNewer) return null;
  final newest =
      releaseNewer &&
          (!serverNewer ||
              (compareSemVer(release.version, server.version) ?? 0) >= 0)
      ? release.version
      : server!.version;
  if (ref.watch(dismissedUpdateProvider) == newest) return null;
  return UpdateNotice(
    version: newest,
    downloadUrl: releaseNewer && release.version == newest
        ? release.downloadUrl
        : '',
  );
});
