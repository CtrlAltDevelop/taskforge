import 'dart:async';

import 'package:taskforge/features/search/data/search_client.dart';
import 'package:taskforge/features/search/domain/search.dart';

SearchHit taskHit(
  String id,
  String title, {
  List<Mark> marks = const [],
  String snippet = '',
  String project = 'p1',
}) => SearchHit(
  kind: SearchKind.task,
  id: id,
  title: title,
  taskId: id,
  projectId: project,
  key: 'WEB-$id',
  titleMarks: marks,
  snippet: snippet,
  status: 'To do',
);

/// An in-memory search: answers from a function the test sets, notes what it
/// was asked, and can be held back to test overtaking.
class FakeSearchClient implements SearchClient {
  FakeSearchClient({this.answer});

  SearchResults Function(String text, List<SearchKind> types, String cursor)?
  answer;
  List<String> recentValue = [];
  Object? failNext;
  final gates = <String, Completer<void>>{};
  final queries = <({String text, List<SearchKind> types, String cursor})>[];
  final remembered = <String>[];

  @override
  Future<SearchResults> query(
    String workspaceId,
    String text, {
    List<SearchKind> types = const [],
    String cursor = '',
    int pageSize = searchPageSize,
  }) async {
    queries.add((text: text, types: types, cursor: cursor));
    final gate = gates[text];
    if (gate != null) await gate.future;
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
    return answer?.call(text, types, cursor) ?? const SearchResults();
  }

  @override
  Future<void> remember(String workspaceId, String text) async =>
      remembered.add(text);

  @override
  Future<List<String>> recent(String workspaceId) async => recentValue;
}
