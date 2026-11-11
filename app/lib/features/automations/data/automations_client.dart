import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/gen/infrastructure/automations/grpc/automations.pbgrpc.dart'
    as pb;

abstract interface class AutomationsClient {
  Future<List<Automation>> list(String workspaceId, String projectId);
  Future<Automation> create(
    String workspaceId,
    String projectId,
    RuleDraft draft, {
    bool enabled = false,
  });

  /// Only the named [fields] change (`name`, `trigger`, `condition`,
  /// `actions`); a stale [expectedVersion] is a conflict.
  Future<Automation> update(
    String workspaceId,
    Automation rule,
    RuleDraft draft,
    List<String> fields,
  );
  Future<Automation> toggle(
    String workspaceId,
    String projectId,
    String automationId, {
    required bool enabled,
  });
  Future<void> delete(
    String workspaceId,
    String projectId,
    String automationId,
  );
  Future<DryRunResult> dryRun(
    String workspaceId,
    String projectId,
    String automationId,
    String taskId,
  );

  /// Newest first; [before] pages (a `started_at` text from the last run).
  Future<List<AutomationRun>> runs(
    String workspaceId,
    String projectId, {
    String automationId = '',
    String taskId = '',
    String status = '',
    String before = '',
    int limit = 0,
  });
}

AutomationException mapAutomationError(Object error) {
  if (error is AutomationException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => AutomationException(
        AutomationFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists || StatusCode.aborted => AutomationException(
        AutomationFailure.conflict,
        detail: message,
      ),
      StatusCode.permissionDenied => const AutomationException(
        AutomationFailure.denied,
      ),
      StatusCode.notFound => const AutomationException(
        AutomationFailure.notFound,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const AutomationException(AutomationFailure.network),
      _ => const AutomationException(AutomationFailure.other),
    };
  }
  return const AutomationException(AutomationFailure.network);
}

Automation automationFromPb(pb.Automation a) => Automation(
  id: a.id,
  projectId: a.projectId,
  name: a.name,
  enabled: a.enabled,
  trigger: decodeTrigger(a.triggerJson),
  condition: a.conditionTfql,
  actions: decodeActions(a.actionsJson),
  ownerId: a.ownerId,
  disabledReason: a.disabledReason,
  version: a.version,
  lastRunAt: a.lastRunAt,
  lastRunStatus: a.lastRunStatus,
);

AutomationRun runFromPb(pb.AutomationRun r) => AutomationRun(
  id: r.id,
  automationId: r.automationId,
  automationName: r.automationName,
  status: RunStatus.tryParse(r.status),
  rawStatus: r.status,
  taskId: r.taskId,
  taskKey: r.taskKey,
  depth: r.depth,
  steps: decodeSteps(r.stepsJson),
  error: r.error,
  explanation: r.explanation,
  startedAt: r.startedAt,
  finishedAt: r.finishedAt,
);

class GrpcAutomationsClient implements AutomationsClient {
  GrpcAutomationsClient(ClientChannelBase channel, this._session)
    : _client = pb.AutomationControllerClient(channel),
      _runs = pb.AutomationRunControllerClient(channel);

  final pb.AutomationControllerClient _client;
  final pb.AutomationRunControllerClient _runs;
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
      throw mapAutomationError(e);
    }
  }

  @override
  Future<List<Automation>> list(String workspaceId, String projectId) =>
      _run(() async {
        final a = await _client.list(
          pb.AutomationListRequest(
            workspaceId: workspaceId,
            projectId: projectId,
          ),
          options: _options,
        );
        return List.unmodifiable(a.automations.map(automationFromPb));
      });

  @override
  Future<Automation> create(
    String workspaceId,
    String projectId,
    RuleDraft draft, {
    bool enabled = false,
  }) => _run(
    () async => automationFromPb(
      (await _client.create(
        pb.AutomationCreateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          name: draft.name.trim(),
          triggerJson: _json(draft.trigger.toJson()),
          conditionTfql: draft.condition.trim(),
          actionsJson: encodeActions(draft.actions),
          enabled: enabled,
        ),
        options: _options,
      )).automation,
    ),
  );

  @override
  Future<Automation> update(
    String workspaceId,
    Automation rule,
    RuleDraft draft,
    List<String> fields,
  ) => _run(
    () async => automationFromPb(
      (await _client.update(
        pb.AutomationUpdateRequest(
          workspaceId: workspaceId,
          projectId: rule.projectId,
          automationId: rule.id,
          fields: fields,
          expectedVersion: rule.version,
          name: draft.name.trim(),
          triggerJson: _json(draft.trigger.toJson()),
          conditionTfql: draft.condition.trim(),
          actionsJson: encodeActions(draft.actions),
        ),
        options: _options,
      )).automation,
    ),
  );

  @override
  Future<Automation> toggle(
    String workspaceId,
    String projectId,
    String automationId, {
    required bool enabled,
  }) => _run(
    () async => automationFromPb(
      (await _client.toggle(
        pb.AutomationToggleRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          automationId: automationId,
          enabled: enabled,
        ),
        options: _options,
      )).automation,
    ),
  );

  @override
  Future<void> delete(
    String workspaceId,
    String projectId,
    String automationId,
  ) => _run(() async {
    await _client.delete(
      pb.AutomationDeleteRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        automationId: automationId,
      ),
      options: _options,
    );
  });

  @override
  Future<DryRunResult> dryRun(
    String workspaceId,
    String projectId,
    String automationId,
    String taskId,
  ) => _run(() async {
    final a = await _client.dryRun(
      pb.AutomationDryRunRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        automationId: automationId,
        taskId: taskId,
      ),
      options: _options,
    );
    return DryRunResult(
      wouldRun: a.wouldRun,
      status: a.status,
      explanation: a.explanation,
      error: a.error,
      steps: decodeSteps(a.stepsJson),
    );
  });

  @override
  Future<List<AutomationRun>> runs(
    String workspaceId,
    String projectId, {
    String automationId = '',
    String taskId = '',
    String status = '',
    String before = '',
    int limit = 0,
  }) => _run(() async {
    final a = await _runs.list(
      pb.AutomationRunListRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        automationId: automationId,
        taskId: taskId,
        status: status,
        before: before,
        limit: limit,
      ),
      options: _options,
    );
    return List.unmodifiable(a.runs.map(runFromPb));
  });
}

String _json(Map<String, Object> map) => jsonEncode(map);
