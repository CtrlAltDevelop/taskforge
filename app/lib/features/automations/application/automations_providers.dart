import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/automations/data/automations_client.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final automationsClientProvider = Provider<AutomationsClient>(
  (ref) => GrpcAutomationsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// Run history rows shown per read.
const runPageSize = 50;

/// The rules of a project.
final automationsProvider = FutureProvider.autoDispose
    .family<List<Automation>, String>((ref, project) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(automationsClientProvider).list(ws, project);
    }, retry: (_, _) => null);

/// Runs of a project, or of one rule when [rule] is set.
typedef RunsKey = ({String project, String rule});

final automationRunsProvider = FutureProvider.autoDispose
    .family<List<AutomationRun>, RunsKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref
          .watch(automationsClientProvider)
          .runs(ws, key.project, automationId: key.rule, limit: runPageSize);
    }, retry: (_, _) => null);

/// The tasks the dry run may be tried on.
final dryRunTasksProvider = FutureProvider.autoDispose
    .family<List<Task>, String>((ref, project) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      final tasks = await ref
          .watch(tasksClientProvider)
          .list(ws, project)
          .take(200)
          .toList();
      return List.unmodifiable(tasks);
    }, retry: (_, _) => null);

void readAutomationsAgain(Ref ref) {
  ref.invalidate(automationsProvider);
  ref.invalidate(automationRunsProvider);
}

/// What the buttons do. Each call acts on the server, then reads again, even
/// when it failed: a call that timed out may still have happened.
class AutomationActions {
  AutomationActions(this._ref);

  final Ref _ref;

  AutomationsClient get _client => _ref.read(automationsClientProvider);
  String get _ws => _ref.read(workspaceScopeProvider) ?? '';

  Future<T> _then<T>(Future<T> call) async {
    try {
      return await call;
    } finally {
      readAutomationsAgain(_ref);
    }
  }

  Future<Automation> create(
    String project,
    RuleDraft draft, {
    bool enabled = false,
  }) => _then(_client.create(_ws, project, draft, enabled: enabled));

  /// Saves only what changed in [draft] against [rule].
  Future<Automation> save(Automation rule, RuleDraft draft) {
    final fields = changedFields(rule, draft);
    return _then(_client.update(_ws, rule, draft, fields));
  }

  Future<Automation> toggle(Automation rule, bool enabled) =>
      _then(_client.toggle(_ws, rule.projectId, rule.id, enabled: enabled));

  Future<void> delete(Automation rule) =>
      _then(_client.delete(_ws, rule.projectId, rule.id));

  /// Not a write: nothing is read again.
  Future<DryRunResult> dryRun(Automation rule, String taskId) =>
      _client.dryRun(_ws, rule.projectId, rule.id, taskId);
}

final automationActionsProvider = Provider<AutomationActions>(
  AutomationActions.new,
);
