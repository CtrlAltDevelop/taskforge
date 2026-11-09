import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';

void main() {
  late FakeWorkspaceClient client;
  late ProviderContainer container;
  var builds = <String?>[];

  /// A stand-in for any later workspace-scoped provider (projects, tasks...).
  final scopedProvider = Provider<String>((ref) {
    final scope = ref.watch(workspaceScopeProvider);
    builds.add(scope);
    return 'data-of-$scope';
  });

  setUp(() async {
    builds = [];
    client = FakeWorkspaceClient([ws('a', 'Alpha'), ws('b', 'Beta')]);
    final store = MemoryTokenStore();
    await store.write(
      const AuthTokens(accessToken: 'a.b.c', refreshToken: 'r', sessionId: 's'),
    );
    final session = AuthSession(api: MockAuthApi(), store: store);
    await session.restore();
    container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWithValue(session),
        workspaceClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);
    await container.read(workspacesProvider.future);
  });

  test(
    'scoped state is rebuilt, not reused, when the workspace changes',
    () async {
      expect(container.listen(scopedProvider, (_, _) {}).read(), 'data-of-a');

      await container.read(selectedWorkspaceIdProvider.notifier).select('b');

      expect(container.read(scopedProvider), 'data-of-b');
      expect(builds, ['a', 'b']);
    },
  );

  test('renaming the current workspace does not reset scoped state', () async {
    container.listen(scopedProvider, (_, _) {});
    final alpha = container.read(currentWorkspaceProvider)!;

    await container
        .read(workspacesProvider.notifier)
        .saveChanges(alpha, name: 'Alpha 2');

    expect(container.read(currentWorkspaceProvider)!.name, 'Alpha 2');
    expect(builds, ['a']);
  });

  test(
    'a remembered workspace that no longer exists falls back to the first',
    () async {
      await container.read(selectedWorkspaceIdProvider.notifier).select('gone');

      expect(container.read(workspaceScopeProvider), 'a');
    },
  );

  test('the remembered choice is restored on the next launch', () async {
    final store = container.read(workspaceStoreProvider);
    await store.write('b');
    final next = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWithValue(
          container.read(authSessionProvider),
        ),
        workspaceClientProvider.overrideWithValue(client),
        workspaceStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(next.dispose);
    await next.read(workspacesProvider.future);

    expect(next.read(workspaceScopeProvider), 'b');
  });
}
