import 'dart:async';
import 'dart:typed_data';

import 'package:taskforge/features/imports/data/import_files.dart';
import 'package:taskforge/features/imports/data/imports_client.dart';
import 'package:taskforge/features/imports/domain/imports.dart';

ImportJob job(
  String id, {
  String status = 'analyzed',
  String source = 'jira_csv',
  String filename = 'export.csv',
  String projectId = '',
  int total = 4,
  int done = 0,
  String phase = '',
  String error = '',
  Map<String, dynamic> stats = const {},
  int problemCount = 0,
  int version = 1,
}) => ImportJob(
  id: id,
  source: source,
  status: status,
  filename: filename,
  projectId: projectId,
  total: total,
  done: done,
  phase: phase,
  error: error,
  stats: stats,
  problemCount: problemCount,
  createdAt: '2026-11-12T10:00:00+00:00',
  version: version,
);

const jiraAnalysis = ImportAnalysis(
  issues: 4,
  subtasks: 2,
  comments: 2,
  links: 1,
  labels: 2,
  statuses: {'To Do': 2, 'Done': 1, 'Blocked': 1},
  priorities: {'High': 2, 'Lowest': 1},
  people: {'alice@acme.test': 'Alice', 'bob@old.test': 'Bob'},
  sprints: ['Sprint 1', 'Sprint 2'],
  columns: ['Summary', 'Status', 'Assignee'],
);

ImportMapping proposed({String projectId = '', bool csv = true}) =>
    ImportMapping(
      projectId: projectId,
      newName: projectId.isEmpty ? 'Web' : '',
      newKey: projectId.isEmpty ? 'WEB' : '',
      columns: csv ? const {'title': 'Summary', 'status': 'Status'} : const {},
      statuses: const {'To Do': 'new', 'Done': 'new', 'Blocked': 'new'},
      priorities: const {'High': 'high', 'Lowest': 'low'},
      users: const {'alice@acme.test': 'u1', 'bob@old.test': 'placeholder'},
      labels: true,
    );

/// An in-memory server for the wizard. What it answers is set on the fields;
/// every call is noted in [calls].
class FakeImportsClient implements ImportsClient {
  FakeImportsClient({List<ImportJob>? jobs}) : jobs = [...?jobs];

  final List<ImportJob> jobs;
  final calls = <String>[];
  ImportProposal? proposal;
  ImportReport report = const ImportReport(
    counts: {'tasks': 4, 'subtasks': 2, 'comments': 2, 'links': 1},
  );
  Object? failWith;

  /// What `start` answers, and the jobs `progress` then streams.
  ImportJob started = job('j1', status: 'queued');
  List<ImportJob> stream = [
    job('j1', status: 'running', done: 2, phase: 'tasks', version: 2),
    job(
      'j1',
      status: 'done',
      done: 4,
      projectId: 'p9',
      stats: {'tasks': 4, 'comments': 2, 'links': 1, 'sprints': 2},
      problemCount: 1,
      version: 3,
    ),
  ];
  List<ImportProblem> problems = const [
    ImportProblem(line: 3, message: 'The row has no title.'),
  ];
  Map<String, int> removed = const {'tasks': 4};
  List<WaitingPerson> waiting = [];
  int claimed = 2;
  ExportJob export = const ExportJob(
    id: 'e1',
    status: 'done',
    filename: 'taskforge-all.zip',
    size: 2048,
    downloadPath: '/exports/download?token=t',
  );
  final exportPolls = <String>[];

  void _fail() {
    final e = failWith;
    if (e != null) throw e;
  }

  @override
  Future<List<ImportJob>> list(String workspaceId) async {
    calls.add('list');
    _fail();
    return List.unmodifiable(jobs);
  }

  @override
  Future<ImportDetail> get(String workspaceId, String jobId) async {
    calls.add('get $jobId');
    _fail();
    final j = jobs.firstWhere((j) => j.id == jobId, orElse: () => started);
    return ImportDetail(
      job: j,
      problems: problems,
      mapping: proposal?.mapping ?? proposed(),
      analysis: proposal?.analysis ?? jiraAnalysis,
    );
  }

  @override
  Future<ImportProposal> analyze(
    String workspaceId,
    String jobId, {
    String source = '',
    String member = '',
  }) async {
    calls.add('analyze $jobId $source $member');
    _fail();
    return proposal ??
        ImportProposal(
          job: job(jobId),
          mapping: proposed(),
          analysis: jiraAnalysis,
        );
  }

  @override
  Future<ImportReport> dryRun(
    String workspaceId,
    String jobId,
    ImportMapping mapping, {
    required bool csv,
  }) async {
    calls.add('dryRun $jobId ${mapping.toJson(csv: csv)}');
    _fail();
    return report;
  }

  @override
  Future<ImportJob> start(
    String workspaceId,
    String jobId,
    ImportMapping mapping, {
    required bool csv,
  }) async {
    calls.add('start $jobId ${mapping.toJson(csv: csv)}');
    _fail();
    return started;
  }

  @override
  Stream<ImportJob> progress(String workspaceId, String jobId) async* {
    calls.add('progress $jobId');
    for (final j in stream) {
      yield j;
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  Future<ImportJob> cancel(String workspaceId, String jobId) async {
    calls.add('cancel $jobId');
    _fail();
    return job(jobId, status: 'cancelled', done: 1, version: 9);
  }

  @override
  Future<(ImportJob, Map<String, int>)> undo(
    String workspaceId,
    String jobId,
  ) async {
    calls.add('undo $jobId');
    _fail();
    return (
      job(jobId, status: 'undone', stats: {'undone': removed}, version: 10),
      removed,
    );
  }

  @override
  Future<void> discard(String workspaceId, String jobId) async {
    calls.add('discard $jobId');
    _fail();
    jobs.removeWhere((j) => j.id == jobId);
  }

  @override
  Future<List<WaitingPerson>> placeholders(String workspaceId) async {
    calls.add('placeholders');
    _fail();
    return List.unmodifiable(waiting);
  }

  @override
  Future<int> claim(
    String workspaceId,
    String placeholderId,
    String userId,
  ) async {
    calls.add('claim $placeholderId $userId');
    _fail();
    waiting.removeWhere((w) => w.id == placeholderId);
    return claimed;
  }

  @override
  Future<ExportJob> startExport(
    String workspaceId, {
    String projectId = '',
  }) async {
    calls.add('export $projectId');
    _fail();
    return export;
  }

  @override
  Future<ExportJob> exportStatus(String workspaceId, String exportId) async {
    exportPolls.add(exportId);
    _fail();
    return export;
  }
}

/// The REST side: notes what was uploaded and hands back [result].
class FakeImportFiles implements ImportFiles {
  FakeImportFiles({this.result, this.bytes});

  UploadResult? result;
  Uint8List? bytes;
  Object? failWith;

  /// Holds an upload until it completes (to leave the screen meanwhile).
  Completer<void>? hold;
  final uploads = <({String name, int size, int read, String source})>[];
  final fetched = <String>[];

  @override
  Future<UploadResult> upload({
    required String workspaceId,
    required String filename,
    required Stream<List<int>> stream,
    required int size,
    String source = '',
  }) async {
    var read = 0;
    await for (final chunk in stream) {
      read += chunk.length;
    }
    uploads.add((name: filename, size: size, read: read, source: source));
    await hold?.future;
    final e = failWith;
    if (e != null) throw e;
    return result ??
        UploadResult(
          id: 'j1',
          source: source.isEmpty ? 'jira_csv' : source,
          filename: filename,
          size: size,
        );
  }

  final clickupAsked = <({String token, List<String> lists})>[];

  @override
  Future<List<ClickUpWorkspace>> clickupLists({
    required String workspaceId,
    required String token,
  }) async => const [
    ClickUpWorkspace(
      id: '9',
      name: 'Acme',
      lists: [
        ClickUpList(id: 'L1', path: 'Eng › Q4 › Launch'),
        ClickUpList(id: 'L2', path: 'Eng › Loose'),
      ],
    ),
  ];

  @override
  Future<ImportJob> clickupFetch({
    required String workspaceId,
    required String token,
    required List<String> listIds,
  }) async {
    clickupAsked.add((token: token, lists: listIds));
    return job('j1', status: 'uploaded', source: 'clickup_json');
  }

  @override
  Future<Uint8List> fetch(String path) async {
    fetched.add(path);
    return bytes ?? Uint8List.fromList([80, 75, 3, 4]);
  }

  @override
  void close() {}
}
