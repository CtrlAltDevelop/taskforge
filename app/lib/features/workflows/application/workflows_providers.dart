import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/workflows/data/workflows_client.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final workflowsClientProvider = Provider<WorkflowsClient>(
  (ref) => GrpcWorkflowsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
    cache: ref.watch(readCacheProvider),
  ),
);

/// The workflow of one project: what task pickers show and the editor starts
/// from. Rebuilt on a workspace switch, a refused call, or [ref.invalidate]
/// after a save.
final workflowProvider = FutureProvider.autoDispose.family<Workflow, String>((
  ref,
  projectId,
) async {
  ref.watch(refusalCountProvider);
  final workspace = ref.watch(workspaceScopeProvider);
  if (workspace == null) {
    throw const WorkflowException(WorkflowFailure.other);
  }
  return ref.watch(workflowsClientProvider).get(workspace, projectId);
}, retry: (_, _) => null);
