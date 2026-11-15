import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Mirrors the server's limits; the server stays the authority.
const maxProblemsShown = 100;

/// What a file can be imported from (the wire names are the server's).
enum ImportSource {
  jiraCsv('jira_csv', 'Jira (CSV export)', true),
  jiraJson('jira_json', 'Jira (JSON)', false),
  clickupCsv('clickup_csv', 'ClickUp (CSV export)', true),
  clickupJson('clickup_json', 'ClickUp (JSON)', false),
  csv('csv', 'Any CSV file', true),
  taskforge('taskforge', 'TaskForge export (tasks.json)', false);

  const ImportSource(this.wire, this.label, this.isCsv);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    jiraCsv => l.grpMImpJiraCsv,
    jiraJson => l.grpMImpJiraJson,
    clickupCsv => l.grpMImpClickupCsv,
    clickupJson => l.grpMImpClickupJson,
    csv => l.grpMImpCsv,
    taskforge => l.grpMImpTaskforge,
  };
  final bool isCsv;

  static ImportSource? tryParse(String wire) =>
      values.where((s) => s.wire == wire).firstOrNull;
}

/// The statuses of a job (the server's words).
const activeStatuses = {'queued', 'running'};

@immutable
class ImportJob {
  const ImportJob({
    required this.id,
    required this.source,
    required this.status,
    this.filename = '',
    this.projectId = '',
    this.total = 0,
    this.done = 0,
    this.phase = '',
    this.error = '',
    this.stats = const {},
    this.problemCount = 0,
    this.createdAt = '',
    this.startedAt = '',
    this.finishedAt = '',
    this.version = 1,
  });

  final String id;
  final String source;
  final String status;
  final String filename;
  final String projectId;
  final int total;
  final int done;
  final String phase;
  final String error;

  /// What was made: `tasks`, `comments`, `links`, `sprints`, `placeholders` ...
  final Map<String, dynamic> stats;
  final int problemCount;
  final String createdAt;
  final String startedAt;
  final String finishedAt;
  final int version;

  bool get isActive => activeStatuses.contains(status);
  bool get isFinished =>
      const {'done', 'failed', 'cancelled', 'undone'}.contains(status);

  /// Whether Undo applies: it made (or part-made) something and is not running.
  bool get canUndo => const {'done', 'failed', 'cancelled'}.contains(status);

  /// Whether Start (again) applies: a stopped run resumes.
  bool get canResume => status == 'failed' || status == 'cancelled';

  double get progress => total == 0 ? 0 : (done / total).clamp(0, 1).toDouble();

  int stat(String name) => (stats[name] as num?)?.toInt() ?? 0;

  ImportSource? get kind => ImportSource.tryParse(source);
}

@immutable
class UploadResult {
  const UploadResult({
    required this.id,
    required this.source,
    required this.filename,
    required this.size,
    this.member = '',
    this.members = const [],
  });

  final String id;
  final String source;
  final String filename;
  final int size;

  /// The data file inside a zip that will be read; empty when the zip holds
  /// several and the person must choose.
  final String member;

  /// The data files inside a zip, when it holds several to choose from.
  final List<String> members;
}

@immutable
class ImportProblem {
  const ImportProblem({
    required this.line,
    required this.message,
    this.level = 'error',
  });

  final int line;
  final String message;
  final String level;

  bool get isError => level == 'error';
}

/// What the file holds (the server's analysis).
@immutable
class ImportAnalysis {
  const ImportAnalysis({
    this.issues = 0,
    this.subtasks = 0,
    this.comments = 0,
    this.links = 0,
    this.labels = 0,
    this.statuses = const {},
    this.priorities = const {},
    this.people = const {},
    this.sprints = const [],
    this.columns = const [],
    this.sample = const [],
  });

  final int issues;
  final int subtasks;
  final int comments;
  final int links;
  final int labels;
  final Map<String, int> statuses;
  final Map<String, int> priorities;

  /// Person key (email or name) to display name.
  final Map<String, String> people;
  final List<String> sprints;
  final List<String> columns;
  final List<Map<String, String>> sample;

  factory ImportAnalysis.fromJson(String text) {
    if (text.isEmpty) return const ImportAnalysis();
    final j = jsonDecode(text) as Map<String, dynamic>;
    Map<String, int> counts(Object? raw) => {
      for (final e in ((raw as Map<String, dynamic>?) ?? const {}).entries)
        e.key: (e.value as num).toInt(),
    };
    return ImportAnalysis(
      issues: (j['issues'] as num?)?.toInt() ?? 0,
      subtasks: (j['subtasks'] as num?)?.toInt() ?? 0,
      comments: (j['comments'] as num?)?.toInt() ?? 0,
      links: (j['links'] as num?)?.toInt() ?? 0,
      labels: (j['labels'] as num?)?.toInt() ?? 0,
      statuses: counts(j['statuses']),
      priorities: counts(j['priorities']),
      people: {
        for (final e
            in ((j['people'] as Map<String, dynamic>?) ?? const {}).entries)
          e.key: '${e.value}',
      },
      sprints: List.unmodifiable(
        (j['sprints'] as List<dynamic>? ?? const []).map((s) => '$s'),
      ),
      columns: List.unmodifiable(
        (j['columns'] as List<dynamic>? ?? const []).map((s) => '$s'),
      ),
      sample: List.unmodifiable([
        for (final row in (j['sample'] as List<dynamic>? ?? const []))
          {
            for (final e in (row as Map<String, dynamic>).entries)
              e.key: '${e.value}',
          },
      ]),
    );
  }
}

/// The choices of an import: where, and how each part of the file maps.
@immutable
class ImportMapping {
  const ImportMapping({
    this.projectId = '',
    this.newName = '',
    this.newKey = '',
    this.columns = const {},
    this.statuses = const {},
    this.priorities = const {},
    this.users = const {},
    this.labels = false,
  });

  /// An existing project, or (empty) a new one named [newName] with [newKey].
  final String projectId;
  final String newName;
  final String newKey;
  final Map<String, String> columns;

  /// Source status to `id:<status id>` or `new`.
  final Map<String, String> statuses;
  final Map<String, String> priorities;

  /// Person key to a member's user id, `placeholder` or `skip`.
  final Map<String, String> users;
  final bool labels;

  bool get intoNewProject => projectId.isEmpty;

  /// Why the mapping cannot be used yet, or null.
  String? problemFor(ImportSource? source) {
    if (intoNewProject) {
      if (newName.trim().isEmpty) return 'Name the new project.';
      if (!RegExp(r'^[A-Za-z][A-Za-z0-9]{1,9}$').hasMatch(newKey.trim())) {
        return 'The project key is 2 to 10 letters and digits, starting with a letter.';
      }
    }
    if ((source?.isCsv ?? false) && (columns['title'] ?? '').isEmpty) {
      return 'Choose the column that holds the title.';
    }
    return null;
  }

  ImportMapping copyWith({
    String? projectId,
    String? newName,
    String? newKey,
    Map<String, String>? columns,
    Map<String, String>? statuses,
    Map<String, String>? priorities,
    Map<String, String>? users,
    bool? labels,
  }) => ImportMapping(
    projectId: projectId ?? this.projectId,
    newName: newName ?? this.newName,
    newKey: newKey ?? this.newKey,
    columns: columns ?? this.columns,
    statuses: statuses ?? this.statuses,
    priorities: priorities ?? this.priorities,
    users: users ?? this.users,
    labels: labels ?? this.labels,
  );

  factory ImportMapping.fromJson(String text) {
    if (text.isEmpty) return const ImportMapping();
    final j = jsonDecode(text) as Map<String, dynamic>;
    Map<String, String> strings(Object? raw) => {
      for (final e in ((raw as Map<String, dynamic>?) ?? const {}).entries)
        e.key: '${e.value}',
    };
    final target = (j['target'] as Map<String, dynamic>?) ?? const {};
    return ImportMapping(
      projectId: '${target['project_id'] ?? ''}',
      newName: '${target['name'] ?? ''}',
      newKey: '${target['key'] ?? ''}',
      columns: strings(j['columns']),
      statuses: strings(j['statuses']),
      priorities: strings(j['priorities']),
      users: strings(j['users']),
      labels: j['labels'] == true,
    );
  }

  String toJson({bool csv = false}) => jsonEncode({
    'target': intoNewProject
        ? {'name': newName.trim(), 'key': newKey.trim().toUpperCase()}
        : {'project_id': projectId},
    if (csv) 'columns': columns,
    'statuses': statuses,
    'priorities': priorities,
    'users': users,
    'labels': labels,
  });
}

@immutable
class ImportProposal {
  const ImportProposal({
    required this.job,
    required this.mapping,
    required this.analysis,
    this.members = const [],
  });

  final ImportJob job;
  final ImportMapping mapping;
  final ImportAnalysis analysis;
  final List<String> members;
}

@immutable
class ImportDetail {
  const ImportDetail({
    required this.job,
    this.problems = const [],
    this.mapping = const ImportMapping(),
    this.analysis = const ImportAnalysis(),
  });

  final ImportJob job;
  final List<ImportProblem> problems;
  final ImportMapping mapping;
  final ImportAnalysis analysis;
}

@immutable
class ImportReport {
  const ImportReport({
    this.counts = const {},
    this.warnings = const [],
    this.errors = 0,
    this.warningTotal = 0,
    this.alreadyImported = 0,
  });

  final Map<String, int> counts;
  final List<ImportProblem> warnings;
  final int errors;
  final int warningTotal;
  final int alreadyImported;

  int count(String name) => counts[name] ?? 0;
}

@immutable
class WaitingPerson {
  const WaitingPerson({
    required this.id,
    required this.name,
    this.email = '',
    this.tasks = 0,
  });

  final String id;
  final String name;
  final String email;
  final int tasks;
}

@immutable
class ExportJob {
  const ExportJob({
    required this.id,
    required this.status,
    this.scope = 'project',
    this.projectId = '',
    this.filename = '',
    this.size = 0,
    this.stats = const {},
    this.error = '',
    this.downloadPath = '',
  });

  final String id;
  final String status;
  final String scope;
  final String projectId;
  final String filename;
  final int size;
  final Map<String, dynamic> stats;
  final String error;

  /// A signed, short-lived path on the REST host (done only).
  final String downloadPath;

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isWorking => status == 'queued' || status == 'running';
}

enum ImportFailure {
  network,
  denied,
  invalid,
  notFound,
  conflict,
  tooBig,
  other,
}

class ImportException implements Exception {
  const ImportException(this.failure, {this.detail});

  final ImportFailure failure;
  final String? detail;

  @override
  String toString() => 'ImportException($failure)';
}

String importErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! ImportException) return t.grpLGeneric;
  final detail = error.detail;
  final said = detail != null && detail.isNotEmpty;
  return switch (error.failure) {
    ImportFailure.invalid => said ? detail : t.grpLNotValid,
    ImportFailure.conflict => said ? detail : t.grpLImpCannot,
    ImportFailure.tooBig => t.grpLImpTooBig,
    ImportFailure.denied => t.grpLImpDenied,
    ImportFailure.notFound => t.grpLImpNotFound,
    ImportFailure.network => t.grpLNetTry,
    ImportFailure.other => t.grpLGeneric,
  };
}

/// "5.0 MB" for [bytes]; the unit is in the language of [l10n] (English when
/// null).
String humanSize(int bytes, [AppLocalizations? l10n]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (bytes < 1024) return '$bytes ${l.grpRUnitB}';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} ${l.grpRUnitKB}';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ${l.grpRUnitMB}';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ${l.grpRUnitGB}';
}
