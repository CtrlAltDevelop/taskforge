import 'package:flutter/foundation.dart';

import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// What a field holds, which decides the operators and the value editor. The
/// server's `language.KIND_OPS` has the same table.
enum FilterKind {
  text,
  status,
  category,
  priority,
  select,
  multiselect,
  user,
  date,
  datetime,
  number,
  bool,
  id,
  sprint,
}

const _lists = ['in', 'not_in'];
const _empties = ['empty', 'not_empty'];
const _ordering = ['lt', 'lte', 'gt', 'gte'];

const operatorsOf = <FilterKind, List<String>>{
  FilterKind.text: [
    'eq',
    'ne',
    'contains',
    'not_contains',
    ..._lists,
    ..._empties,
  ],
  FilterKind.status: ['eq', 'ne', ..._lists],
  FilterKind.category: ['eq', 'ne', ..._lists],
  FilterKind.priority: ['eq', 'ne', ..._lists],
  FilterKind.select: ['eq', 'ne', ..._lists, ..._empties],
  FilterKind.multiselect: ['eq', 'ne', ..._lists, ..._empties],
  FilterKind.user: ['eq', 'ne', ..._lists, ..._empties],
  FilterKind.date: ['eq', 'ne', ..._ordering, ..._empties],
  FilterKind.datetime: ['eq', 'ne', ..._ordering],
  FilterKind.number: ['eq', 'ne', ..._ordering, ..._empties],
  FilterKind.bool: ['eq', 'ne'],
  FilterKind.id: ['eq', 'ne', ..._lists],
  FilterKind.sprint: ['eq', 'ne'],
};

const operatorLabels = {
  'eq': 'is',
  'ne': 'is not',
  'lt': 'before / less than',
  'lte': 'on or before / at most',
  'gt': 'after / more than',
  'gte': 'on or after / at least',
  'contains': 'contains',
  'not_contains': 'does not contain',
  'in': 'is any of',
  'not_in': 'is none of',
  'empty': 'is empty',
  'not_empty': 'is not empty',
};

bool takesList(String cmp) => cmp == 'in' || cmp == 'not_in';
bool takesNoValue(String cmp) => cmp == 'empty' || cmp == 'not_empty';

/// A fixed choice of a field (a status, an option, a person, a priority).
@immutable
class FilterChoice {
  const FilterChoice(this.id, this.label);

  final String id;
  final String label;
}

@immutable
class FilterField {
  const FilterField(
    this.ref,
    this.label,
    this.kind, {
    this.choices = const [],
    this.sortable = false,
  });

  /// A built-in's name or `cf:<id>`.
  final String ref;
  final String label;
  final FilterKind kind;
  final List<FilterChoice> choices;

  /// ORDER BY can use it.
  final bool sortable;

  List<String> get operators => operatorsOf[kind]!;

  bool get hasChoices => const {
    FilterKind.status,
    FilterKind.category,
    FilterKind.priority,
    FilterKind.select,
    FilterKind.multiselect,
    FilterKind.user,
  }.contains(kind);
}

const _priorities = [
  FilterChoice('urgent', 'Urgent'),
  FilterChoice('high', 'High'),
  FilterChoice('normal', 'Normal'),
  FilterChoice('low', 'Low'),
  FilterChoice('none', 'None'),
];
const _categories = [
  FilterChoice('not_started', 'Not started'),
  FilterChoice('active', 'Active'),
  FilterChoice('done', 'Done'),
  FilterChoice('cancelled', 'Cancelled'),
];

/// The fields a project's filter can name: the built-ins, then its custom
/// fields. People are offered as `me` and the members.
List<FilterField> filterFields({
  Workflow? flow,
  List<Member> members = const [],
  List<CustomField> fields = const [],
  bool workspaceWide = false,
}) {
  final people = [for (final m in members) FilterChoice(m.userId, m.label)];
  final all = [
    const FilterField('title', 'Title', FilterKind.text, sortable: true),
    FilterField(
      'status',
      'Status',
      FilterKind.status,
      sortable: true,
      choices: [
        for (final s in flow?.statuses ?? const <WorkflowStatus>[])
          FilterChoice(s.id, s.name),
      ],
    ),
    const FilterField(
      'category',
      'Status category',
      FilterKind.category,
      choices: _categories,
    ),
    const FilterField(
      'priority',
      'Priority',
      FilterKind.priority,
      choices: _priorities,
      sortable: true,
    ),
    FilterField('assignee', 'Assignee', FilterKind.user, choices: people),
    const FilterField('due', 'Due date', FilterKind.date, sortable: true),
    const FilterField('start', 'Start date', FilterKind.date, sortable: true),
    const FilterField(
      'created',
      'Created',
      FilterKind.datetime,
      sortable: true,
    ),
    const FilterField(
      'updated',
      'Updated',
      FilterKind.datetime,
      sortable: true,
    ),
    const FilterField('blocked', 'Blocked', FilterKind.bool),
    const FilterField('id', 'Task number', FilterKind.id, sortable: true),
    for (final f in fields)
      FilterField(
        'cf:${f.id}',
        f.name,
        _kindOf(f.type),
        sortable: f.type != FieldType.multiselect,
        choices: [
          if (f.type == FieldType.select || f.type == FieldType.multiselect)
            for (final o in f.options) FilterChoice(o.id, o.label),
          if (f.type == FieldType.user) ...people,
        ],
      ),
  ];
  // Across projects only what means the same in each: no status, task number
  // or custom field.
  return workspaceWide
      ? [
          for (final f in all)
            if (f.ref != 'status' && f.ref != 'id' && !f.ref.startsWith('cf:'))
              f,
        ]
      : all;
}

FilterKind _kindOf(FieldType type) => switch (type) {
  FieldType.text || FieldType.url => FilterKind.text,
  FieldType.number || FieldType.money => FilterKind.number,
  FieldType.select => FilterKind.select,
  FieldType.multiselect => FilterKind.multiselect,
  FieldType.date => FilterKind.date,
  FieldType.checkbox => FilterKind.bool,
  FieldType.user => FilterKind.user,
};
