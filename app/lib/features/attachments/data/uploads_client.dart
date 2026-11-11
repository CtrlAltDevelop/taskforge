import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';

/// How long a call may take before it counts as a lost connection. A chunk is
/// megabytes on a slow line, so it gets longer than the rest.
const shortCallTimeout = Duration(seconds: 20);
const chunkCallTimeout = Duration(seconds: 60);

/// The first part of a text file, and whether there was more.
typedef TextPreview = ({String text, bool truncated});

/// The REST side of attachments: chunked, resumable uploads and signed links
/// to files. Files suit HTTP better than gRPC (browsers, big bodies).
abstract interface class UploadsClient {
  Future<UploadSession> create({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String filename,
    required int size,
    String commentId = '',
  });

  /// The session again, with what the server already has (for a resume).
  Future<UploadSession> status(String id);

  /// Sends chunk [n]; answers with every chunk the server now has. Completing
  /// [abort] drops the request in flight.
  Future<Set<int>> putChunk(
    String id,
    int n,
    List<int> bytes, {
    Future<void>? abort,
  });

  Future<Attachment> complete(String id);

  Future<void> cancel(String id);

  /// A signed link to the file (or its thumbnail), good for a short while.
  Future<FileLink> link(String id, {bool thumb = false});

  /// The first [maxBytes] of the file at [url], as text.
  Future<TextPreview> fetchText(String url, {int maxBytes = 200 * 1024});

  /// Lets go of the connections.
  void close();
}

class HttpUploadsClient implements UploadsClient {
  HttpUploadsClient(
    this._session, {
    required this.restUrl,
    required String? Function() selectedWorkspace,
    http.Client? httpClient,
    this.shortTimeout = shortCallTimeout,
    this.chunkTimeout = chunkCallTimeout,
  }) : _selected = selectedWorkspace,
       _http = httpClient ?? http.Client();

  /// How long an ordinary call, and a chunk, may take.
  final Duration shortTimeout;
  final Duration chunkTimeout;

  final AuthSession _session;
  final String restUrl;
  final String? Function() _selected;
  final http.Client _http;

  @override
  void close() => _http.close();

  Future<http.Response> _send(
    String method,
    String path, {
    Object? json,
    List<int>? bytes,
    Map<String, String>? query,
    Future<void>? abort,
    Duration? timeout,
  }) async {
    final limit = timeout ?? shortTimeout;
    Future<http.Response> once(String token) async {
      final uri = Uri.parse('$restUrl/api/v1$path')
          .replace(queryParameters: query);
      final request = http.AbortableRequest(method, uri, abortTrigger: abort)
        ..headers.addAll(scopedHeaders(token, _selected()));
      if (json != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(json);
      }
      if (bytes != null) {
        request.headers['Content-Type'] = 'application/octet-stream';
        request.bodyBytes = bytes;
      }
      return http.Response.fromStream(await _http.send(request));
    }

    try {
      final token = await _session.accessToken();
      if (token == null) {
        throw const AttachmentException(AttachmentFailure.forbidden);
      }
      var response = await once(token).timeout(limit);
      if (response.statusCode == 401) {
        final fresh = await _session.forceRefresh();
        if (fresh != null) {
          response = await once(await _session.accessToken() ?? token)
              .timeout(limit);
        }
      }
      return response;
    } on AttachmentException {
      rethrow;
    } on Object {
      // A timeout, an abort, a dropped line: all "no connection" here.
      throw const AttachmentException(AttachmentFailure.network);
    }
  }

  /// The `data` of a good answer, or the exception for a refused one. [chunk]
  /// says the call was a chunk upload, where a 400/413/404 means something
  /// other than it does elsewhere.
  Map<String, dynamic> _data(http.Response response, {bool chunk = false}) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on Object {
      body = const {};
    }
    if (response.statusCode < 400) {
      return (body['data'] as Map<String, dynamic>?) ?? const {};
    }
    throw _refusal(response.statusCode, body, chunk: chunk);
  }

  AttachmentException _refusal(
    int status,
    Map<String, dynamic> body, {
    bool chunk = false,
  }) {
    final title = body['title'] as String? ?? '';
    final data = body['data'];
    final errors = body['errors'];
    final first = errors is List && errors.isNotEmpty
        ? '${errors.first}'
        : null;
    // The status comes first: the scanner being down (503) and "too many
    // uploads" (429) share a title with a refusal and the workspace being full.
    if (status == 503) {
      return const AttachmentException(AttachmentFailure.unavailable);
    }
    if (status == 429) {
      return const AttachmentException(AttachmentFailure.tooManyUploads);
    }
    if (chunk && (status == 413 || status == 400)) {
      return const AttachmentException(AttachmentFailure.chunkRejected);
    }
    if (chunk && status == 404) {
      return const AttachmentException(AttachmentFailure.expired);
    }
    if (title == 'ATTACHMENT_TOO_BIG' || status == 413) {
      return const AttachmentException(AttachmentFailure.tooBig);
    }
    return switch (title) {
      'ATTACHMENT_QUOTA' => const AttachmentException(AttachmentFailure.quota),
      'ATTACHMENT_REFUSED' => AttachmentException(
        AttachmentFailure.refused,
        detail: (data is Map ? data['reason'] as String? : null) ?? first,
      ),
      'UPLOAD_INCOMPLETE' => AttachmentException(
        AttachmentFailure.incomplete,
        missing: _numbers(data is Map ? data['missing'] : null),
      ),
      'UPLOAD_EXPIRED' ||
      'LINK_EXPIRED' => const AttachmentException(AttachmentFailure.expired),
      _ => switch (status) {
        401 || 403 =>
          data is Map && data['permission'] is String
              ? AttachmentException(
                  AttachmentFailure.denied,
                  detail: 'You need permission "${data['permission']}"',
                )
              : const AttachmentException(AttachmentFailure.forbidden),
        404 => const AttachmentException(AttachmentFailure.notFound),
        >= 500 => const AttachmentException(AttachmentFailure.network),
        _ => AttachmentException(AttachmentFailure.other, detail: first),
      },
    };
  }

  /// Chunk numbers as the server writes them: a comma-joined string like
  /// "1,2,3" (a list is taken too).
  static List<int> _numbers(Object? raw) {
    final parts = switch (raw) {
      final String s => s.split(','),
      final List<dynamic> l => l,
      _ => const <Object?>[],
    };
    return List.unmodifiable([
      for (final p in parts) ?int.tryParse('$p'.trim()),
    ]);
  }

  UploadSession _sessionOf(Map<String, dynamic> d) => UploadSession(
    id: d['id'] as String,
    chunkSize: (d['chunk_size'] as num).toInt(),
    chunkCount: (d['chunk_count'] as num).toInt(),
    received: Set.unmodifiable([
      for (final n in (d['received'] as List<dynamic>? ?? const []))
        (n as num).toInt(),
    ]),
  );

  @override
  Future<UploadSession> create({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String filename,
    required int size,
    String commentId = '',
  }) async => _sessionOf(
    _data(
      await _send(
        'POST',
        '/uploads',
        json: {
          'workspace_id': workspaceId,
          'project_id': projectId,
          'task_id': taskId,
          if (commentId.isNotEmpty) 'comment_id': commentId,
          'filename': filename,
          'size': size,
        },
      ),
    ),
  );

  @override
  Future<UploadSession> status(String id) async =>
      _sessionOf(_data(await _send('GET', '/uploads/$id')));

  @override
  Future<Set<int>> putChunk(
    String id,
    int n,
    List<int> bytes, {
    Future<void>? abort,
  }) async {
    final data = _data(
      await _send(
        'PUT',
        '/uploads/$id/chunk/$n',
        bytes: bytes,
        abort: abort,
        timeout: chunkTimeout,
      ),
      chunk: true,
    );
    return {
      for (final c in (data['received'] as List<dynamic>? ?? const []))
        (c as num).toInt(),
    };
  }

  @override
  Future<Attachment> complete(String id) async {
    final d = _data(
      await _send('POST', '/uploads/$id/complete', timeout: chunkTimeout),
    );
    return Attachment(
      id: d['id'] as String,
      taskId: d['task_id'] as String,
      commentId: (d['comment_id'] as String?) ?? '',
      uploaderId: d['uploader_id'] as String,
      filename: d['filename'] as String,
      mime: d['mime'] as String,
      size: (d['size'] as num).toInt(),
      hasThumb: (d['has_thumb'] as bool?) ?? false,
      createdAt: DateTime.tryParse('${d['created_at']}') ?? DateTime.now(),
    );
  }

  @override
  Future<void> cancel(String id) async {
    _data(await _send('DELETE', '/uploads/$id'));
  }

  @override
  Future<FileLink> link(String id, {bool thumb = false}) async {
    final d = _data(
      await _send(
        'GET',
        '/files/$id/link',
        query: {'thumb': thumb ? '1' : '0'},
      ),
    );
    final url = d['url'] as String;
    return FileLink(
      // A relative link is relative to the server.
      url.startsWith('http') ? url : '$restUrl$url',
      DateTime.tryParse('${d['expires_at']}') ??
          DateTime.now().add(const Duration(minutes: 1)),
    );
  }

  @override
  Future<TextPreview> fetchText(String url, {int maxBytes = 200 * 1024}) async {
    try {
      final request = http.Request('GET', Uri.parse(url))
        // One byte more than shown, to know whether there was more.
        ..headers['Range'] = 'bytes=0-$maxBytes';
      final response = await _http.send(request).timeout(shortTimeout);
      if (response.statusCode >= 400) {
        throw const AttachmentException(AttachmentFailure.notFound);
      }
      final out = BytesBuilder(copy: false);
      // A server that ignores the Range sends the whole file: we stop reading.
      await for (final part in response.stream.timeout(shortTimeout)) {
        out.add(part);
        if (out.length > maxBytes) break;
      }
      final bytes = out.takeBytes();
      final truncated = bytes.length > maxBytes;
      return (
        text: utf8.decode(
          truncated ? bytes.sublist(0, maxBytes) : bytes,
          allowMalformed: true,
        ),
        truncated: truncated,
      );
    } on AttachmentException {
      rethrow;
    } on Object {
      throw const AttachmentException(AttachmentFailure.network);
    }
  }
}
