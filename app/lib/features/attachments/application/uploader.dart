import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:taskforge/features/attachments/data/uploads_client.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';

/// Thrown out of [runUpload] when the person cancelled it.
class UploadCancelled implements Exception {
  const UploadCancelled();
}

/// Waits before retry number [attempt] (0, 1, ...) of a chunk.
typedef Backoff = Future<void> Function(int attempt);

/// Looks among the task's files for one this person just uploaded with this
/// name, size and comment: an upload whose last answer was lost may have
/// worked.
typedef FindUploaded = Future<Attachment?> Function(
  String filename,
  int size,
  String commentId,
);

Future<void> exponentialBackoff(int attempt) => Future<void>.delayed(
  Duration(milliseconds: 400 * math.pow(2, attempt).toInt()),
);

const _attempts = 3;

/// Sends [source] as a chunked upload and returns the stored attachment.
///
/// With a [sessionId] from an earlier try it asks the server what it already
/// has and sends only the rest (a new session when the old one is gone, unless
/// [findUploaded] says the file already made it). A chunk, and the final
/// `complete`, that fail for want of a connection are tried again a few times;
/// a refusal stops the upload at once. [onProgress] hears the session id and
/// the bytes the server holds; [cancelled] is looked at between chunks and
/// [abort] drops the request in flight.
Future<Attachment> runUpload({
  required UploadsClient client,
  required UploadSource source,
  required String workspaceId,
  required String projectId,
  required String taskId,
  required void Function(String sessionId, int sent) onProgress,
  required bool Function() cancelled,
  String commentId = '',
  String? sessionId,
  Future<void>? abort,
  FindUploaded? findUploaded,
  Backoff backoff = exponentialBackoff,
}) async {
  final size = await source.length();

  Future<Attachment?> alreadyThere() async {
    try {
      return await findUploaded?.call(source.name, size, commentId);
    } on AttachmentException {
      return null; // cannot tell: carry on as if not
    }
  }

  UploadSession? session;
  if (sessionId != null) {
    try {
      session = await client.status(sessionId);
    } on AttachmentException catch (e) {
      if (e.failure != AttachmentFailure.notFound &&
          e.failure != AttachmentFailure.expired) {
        rethrow;
      }
      // The session is gone: either it expired or it finished and we never
      // heard. Do not upload it a second time if it is already there.
      final found = await alreadyThere();
      if (found != null) return found;
    }
  }
  session ??= await client.create(
    workspaceId: workspaceId,
    projectId: projectId,
    taskId: taskId,
    filename: source.name,
    size: size,
    commentId: commentId,
  );
  final open = session;

  int span(int n) =>
      math.min(size, (n + 1) * open.chunkSize) - n * open.chunkSize;

  var have = {...open.received};
  var sent = have.fold<int>(0, (total, n) => total + span(n));
  onProgress(open.id, sent);

  Future<Never> stop() async {
    await _abandon(client, open.id);
    throw const UploadCancelled();
  }

  Future<void> send(int n) async {
    final start = n * open.chunkSize;
    final bytes = await _read(source, start, start + span(n));
    for (var attempt = 0; ; attempt++) {
      try {
        have = await client.putChunk(open.id, n, bytes, abort: abort);
        return;
      } on AttachmentException catch (e) {
        if (cancelled()) await stop();
        if (e.failure != AttachmentFailure.network ||
            attempt + 1 >= _attempts) {
          rethrow;
        }
        await backoff(attempt);
        if (cancelled()) await stop();
      }
    }
  }

  Future<void> sendAll(Iterable<int> chunks) async {
    for (final n in chunks) {
      if (cancelled()) await stop();
      await send(n);
      sent = math.min(size, sent + span(n));
      onProgress(open.id, sent);
    }
  }

  await sendAll([
    for (var n = 0; n < open.chunkCount; n++)
      if (!have.contains(n)) n,
  ]);
  if (cancelled()) await stop();

  /// `complete` may have worked even when its answer never came: asking again
  /// then finds no session (404). That is "done" if the file is on the task.
  Future<Attachment> complete() async {
    var lostAnswer = false;
    for (var attempt = 0; ; attempt++) {
      try {
        return await client.complete(open.id);
      } on AttachmentException catch (e) {
        if (e.failure == AttachmentFailure.notFound && lostAnswer) {
          final found = await alreadyThere();
          if (found != null) return found;
        }
        if (e.failure != AttachmentFailure.network ||
            attempt + 1 >= _attempts) {
          rethrow;
        }
        lostAnswer = true;
        await backoff(attempt);
        if (cancelled()) await stop();
      }
    }
  }

  try {
    return await complete();
  } on AttachmentException catch (e) {
    if (e.failure != AttachmentFailure.incomplete || e.missing.isEmpty) rethrow;
    // The server lost some pieces: send just those and finish.
    await sendAll(e.missing);
    return complete();
  }
}

Future<void> _abandon(UploadsClient client, String id) async {
  try {
    await client.cancel(id);
  } on AttachmentException {
    // It expires on its own; nothing to tell the person.
  }
}

Future<Uint8List> _read(UploadSource source, int start, int end) async {
  final out = BytesBuilder(copy: false);
  await for (final part in source.read(start, end)) {
    out.add(part);
  }
  return out.takeBytes();
}
