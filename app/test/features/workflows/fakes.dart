import 'package:taskforge/features/workflows/data/workflows_client.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';

/// The workflow every project starts with, with ids the task fakes also use.
Workflow defaultWorkflow({
  String projectId = 'p1',
  bool restrict = false,
  bool restrictCreation = false,
  List<WorkflowTransition> transitions = const [],
  int version = 1,
  int doingTasks = 0,
}) => Workflow(
  projectId: projectId,
  restrict: restrict,
  restrictCreation: restrictCreation,
  transitions: transitions,
  version: version,
  statuses: [
    const WorkflowStatus(
      id: 'todo',
      name: 'To do',
      color: '#9E9E9E',
      category: StatusCategory.notStarted,
      isDefault: true,
    ),
    WorkflowStatus(
      id: 'doing',
      name: 'In progress',
      color: '#1E88E5',
      position: 1,
      taskCount: doingTasks,
    ),
    const WorkflowStatus(
      id: 'done',
      name: 'Done',
      color: '#43A047',
      category: StatusCategory.done,
      position: 2,
    ),
  ],
);

/// In-memory workflow server: applies a saved draft the way the real one does
/// (new keys get ids, deleted statuses disappear) and bumps the version.
class FakeWorkflowsClient implements WorkflowsClient {
  FakeWorkflowsClient([Workflow? initial])
    : workflow = initial ?? defaultWorkflow();

  Workflow workflow;
  final saved = <WorkflowDraft>[];
  final validated = <WorkflowDraft>[];
  WorkflowException? failNext;

  /// When set, the next [get] after an [update] fails (to test a conflict
  /// whose follow-up read fails).
  bool failNextGetAfterUpdate = false;
  var _updated = false;

  /// What [validate] answers (the real one runs the server's rules).
  List<WorkflowProblem> problems = const [];

  /// When set, [update] answers with these problems as a refusal.
  List<WorkflowProblem>? rejectWith;
  var _next = 0;

  @override
  Future<Workflow> get(String workspaceId, String projectId) async {
    if (failNextGetAfterUpdate && _updated) {
      failNextGetAfterUpdate = false;
      throw const WorkflowException(WorkflowFailure.network);
    }
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
    return workflow;
  }

  @override
  Future<Workflow> update(
    String workspaceId,
    String projectId,
    WorkflowDraft draft,
    int expectedVersion,
  ) async {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
    final rejected = rejectWith;
    if (rejected != null) {
      throw WorkflowException(WorkflowFailure.invalid, problems: rejected);
    }
    _updated = true;
    if (expectedVersion != workflow.version) {
      throw const WorkflowException(WorkflowFailure.conflict);
    }
    saved.add(draft);
    final ids = {
      for (final s in draft.statuses) s.key: s.isNew ? 'new-${_next++}' : s.key,
    };
    workflow = Workflow(
      projectId: projectId,
      restrict: draft.restrict,
      restrictCreation: draft.restrictCreation,
      version: workflow.version + 1,
      statuses: [
        for (final (i, s) in draft.statuses.indexed)
          WorkflowStatus(
            id: ids[s.key]!,
            name: s.name.trim(),
            color: s.color,
            category: s.category,
            position: i,
            isDefault: s.isDefault,
            taskCount: s.taskCount,
          ),
      ],
      transitions: [
        for (final t in draft.transitions)
          WorkflowTransition(
            from: ids[t.from]!,
            to: ids[t.to]!,
            requiredRoleId: t.requiredRoleId,
            requireAssignee: t.requireAssignee,
            requireSubtasksDone: t.requireSubtasksDone,
          ),
      ],
    );
    return workflow;
  }

  @override
  Future<List<WorkflowProblem>> validate(
    String workspaceId,
    String projectId,
    WorkflowDraft draft,
  ) async {
    validated.add(draft);
    return problems;
  }
}

extension WorkflowCopies on Workflow {
  /// This workflow with [extra] statuses appended (as if someone added them).
  Workflow copyWithStatuses(WorkflowStatus extra) => Workflow(
    projectId: projectId,
    statuses: [...statuses, extra],
    transitions: transitions,
    restrict: restrict,
    restrictCreation: restrictCreation,
    version: version,
  );
}
