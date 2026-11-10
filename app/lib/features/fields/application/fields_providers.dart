import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/fields/data/fields_client.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final fieldsClientProvider = Provider<FieldsClient>(
  (ref) => GrpcFieldsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
  ),
);

/// The active custom fields of one project, in order. Read again after the
/// fields change (`ref.invalidate`) or the user's permissions might have.
final fieldsProvider = FutureProvider.autoDispose
    .family<List<CustomField>, String>((ref, projectId) async {
      ref.watch(refusalCountProvider);
      final workspace = ref.watch(workspaceScopeProvider);
      if (workspace == null) return const [];
      try {
        return await ref.watch(fieldsClientProvider).list(workspace, projectId);
      } on Object catch (e) {
        throw mapFieldError(e);
      }
    }, retry: (_, _) => null);

/// The archived fields still inside their 30 days (for people who may edit
/// fields; others would be refused).
final archivedFieldsProvider = FutureProvider.autoDispose
    .family<List<CustomField>, String>((ref, projectId) async {
      ref.watch(refusalCountProvider);
      final workspace = ref.watch(workspaceScopeProvider);
      if (workspace == null) return const [];
      try {
        final all = await ref
            .watch(fieldsClientProvider)
            .list(workspace, projectId, includeArchived: true);
        return [
          for (final f in all)
            if (f.isArchived) f,
        ];
      } on Object catch (e) {
        throw mapFieldError(e);
      }
    }, retry: (_, _) => null);
