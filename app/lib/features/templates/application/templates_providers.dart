import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/templates/data/templates_client.dart';
import 'package:taskforge/features/templates/domain/templates.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final templatesClientProvider = Provider<TemplatesClient>(
  (ref) => GrpcTemplatesClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// The gallery for a search text; the kind filter is part of the key.
typedef GalleryQuery = ({String text, TemplateKind? kind});

final templatesProvider = FutureProvider.autoDispose
    .family<List<Template>, GalleryQuery>((ref, q) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref
          .watch(templatesClientProvider)
          .list(ws, query: q.text, kind: q.kind);
    }, retry: (_, _) => null);

/// One template with its snapshot (for the preview).
final templateProvider = FutureProvider.autoDispose.family<Template, String>((
  ref,
  id,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) throw const TemplatesException(TemplatesFailure.notFound);
  return ref.watch(templatesClientProvider).get(ws, id);
}, retry: (_, _) => null);

/// Applying creates projects and tasks, so the lists that show them reload.
void refreshAfterApply(WidgetRef ref) {
  ref.invalidate(projectsProvider);
}
