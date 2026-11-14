import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/templates/domain/templates.dart';
import 'package:taskforge/gen/infrastructure/templates/grpc/templates.pbgrpc.dart'
    as pb;

/// Templates over gRPC.
abstract interface class TemplatesClient {
  /// The gallery: built-ins, shared and own private templates.
  Future<List<Template>> list(
    String workspaceId, {
    String query = '',
    TemplateKind? kind,
  });

  /// One template with its snapshot.
  Future<Template> get(String workspaceId, String templateId);

  /// Changes the named fields (the server's `changed` names).
  Future<Template> update(
    String workspaceId,
    Template template, {
    String? name,
    String? description,
    TemplateVisibility? visibility,
  });
  Future<void> delete(String workspaceId, String templateId);
  Future<Template> saveFromTask(
    String workspaceId,
    String projectId,
    String taskId,
    SaveDraft draft,
  );
  Future<Template> saveFromProject(
    String workspaceId,
    String projectId,
    SaveDraft draft,
  );
  Future<ApplyResult> apply(String workspaceId, ApplyDraft draft);
}

TemplatesException mapTemplatesError(Object error) {
  if (error is TemplatesException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => TemplatesException(
        TemplatesFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists ||
      StatusCode.aborted => const TemplatesException(TemplatesFailure.conflict),
      StatusCode.permissionDenied => const TemplatesException(
        TemplatesFailure.denied,
      ),
      StatusCode.notFound => const TemplatesException(
        TemplatesFailure.notFound,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const TemplatesException(TemplatesFailure.network),
      _ => const TemplatesException(TemplatesFailure.other),
    };
  }
  return const TemplatesException(TemplatesFailure.other);
}

Template templateFromPb(pb.Template t) => Template(
  id: t.id,
  kind: TemplateKind.parse(t.kind),
  name: t.name,
  description: t.description,
  visibility: TemplateVisibility.parse(t.visibility),
  builtin: t.builtin,
  version: t.version,
  taskCount: t.taskCount,
  variables: List.unmodifiable(t.variables),
  includes: List.unmodifiable(
    t.includes.map(TemplatePart.parse).whereType<TemplatePart>(),
  ),
  statusNames: List.unmodifiable(t.statusNames),
  canEdit: t.canEdit,
  contentJson: t.contentJson,
);

class GrpcTemplatesClient implements TemplatesClient {
  GrpcTemplatesClient(ClientChannelBase channel, this._session)
    : _stub = pb.TemplateControllerClient(channel);

  final pb.TemplateControllerClient _stub;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapTemplatesError(e);
    }
  }

  @override
  Future<List<Template>> list(
    String workspaceId, {
    String query = '',
    TemplateKind? kind,
  }) => _run(() async {
    final r = await _stub.list(
      pb.TemplateListRequest(
        workspaceId: workspaceId,
        query: query.trim(),
        kind: kind?.wire ?? '',
      ),
      options: _options,
    );
    return List.unmodifiable(r.templates.map(templateFromPb));
  });

  @override
  Future<Template> get(String workspaceId, String templateId) => _run(() async {
    final r = await _stub.get(
      pb.TemplateGetRequest(workspaceId: workspaceId, templateId: templateId),
      options: _options,
    );
    return templateFromPb(r.template);
  });

  @override
  Future<Template> update(
    String workspaceId,
    Template template, {
    String? name,
    String? description,
    TemplateVisibility? visibility,
  }) => _run(() async {
    final r = await _stub.update(
      pb.TemplateUpdateRequest(
        workspaceId: workspaceId,
        templateId: template.id,
        expectedVersion: template.version,
        changed: [
          if (name != null) 'name',
          if (description != null) 'description',
          if (visibility != null) 'visibility',
        ],
        name: name?.trim(),
        description: description?.trim(),
        visibility: visibility?.wire,
      ),
      options: _options,
    );
    return templateFromPb(r.template);
  });

  @override
  Future<void> delete(String workspaceId, String templateId) => _run(
    () => _stub.delete(
      pb.TemplateDeleteRequest(
        workspaceId: workspaceId,
        templateId: templateId,
      ),
      options: _options,
    ),
  );

  @override
  Future<Template> saveFromTask(
    String workspaceId,
    String projectId,
    String taskId,
    SaveDraft d,
  ) => _run(() async {
    final r = await _stub.saveFromTask(
      pb.TemplateSaveFromTaskRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        name: d.name.trim(),
        description: d.description.trim(),
        visibility: d.visibility.wire,
        includeAssignees: d.includeAssignees,
      ),
      options: _options,
    );
    return templateFromPb(r.template);
  });

  @override
  Future<Template> saveFromProject(
    String workspaceId,
    String projectId,
    SaveDraft d,
  ) => _run(() async {
    final r = await _stub.saveFromProject(
      pb.TemplateSaveFromProjectRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        name: d.name.trim(),
        description: d.description.trim(),
        visibility: d.visibility.wire,
        include: d.parts.map((p) => p.wire),
        includeAssignees: d.includeAssignees,
      ),
      options: _options,
    );
    return templateFromPb(r.template);
  });

  @override
  Future<ApplyResult> apply(String workspaceId, ApplyDraft d) => _run(() async {
    final r = await _stub.apply(
      pb.TemplateApplyRequest(
        workspaceId: workspaceId,
        templateId: d.templateId,
        projectId: d.projectId,
        parentTaskId: d.parentTaskId,
        projectName: d.projectName.trim(),
        projectKey: d.projectKey.trim(),
        projectDescription: d.projectDescription.trim(),
        projectVisibility: d.projectVisibility,
        startDate: d.startDate,
        variables: d.variables.entries.map(
          (e) => pb.Variable(name: e.key, value: e.value),
        ),
      ),
      options: _options,
    );
    return ApplyResult(
      projectId: r.projectId,
      taskIds: List.unmodifiable(r.taskIds),
      warnings: List.unmodifiable(r.warnings.map((w) => w.message)),
    );
  });
}
