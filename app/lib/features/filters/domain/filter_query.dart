import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A value in a condition, as the server's AST holds it: text, an id (of a
/// status, option or person), a number, a date, a relative date (`+7d`), `me`,
/// true/false or a function like `currentSprint()`.
@immutable
class FilterValue {
  const FilterValue(this.kind, [this.value]) : amount = null, unit = null;

  const FilterValue.text(String text) : this('text', text);
  const FilterValue.id(String id) : this('id', id);
  const FilterValue.number(String number) : this('num', number);
  const FilterValue.date(String iso) : this('date', iso);
  const FilterValue.flag({required bool on}) : this('bool', on);
  const FilterValue.me() : this('me');
  const FilterValue.sprint() : this('func', 'currentSprint');
  const FilterValue.relative(int n, this.unit)
    : kind = 'rel',
      value = null,
      amount = n;

  final String kind;
  final Object? value;
  final int? amount;
  final String? unit;

  Map<String, Object?> toJson() => switch (kind) {
    'me' => {'k': 'me'},
    'rel' => {'k': 'rel', 'n': amount, 'u': unit},
    _ => {'k': kind, 'v': value},
  };

  factory FilterValue.fromJson(Map<String, dynamic> json) {
    final kind = json['k'] as String;
    return switch (kind) {
      'me' => const FilterValue.me(),
      'rel' => FilterValue.relative(json['n'] as int, json['u'] as String),
      _ => FilterValue(kind, json['v']),
    };
  }

  /// The text of a text/number/date value (for an input box).
  String get asText => switch (kind) {
    'rel' => amount == 0 ? 'today' : '${amount! >= 0 ? '+' : ''}$amount$unit',
    'me' => 'me',
    _ => '${value ?? ''}',
  };

  @override
  bool operator ==(Object other) =>
      other is FilterValue &&
      other.kind == kind &&
      other.value == value &&
      other.amount == amount &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(kind, value, amount, unit);
}

/// One node of the condition tree the builder edits: a group of nodes joined by
/// AND or OR (optionally negated) or a single condition.
@immutable
sealed class FilterNode {
  const FilterNode();

  /// The server's AST of this node.
  Map<String, Object?> toJson();
}

@immutable
class FilterCondition extends FilterNode {
  const FilterCondition({
    required this.field,
    required this.cmp,
    this.values = const [],
  });

  /// A built-in field's name or `cf:<id>`.
  final String field;

  /// eq ne lt lte gt gte contains not_contains in not_in empty not_empty.
  final String cmp;
  final List<FilterValue> values;

  FilterCondition copyWith({
    String? field,
    String? cmp,
    List<FilterValue>? values,
  }) => FilterCondition(
    field: field ?? this.field,
    cmp: cmp ?? this.cmp,
    values: List.unmodifiable(values ?? this.values),
  );

  @override
  Map<String, Object?> toJson() => {
    'op': 'cmp',
    'field': field,
    'cmp': cmp,
    'values': [for (final v in values) v.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is FilterCondition &&
      other.field == field &&
      other.cmp == cmp &&
      listEquals(other.values, values);

  @override
  int get hashCode => Object.hash(field, cmp, Object.hashAll(values));
}

@immutable
class FilterGroup extends FilterNode {
  const FilterGroup({
    this.op = 'and',
    this.children = const [],
    this.negated = false,
  });

  final String op; // and | or
  final List<FilterNode> children;
  final bool negated;

  FilterGroup copyWith({
    String? op,
    List<FilterNode>? children,
    bool? negated,
  }) => FilterGroup(
    op: op ?? this.op,
    children: List.unmodifiable(children ?? this.children),
    negated: negated ?? this.negated,
  );

  @override
  Map<String, Object?> toJson() {
    final Map<String, Object?> body = children.length == 1
        ? children.single.toJson()
        : {
            'op': op,
            'args': [for (final c in children) c.toJson()],
          };
    return negated ? {'op': 'not', 'arg': body} : body;
  }

  @override
  bool operator ==(Object other) =>
      other is FilterGroup &&
      other.op == op &&
      other.negated == negated &&
      listEquals(other.children, children);

  @override
  int get hashCode => Object.hash(op, negated, Object.hashAll(children));
}

@immutable
class FilterOrder {
  const FilterOrder(this.field, {this.desc = false});

  final String field;
  final bool desc;

  @override
  bool operator ==(Object other) =>
      other is FilterOrder && other.field == field && other.desc == desc;

  @override
  int get hashCode => Object.hash(field, desc);
}

/// A whole filter: a condition tree and an ORDER BY.
@immutable
class FilterQuery {
  const FilterQuery({this.root = const FilterGroup(), this.order = const []});

  static const none = FilterQuery();

  final FilterGroup root;
  final List<FilterOrder> order;

  bool get isEmpty => root.children.isEmpty && order.isEmpty;

  /// Conditions anywhere in the tree.
  int get conditionCount => _count(root);

  static int _count(FilterNode node) => switch (node) {
    FilterCondition() => 1,
    FilterGroup(:final children) => children.fold(0, (n, c) => n + _count(c)),
  };

  FilterQuery copyWith({FilterGroup? root, List<FilterOrder>? order}) =>
      FilterQuery(
        root: root ?? this.root,
        order: List.unmodifiable(order ?? this.order),
      );

  /// The AST the server takes as `filter_ast`.
  Map<String, Object?> toJson() => {
    'where': root.children.isEmpty ? null : root.toJson(),
    'order': [
      for (final o in order) {'field': o.field, 'desc': o.desc},
    ],
  };

  String toJsonString() => isEmpty ? '' : jsonEncode(toJson());

  /// Reads the server's AST. A negated condition becomes a negated group of
  /// one, so the builder can show it.
  factory FilterQuery.fromJson(Map<String, dynamic> json) {
    final where = json['where'] as Map<String, dynamic>?;
    final order = [
      for (final o in (json['order'] as List? ?? const []))
        FilterOrder(
          (o as Map<String, dynamic>)['field'] as String,
          desc: o['desc'] == true,
        ),
    ];
    if (where == null) return FilterQuery(order: order);
    final node = _node(where);
    final root = node is FilterGroup && !node.negated
        ? node
        : FilterGroup(children: [node]);
    return FilterQuery(root: root, order: order);
  }

  factory FilterQuery.fromJsonString(String json) => json.isEmpty
      ? none
      : FilterQuery.fromJson(jsonDecode(json) as Map<String, dynamic>);

  static FilterNode _node(Map<String, dynamic> json) {
    switch (json['op'] as String) {
      case 'cmp':
        return FilterCondition(
          field: json['field'] as String,
          cmp: json['cmp'] as String,
          values: [
            for (final v in json['values'] as List)
              FilterValue.fromJson(v as Map<String, dynamic>),
          ],
        );
      case 'not':
        final inner = _node(json['arg'] as Map<String, dynamic>);
        return inner is FilterGroup
            ? inner.copyWith(negated: !inner.negated)
            : FilterGroup(children: [inner], negated: true);
      default:
        return FilterGroup(
          op: json['op'] as String,
          children: [
            for (final a in json['args'] as List)
              _node(a as Map<String, dynamic>),
          ],
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is FilterQuery &&
      other.root == root &&
      listEquals(other.order, order);

  @override
  int get hashCode => Object.hash(root, Object.hashAll(order));
}

/// The node at [path] (child indexes from [group]) replaced by what [change]
/// returns (null removes it). Returns a new tree.
FilterGroup updateAt(
  FilterGroup group,
  List<int> path,
  FilterNode? Function(FilterNode) change,
) {
  if (path.isEmpty) {
    final next = change(group);
    return next is FilterGroup ? next : group;
  }
  final i = path.first;
  if (i < 0 || i >= group.children.length) return group;
  final child = group.children[i];
  final List<FilterNode> children;
  if (path.length == 1) {
    final next = change(child);
    children = [
      for (var k = 0; k < group.children.length; k++)
        if (k != i) group.children[k] else ?next,
    ];
  } else if (child is FilterGroup) {
    children = [
      for (var k = 0; k < group.children.length; k++)
        k == i ? updateAt(child, path.sublist(1), change) : group.children[k],
    ];
  } else {
    return group;
  }
  return group.copyWith(children: children);
}

/// The viewer's calendar day (`YYYY-MM-DD`), sent with a filter so relative dates
/// ("+7d", today) count from it.
String localToday() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}
