import 'dart:async';
import 'dart:typed_data';

import 'package:taskforge/features/attachments/data/attachments_client.dart';
import 'package:taskforge/features/attachments/data/uploads_client.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';

class _Session {
  _Session(
    this.id,
    this.filename,
    this.size,
    this.commentId,
    this.taskId,
    this.workspaceId,
  );

  final String id;
  final String workspaceId;
  final String filename;
  final int size;
  final String commentId;
  final String taskId;
  final chunks = <int, List<int>>{};
}

/// An in-memory server for attachments: the gRPC list and the REST uploads.
/// Small [chunkSize] so a few bytes make several chunks.
class FakeAttachments implements AttachmentsClient, UploadsClient {
  FakeAttachments({
    this.me = 'u1',
    List<Attachment> initial = const [],
    this.chunkSize = 4,
    this.usageValue = const StorageUsage(
      usedBytes: 0,
      quotaBytes: 0,
      fileCount: 0,
      maxFileBytes: 1 << 20,
    ),
  }) : files = [...initial];

  final String me;
  final List<Attachment> files;
  final int chunkSize;
  StorageUsage usageValue;

  final _sessions = <String, _Session>{};
  var _next = 1;

  /// What the server was asked, in order.
  final created =
      <({String filename, int size, String commentId, String workspace})>[];
  final _fileWorkspace = <String, String>{};
  Completer<void>? deleteGate;
  Future<void>? lastAbort;
  final links = <String>[];
  Completer<void>? linkGate;
  AttachmentException? failLink;
  final puts = <({String id, int n, int length})>[];
  final cancelled = <String>[];
  final deleted = <String>[];
  var listCalls = 0;
  String textBody = 'hello text';
  bool textTruncated = false;
  bool closed = false;

  /// Failures handed out by the next put (one per call) / create / complete.
  final putFailures = <AttachmentException>[];
  AttachmentException? failCreate;
  AttachmentException? failComplete;
  final completeFailures = <AttachmentException>[];

  /// How many times `complete` does its work but its answer never arrives.
  int loseCompleteAnswers = 0;
  int completes = 0;
  AttachmentException? failDelete;

  /// When set, a chunk waits for it (to see progress mid-way).
  Completer<void>? gate;

  /// Sessions the server has forgotten.
  bool forgetSessions = false;

  /// Chunks to leave out of the answer to `complete` once (as if lost).
  final dropChunks = <int>[];

  String sessionOfLast() => 'up${_next - 1}';

  // -- AttachmentsClient -------------------------------------------------

  @override
  Future<List<Attachment>> list(
    String workspaceId,
    String projectId,
    String taskId,
  ) async {
    listCalls++;
    return List.unmodifiable([
      for (final f in files)
        if (f.taskId == taskId &&
            (_fileWorkspace[f.id] ?? workspaceId) == workspaceId)
          f,
    ]);
  }

  @override
  Future<void> delete(
    String workspaceId,
    String projectId,
    Attachment file,
  ) async {
    if (deleteGate != null) await deleteGate!.future;
    final failure = failDelete;
    if (failure != null) {
      failDelete = null;
      throw failure;
    }
    deleted.add(file.id);
    files.removeWhere((f) => f.id == file.id);
  }

  @override
  Future<StorageUsage> usage(String workspaceId) async => usageValue;

  // -- UploadsClient -----------------------------------------------------

  UploadSession _view(_Session s) => UploadSession(
    id: s.id,
    chunkSize: chunkSize,
    chunkCount: s.size == 0 ? 1 : (s.size + chunkSize - 1) ~/ chunkSize,
    received: s.chunks.keys.toSet(),
  );

  @override
  Future<UploadSession> create({
    required String workspaceId,
    required String projectId,
    required String taskId,
    required String filename,
    required int size,
    String commentId = '',
  }) async {
    final failure = failCreate;
    if (failure != null) {
      failCreate = null;
      throw failure;
    }
    created.add((
      filename: filename,
      size: size,
      commentId: commentId,
      workspace: workspaceId,
    ));
    final s = _Session(
      'up${_next++}',
      filename,
      size,
      commentId,
      taskId,
      workspaceId,
    );
    _sessions[s.id] = s;
    return _view(s);
  }

  @override
  Future<UploadSession> status(String id) async {
    final s = _sessions[id];
    if (s == null || forgetSessions) {
      throw const AttachmentException(AttachmentFailure.notFound);
    }
    return _view(s);
  }

  @override
  Future<Set<int>> putChunk(
    String id,
    int n,
    List<int> bytes, {
    Future<void>? abort,
  }) async {
    puts.add((id: id, n: n, length: bytes.length));
    lastAbort = abort;
    if (gate != null) await gate!.future;
    if (putFailures.isNotEmpty) throw putFailures.removeAt(0);
    final s = _sessions[id]!;
    s.chunks[n] = List.of(bytes);
    return s.chunks.keys.toSet();
  }

  @override
  Future<Attachment> complete(String id) async {
    completes++;
    if (completeFailures.isNotEmpty) throw completeFailures.removeAt(0);
    final failure = failComplete;
    if (failure != null) {
      failComplete = null;
      throw failure;
    }
    final s = _sessions[id];
    if (s == null) throw const AttachmentException(AttachmentFailure.notFound);
    for (final n in dropChunks) {
      s.chunks.remove(n);
    }
    final view = _view(s);
    final missing = [
      for (var n = 0; n < view.chunkCount; n++)
        if (!s.chunks.containsKey(n)) n,
    ];
    if (missing.isNotEmpty) {
      dropChunks.clear();
      throw AttachmentException(AttachmentFailure.incomplete, missing: missing);
    }
    final ext = s.filename.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'png' || 'jpg' => 'image/$ext',
      'txt' => 'text/plain',
      'pdf' => 'application/pdf',
      'mp4' => 'video/mp4',
      _ => 'application/octet-stream',
    };
    final file = Attachment(
      id: 'f${files.length + 1}',
      taskId: s.taskId,
      commentId: s.commentId,
      uploaderId: me,
      filename: s.filename,
      mime: mime,
      size: s.size,
      hasThumb: mime.startsWith('image/') || mime == 'application/pdf',
      createdAt: DateTime.now(),
    );
    files.add(file);
    _fileWorkspace[file.id] = s.workspaceId;
    _sessions.remove(id);
    if (loseCompleteAnswers > 0) {
      loseCompleteAnswers--;
      throw const AttachmentException(AttachmentFailure.network);
    }
    return file;
  }

  @override
  Future<void> cancel(String id) async {
    cancelled.add(id);
    _sessions.remove(id);
  }

  @override
  Future<FileLink> link(String id, {bool thumb = false}) async {
    links.add('$id${thumb ? '/thumb' : ''}');
    if (linkGate != null) await linkGate!.future;
    final failure = failLink;
    if (failure != null) throw failure;
    return FileLink(
      'https://files.test/$id${thumb ? '/thumb' : ''}',
      DateTime.now().add(const Duration(minutes: 2)),
    );
  }

  @override
  Future<TextPreview> fetchText(
    String url, {
    int maxBytes = 200 * 1024,
  }) async => (text: textBody, truncated: textTruncated);

  @override
  void close() => closed = true;

  /// All the bytes the server holds for the file [id] was uploaded as.
  Uint8List bytesOf(String sessionId) => Uint8List.fromList([
    for (final n
        in (_sessions[sessionId]?.chunks.keys.toList() ?? <int>[])..sort())
      ..._sessions[sessionId]!.chunks[n]!,
  ]);
}

Attachment attachment(
  String id,
  String filename, {
  String taskId = 'a',
  String uploader = 'u1',
  String mime = 'application/octet-stream',
  int size = 10,
  bool thumb = false,
}) => Attachment(
  id: id,
  taskId: taskId,
  uploaderId: uploader,
  filename: filename,
  mime: mime,
  size: size,
  hasThumb: thumb,
  createdAt: DateTime.now(),
);
