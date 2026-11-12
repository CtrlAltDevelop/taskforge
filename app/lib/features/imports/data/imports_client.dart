import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/gen/infrastructure/imports/grpc/imports.pbgrpc.dart'
    as pb;

abstract interface class ImportsClient {
  Future<List<ImportJob>> list(String workspaceId);
  Future<ImportDetail> get(String workspaceId, String jobId);

  /// Reads the uploaded file and proposes the mapping; [source] / [member]
  /// override what was detected.
  Future<ImportProposal> analyze(
    String workspaceId,
    String jobId, {
    String source = '',
    String member = '',
  });
  Future<ImportReport> dryRun(
    String workspaceId,
    String jobId,
    ImportMapping mapping, {
    required bool csv,
  });
  Future<ImportJob> start(
    String workspaceId,
    String jobId,
    ImportMapping mapping, {
    required bool csv,
  });

  /// The job now, then again as it moves, until it stops.
  Stream<ImportJob> progress(String workspaceId, String jobId);
  Future<ImportJob> cancel(String workspaceId, String jobId);

  /// Removes what the import made; the map says how much of each went.
  Future<(ImportJob, Map<String, int>)> undo(String workspaceId, String jobId);
  Future<void> discard(String workspaceId, String jobId);
  Future<List<WaitingPerson>> placeholders(String workspaceId);
  Future<int> claim(String workspaceId, String placeholderId, String userId);

  /// Exports one project, or (empty [projectId]) every project the caller can
  /// open.
  Future<ExportJob> startExport(String workspaceId, {String projectId = ''});
  Future<ExportJob> exportStatus(String workspaceId, String exportId);
}

ImportException mapImportError(Object error) {
  if (error is ImportException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => ImportException(
        ImportFailure.invalid,
        detail: message,
      ),
      StatusCode.permissionDenied => const ImportException(
        ImportFailure.denied,
      ),
      StatusCode.notFound => const ImportException(ImportFailure.notFound),
      StatusCode.alreadyExists || StatusCode.aborted => ImportException(
        ImportFailure.conflict,
        detail: message,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const ImportException(ImportFailure.network),
      _ => const ImportException(ImportFailure.other),
    };
  }
  return const ImportException(ImportFailure.network);
}

Map<String, dynamic> _json(String text) {
  if (text.isEmpty) return const {};
  return Map<String, dynamic>.from((jsonDecode(text) as Map<dynamic, dynamic>));
}

ImportJob jobFromPb(pb.Job j) => ImportJob(
  id: j.id,
  source: j.source,
  status: j.status,
  filename: j.filename,
  projectId: j.projectId,
  total: j.total,
  done: j.done,
  phase: j.phase,
  error: j.error,
  stats: _json(j.statsJson),
  problemCount: j.problemCount,
  createdAt: j.createdAt,
  startedAt: j.startedAt,
  finishedAt: j.finishedAt,
  version: j.version,
);

ImportProblem problemFromPb(pb.Problem p) =>
    ImportProblem(line: p.line, message: p.message, level: p.level);

ExportJob exportFromPb(pb.ExportJob e) => ExportJob(
  id: e.id,
  status: e.status,
  scope: e.scope,
  projectId: e.projectId,
  filename: e.filename,
  size: e.size.toInt(),
  stats: _json(e.statsJson),
  error: e.error,
  downloadPath: e.downloadPath,
);

class GrpcImportsClient implements ImportsClient {
  GrpcImportsClient(ClientChannelBase channel, this._session)
    : _imports = pb.ImportControllerClient(channel),
      _exports = pb.ExportControllerClient(channel);

  final pb.ImportControllerClient _imports;
  final pb.ExportControllerClient _exports;
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
      throw mapImportError(e);
    }
  }

  @override
  Future<List<ImportJob>> list(String workspaceId) => _run(() async {
    final r = await _imports.list(
      pb.ImportListRequest(workspaceId: workspaceId),
      options: _options,
    );
    return List.unmodifiable(r.jobs.map(jobFromPb));
  });

  @override
  Future<ImportDetail> get(String workspaceId, String jobId) => _run(() async {
    final r = await _imports.get(
      pb.ImportGetRequest(workspaceId: workspaceId, jobId: jobId),
      options: _options,
    );
    return ImportDetail(
      job: jobFromPb(r.job),
      problems: List.unmodifiable(r.problems.map(problemFromPb)),
      mapping: ImportMapping.fromJson(r.mappingJson),
      analysis: ImportAnalysis.fromJson(r.analysisJson),
    );
  });

  @override
  Future<ImportProposal> analyze(
    String workspaceId,
    String jobId, {
    String source = '',
    String member = '',
  }) => _run(() async {
    final r = await _imports.analyze(
      pb.ImportAnalyzeRequest(
        workspaceId: workspaceId,
        jobId: jobId,
        source: source,
        member: member,
      ),
      options: _options,
    );
    return ImportProposal(
      job: jobFromPb(r.job),
      mapping: ImportMapping.fromJson(r.mappingJson),
      analysis: ImportAnalysis.fromJson(r.analysisJson),
      members: List.unmodifiable(r.members),
    );
  });

  @override
  Future<ImportReport> dryRun(
    String workspaceId,
    String jobId,
    ImportMapping mapping, {
    required bool csv,
  }) => _run(() async {
    final r = await _imports.dryRun(
      pb.ImportDryRunRequest(
        workspaceId: workspaceId,
        jobId: jobId,
        mappingJson: mapping.toJson(csv: csv),
      ),
      options: _options,
    );
    return ImportReport(
      counts: {
        for (final e in _json(r.countsJson).entries)
          e.key: (e.value as num).toInt(),
      },
      warnings: List.unmodifiable(r.warnings.map(problemFromPb)),
      errors: r.errors,
      warningTotal: r.warningTotal,
      alreadyImported: r.alreadyImported,
    );
  });

  @override
  Future<ImportJob> start(
    String workspaceId,
    String jobId,
    ImportMapping mapping, {
    required bool csv,
  }) => _run(
    () async => jobFromPb(
      (await _imports.start(
        pb.ImportStartRequest(
          workspaceId: workspaceId,
          jobId: jobId,
          mappingJson: mapping.toJson(csv: csv),
        ),
        options: _options,
      )).job,
    ),
  );

  @override
  Stream<ImportJob> progress(String workspaceId, String jobId) async* {
    try {
      await for (final m in _imports.progress(
        pb.ImportProgressRequest(workspaceId: workspaceId, jobId: jobId),
        options: _options,
      )) {
        yield jobFromPb(m.job);
      }
    } on Object catch (e) {
      throw mapImportError(e);
    }
  }

  @override
  Future<ImportJob> cancel(String workspaceId, String jobId) => _run(
    () async => jobFromPb(
      (await _imports.cancel(
        pb.ImportCancelRequest(workspaceId: workspaceId, jobId: jobId),
        options: _options,
      )).job,
    ),
  );

  @override
  Future<(ImportJob, Map<String, int>)> undo(
    String workspaceId,
    String jobId,
  ) => _run(() async {
    final r = await _imports.undo(
      pb.ImportUndoRequest(workspaceId: workspaceId, jobId: jobId),
      options: _options,
    );
    return (
      jobFromPb(r.job),
      {
        for (final e in _json(r.removedJson).entries)
          e.key: (e.value as num).toInt(),
      },
    );
  });

  @override
  Future<void> discard(String workspaceId, String jobId) => _run(() async {
    await _imports.discard(
      pb.ImportDiscardRequest(workspaceId: workspaceId, jobId: jobId),
      options: _options,
    );
  });

  @override
  Future<List<WaitingPerson>> placeholders(String workspaceId) =>
      _run(() async {
        final r = await _imports.listPlaceholders(
          pb.PlaceholderListRequest(workspaceId: workspaceId),
          options: _options,
        );
        return List.unmodifiable(
          r.placeholders.map(
            (p) => WaitingPerson(
              id: p.id,
              name: p.name,
              email: p.email,
              tasks: p.tasks,
            ),
          ),
        );
      });

  @override
  Future<int> claim(String workspaceId, String placeholderId, String userId) =>
      _run(() async {
        final r = await _imports.claimPlaceholder(
          pb.PlaceholderClaimRequest(
            workspaceId: workspaceId,
            placeholderId: placeholderId,
            userId: userId,
          ),
          options: _options,
        );
        return r.assigned;
      });

  @override
  Future<ExportJob> startExport(String workspaceId, {String projectId = ''}) =>
      _run(
        () async => exportFromPb(
          (await _exports.start(
            pb.ExportStartRequest(
              workspaceId: workspaceId,
              projectId: projectId,
            ),
            options: _options,
          )).export,
        ),
      );

  @override
  Future<ExportJob> exportStatus(String workspaceId, String exportId) => _run(
    () async => exportFromPb(
      (await _exports.status(
        pb.ExportStatusRequest(workspaceId: workspaceId, exportId: exportId),
        options: _options,
      )).export,
    ),
  );
}
