import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/gen/infrastructure/search/grpc/search.pbgrpc.dart'
    as pb;

/// How many hits of each kind one question asks for.
const searchPageSize = 6;

abstract interface class SearchClient {
  /// [types] empty means every kind. [cursor] is what an earlier answer
  /// gave for the kind being continued.
  Future<SearchResults> query(
    String workspaceId,
    String text, {
    List<SearchKind> types = const [],
    String cursor = '',
    int pageSize = searchPageSize,
  });

  Future<void> remember(String workspaceId, String text);
  Future<List<String>> recent(String workspaceId);
}

SearchException mapSearchError(Object error) {
  if (error is SearchException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => SearchException(
        SearchFailure.invalid,
        detail: message,
      ),
      StatusCode.permissionDenied => const SearchException(
        SearchFailure.denied,
      ),
      StatusCode.resourceExhausted => const SearchException(
        SearchFailure.rateLimited,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const SearchException(SearchFailure.network),
      _ => const SearchException(SearchFailure.other),
    };
  }
  return const SearchException(SearchFailure.network);
}

SearchHit hitFromPb(pb.Hit h) => SearchHit(
  kind: SearchKind.of(h.kind) ?? SearchKind.task,
  id: h.id,
  title: h.title,
  taskId: h.taskId,
  projectId: h.projectId,
  key: h.key,
  titleMarks: [for (final m in h.titleMarks) Mark(m.start, m.end)],
  snippet: h.snippet,
  snippetMarks: [for (final m in h.snippetMarks) Mark(m.start, m.end)],
  projectName: h.projectName,
  status: h.status,
  author: h.author,
);

class GrpcSearchClient implements SearchClient {
  GrpcSearchClient(ClientChannelBase channel, this._session)
    : _client = pb.SearchControllerClient(channel);

  final pb.SearchControllerClient _client;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapSearchError(e);
    }
  }

  @override
  Future<SearchResults> query(
    String workspaceId,
    String text, {
    List<SearchKind> types = const [],
    String cursor = '',
    int pageSize = searchPageSize,
  }) => _run(() async {
    final answer = await _client.query(
      pb.SearchQueryRequest(
        workspaceId: workspaceId,
        text: text,
        types: [for (final t in types) t.wire],
        cursor: cursor,
        pageSize: pageSize,
      ),
      options: _options,
    );
    final hits = {
      SearchKind.task: answer.tasks.map(hitFromPb).toList(),
      SearchKind.comment: answer.comments.map(hitFromPb).toList(),
      SearchKind.project: answer.projects.map(hitFromPb).toList(),
      SearchKind.member: answer.members.map(hitFromPb).toList(),
      SearchKind.doc: answer.docs.map(hitFromPb).toList(),
    };
    return SearchResults(
      hits: hits,
      jump: answer.jump.id.isEmpty ? null : hitFromPb(answer.jump),
      cursors: {
        if (answer.nextCursor.isNotEmpty)
          for (final e in hits.entries)
            if (e.value.length >= pageSize) e.key: answer.nextCursor,
      },
    );
  });

  @override
  Future<void> remember(String workspaceId, String text) => _run(
    () => _client.remember(
      pb.SearchRememberRequest(workspaceId: workspaceId, text: text),
      options: _options,
    ),
  );

  @override
  Future<List<String>> recent(String workspaceId) => _run(
    () async => List.unmodifiable(
      (await _client.recent(
        pb.SearchRecentRequest(workspaceId: workspaceId),
        options: _options,
      )).queries,
    ),
  );
}
