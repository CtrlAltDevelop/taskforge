import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart'
    show stripErrorTitle;
import 'package:taskforge/gen/infrastructure/tasks/grpc/tasks.pbgrpc.dart'
    as pb;

abstract interface class TasksClient {
  /// Every task of the project in board order, as the server streams them.
  /// Every task of the project in tree order (a parent right before its own
  /// subtasks), as the server streams them.
  Stream<Task> list(String workspaceId, String projectId);
  Future<Task> get(String workspaceId, String projectId, String id);
  Future<Task> create(
    String workspaceId,
    String projectId, {
    required String title,
    TaskPriority priority = TaskPriority.none,
    List<String> assigneeIds = const [],
    String parentId = '',
    Map<String, String> fieldValues = const {},
  });

  /// Makes [task] a subtask of [parentId] (empty: a top-level task), with
  /// everything under it.
  Future<Task> setParent(String workspaceId, Task task, String parentId);

  /// Changes the status only; [includeSubtasks] also moves the open subtasks.
  Future<Task> move(
    String workspaceId,
    Task task,
    String statusId, {
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  });

  /// Sends only the fields of [patch] (a field mask) and [expectedVersion].
  Future<Task> update(
    String workspaceId,
    Task task,
    TaskPatch patch, {
    int? expectedVersion,
    bool overrideBlocked = false,
  });

  /// Live tasks of every project the viewer can open whose title or `KEY-N`
  /// matches [query] (the most recent ones when empty), to pick a link target.
  Future<List<LinkCandidate>> searchTasks(String workspaceId, String query);

  /// The links of [taskId], as that task sees them.
  Future<List<TaskLink>> listLinks(String workspaceId, String taskId);

  /// Links [taskId] to [otherId] as [kind] (from [taskId]'s side) and returns
  /// the task's links. [closeDuplicate] also closes the duplicate.
  Future<List<TaskLink>> addLink(
    String workspaceId,
    String taskId,
    String otherId,
    LinkKind kind, {
    bool closeDuplicate = false,
  });

  Future<List<TaskLink>> removeLink(
    String workspaceId,
    String taskId,
    String linkId,
  );

  /// A task with subtasks needs a [mode]; without one it is a
  /// [TaskFailure.hasSubtasks].
  Future<Task> delete(
    String workspaceId,
    String projectId,
    String id, {
    DeleteMode? mode,
  });
  Future<Task> restore(String workspaceId, String projectId, String id);

  /// Deleted tasks, newest deletion first (needs `task.delete`).
  Future<List<Task>> listTrash(String workspaceId, String projectId);
}

/// Maps a transport failure to a [TaskException]. The gRPC message starts with
/// a `TITLE: ` that tells the refusals apart, read before it is stripped.
TaskException mapTaskError(Object error) {
  if (error is TaskException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.permissionDenied when denied != null => TaskException(
        TaskFailure.denied,
        detail: denied.message,
      ),
      StatusCode.permissionDenied => const TaskException(TaskFailure.forbidden),
      StatusCode.alreadyExists when title == 'PROJECT_ARCHIVED' =>
        const TaskException(TaskFailure.archived),
      StatusCode.alreadyExists when title == 'LINK_CYCLE' => TaskException(
        TaskFailure.linkCycle,
        detail: errorTrailer(error, 'x-error-path-bin'),
      ),
      StatusCode.alreadyExists when title == 'LINK_EXISTS' =>
        const TaskException(TaskFailure.linkExists),
      StatusCode.failedPrecondition when title == 'TASK_BLOCKED' =>
        TaskException(
          TaskFailure.blocked,
          detail: errorTrailer(error, 'x-error-blockers-bin'),
          canOverride:
              errorTrailer(error, 'x-error-can_override-bin') == 'true',
        ),
      StatusCode.failedPrecondition when title == 'TRANSITION_NOT_ALLOWED' =>
        TaskException(
          TaskFailure.transitionNotAllowed,
          detail: errorTrailer(error, 'x-error-reason-bin'),
        ),
      StatusCode.invalidArgument when title == 'HAS_SUBTASKS' => TaskException(
        TaskFailure.hasSubtasks,
        subtaskCount:
            int.tryParse(errorTrailer(error, 'x-error-count-bin')) ?? 0,
      ),
      StatusCode.invalidArgument when title == 'FIELD_REQUIRED' =>
        TaskException(
          TaskFailure.fieldRequired,
          detail: stripErrorTitle(message),
          fieldIds: _fieldIds(errorTrailer(error, 'x-error-fields-bin')),
        ),
      StatusCode.invalidArgument when title == 'SUBTASK_CYCLE' =>
        const TaskException(TaskFailure.cycle),
      StatusCode.invalidArgument => TaskException(
        TaskFailure.invalid,
        detail: stripErrorTitle(message),
      ),
      StatusCode.notFound => const TaskException(TaskFailure.notFound),
      StatusCode.aborted => TaskException(
        TaskFailure.conflict,
        conflict: TaskConflict(
          field: errorTrailer(error, 'x-error-field-bin'),
          current: errorTrailer(error, 'x-error-current-bin'),
          version:
              int.tryParse(errorTrailer(error, 'x-error-version-bin')) ?? 0,
        ),
      ),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const TaskException(TaskFailure.network),
      _ => const TaskException(TaskFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const TaskException(TaskFailure.network);
  }
  return const TaskException(TaskFailure.other);
}

List<String> _fieldIds(String json) {
  try {
    final decoded = jsonDecode(json);
    return decoded is List ? [for (final e in decoded) '$e'] : const [];
  } on FormatException {
    return const [];
  }
}

Task _task(pb.Task t) => Task(
  id: t.id,
  projectId: t.projectId,
  number: t.number,
  displayId: t.displayId,
  title: t.title,
  description: t.description,
  statusId: t.status,
  statusName: t.statusName,
  statusCategory: StatusCategory.parse(t.statusCategory),
  priority: TaskPriority.parse(t.priority),
  startDate: t.startDate,
  dueDate: t.dueDate,
  assigneeIds: List.unmodifiable(t.assigneeIds),
  version: t.version,
  position: t.position,
  deletedAt: t.deletedAt,
  parentId: t.parentId,
  depth: t.depth,
  isBlocked: t.isBlocked,
  blockedBy: List.unmodifiable(t.blockedBy),
  fieldValues: Map.unmodifiable({for (final v in t.fields) v.fieldId: v.value}),
);

TaskLink _link(pb.Link l) => TaskLink(
  id: l.id,
  kind: LinkKind.parse(l.kind),
  restricted: l.restricted,
  otherId: l.otherId,
  otherProjectId: l.otherProjectId,
  otherDisplayId: l.otherDisplayId,
  otherTitle: l.otherTitle,
  otherStatusName: l.otherStatusName,
  otherDone: const {'done', 'cancelled'}.contains(l.otherStatusCategory),
);

class GrpcTasksClient implements TasksClient {
  GrpcTasksClient(ClientChannelBase channel, this._session, {this.onRefusal})
    : _stub = pb.TaskControllerClient(channel),
      _links = pb.LinkControllerClient(channel);

  final pb.TaskControllerClient _stub;
  final pb.LinkControllerClient _links;
  final AuthSession _session;

  /// Called when a mutating call is refused (permissions may be stale).
  final void Function()? onRefusal;

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
      final mapped = mapTaskError(e);
      if (!isRead &&
          (mapped.failure == TaskFailure.denied ||
              mapped.failure == TaskFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  @override
  Stream<Task> list(String workspaceId, String projectId) async* {
    try {
      yield* _stub
          .list(
            pb.TaskListRequest(
              workspaceId: workspaceId,
              projectId: projectId,
              includeSubtasks: true,
            ),
            options: _options,
          )
          .map(_task);
    } on Object catch (e) {
      throw mapTaskError(e);
    }
  }

  @override
  Future<Task> get(String workspaceId, String projectId, String id) async =>
      _task(
        await _run(
          () => _stub.get(
            pb.TaskGetRequest(
              workspaceId: workspaceId,
              projectId: projectId,
              id: id,
            ),
            options: _options,
          ),
          isRead: true,
        ),
      );

  @override
  Future<Task> create(
    String workspaceId,
    String projectId, {
    required String title,
    TaskPriority priority = TaskPriority.none,
    List<String> assigneeIds = const [],
    String parentId = '',
    Map<String, String> fieldValues = const {},
  }) async => _task(
    await _run(
      () => _stub.create(
        pb.TaskCreateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          title: title,
          priority: priority.wire,
          assigneeIds: assigneeIds,
          parentId: parentId,
          fieldValues: [
            for (final e in fieldValues.entries)
              pb.TaskFieldValue(fieldId: e.key, value: e.value),
          ],
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Task> update(
    String workspaceId,
    Task task,
    TaskPatch patch, {
    int? expectedVersion,
    bool overrideBlocked = false,
  }) async => _task(
    await _run(
      () => _stub.update(
        pb.TaskUpdateRequest(
          workspaceId: workspaceId,
          projectId: task.projectId,
          id: task.id,
          expectedVersion: expectedVersion ?? task.version,
          title: patch.title,
          description: patch.description,
          status: patch.status?.id,
          priority: patch.priority?.wire,
          startDate: patch.startDate,
          dueDate: patch.dueDate,
          setAssignees: patch.assigneeIds != null,
          assigneeIds: patch.assigneeIds,
          overrideBlocked: overrideBlocked,
          fieldValues: [
            for (final e
                in (patch.fieldValues ?? const <String, String>{}).entries)
              pb.TaskFieldValue(fieldId: e.key, value: e.value),
          ],
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Task> delete(
    String workspaceId,
    String projectId,
    String id, {
    DeleteMode? mode,
  }) async => _task(
    await _run(
      () => _stub.delete(
        pb.TaskDeleteRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: id,
          mode: mode?.wire,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Task> setParent(
    String workspaceId,
    Task task,
    String parentId,
  ) async => _task(
    await _run(
      () => _stub.setParent(
        pb.TaskSetParentRequest(
          workspaceId: workspaceId,
          projectId: task.projectId,
          id: task.id,
          expectedVersion: task.version,
          parentId: parentId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Task> move(
    String workspaceId,
    Task task,
    String statusId, {
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  }) async => _task(
    await _run(
      () => _stub.move(
        pb.TaskMoveRequest(
          workspaceId: workspaceId,
          projectId: task.projectId,
          id: task.id,
          expectedVersion: task.version,
          status: statusId,
          includeSubtasks: includeSubtasks,
          overrideBlocked: overrideBlocked,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<LinkCandidate>> searchTasks(
    String workspaceId,
    String query,
  ) async {
    final reply = await _run(
      () => _links.searchTasks(
        pb.LinkSearchTasksRequest(workspaceId: workspaceId, query: query),
        options: _options,
      ),
      isRead: true,
    );
    return [
      for (final t in reply.tasks)
        LinkCandidate(
          id: t.id,
          projectId: t.projectId,
          displayId: t.displayId,
          title: t.title,
          statusName: t.statusName,
        ),
    ];
  }

  @override
  Future<List<TaskLink>> listLinks(String workspaceId, String taskId) async {
    final reply = await _run(
      () => _links.listForTask(
        pb.LinkListForTaskRequest(workspaceId: workspaceId, taskId: taskId),
        options: _options,
      ),
      isRead: true,
    );
    return [for (final l in reply.links) _link(l)];
  }

  @override
  Future<List<TaskLink>> addLink(
    String workspaceId,
    String taskId,
    String otherId,
    LinkKind kind, {
    bool closeDuplicate = false,
  }) async {
    final reply = await _run(
      () => _links.add(
        pb.LinkAddRequest(
          workspaceId: workspaceId,
          taskId: taskId,
          otherTaskId: otherId,
          kind: kind.wire,
          closeDuplicate: closeDuplicate,
        ),
        options: _options,
      ),
    );
    return [for (final l in reply.links) _link(l)];
  }

  @override
  Future<List<TaskLink>> removeLink(
    String workspaceId,
    String taskId,
    String linkId,
  ) async {
    final reply = await _run(
      () => _links.remove(
        pb.LinkRemoveRequest(
          workspaceId: workspaceId,
          taskId: taskId,
          id: linkId,
        ),
        options: _options,
      ),
    );
    return [for (final l in reply.links) _link(l)];
  }

  @override
  Future<List<Task>> listTrash(String workspaceId, String projectId) async {
    final reply = await _run(
      () => _stub.listTrash(
        pb.TaskListTrashRequest(workspaceId: workspaceId, projectId: projectId),
        options: _options,
      ),
      isRead: true,
    );
    return [for (final t in reply.tasks) _task(t)];
  }

  @override
  Future<Task> restore(String workspaceId, String projectId, String id) async =>
      _task(
        await _run(
          () => _stub.restore(
            pb.TaskRestoreRequest(
              workspaceId: workspaceId,
              projectId: projectId,
              id: id,
            ),
            options: _options,
          ),
        ),
      );
}
