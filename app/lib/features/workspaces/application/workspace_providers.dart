import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/service_api.dart' show CallOptions;

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/workspaces/data/workspace_client.dart';
import 'package:taskforge/features/workspaces/data/workspace_store.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

/// `main` overrides this with the on-device store.
final workspaceStoreProvider = Provider<WorkspaceStore>(
  (ref) => MemoryWorkspaceStore(),
);

final workspaceClientProvider = Provider<WorkspaceClient>(
  (ref) => GrpcWorkspaceClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    restUrl: AppConfig.restUrl,
    selectedWorkspace: () => ref.read(workspaceScopeProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
    cache: ref.watch(readCacheProvider),
  ),
);

/// The id the user picked, remembered per device. May name a workspace that no
/// longer exists; use [workspaceScopeProvider] for the one actually in force.
final selectedWorkspaceIdProvider =
    AsyncNotifierProvider<SelectedWorkspaceId, String?>(
      SelectedWorkspaceId.new,
    );

class SelectedWorkspaceId extends AsyncNotifier<String?> {
  @override
  Future<String?> build() => ref.read(workspaceStoreProvider).read();

  Future<void> select(String id) async {
    state = AsyncData(id);
    await ref.read(workspaceStoreProvider).write(id);
  }
}

/// The signed-in user's workspaces. Empty (not an error) while signed out, and
/// rebuilt whenever the session changes so one user's list never reaches another.
final workspacesProvider =
    AsyncNotifierProvider<WorkspacesNotifier, List<Workspace>>(
      WorkspacesNotifier.new,
    );

class WorkspacesNotifier extends AsyncNotifier<List<Workspace>> {
  @override
  Future<List<Workspace>> build() async {
    final session = ref.watch(authSessionProvider);
    void onSessionChange() => ref.invalidateSelf();
    session.addListener(onSessionChange);
    ref.onDispose(() => session.removeListener(onSessionChange));
    if (session.status != AuthStatus.signedIn) return const [];
    await ref.read(selectedWorkspaceIdProvider.future);
    return ref.read(workspaceClientProvider).list();
  }

  List<Workspace> get _current => state.value ?? const [];

  Future<Workspace> create({required String name, required String slug}) async {
    final created = await ref
        .read(workspaceClientProvider)
        .create(name: name, slug: slug);
    state = AsyncData([..._current, created]);
    await ref.read(selectedWorkspaceIdProvider.notifier).select(created.id);
    return created;
  }

  Future<Workspace> saveChanges(
    Workspace workspace, {
    String? name,
    String? slug,
  }) async {
    final updated = await ref
        .read(workspaceClientProvider)
        .update(
          workspace.id,
          expectedVersion: workspace.version,
          name: name,
          slug: slug,
        );
    return _replace(updated);
  }

  Future<Workspace> uploadLogo(
    Workspace workspace, {
    required List<int> bytes,
    required String filename,
  }) async => _replace(
    await ref
        .read(workspaceClientProvider)
        .uploadLogo(workspace, bytes: bytes, filename: filename),
  );

  Future<Workspace> delete(Workspace workspace, String confirmation) async {
    await ref
        .read(workspaceClientProvider)
        .delete(workspace.id, confirmation: confirmation);
    state = AsyncData([
      for (final w in _current)
        if (w.id != workspace.id) w,
    ]);
    return workspace;
  }

  Future<Workspace> restore(String id) async {
    final restored = await ref.read(workspaceClientProvider).restore(id);
    state = AsyncData([..._current, restored]);
    await ref.read(selectedWorkspaceIdProvider.notifier).select(restored.id);
    return restored;
  }

  /// Adds a workspace the user just joined and makes it the current one.
  Future<void> adopt(Workspace joined) async {
    final others = [
      for (final w in _current)
        if (w.id != joined.id) w,
    ];
    state = AsyncData([...others, joined]);
    await ref.read(selectedWorkspaceIdProvider.notifier).select(joined.id);
  }

  /// Drops a workspace the user left; the current one falls back to the first.
  void forget(String id) => state = AsyncData([
    for (final w in _current)
      if (w.id != id) w,
  ]);

  /// Re-reads the list, e.g. after a version conflict.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Workspace _replace(Workspace updated) {
    state = AsyncData([
      for (final w in _current) w.id == updated.id ? updated : w,
    ]);
    return updated;
  }
}

/// The caller's recently deleted workspaces. Re-read whenever the live list
/// changes (a delete adds one here, a restore removes one); a failed read is
/// just an empty section, never an error screen.
final deletedWorkspacesProvider = FutureProvider.autoDispose<List<Workspace>>((
  ref,
) async {
  if (ref.watch(workspacesProvider).value == null) return const [];
  try {
    return await ref.read(workspaceClientProvider).listDeleted();
  } on WorkspaceException {
    return const [];
  }
});

/// The workspace in force: the remembered one if it still exists, else the
/// first, else null (the user has none yet).
final currentWorkspaceProvider = Provider<Workspace?>((ref) {
  final all = ref.watch(workspacesProvider).value;
  if (all == null || all.isEmpty) return null;
  final picked = ref.watch(selectedWorkspaceIdProvider).value;
  return all.firstWhere((w) => w.id == picked, orElse: () => all.first);
});

/// The id of the workspace in force. Everything workspace-scoped must watch this
/// (directly or through a provider that does): a switch rebuilds it, discarding
/// the previous workspace's state. Rename and logo changes do not, as the id
/// stays the same.
final workspaceScopeProvider = Provider<String?>(
  (ref) => ref.watch(currentWorkspaceProvider.select((w) => w?.id)),
);

/// gRPC call options for workspace-scoped clients: bearer token plus
/// `x-workspace`. Later phases build their clients with this.
final scopedCallOptionsProvider = Provider<CallOptions>(
  (ref) => scopedCallOptions(
    ref.watch(authSessionProvider),
    () => ref.read(workspaceScopeProvider),
  ),
);
