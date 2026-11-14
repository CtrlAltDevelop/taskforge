import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/goals/data/goals_client.dart';
import 'package:taskforge/features/goals/domain/goals.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final goalsClientProvider = Provider<GoalsClient>(
  (ref) => GrpcGoalsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// Every goal of the workspace the caller may see, and its folders.
final goalsProvider = FutureProvider.autoDispose<GoalCatalog>((ref) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return GoalCatalog.empty;
  return ref.watch(goalsClientProvider).list(ws);
}, retry: (_, _) => null);

/// A key result's check-ins, newest first.
final checkInsProvider = FutureProvider.autoDispose
    .family<List<CheckIn>, String>((ref, krId) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(goalsClientProvider).checkIns(ws, krId);
    }, retry: (_, _) => null);

/// The key results that count a task ("Contributes to").
final taskContributionsProvider = FutureProvider.autoDispose
    .family<List<Contribution>, String>((ref, taskId) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(goalsClientProvider).forTask(ws, taskId);
    }, retry: (_, _) => null);
