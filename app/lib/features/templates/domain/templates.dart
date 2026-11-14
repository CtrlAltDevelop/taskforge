import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What a template creates: tasks inside a project, or a whole project.
enum TemplateKind {
  task('task'),
  project('project');

  const TemplateKind(this.wire);

  final String wire;

  static TemplateKind parse(String wire) => values.firstWhere(
    (k) => k.wire == wire,
    orElse: () => TemplateKind.project,
  );
}

enum TemplateVisibility {
  workspace('workspace'),
  private('private');

  const TemplateVisibility(this.wire);

  final String wire;

  static TemplateVisibility parse(String wire) => values.firstWhere(
    (v) => v.wire == wire,
    orElse: () => TemplateVisibility.workspace,
  );
}

/// The parts of a project a "save as template" can keep (the server's
/// `include` names).
enum TemplatePart {
  workflow('workflow'),
  fields('fields'),
  automations('automations'),
  features('features'),
  tasks('tasks');

  const TemplatePart(this.wire);

  final String wire;

  static TemplatePart? parse(String wire) =>
      values.where((p) => p.wire == wire).firstOrNull;
}

@immutable
class Template {
  const Template({
    required this.id,
    required this.kind,
    required this.name,
    required this.description,
    required this.visibility,
    required this.builtin,
    required this.version,
    required this.taskCount,
    required this.variables,
    required this.includes,
    required this.statusNames,
    required this.canEdit,
    required this.contentJson,
  });

  final String id;
  final TemplateKind kind;
  final String name;
  final String description;
  final TemplateVisibility visibility;
  final bool builtin;
  final int version;
  final int taskCount;

  /// The `{{names}}` to ask for when applying.
  final List<String> variables;

  /// Which parts a project template holds.
  final List<TemplatePart> includes;
  final List<String> statusNames;
  final bool canEdit;

  /// The snapshot; empty in the gallery list, filled by a single read.
  final String contentJson;

  bool get hasContent => contentJson.isNotEmpty;
}

/// One task of a template, with dates as days from the start date.
@immutable
class TemplateTask {
  const TemplateTask({
    required this.ref,
    required this.parent,
    required this.title,
    required this.status,
    required this.priority,
    required this.startOffset,
    required this.dueOffset,
  });

  final String ref;
  final String parent;
  final String title;
  final String status;
  final String priority;
  final int? startOffset;
  final int? dueOffset;
}

@immutable
class TemplateStatus {
  const TemplateStatus({
    required this.name,
    required this.category,
    required this.color,
  });

  final String name;
  final String category;
  final String color;
}

/// What the preview shows, read from a template's snapshot.
@immutable
class TemplateContent {
  const TemplateContent({
    required this.tasks,
    required this.statuses,
    required this.fields,
    required this.features,
    required this.automations,
  });

  static const empty = TemplateContent(
    tasks: [],
    statuses: [],
    fields: [],
    features: [],
    automations: 0,
  );

  final List<TemplateTask> tasks;
  final List<TemplateStatus> statuses;
  final List<String> fields;
  final List<String> features;
  final int automations;

  static TemplateContent parse(String json) {
    if (json.isEmpty) return empty;
    try {
      final raw = jsonDecode(json);
      if (raw is! Map<String, dynamic>) return empty;
      final workflow = raw['workflow'];
      return TemplateContent(
        tasks: [
          for (final t in (raw['tasks'] as List? ?? const []))
            if (t is Map<String, dynamic>)
              TemplateTask(
                ref: '${t['ref']}',
                parent: '${t['parent'] ?? ''}',
                title: '${t['title']}',
                status: '${t['status'] ?? ''}',
                priority: '${t['priority'] ?? 'none'}',
                startOffset: t['start_offset'] as int?,
                dueOffset: t['due_offset'] as int?,
              ),
        ],
        statuses: [
          if (workflow is Map<String, dynamic>)
            for (final s in (workflow['statuses'] as List? ?? const []))
              if (s is Map<String, dynamic>)
                TemplateStatus(
                  name: '${s['name']}',
                  category: '${s['category']}',
                  color: '${s['color'] ?? ''}',
                ),
        ],
        fields: [
          for (final f in (raw['fields'] as List? ?? const []))
            if (f is Map<String, dynamic>) '${f['name']}',
        ],
        features: [
          for (final f in (raw['features'] as List? ?? const [])) '$f',
        ],
        automations: (raw['automations'] as List? ?? const []).length,
      );
    } on Object {
      return empty;
    }
  }
}

/// A task of the preview tree and how deep it sits.
@immutable
class TemplateRow {
  const TemplateRow(this.task, this.depth);

  final TemplateTask task;
  final int depth;
}

/// The tasks in display order (parents first) with their depth.
List<TemplateRow> templateRows(List<TemplateTask> tasks) {
  final depth = <String, int>{};
  final rows = <TemplateRow>[];
  for (final task in tasks) {
    final d = task.parent.isEmpty ? 0 : (depth[task.parent] ?? 0) + 1;
    depth[task.ref] = d;
    rows.add(TemplateRow(task, d));
  }
  return rows;
}

/// "+3d", "-1d", "0d": a relative date as the preview shows it.
String offsetLabel(int days) => days > 0 ? '+${days}d' : '${days}d';

@immutable
class SaveDraft {
  const SaveDraft({
    required this.name,
    required this.description,
    required this.visibility,
    this.parts = const {},
    this.includeAssignees = false,
  });

  final String name;
  final String description;
  final TemplateVisibility visibility;
  final Set<TemplatePart> parts;
  final bool includeAssignees;
}

@immutable
class ApplyDraft {
  const ApplyDraft({
    required this.templateId,
    this.projectId = '',
    this.parentTaskId = '',
    this.projectName = '',
    this.projectKey = '',
    this.projectDescription = '',
    this.projectVisibility = 'open',
    this.startDate = '',
    this.variables = const {},
  });

  final String templateId;
  final String projectId;
  final String parentTaskId;
  final String projectName;
  final String projectKey;
  final String projectDescription;
  final String projectVisibility;
  final String startDate;
  final Map<String, String> variables;
}

@immutable
class ApplyResult {
  const ApplyResult({
    required this.projectId,
    required this.taskIds,
    required this.warnings,
  });

  final String projectId;
  final List<String> taskIds;

  /// What the template named that no longer exists and was skipped.
  final List<String> warnings;
}

enum TemplatesFailure { network, denied, invalid, notFound, conflict, other }

class TemplatesException implements Exception {
  const TemplatesException(this.failure, {this.detail});

  final TemplatesFailure failure;
  final String? detail;

  @override
  String toString() => 'TemplatesException($failure)';
}

String templatesErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! TemplatesException) return t.grpLGeneric;
  final detail = error.detail;
  return switch (error.failure) {
    TemplatesFailure.network => t.grpLNetCheckShort,
    TemplatesFailure.denied => t.tplDenied,
    TemplatesFailure.notFound => t.tplGone,
    TemplatesFailure.conflict => t.tplConflict,
    TemplatesFailure.invalid =>
      detail != null && detail.isNotEmpty ? detail : t.grpLNotValid,
    TemplatesFailure.other => t.grpLGeneric,
  };
}

String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
