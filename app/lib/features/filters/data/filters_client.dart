import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart'
    show stripErrorTitle;
import 'package:taskforge/gen/infrastructure/filters/grpc/filters.pbgrpc.dart'
    as pb;

abstract interface class FiltersClient {
  /// Reads [tfql] (or [astJson] when [tfql] is empty) for a project (empty
  /// [projectId]: the workspace). A query that is wrong is an answer with
  /// problems, not an exception.
  Future<QueryChecked> validate(
    String workspaceId,
    String projectId, {
    String tfql = '',
    String astJson = '',
  });

  /// What could come next at [cursor] in [partial].
  Future<List<QuerySuggestion>> suggest(
    String workspaceId,
    String projectId,
    String partial,
    int cursor,
  );

  /// The filters the person may use in the project (shared ones first).
  Future<List<SavedFilter>> list(String workspaceId, String projectId);

  Future<SavedFilter> save(
    String workspaceId,
    String projectId, {
    required String name,
    required FilterQuery query,
    String visibility = 'private',
    String id = '',
    int expectedVersion = 0,
  });

  Future<void> delete(String workspaceId, String projectId, String id);
}

FilterException mapFilterError(Object error) {
  if (error is FilterException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.permissionDenied when denied != null => FilterException(
        FilterFailure.denied,
        detail: denied.message,
      ),
      StatusCode.permissionDenied => const FilterException(
        FilterFailure.forbidden,
      ),
      StatusCode.alreadyExists when title == 'PROJECT_ARCHIVED' =>
        const FilterException(FilterFailure.archived),
      StatusCode.alreadyExists when title == 'FILTER_NAME_TAKEN' =>
        const FilterException(FilterFailure.nameTaken),
      StatusCode.invalidArgument when title == 'FILTER_LIMIT' =>
        const FilterException(FilterFailure.limit),
      StatusCode.invalidArgument => FilterException(
        FilterFailure.invalid,
        detail: stripErrorTitle(message),
      ),
      StatusCode.notFound => const FilterException(FilterFailure.notFound),
      StatusCode.aborted => FilterException(
        FilterFailure.conflict,
        version: int.tryParse(errorTrailer(error, 'x-error-version-bin')) ?? 0,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const FilterException(FilterFailure.network),
      _ => const FilterException(FilterFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const FilterException(FilterFailure.network);
  }
  return const FilterException(FilterFailure.other);
}

SavedFilter _saved(pb.Filter f) => SavedFilter(
  id: f.id,
  name: f.name,
  visibility: f.visibility,
  query: FilterQuery.fromJsonString(f.astJson),
  tfql: f.tfql,
  version: f.version,
  projectId: f.projectId,
);

class GrpcFiltersClient implements FiltersClient {
  GrpcFiltersClient(ClientChannelBase channel, this._session)
    : _query = pb.QueryControllerClient(channel),
      _filters = pb.FilterControllerClient(channel);

  final pb.QueryControllerClient _query;
  final pb.FilterControllerClient _filters;
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
      throw mapFilterError(e);
    }
  }

  @override
  Future<QueryChecked> validate(
    String workspaceId,
    String projectId, {
    String tfql = '',
    String astJson = '',
  }) => _run(() async {
    final reply = await _query.validate(
      pb.QueryValidateRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        tfql: tfql,
        astJson: astJson,
      ),
      options: _options,
    );
    return QueryChecked(
      query: reply.ok ? FilterQuery.fromJsonString(reply.astJson) : null,
      tfql: reply.tfql,
      errors: [
        for (final e in reply.errors)
          QueryProblem(e.position, e.length, e.message),
      ],
    );
  });

  @override
  Future<List<QuerySuggestion>> suggest(
    String workspaceId,
    String projectId,
    String partial,
    int cursor,
  ) => _run(() async {
    final reply = await _query.suggest(
      pb.QuerySuggestRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        partial: partial,
        cursor: cursor,
      ),
      options: _options,
    );
    return [
      for (final s in reply.items)
        QuerySuggestion(s.text, s.kind, s.start, s.label),
    ];
  });

  @override
  Future<List<SavedFilter>> list(String workspaceId, String projectId) =>
      _run(() async {
        final reply = await _filters.list(
          pb.FilterListRequest(workspaceId: workspaceId, projectId: projectId),
          options: _options,
        );
        return [for (final f in reply.filters) _saved(f)];
      });

  @override
  Future<SavedFilter> save(
    String workspaceId,
    String projectId, {
    required String name,
    required FilterQuery query,
    String visibility = 'private',
    String id = '',
    int expectedVersion = 0,
  }) => _run(
    () async => _saved(
      await _filters.save(
        pb.FilterSaveRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: id,
          expectedVersion: expectedVersion,
          name: name,
          astJson: query.toJsonString(),
          visibility: visibility,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<void> delete(String workspaceId, String projectId, String id) =>
      _run(() async {
        await _filters.delete(
          pb.FilterDeleteRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            id: id,
          ),
          options: _options,
        );
      });
}
