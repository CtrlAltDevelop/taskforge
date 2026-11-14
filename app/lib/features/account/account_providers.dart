import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/sessions_api.dart';

final accountClientProvider = Provider<AccountClient>(
  (ref) => GrpcAccountClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

final accountProvider = FutureProvider.autoDispose<Account>(
  (ref) => ref.watch(accountClientProvider).me(),
);

/// The session list and rename, over REST (every request carries a DPoP proof via the shared
/// HTTP client).
final sessionsApiProvider = Provider<SessionsApi>(
  (ref) => HttpSessionsApi(AppConfig.restUrl, ref.watch(authSessionProvider)),
);

final sessionsProvider = FutureProvider.autoDispose<List<SessionInfo>>(
  (ref) => ref.watch(sessionsApiProvider).list(),
);
