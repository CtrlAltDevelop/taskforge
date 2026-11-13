import 'package:flutter/material.dart';

import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/fields/presentation/field_input.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What the list needs to put names to ids: the workflow's statuses, the
/// project's members and its custom fields.
class ListLookups {
  const ListLookups({
    this.flow,
    this.members = const [],
    this.fields = const [],
  });

  final Workflow? flow;
  final List<Member> members;
  final List<CustomField> fields;

  String person(String userId) =>
      members.where((m) => m.userId == userId).firstOrNull?.label ?? userId;

  CustomField? field(String column) {
    if (!column.startsWith(fieldColumnPrefix)) return null;
    final id = column.substring(fieldColumnPrefix.length);
    return fields.where((f) => f.id == id).firstOrNull;
  }

  /// The heading of a column: a built-in's name or the custom field's.
  String columnLabel(String column) =>
      builtInColumns[column] ?? field(column)?.name ?? '';

  /// Whether the list can be sorted by [column] (a multi-select field cannot).
  bool sortable(String column) {
    if (sortableBuiltIns.contains(column)) return true;
    final f = field(column);
    return f != null && f.type != FieldType.multiselect;
  }

  /// A column that is a custom field that has been archived or removed since
  /// the layout was saved is not shown.
  bool known(String column) =>
      builtInColumns.containsKey(column) || field(column) != null;

  /// The name of a group on its header.
  String groupLabel(String groupBy, String key, [AppLocalizations? l10n]) {
    final t = l10n ?? lookupAppLocalizations(const Locale('en'));
    if (key.isEmpty) {
      return switch (groupBy) {
        'assignee' => t.grpFUnassigned,
        _ => t.grpFNoValue,
      };
    }
    return switch (groupBy) {
      'status' => flow?.statusById(key)?.name ?? t.grpFStatus,
      'priority' => TaskPriority.parse(key).label,
      'assignee' => person(key),
      _ => field(groupBy)?.option(key)?.label ?? t.grpFNoValue,
    };
  }

  Color? groupColor(String groupBy, String key) {
    if (groupBy == 'status') return flow?.statusById(key)?.swatch;
    final option = field(groupBy)?.option(key);
    return groupBy.startsWith(fieldColumnPrefix) && option != null
        ? optionColor(option)
        : null;
  }

  /// What the group-by menu offers: the fixed ones and each select field.
  List<({String key, String label})> get groupChoices =>
      groupChoicesFor(lookupAppLocalizations(const Locale('en')));

  /// [groupChoices] with the built-in names in the language on screen.
  List<({String key, String label})> groupChoicesFor(AppLocalizations l10n) => [
    (key: 'status', label: l10n.grpFStatus),
    (key: 'assignee', label: l10n.grpFAssignee),
    (key: 'priority', label: l10n.grpFPriority),
    for (final f in fields)
      if (f.type == FieldType.select)
        (key: '$fieldColumnPrefix${f.id}', label: f.name),
  ];
}
