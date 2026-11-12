import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/gen/infrastructure/recurrence/grpc/recurrence.pbgrpc.dart'
    as pb;

abstract interface class RecurrenceClient {
  /// The task's repeat rule, or null when it does not repeat.
  Future<RepeatSeries?> get(
    String workspaceId,
    String projectId,
    String taskId,
  );
  Future<RepeatSeries> set(
    String workspaceId,
    String projectId,
    String taskId,
    RepeatDraft draft,
  );

  /// Stops the repeat; every instance stays as an ordinary task.
  Future<void> clear(String workspaceId, String projectId, String taskId);
  Future<RepeatSeries> pause(
    String workspaceId,
    String projectId,
    String taskId, {
    required bool paused,
  });

  /// Takes the task as the new template and carries its title, description,
  /// priority and people to the open later instances. Returns how many changed.
  Future<({RepeatSeries series, int changed})> updateFuture(
    String workspaceId,
    String projectId,
    String taskId,
  );
  Future<RepeatPreview> preview(
    String workspaceId,
    RepeatDraft draft, {
    String startsOn = '',
    String after = '',
    int count = previewCount,
  });

  /// The dates still to be made in `[start, end]` (`YYYY-MM-DD`).
  Future<List<RepeatGhost>> upcoming(
    String workspaceId, {
    required String start,
    required String end,
    String projectId = '',
  });
}

RepeatException mapRepeatError(Object error) {
  if (error is RepeatException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => RepeatException(
        RepeatFailure.invalid,
        detail: message,
      ),
      StatusCode.permissionDenied => const RepeatException(
        RepeatFailure.denied,
      ),
      StatusCode.notFound => const RepeatException(RepeatFailure.notFound),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const RepeatException(RepeatFailure.network),
      _ => const RepeatException(RepeatFailure.other),
    };
  }
  return const RepeatException(RepeatFailure.network);
}

RepeatSeries seriesFromPb(pb.Series s) => RepeatSeries(
  id: s.id,
  projectId: s.projectId,
  taskId: s.taskId,
  rrule: s.rrule,
  mode: RepeatKind.parse(s.mode),
  zone: s.timezone,
  atTime: s.atTime,
  leadDays: s.leadDays,
  startsOn: s.startsOn,
  endsOn: s.endsOn,
  skipWeekends: s.skipWeekends,
  paused: s.paused,
  pauseReason: s.pauseReason,
  summary: s.summary,
  nextDueOn: s.nextDueOn,
  nextDates: List.unmodifiable(s.nextDates),
  instanceCount: s.instanceCount,
  index: s.index,
  isTemplate: s.isTemplate,
  templateMissing: s.templateMissing,
  version: s.version,
);

class GrpcRecurrenceClient implements RecurrenceClient {
  GrpcRecurrenceClient(ClientChannelBase channel, this._session)
    : _client = pb.RecurrenceControllerClient(channel);

  final pb.RecurrenceControllerClient _client;
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
      throw mapRepeatError(e);
    }
  }

  @override
  Future<RepeatSeries?> get(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(() async {
    final answer = await _client.get(
      pb.RecurrenceGetRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
      ),
      options: _options,
    );
    return answer.repeats ? seriesFromPb(answer.series) : null;
  });

  @override
  Future<RepeatSeries> set(
    String workspaceId,
    String projectId,
    String taskId,
    RepeatDraft draft,
  ) => _run(
    () async => seriesFromPb(
      (await _client.set(
        pb.RecurrenceSetRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
          rrule: draft.toRrule(),
          mode: draft.mode.wire,
          timezone: draft.zone,
          atTime: draft.atTime,
          leadDays: draft.leadDays,
          skipWeekends: draft.skipWeekends,
        ),
        options: _options,
      )).series,
    ),
  );

  @override
  Future<void> clear(String workspaceId, String projectId, String taskId) =>
      _run(() async {
        await _client.clear(
          pb.RecurrenceClearRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            taskId: taskId,
          ),
          options: _options,
        );
      });

  @override
  Future<RepeatSeries> pause(
    String workspaceId,
    String projectId,
    String taskId, {
    required bool paused,
  }) => _run(
    () async => seriesFromPb(
      (await _client.pause(
        pb.RecurrencePauseRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
          paused: paused,
        ),
        options: _options,
      )).series,
    ),
  );

  @override
  Future<({RepeatSeries series, int changed})> updateFuture(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(() async {
    final answer = await _client.updateFuture(
      pb.RecurrenceUpdateFutureRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
      ),
      options: _options,
    );
    return (series: seriesFromPb(answer.series), changed: answer.changed);
  });

  @override
  Future<RepeatPreview> preview(
    String workspaceId,
    RepeatDraft draft, {
    String startsOn = '',
    String after = '',
    int count = previewCount,
  }) => _run(() async {
    final shown = await _client.preview(
      pb.RecurrencePreviewRequest(
        workspaceId: workspaceId,
        rrule: draft.toRrule(),
        mode: draft.mode.wire,
        timezone: draft.zone,
        skipWeekends: draft.skipWeekends,
        startsOn: startsOn,
        after: after,
        count: count,
      ),
      options: _options,
    );
    return RepeatPreview(
      summary: shown.summary,
      dates: List.unmodifiable(shown.dates),
    );
  });

  @override
  Future<List<RepeatGhost>> upcoming(
    String workspaceId, {
    required String start,
    required String end,
    String projectId = '',
  }) => _run(() async {
    final answer = await _client.upcoming(
      pb.RecurrenceUpcomingRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        start: start,
        end: end,
      ),
      options: _options,
    );
    return List.unmodifiable(
      answer.ghosts.map(
        (g) => RepeatGhost(
          seriesId: g.seriesId,
          projectId: g.projectId,
          title: g.title,
          dueDate: g.dueDate,
        ),
      ),
    );
  });
}
