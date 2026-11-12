import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskforge/app.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';

import '../shortcuts/fakes.dart';

import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/application/push.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/data/workspace_client.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/features/workspaces/presentation/logo_picker.dart';

import '../inbox/fakes.dart';
import '../projects/fakes.dart';
import '../roles/fakes.dart';
import '../automations/fakes.dart';
import '../docs/fakes.dart';
import '../sprints/fakes.dart';
import '../time/fakes.dart';

class MockAuthApi extends Mock implements AuthApi {
  @override
  Future<void> logout(String refreshToken) async {}
}

class FakeAccounts implements AccountClient {
  @override
  Future<Account> me() async =>
      const Account(id: 'u1', email: 'zoe@example.com', displayName: 'Zoe');

  @override
  Future<List<SessionInfo>> sessions() async => const [];
}

Workspace ws(String id, String name, {String? slug, bool owner = true}) =>
    Workspace(
      id: id,
      name: name,
      slug: slug ?? slugify(name),
      version: 1,
      isOwner: owner,
    );

/// In-memory server: enforces slug uniqueness, versions and typed confirmation.
class FakeWorkspaceClient implements WorkspaceClient {
  FakeWorkspaceClient([List<Workspace> initial = const []])
    : items = [...initial];

  final List<Workspace> items;
  final deleted = <Workspace>[];
  final takenSlugs = <String>{};
  WorkspaceException? failNext;
  bool failList = false;
  int listCalls = 0;
  int _next = 100;

  void _maybeFail() {
    final e = failNext;
    failNext = null;
    if (e != null) throw e;
  }

  @override
  Future<List<Workspace>> list() async {
    listCalls++;
    if (failList) throw const WorkspaceException(WorkspaceFailure.network);
    return [...items];
  }

  @override
  Future<Workspace> create({required String name, required String slug}) async {
    _maybeFail();
    if (takenSlugs.contains(slug)) {
      throw const WorkspaceException(WorkspaceFailure.slugTaken);
    }
    final w = ws('w${_next++}', name, slug: slug);
    items.add(w);
    return w;
  }

  @override
  Future<Workspace> update(
    String id, {
    required int expectedVersion,
    String? name,
    String? slug,
  }) async {
    _maybeFail();
    if (slug != null && takenSlugs.contains(slug)) {
      throw const WorkspaceException(WorkspaceFailure.slugTaken);
    }
    final i = items.indexWhere((w) => w.id == id);
    final old = items[i];
    final updated = Workspace(
      id: id,
      name: name ?? old.name,
      slug: slug ?? old.slug,
      logo: old.logo,
      version: old.version + 1,
      isOwner: old.isOwner,
    );
    return items[i] = updated;
  }

  @override
  Future<Workspace> delete(String id, {required String confirmation}) async {
    _maybeFail();
    final w = items.firstWhere((w) => w.id == id);
    if (confirmation != w.name) {
      throw const WorkspaceException(WorkspaceFailure.invalid);
    }
    items.remove(w);
    deleted.add(w);
    return w;
  }

  @override
  Future<List<Workspace>> listDeleted() async => [...deleted];

  @override
  Future<Workspace> restore(String id) async {
    final w = deleted.firstWhere((w) => w.id == id);
    deleted.remove(w);
    items.add(w);
    return w;
  }

  @override
  Future<Workspace> uploadLogo(
    Workspace workspace, {
    required List<int> bytes,
    required String filename,
  }) async => throw UnimplementedError();
}

/// Pumps the whole app signed in, with [client] standing in for the server.
Future<ProviderContainer> pumpSignedIn(
  WidgetTester tester,
  FakeWorkspaceClient client, {
  FakeShortcutsClient? shortcuts,
  List<Override> overrides = const [],
  FakeRolesClient? roles,
  FakeProjectsClient? projects,
  FakeInboxClient? inbox,
  FakeTimeClient? time,
  FakeSprintsClient? sprints,
  FakeDocsClient? docs,
  FakeAutomationsClient? automations,
  FakeLocalNotifier? localNotifier,

  /// The live connection: none unless a test brings its own.
  Override? sync,
}) async {
  final store = MemoryTokenStore();
  await store.write(
    const AuthTokens(accessToken: 'a.b.c', refreshToken: 'r', sessionId: 's'),
  );
  final session = AuthSession(api: MockAuthApi(), store: store);
  await session.restore();
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWithValue(session),
      accountClientProvider.overrideWithValue(FakeAccounts()),
      workspaceClientProvider.overrideWithValue(client),
      // By default the caller is Owner where the workspace says so, else Member.
      rolesClientProvider.overrideWithValue(
        roles ??
            FakeRolesClient(
              callerRole: (id) =>
                  client.items.any((w) => w.id == id && !w.isOwner)
                  ? 'Member'
                  : 'Owner',
            ),
      ),
      projectsClientProvider.overrideWithValue(
        projects ?? FakeProjectsClient(),
      ),
      logoPickerProvider.overrideWithValue(() async => null),
      sync ?? syncClientProvider.overrideWithValue(null),
      // Nobody is notified for real: an empty inbox and a notifier that notes.
      inboxClientProvider.overrideWithValue(inbox ?? FakeInboxClient()),
      // Nobody is timed for real either.
      timeClientProvider.overrideWithValue(time ?? FakeTimeClient()),
      sprintsClientProvider.overrideWithValue(sprints ?? FakeSprintsClient()),
      docsClientProvider.overrideWithValue(docs ?? FakeDocsClient()),
      automationsClientProvider.overrideWithValue(
        automations ?? FakeAutomationsClient(),
      ),
      localNotifierProvider.overrideWithValue(
        localNotifier ?? FakeLocalNotifier(),
      ),
      shortcutsClientProvider.overrideWithValue(
        shortcuts ?? FakeShortcutsClient(),
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TaskForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder byKey(String key) => find.byKey(Key(key));
