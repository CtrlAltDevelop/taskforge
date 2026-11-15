import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/imports/domain/imports.dart';

/// The two REST calls importing needs: sending the file, and fetching an export.
abstract interface class ImportFiles {
  /// Sends [stream] (of [size] bytes) as a new import job. [source] empty:
  /// the server detects it.
  Future<UploadResult> upload({
    required String workspaceId,
    required String filename,
    required Stream<List<int>> stream,
    required int size,
    String source = '',
  });

  /// The ClickUp workspaces and lists [token] can read (the server keeps no
  /// copy of it).
  Future<List<ClickUpWorkspace>> clickupLists({
    required String workspaceId,
    required String token,
  });

  /// Starts fetching [listIds] into a new job (status `fetching`).
  Future<ImportJob> clickupFetch({
    required String workspaceId,
    required String token,
    required List<String> listIds,
  });

  /// The bytes behind a signed [path] (as `Export.Status` returns it).
  Future<Uint8List> fetch(String path);

  void close();
}

class HttpImportFiles implements ImportFiles {
  HttpImportFiles(
    this._session, {
    required this.restUrl,
    required String? Function() selectedWorkspace,
    http.Client? httpClient,
    this.timeout = const Duration(minutes: 30),
  }) : _selected = selectedWorkspace,
       _http = httpClient ?? http.Client();

  final AuthSession _session;
  final String restUrl;
  final String? Function() _selected;
  final http.Client _http;
  final Duration timeout;

  @override
  void close() => _http.close();

  Future<UploadResult> _once(
    String token,
    String workspaceId,
    String filename,
    Stream<List<int>> stream,
    int size,
    String source,
  ) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('$restUrl/api/v1/imports/upload'),
          )
          ..headers.addAll(scopedHeaders(token, _selected()))
          ..fields['workspace_id'] = workspaceId
          ..files.add(
            http.MultipartFile('file', stream, size, filename: filename),
          );
    if (source.isNotEmpty) request.fields['source'] = source;
    final response = await http.Response.fromStream(await _http.send(request))
        .timeout(timeout);
    if (response.statusCode == 401) throw const _Unauthorized();
    return _uploaded(response);
  }

  UploadResult _uploaded(http.Response response) {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on Object {
      body = null;
    }
    if (response.statusCode >= 400) {
      final message = '${body?['message'] ?? body?['detail'] ?? ''}';
      throw switch (response.statusCode) {
        403 => const ImportException(ImportFailure.denied),
        413 => const ImportException(ImportFailure.tooBig),
        400 || 422 => ImportException(ImportFailure.invalid, detail: message),
        _ => const ImportException(ImportFailure.other),
      };
    }
    final d = (body?['data'] as Map<String, dynamic>?) ?? body ?? const {};
    return UploadResult(
      id: '${d['id']}',
      source: '${d['source']}',
      filename: '${d['filename']}',
      size: (d['size'] as num?)?.toInt() ?? 0,
      member: '${d['member'] ?? ''}',
      members: List.unmodifiable(
        (d['members'] as List<dynamic>? ?? const []).map((m) => '$m'),
      ),
    );
  }

  @override
  Future<UploadResult> upload({
    required String workspaceId,
    required String filename,
    required Stream<List<int>> stream,
    required int size,
    String source = '',
  }) async {
    try {
      final token = await _session.accessToken();
      if (token == null) throw const ImportException(ImportFailure.denied);
      try {
        return await _once(token, workspaceId, filename, stream, size, source);
      } on _Unauthorized {
        // A stream can be read once: a refreshed token cannot resend it.
        await _session.forceRefresh();
        throw const ImportException(ImportFailure.network);
      }
    } on ImportException {
      rethrow;
    } on Object {
      throw const ImportException(ImportFailure.network);
    }
  }

  Future<dynamic> _post(String path, Map<String, Object?> body) async {
    try {
      final token = await _session.accessToken();
      if (token == null) throw const ImportException(ImportFailure.denied);
      final response = await _http
          .post(
            Uri.parse('$restUrl/api/v1$path'),
            headers: {
              ...scopedHeaders(token, _selected()),
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      Map<String, dynamic>? parsed;
      try {
        parsed = jsonDecode(response.body) as Map<String, dynamic>;
      } on Object {
        parsed = null;
      }
      if (response.statusCode >= 400) {
        final message = '${parsed?['message'] ?? parsed?['detail'] ?? ''}';
        throw switch (response.statusCode) {
          403 => const ImportException(ImportFailure.denied),
          400 ||
          422 ||
          429 => ImportException(ImportFailure.invalid, detail: message),
          _ => const ImportException(ImportFailure.other),
        };
      }
      return parsed?['data'] ?? parsed;
    } on ImportException {
      rethrow;
    } on Object {
      throw const ImportException(ImportFailure.network);
    }
  }

  @override
  Future<List<ClickUpWorkspace>> clickupLists({
    required String workspaceId,
    required String token,
  }) async {
    final data = await _post('/imports/clickup/lists', {
      'workspace_id': workspaceId,
      'token': token,
    });
    return List.unmodifiable(
      (data as List<dynamic>? ?? const []).map(
        (w) => ClickUpWorkspace.fromJson(w as Map<String, dynamic>),
      ),
    );
  }

  @override
  Future<ImportJob> clickupFetch({
    required String workspaceId,
    required String token,
    required List<String> listIds,
  }) async {
    final d = await _post('/imports/clickup/fetch', {
      'workspace_id': workspaceId,
      'token': token,
      'list_ids': listIds,
    }) as Map<String, dynamic>;
    return ImportJob(
      id: '${d['id']}',
      source: 'clickup_json',
      status: '${d['status']}',
    );
  }

  @override
  Future<Uint8List> fetch(String path) async {
    try {
      final response = await _http
          .get(Uri.parse('$restUrl/api/v1$path'))
          .timeout(timeout);
      if (response.statusCode == 410) {
        throw const ImportException(
          ImportFailure.conflict,
          detail: 'This link has expired. Start the export again.',
        );
      }
      if (response.statusCode >= 400) {
        throw const ImportException(ImportFailure.other);
      }
      return response.bodyBytes;
    } on ImportException {
      rethrow;
    } on Object {
      throw const ImportException(ImportFailure.network);
    }
  }
}

class _Unauthorized implements Exception {
  const _Unauthorized();
}
