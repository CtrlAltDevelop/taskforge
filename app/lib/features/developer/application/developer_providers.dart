import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/developer/data/developer_client.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final developerClientProvider = Provider<DeveloperClient>(
  (ref) => GrpcDeveloperClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

const _empty = DeveloperCatalog(scopes: [], events: []);

/// The scopes and events the server offers.
final developerCatalogProvider = FutureProvider.autoDispose<DeveloperCatalog>((
  ref,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return _empty;
  return ref.watch(developerClientProvider).catalog(ws);
}, retry: (_, _) => null);

/// The caller's own tokens in this workspace.
final apiTokensProvider = FutureProvider.autoDispose<List<ApiToken>>((
  ref,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(developerClientProvider).tokens(ws);
}, retry: (_, _) => null);

/// The workspace's webhooks (the caller must be allowed to manage them).
final webhooksProvider = FutureProvider.autoDispose<List<Webhook>>((ref) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(developerClientProvider).webhooks(ws);
}, retry: (_, _) => null);

/// The first page of a webhook's delivery log.
final deliveriesProvider = FutureProvider.autoDispose
    .family<DeliveryPage, String>((ref, webhookId) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const DeliveryPage([], '');
      return ref.watch(developerClientProvider).deliveries(ws, webhookId);
    }, retry: (_, _) => null);
