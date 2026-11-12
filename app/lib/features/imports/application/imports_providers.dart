import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/imports/data/import_files.dart';
import 'package:taskforge/features/imports/data/imports_client.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final importsClientProvider = Provider<ImportsClient>(
  (ref) => GrpcImportsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

final importFilesProvider = Provider<ImportFiles>((ref) {
  final files = HttpImportFiles(
    ref.watch(authSessionProvider),
    restUrl: AppConfig.restUrl,
    selectedWorkspace: () => ref.read(workspaceScopeProvider),
  );
  ref.onDispose(files.close);
  return files;
});

String _workspace(Ref ref) {
  final id = ref.read(workspaceScopeProvider);
  if (id == null) throw const ImportException(ImportFailure.other);
  return id;
}

/// The workspace's imports, newest first.
final importJobsProvider = FutureProvider.autoDispose<List<ImportJob>>((
  ref,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(importsClientProvider).list(ws);
});

/// One import with its error report.
final importDetailProvider = FutureProvider.autoDispose
    .family<ImportDetail, String>((ref, id) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) throw const ImportException(ImportFailure.other);
      return ref.watch(importsClientProvider).get(ws, id);
    }, retry: (_, _) => null);

/// The job as it moves, until it stops.
final importProgressProvider = StreamProvider.autoDispose
    .family<ImportJob, String>((ref, id) {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const Stream.empty();
      return ref.watch(importsClientProvider).progress(ws, id);
    });

/// People an import named who are not members yet.
final placeholdersProvider = FutureProvider.autoDispose<List<WaitingPerson>>((
  ref,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const [];
  return ref.watch(importsClientProvider).placeholders(ws);
});

// -------------------------------------------------------------------- wizard

enum ImportStep { source, upload, map, review, run }

@immutable
class ImportWizardState {
  const ImportWizardState({
    this.step = ImportStep.source,
    this.source,
    this.job,
    this.proposal,
    this.mapping = const ImportMapping(),
    this.report,
    this.busy = false,
    this.error,
    this.pendingJob = '',
    this.choices = const [],
  });

  final ImportStep step;

  /// What the person chose; null: let the server detect it.
  final ImportSource? source;
  final ImportJob? job;
  final ImportProposal? proposal;
  final ImportMapping mapping;
  final ImportReport? report;
  final bool busy;
  final String? error;

  /// An uploaded zip that holds several data files: which job, and the files
  /// to choose from.
  final String pendingJob;
  final List<String> choices;

  /// The source the file turned out to be (the server's detection or the
  /// choice).
  ImportSource? get detected =>
      ImportSource.tryParse(job?.source ?? '') ?? source;
  bool get isCsv => detected?.isCsv ?? false;

  ImportWizardState copyWith({
    ImportStep? step,
    ImportSource? Function()? source,
    ImportJob? job,
    ImportProposal? proposal,
    ImportMapping? mapping,
    ImportReport? Function()? report,
    bool? busy,
    String? Function()? error,
    String? pendingJob,
    List<String>? choices,
  }) => ImportWizardState(
    step: step ?? this.step,
    source: source == null ? this.source : source(),
    job: job ?? this.job,
    proposal: proposal ?? this.proposal,
    mapping: mapping ?? this.mapping,
    report: report == null ? this.report : report(),
    busy: busy ?? this.busy,
    error: error == null ? this.error : error(),
    pendingJob: pendingJob ?? this.pendingJob,
    choices: choices ?? this.choices,
  );
}

/// The import wizard: Source, Upload, Map, Review, Import. Each step asks the
/// server and only moves on when it answered; a refusal is shown and the step
/// stays.
final importWizardProvider =
    NotifierProvider.autoDispose<ImportWizard, ImportWizardState>(
      ImportWizard.new,
    );

class ImportWizard extends Notifier<ImportWizardState> {
  @override
  ImportWizardState build() => const ImportWizardState();

  ImportsClient get _client => ref.read(importsClientProvider);

  /// Marks the source on the first step without leaving it.
  void select(ImportSource? source) =>
      state = state.copyWith(source: () => source, error: () => null);

  void chooseSource(ImportSource? source) => state = state.copyWith(
    source: () => source,
    step: ImportStep.upload,
    error: () => null,
  );

  void back() {
    final previous = switch (state.step) {
      ImportStep.upload => ImportStep.source,
      ImportStep.map => ImportStep.upload,
      ImportStep.review => ImportStep.map,
      _ => state.step,
    };
    state = state.copyWith(step: previous, error: () => null);
  }

  /// Runs [call] with the busy flag up and any refusal shown. The workspace is
  /// looked up inside, and nothing is set once the screen has gone.
  Future<T?> _guard<T>(Future<T> Function(String ws) call) async {
    state = state.copyWith(busy: true, error: () => null);
    try {
      return await call(_workspace(ref));
    } on ImportException catch (e) {
      if (ref.mounted) {
        state = state.copyWith(error: () => importErrorMessage(e));
      }
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  /// Sends the file, then reads it for a proposed mapping.
  Future<void> upload({
    required String filename,
    required Stream<List<int>> stream,
    required int size,
  }) async {
    await _guard((ws) async {
      final sent = await ref
          .read(importFilesProvider)
          .upload(
            workspaceId: ws,
            filename: filename,
            stream: stream,
            size: size,
            source: state.source?.wire ?? '',
          );
      if (!ref.mounted) return;
      if (sent.member.isEmpty && sent.members.length > 1) {
        // A zip with several data files (a workspace export): ask which.
        state = state.copyWith(pendingJob: sent.id, choices: sent.members);
        return;
      }
      final proposal = await _client.analyze(ws, sent.id);
      if (!ref.mounted) return;
      state = state.copyWith(
        job: proposal.job,
        proposal: proposal,
        mapping: proposal.mapping,
        step: ImportStep.map,
        pendingJob: '',
        choices: const [],
      );
    });
  }

  /// Several data files in a zip: reads the chosen one (before or after the
  /// wizard reached Map).
  Future<void> chooseMember(String member) async {
    final id = state.job?.id ?? state.pendingJob;
    if (id.isEmpty) return;
    await _guard((ws) async {
      final proposal = await _client.analyze(ws, id, member: member);
      if (!ref.mounted) return;
      state = state.copyWith(
        job: proposal.job,
        proposal: proposal,
        mapping: proposal.mapping,
        step: ImportStep.map,
        pendingJob: '',
        choices: const [],
      );
    });
  }

  /// Changes how the file is read (a different source of the same file).
  Future<void> changeSource(ImportSource source) async {
    final job = state.job;
    if (job == null) return;
    await _guard((ws) async {
      final proposal = await _client.analyze(ws, job.id, source: source.wire);
      if (!ref.mounted) return;
      state = state.copyWith(
        job: proposal.job,
        proposal: proposal,
        mapping: proposal.mapping,
      );
    });
  }

  void edit(ImportMapping mapping) =>
      state = state.copyWith(mapping: mapping, error: () => null);

  /// Takes up an import from the history (one that stopped, to resume it).
  Future<void> resume(ImportJob job) async {
    await _guard((ws) async {
      final detail = await _client.get(ws, job.id);
      if (!ref.mounted) return;
      state = ImportWizardState(
        step: ImportStep.review,
        source: detail.job.kind,
        job: detail.job,
        mapping: detail.mapping,
        proposal: ImportProposal(
          job: detail.job,
          mapping: detail.mapping,
          analysis: detail.analysis,
        ),
      );
    });
  }

  Future<void> review() async {
    final job = state.job;
    if (job == null) return;
    final problem = state.mapping.problemFor(state.detected);
    if (problem != null) {
      state = state.copyWith(error: () => problem);
      return;
    }
    await _guard((ws) async {
      final report = await _client.dryRun(
        ws,
        job.id,
        state.mapping,
        csv: state.isCsv,
      );
      if (!ref.mounted) return;
      state = state.copyWith(report: () => report, step: ImportStep.review);
    });
  }

  Future<void> start() async {
    final job = state.job;
    if (job == null) return;
    await _guard((ws) async {
      final started = await _client.start(
        ws,
        job.id,
        state.mapping,
        csv: state.isCsv,
      );
      if (!ref.mounted) return;
      state = state.copyWith(job: started, step: ImportStep.run);
      ref.invalidate(importJobsProvider);
    });
  }

  Future<void> cancel() async {
    final job = state.job;
    if (job == null) return;
    await _guard((ws) async {
      final stopped = await _client.cancel(ws, job.id);
      if (!ref.mounted) return;
      state = state.copyWith(job: stopped);
      ref
        ..invalidate(importProgressProvider(job.id))
        ..invalidate(importJobsProvider);
    });
  }

  /// Undoes the import this wizard ran; returns what was removed.
  Future<Map<String, int>?> undo() async {
    final job = state.job;
    if (job == null) return null;
    return _guard((ws) async {
      final (undone, removed) = await _client.undo(ws, job.id);
      if (!ref.mounted) return removed;
      state = state.copyWith(job: undone);
      ref
        ..invalidate(importProgressProvider(job.id))
        ..invalidate(importJobsProvider);
      return removed;
    });
  }

  void restart() => state = const ImportWizardState();
}

// -------------------------------------------------------------------- actions

/// What the history and people lists do. Each call acts on the server, then
/// reads again, even when it failed: a call that timed out may have happened.
class ImportActions {
  ImportActions(this._ref);

  final Ref _ref;

  Future<T> _then<T>(Future<T> Function(String ws) call) async {
    try {
      return await call(_workspace(_ref));
    } finally {
      _ref
        ..invalidate(importJobsProvider)
        ..invalidate(placeholdersProvider);
    }
  }

  Future<Map<String, int>> undo(ImportJob job) => _then(
    (ws) async => (await _ref.read(importsClientProvider).undo(ws, job.id)).$2,
  );

  Future<void> discard(ImportJob job) =>
      _then((ws) => _ref.read(importsClientProvider).discard(ws, job.id));

  Future<ImportJob> cancel(ImportJob job) =>
      _then((ws) => _ref.read(importsClientProvider).cancel(ws, job.id));

  Future<int> claim(WaitingPerson who, String userId) =>
      _then((ws) => _ref.read(importsClientProvider).claim(ws, who.id, userId));
}

final importActionsProvider = Provider<ImportActions>(ImportActions.new);

// -------------------------------------------------------------------- export

@immutable
class ExportState {
  const ExportState({this.job, this.busy = false, this.error, this.saved});

  final ExportJob? job;
  final bool busy;
  final String? error;

  /// The file name once the zip was fetched.
  final String? saved;
}

/// Builds an export on the server, waits for it, and hands over its bytes.
final exportProvider =
    NotifierProvider.autoDispose<ExportController, ExportState>(
      ExportController.new,
    );

class ExportController extends Notifier<ExportState> {
  /// How often to ask, and for how long.
  static const pollEvery = Duration(seconds: 1);
  static const giveUpAfter = Duration(minutes: 10);

  var _generation = 0;

  @override
  ExportState build() {
    ref.onDispose(() => _generation++);
    return const ExportState();
  }

  /// Exports [projectId] (empty: every project the caller can open) and
  /// returns the zip's bytes with its file name, or null when it failed.
  Future<(String, Uint8List)?> run({String projectId = ''}) async {
    final generation = ++_generation;
    state = const ExportState(busy: true);
    try {
      final ws = _workspace(ref);
      final client = ref.read(importsClientProvider);
      var job = await client.startExport(ws, projectId: projectId);
      final deadline = DateTime.now().add(giveUpAfter);
      while (job.isWorking) {
        if (generation != _generation || !ref.mounted) return null;
        if (DateTime.now().isAfter(deadline)) {
          throw const ImportException(
            ImportFailure.conflict,
            detail: 'The export is taking too long. Try again later.',
          );
        }
        await Future<void>.delayed(pollEvery);
        job = await client.exportStatus(ws, job.id);
      }
      if (job.isFailed) {
        throw ImportException(ImportFailure.invalid, detail: job.error);
      }
      state = ExportState(job: job, busy: true);
      final bytes = await ref.read(importFilesProvider).fetch(job.downloadPath);
      if (generation != _generation || !ref.mounted) return null;
      state = ExportState(job: job, saved: job.filename);
      return (job.filename, bytes);
    } on ImportException catch (e) {
      if (ref.mounted) state = ExportState(error: importErrorMessage(e));
      return null;
    }
  }
}
