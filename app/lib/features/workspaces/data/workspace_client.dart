import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/gen/infrastructure/workspaces/grpc/workspaces.pbgrpc.dart'
    as pb;

abstract interface class WorkspaceClient {
  Future<List<Workspace>> list();

  /// The caller's own deleted workspaces still inside the 7-day restore window.
  Future<List<Workspace>> listDeleted();
  Future<Workspace> create({required String name, required String slug});
  Future<Workspace> update(
    String id, {
    required int expectedVersion,
    String? name,
    String? slug,
  });
  Future<Workspace> delete(String id, {required String confirmation});
  Future<Workspace> restore(String id);
  Future<Workspace> uploadLogo(
    Workspace workspace, {
    required List<int> bytes,
    required String filename,
  });
}

/// Maps a transport failure to a [WorkspaceException] the UI can explain.
WorkspaceException mapWorkspaceError(Object error) {
  if (error is WorkspaceException) return error;
  if (error is GrpcError) {
    return switch (error.code) {
      StatusCode.alreadyExists => const WorkspaceException(
        WorkspaceFailure.slugTaken,
      ),
      StatusCode.permissionDenied => const WorkspaceException(
        WorkspaceFailure.forbidden,
      ),
      StatusCode.aborted => const WorkspaceException(WorkspaceFailure.stale),
      StatusCode.invalidArgument => WorkspaceException(
        WorkspaceFailure.invalid,
        stripErrorTitle(error.message),
      ),
      StatusCode.notFound => const WorkspaceException(
        WorkspaceFailure.notFound,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const WorkspaceException(WorkspaceFailure.network),
      _ => const WorkspaceException(WorkspaceFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const WorkspaceException(WorkspaceFailure.network);
  }
  return const WorkspaceException(WorkspaceFailure.other);
}

Workspace _fromPb(pb.Workspace w) => Workspace(
  id: w.id,
  name: w.name,
  slug: w.slug,
  logo: w.logo,
  version: w.version,
  isOwner: w.isOwner,
);

/// gRPC for the data calls, REST for the logo upload.
class GrpcWorkspaceClient implements WorkspaceClient {
  GrpcWorkspaceClient(
    ClientChannelBase channel,
    this._session, {
    required this.restUrl,
    required String? Function() selectedWorkspace,
    http.Client? httpClient,
  }) : _rpc = pb.WorkspaceControllerClient(channel),
       _selected = selectedWorkspace,
       _http = httpClient ?? http.Client();

  final pb.WorkspaceControllerClient _rpc;
  final AuthSession _session;
  final String restUrl;
  final String? Function() _selected;
  final http.Client _http;

  // Workspace calls name their workspace in the body, so no x-workspace header.
  late final _options = scopedCallOptions(_session, () => null);

  /// Runs [call]; one refresh-and-retry when the token is rejected.
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
      throw mapWorkspaceError(e);
    }
  }

  @override
  Future<List<Workspace>> list() async {
    final reply = await _run(() => _rpc.list(Empty(), options: _options));
    return [for (final w in reply.workspaces) _fromPb(w)];
  }

  @override
  Future<List<Workspace>> listDeleted() async {
    final reply = await _run(
      () => _rpc.listDeleted(Empty(), options: _options),
    );
    return [for (final w in reply.workspaces) _fromPb(w)];
  }

  @override
  Future<Workspace> create({
    required String name,
    required String slug,
  }) async => _fromPb(
    await _run(
      () => _rpc.create(
        pb.WorkspaceCreateRequest(name: name, slug: slug),
        options: _options,
      ),
    ),
  );

  @override
  Future<Workspace> update(
    String id, {
    required int expectedVersion,
    String? name,
    String? slug,
  }) async => _fromPb(
    await _run(
      () => _rpc.update(
        pb.WorkspaceUpdateRequest(
          id: id,
          expectedVersion: expectedVersion,
          name: name,
          slug: slug,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Workspace> delete(String id, {required String confirmation}) async =>
      _fromPb(
        await _run(
          () => _rpc.delete(
            pb.WorkspaceDeleteRequest(id: id, confirmation: confirmation),
            options: _options,
          ),
        ),
      );

  @override
  Future<Workspace> restore(String id) async => _fromPb(
    await _run(
      () => _rpc.restore(pb.WorkspaceRestoreRequest(id: id), options: _options),
    ),
  );

  @override
  Future<Workspace> uploadLogo(
    Workspace workspace, {
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final token = await _session.accessToken();
      if (token == null) throw const WorkspaceException(WorkspaceFailure.other);
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('$restUrl/api/v1/workspaces/${workspace.id}/logo'),
            )
            ..headers.addAll(scopedHeaders(token, _selected()))
            ..fields['expected_version'] = '${workspace.version}'
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: filename),
            );
      final response = await http.Response.fromStream(
        await _http.send(request),
      );
      return _parseLogoReply(workspace, response);
    } on Object catch (e) {
      throw mapWorkspaceError(e);
    }
  }

  Workspace _parseLogoReply(Workspace old, http.Response response) {
    final status = response.statusCode;
    if (status >= 400) {
      throw switch (status) {
        401 || 403 => const WorkspaceException(WorkspaceFailure.forbidden),
        409 => const WorkspaceException(WorkspaceFailure.stale),
        404 => const WorkspaceException(WorkspaceFailure.notFound),
        _ => WorkspaceException(
          WorkspaceFailure.invalid,
          _firstError(response),
        ),
      };
    }
    final data =
        (jsonDecode(response.body) as Map<String, dynamic>)['data']
            as Map<String, dynamic>;
    return Workspace(
      id: data['id'] as String,
      name: data['name'] as String,
      slug: data['slug'] as String,
      logo: (data['logo'] as String?) ?? '',
      version: data['version'] as int,
      isOwner: old.isOwner,
    );
  }

  String? _firstError(http.Response response) {
    try {
      final errors = (jsonDecode(response.body) as Map)['errors'];
      return errors is List && errors.isNotEmpty ? '${errors.first}' : null;
    } on Object {
      return null;
    }
  }
}
