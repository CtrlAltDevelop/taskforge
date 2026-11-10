import 'dart:convert';

import 'package:taskforge/features/filters/data/filters_client.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';

/// An in-memory query service. It does not read TFQL: [texts] says what each
/// text means (and renders the other way), so a test controls the "server".
class FakeFiltersClient implements FiltersClient {
  FakeFiltersClient({
    Map<String, FilterQuery>? texts,
    List<SavedFilter> saved = const [],
  }) : texts = {...?texts},
       filters = [...saved];

  /// text -> the query it means.
  final Map<String, FilterQuery> texts;
  final List<SavedFilter> filters;
  final validated = <({String tfql, String astJson})>[];
  final suggested = <({String partial, int cursor})>[];
  List<QuerySuggestion> suggestions = const [];
  FilterException? failSave;
  var _next = 1;

  String render(FilterQuery query) {
    for (final e in texts.entries) {
      if (e.value == query) return e.key;
    }
    return query.isEmpty ? '' : 'rendered:${query.conditionCount}';
  }

  @override
  Future<QueryChecked> validate(
    String workspaceId,
    String projectId, {
    String tfql = '',
    String astJson = '',
  }) async {
    validated.add((tfql: tfql, astJson: astJson));
    if (tfql.isNotEmpty || astJson.isEmpty) {
      final found = texts[tfql.trim()];
      if (tfql.trim().isEmpty) {
        return const QueryChecked(query: FilterQuery.none);
      }
      if (found == null) {
        return QueryChecked(
          errors: [
            QueryProblem(
              tfql.contains('?') ? tfql.indexOf('?') : 0,
              1,
              'Unexpected text.',
            ),
          ],
        );
      }
      return QueryChecked(query: found, tfql: tfql.trim());
    }
    final query = FilterQuery.fromJson(
      jsonDecode(astJson) as Map<String, dynamic>,
    );
    for (final c in _conditions(query.root)) {
      if (c.values.isEmpty &&
          !c.cmp.startsWith('empty') &&
          c.cmp != 'not_empty') {
        return const QueryChecked(
          errors: [QueryProblem(0, 1, 'A condition needs a value.')],
        );
      }
    }
    return QueryChecked(query: query, tfql: render(query));
  }

  Iterable<FilterCondition> _conditions(FilterNode node) sync* {
    if (node is FilterCondition) {
      yield node;
    } else if (node is FilterGroup) {
      for (final c in node.children) {
        yield* _conditions(c);
      }
    }
  }

  @override
  Future<List<QuerySuggestion>> suggest(
    String workspaceId,
    String projectId,
    String partial,
    int cursor,
  ) async {
    suggested.add((partial: partial, cursor: cursor));
    return suggestions;
  }

  @override
  Future<List<SavedFilter>> list(String workspaceId, String projectId) async =>
      [...filters];

  @override
  Future<SavedFilter> save(
    String workspaceId,
    String projectId, {
    required String name,
    required FilterQuery query,
    String visibility = 'private',
    String id = '',
    int expectedVersion = 0,
  }) async {
    final failure = failSave;
    if (failure != null) throw failure;
    if (filters.any((f) => f.name.toLowerCase() == name.toLowerCase())) {
      throw const FilterException(FilterFailure.nameTaken);
    }
    final saved = SavedFilter(
      id: 'f${_next++}',
      name: name,
      visibility: visibility,
      query: query,
      tfql: render(query),
      version: 1,
      projectId: projectId,
    );
    filters.add(saved);
    return saved;
  }

  @override
  Future<void> delete(String workspaceId, String projectId, String id) async {
    filters.removeWhere((f) => f.id == id);
  }
}
