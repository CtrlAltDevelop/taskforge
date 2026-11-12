import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';
import 'package:taskforge/core/offline/read_cache.dart';
import 'package:taskforge/gen/infrastructure/workflows/grpc/workflows.pbgrpc.dart'
    as pb;

abstract interface class WorkflowsClient {
  Future<Workflow> get(String workspaceId, String projectId);

  /// Saves the whole workflow or nothing; [expectedVersion] is the version the
  /// editor started from.
  Future<Workflow> update(
    String workspaceId,
    String projectId,
    WorkflowDraft draft,
    int expectedVersion,
  );

  /// A dry run of [update]: the problems, nothing saved.
  Future<List<WorkflowProblem>> validate(
    String workspaceId,
    String projectId,
    WorkflowDraft draft,
  );
}

/// The problems the server lists in the `x-error-errors-bin` trailer (JSON).
List<WorkflowProblem> parseProblems(String json) {
  if (json.isEmpty) return const [];
  try {
    final list = jsonDecode(json);
    if (list is! List) return const [];
    return [
      for (final p in list)
        if (p is Map)
          WorkflowProblem(
            p['code'] as String? ?? '',
            p['message'] as String? ?? '',
            p['status_key'] as String? ?? '',
          ),
    ];
  } on FormatException {
    return const [];
  }
}

WorkflowException mapWorkflowError(Object error) {
  if (error is WorkflowException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.permissionDenied when denied != null => WorkflowException(
        WorkflowFailure.denied,
        detail: denied.message,
      ),
      StatusCode.permissionDenied => const WorkflowException(
        WorkflowFailure.forbidden,
      ),
      StatusCode.alreadyExists when title == 'PROJECT_ARCHIVED' =>
        const WorkflowException(WorkflowFailure.archived),
      StatusCode.invalidArgument => WorkflowException(
        WorkflowFailure.invalid,
        problems: parseProblems(errorTrailer(error, 'x-error-errors-bin')),
        detail: message,
      ),
      StatusCode.notFound => const WorkflowException(WorkflowFailure.notFound),
      StatusCode.aborted => const WorkflowException(WorkflowFailure.conflict),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const WorkflowException(WorkflowFailure.network),
      _ => const WorkflowException(WorkflowFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const WorkflowException(WorkflowFailure.network);
  }
  return const WorkflowException(WorkflowFailure.other);
}

Workflow _workflow(pb.Workflow w) => Workflow(
  projectId: w.projectId,
  restrict: w.restrictTransitions,
  restrictCreation: w.restrictCreation,
  version: w.version,
  statuses: [
    for (final s in w.statuses)
      WorkflowStatus(
        id: s.id,
        name: s.name,
        color: s.color,
        category: StatusCategory.parse(s.category),
        position: s.position,
        isDefault: s.isDefault,
        taskCount: s.taskCount,
      ),
  ],
  transitions: [
    for (final t in w.transitions)
      WorkflowTransition(
        from: t.fromStatus,
        to: t.toStatus,
        requiredRoleId: t.requiredRoleId,
        requireAssignee: t.requireAssignee,
        requireSubtasksDone: t.requireSubtasksDone,
      ),
  ],
);

class GrpcWorkflowsClient implements WorkflowsClient {
  GrpcWorkflowsClient(
    ClientChannelBase channel,
    this._session, {
    this.onRefusal,
    this.cache,
  }) : _stub = pb.WorkflowControllerClient(channel);

  final pb.WorkflowControllerClient _stub;
  final AuthSession _session;

  /// Called when a mutating call is refused (permissions may be stale).
  final void Function()? onRefusal;

  /// Keeps the last workflow read for when the server cannot be reached.
  final ReadCache? cache;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call, {bool isRead = false}) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      final mapped = mapWorkflowError(e);
      if (!isRead &&
          (mapped.failure == WorkflowFailure.denied ||
              mapped.failure == WorkflowFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  List<pb.StatusInput> _statuses(WorkflowDraft d) => [
    for (final s in d.statuses)
      pb.StatusInput(
        key: s.key,
        name: s.name.trim(),
        color: s.color,
        category: s.category.wire,
        isDefault: s.isDefault,
      ),
  ];

  List<pb.TransitionInput> _transitions(WorkflowDraft d) => [
    for (final t in d.transitions)
      pb.TransitionInput(
        fromKey: t.from,
        toKey: t.to,
        requiredRoleId: t.requiredRoleId,
        requireAssignee: t.requireAssignee,
        requireSubtasksDone: t.requireSubtasksDone,
      ),
  ];

  List<pb.MigrationInput> _migrations(WorkflowDraft d) => [
    for (final e in d.migrations.entries)
      pb.MigrationInput(fromKey: e.key, toKey: e.value),
  ];

  @override
  Future<Workflow> get(String workspaceId, String projectId) async => _workflow(
    await _run(
      () => readThrough(
        cache,
        workspaceId,
        'workflow:$projectId',
        () => _stub.get(
          pb.WorkflowGetRequest(workspaceId: workspaceId, projectId: projectId),
          options: _options,
        ),
        pb.Workflow.fromBuffer,
      ),
      isRead: true,
    ),
  );

  @override
  Future<Workflow> update(
    String workspaceId,
    String projectId,
    WorkflowDraft draft,
    int expectedVersion,
  ) async => _workflow(
    await _run(
      () => _stub.update(
        pb.WorkflowUpdateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          expectedVersion: expectedVersion,
          restrictTransitions: draft.restrict,
          restrictCreation: draft.restrictCreation,
          statuses: _statuses(draft),
          transitions: _transitions(draft),
          migrations: _migrations(draft),
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<WorkflowProblem>> validate(
    String workspaceId,
    String projectId,
    WorkflowDraft draft,
  ) async {
    final reply = await _run(
      () => _stub.validate(
        pb.WorkflowValidateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          restrictTransitions: draft.restrict,
          restrictCreation: draft.restrictCreation,
          statuses: _statuses(draft),
          transitions: _transitions(draft),
          migrations: _migrations(draft),
        ),
        options: _options,
      ),
      isRead: true,
    );
    return [
      for (final p in reply.problems)
        WorkflowProblem(p.code, p.message, p.statusKey),
    ];
  }
}
