import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Columns a list can show besides the title, in the order they are offered.
/// A custom field is `field:<id>` ([fieldColumnPrefix]).
const fieldColumnPrefix = 'field:';

const builtInColumns = <String, String>{
  'status': 'Status',
  'assignee': 'Assignee',
  'priority': 'Priority',
  'start_date': 'Start',
  'due_date': 'Due',
  'created_at': 'Created',
  'updated_at': 'Updated',
};

/// The label of [key] in the language of [l]; null when unknown.
String? builtInColumnLabelIn(AppLocalizations l, String key) => switch (key) {
  'status' => l.grpMLblStatus,
  'assignee' => l.grpMLblAssignee,
  'priority' => l.grpMLblPriority,
  'start_date' => l.grpMLblStart,
  'due_date' => l.grpMLblDue,
  'created_at' => l.grpMLblCreated,
  'updated_at' => l.grpMLblUpdated,
  _ => null,
};

/// The columns a new list starts with.
const defaultColumns = ['status', 'assignee', 'priority', 'due_date'];

/// What can be sorted by on the server (a custom field too, except multi-select).
const sortableBuiltIns = {
  'title',
  'status',
  'priority',
  'start_date',
  'due_date',
  'created_at',
  'updated_at',
};

/// What can be grouped by (a select field too).
const groupableBuiltIns = {'status', 'assignee', 'priority'};

const defaultColumnWidth = 140.0;
const titleDefaultWidth = 360.0;
const minColumnWidth = 60.0;
const maxColumnWidth = 800.0;
const maxSortKeys = 3;

@immutable
class SortKey {
  const SortKey(this.key, {this.desc = false});

  final String key;
  final bool desc;

  @override
  bool operator ==(Object other) =>
      other is SortKey && other.key == key && other.desc == desc;

  @override
  int get hashCode => Object.hash(key, desc);
}

/// What the server needs to order a list: the sort keys and the grouping.
@immutable
class ListQuery {
  const ListQuery({
    this.sort = const [],
    this.groupBy = '',
    this.filterAst = '',
  });

  final List<SortKey> sort;
  final String groupBy;

  /// A filter's AST as JSON ('' for none); the server keeps only what matches.
  final String filterAst;

  /// The tree order of every task: no sort, grouping or filter.
  bool get isDefault => sort.isEmpty && groupBy.isEmpty && filterAst.isEmpty;

  ListQuery withFilter(String ast) => ast == filterAst
      ? this
      : ListQuery(sort: sort, groupBy: groupBy, filterAst: ast);

  @override
  bool operator ==(Object other) =>
      other is ListQuery &&
      other.groupBy == groupBy &&
      other.filterAst == filterAst &&
      listEquals(other.sort, sort);

  @override
  int get hashCode => Object.hash(groupBy, filterAst, Object.hashAll(sort));
}

/// How a person likes a project's list: which columns, how wide, the sort and
/// the grouping. Immutable; every change returns a new layout.
@immutable
class ListLayout {
  const ListLayout({
    this.columns = defaultColumns,
    this.widths = const {},
    this.sort = const [],
    this.groupBy = '',
  });

  final List<String> columns;

  /// Pixel width per column (`title` included); a missing one is the default.
  final Map<String, double> widths;
  final List<SortKey> sort;
  final String groupBy;

  ListQuery get query => ListQuery(sort: sort, groupBy: groupBy);

  double widthOf(String column) =>
      widths[column] ??
      (column == 'title' ? titleDefaultWidth : defaultColumnWidth);

  ListLayout copyWith({
    List<String>? columns,
    Map<String, double>? widths,
    List<SortKey>? sort,
    String? groupBy,
  }) => ListLayout(
    columns: List.unmodifiable(columns ?? this.columns),
    widths: Map.unmodifiable(widths ?? this.widths),
    sort: List.unmodifiable(sort ?? this.sort),
    groupBy: groupBy ?? this.groupBy,
  );

  ListLayout withWidth(String column, double width) => copyWith(
    widths: {
      ...widths,
      column: width.clamp(minColumnWidth, maxColumnWidth).toDouble(),
    },
  );

  ListLayout withColumn(String column, {required bool shown}) {
    if (shown == columns.contains(column)) return this;
    return copyWith(
      columns: shown
          ? [...columns, column]
          : [
              for (final c in columns)
                if (c != column) c,
            ],
    );
  }

  /// A header click: this column becomes the only sort key, ascending; again,
  /// descending; again, no sort. With [add] (shift) it joins the keys
  /// instead, so a second click on it only flips or drops that key.
  ListLayout sortedBy(String key, {bool add = false}) {
    final current = sort.where((s) => s.key == key).firstOrNull;
    final next = switch (current) {
      null => SortKey(key),
      SortKey(desc: false) => SortKey(key, desc: true),
      _ => null,
    };
    final others = add
        ? [
            for (final s in sort)
              if (s.key != key) s,
          ]
        : const <SortKey>[];
    if (next == null) return copyWith(sort: others);
    final keys = [
      for (final s in sort)
        if (add && s.key == key) next else if (add) s,
      if (current == null) next,
    ];
    final joined = add ? keys : [next];
    return copyWith(
      sort: joined.length > maxSortKeys
          ? joined.sublist(0, maxSortKeys)
          : joined,
    );
  }

  ListLayout groupedBy(String key) => copyWith(groupBy: key);

  /// The layout as the server stores it.
  Map<String, Object> toJson() => {
    'columns': columns,
    'widths': {for (final e in widths.entries) e.key: e.value.round()},
    'sort': [
      for (final s in sort) {'key': s.key, 'desc': s.desc},
    ],
    'group_by': groupBy,
  };

  @override
  bool operator ==(Object other) =>
      other is ListLayout &&
      listEquals(other.columns, columns) &&
      mapEquals(other.widths, widths) &&
      listEquals(other.sort, sort) &&
      other.groupBy == groupBy;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(columns),
    Object.hashAll(widths.entries.map((e) => Object.hash(e.key, e.value))),
    Object.hashAll(sort),
    groupBy,
  );
}

/// One stored layout: the caller's own or one shared with the project.
@immutable
class SavedView {
  const SavedView({
    required this.id,
    required this.name,
    required this.layout,
    required this.isShared,
    required this.version,
    this.pinnedAsTab = false,
    this.tabOrder = 0,
  });

  final String id;
  final String name;
  final ListLayout layout;
  final bool isShared;
  final int version;

  /// Shown as its own tab on the project page, at [tabOrder] among the tabs.
  final bool pinnedAsTab;
  final int tabOrder;
}

/// The layouts pinned as tabs, in tab order.
List<SavedView> pinnedTabs(Iterable<SavedView> views) =>
    [
      for (final v in views)
        if (v.pinnedAsTab) v,
    ]..sort(
      (a, b) => a.tabOrder != b.tabOrder
          ? a.tabOrder.compareTo(b.tabOrder)
          : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

/// The name the person's own layout is saved under; they never see it.
const personalLayoutName = 'My layout';

enum ViewFailure {
  conflict,
  invalid,
  nameTaken,
  limit,
  denied,
  forbidden,
  archived,
  notFound,
  network,
  other,
}

class ViewException implements Exception {
  const ViewException(this.failure, {this.detail, this.version = 0});

  final ViewFailure failure;
  final String? detail;

  /// For [ViewFailure.conflict]: the layout's current version.
  final int version;

  @override
  String toString() => 'ViewException($failure, $detail)';
}

String viewErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! ViewException) return t.grpLGeneric;
  return switch (error.failure) {
    ViewFailure.conflict => t.grpLViewConflict,
    ViewFailure.invalid => error.detail ?? t.grpLViewInvalid,
    ViewFailure.nameTaken => t.grpLViewNameTaken,
    ViewFailure.limit => t.grpLViewLimit,
    ViewFailure.denied => error.detail ?? t.grpLNoPerm,
    ViewFailure.forbidden => t.grpLNoPermDo,
    ViewFailure.archived => t.grpLArchived,
    ViewFailure.notFound => t.grpLViewGone,
    ViewFailure.network => t.grpLNetCheck,
    ViewFailure.other => t.grpLGeneric,
  };
}
