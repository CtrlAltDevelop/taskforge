import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/account/account_client.dart';

final accountClientProvider = Provider<AccountClient>(
  (ref) => GrpcAccountClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

final accountProvider = FutureProvider.autoDispose<Account>(
  (ref) => ref.watch(accountClientProvider).me(),
);

final sessionsProvider = FutureProvider.autoDispose<List<SessionInfo>>(
  (ref) => ref.watch(accountClientProvider).sessions(),
);
