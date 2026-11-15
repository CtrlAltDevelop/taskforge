import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// A file on a task (or on one of its comments). [mime] is what the server
/// found in the content, not what the uploader called it.
@immutable
class Attachment {
  const Attachment({
    required this.id,
    required this.taskId,
    required this.uploaderId,
    required this.filename,
    required this.mime,
    required this.size,
    required this.createdAt,
    this.commentId = '',
    this.hasThumb = false,
  });

  final String id;
  final String taskId;
  final String commentId;
  final String uploaderId;
  final String filename;
  final String mime;
  final int size;
  final bool hasThumb;
  final DateTime createdAt;

  bool get isImage => mime.startsWith('image/');
  bool get isVideo => mime.startsWith('video/');
  bool get isText => mime.startsWith('text/');
  bool get isPdf => mime == 'application/pdf';
}

/// What a workspace stores. [quotaBytes] is 0 when there is no limit.
@immutable
class StorageUsage {
  const StorageUsage({
    required this.usedBytes,
    required this.quotaBytes,
    required this.fileCount,
    required this.maxFileBytes,
  });

  final int usedBytes;
  final int quotaBytes;
  final int fileCount;
  final int maxFileBytes;

  bool get limited => quotaBytes > 0;
}

/// A signed link to a file's bytes (or thumbnail); it stops working at
/// [expiresAt] and a new one is asked for.
@immutable
class FileLink {
  const FileLink(this.url, this.expiresAt);

  final String url;
  final DateTime expiresAt;
}

/// An upload the server has started: the file goes up as [chunkCount] pieces
/// of [chunkSize] bytes (the last one is what remains); [received] are the
/// pieces it already has, which a resumed upload skips.
@immutable
class UploadSession {
  const UploadSession({
    required this.id,
    required this.chunkSize,
    required this.chunkCount,
    this.received = const {},
  });

  final String id;
  final int chunkSize;
  final int chunkCount;
  final Set<int> received;

  UploadSession withReceived(Iterable<int> chunks) => UploadSession(
    id: id,
    chunkSize: chunkSize,
    chunkCount: chunkCount,
    received: Set.unmodifiable(chunks),
  );
}

enum AttachmentFailure {
  tooBig,
  quota,

  /// Too many uploads are open at once (not the workspace being full).
  tooManyUploads,
  refused,

  /// The server could not check the file just now; it keeps the upload, so
  /// trying again is right.
  unavailable,

  /// The server did not take a chunk (wrong size or number): the upload
  /// carries on from what it has.
  chunkRejected,
  incomplete,
  expired,

  /// The file cannot be read any more (moved, deleted, access withdrawn).
  unreadable,
  denied,
  forbidden,
  archived,
  notFound,
  network,
  other,
}

class AttachmentException implements Exception {
  const AttachmentException(
    this.failure, {
    this.detail,
    this.missing = const [],
  });

  final AttachmentFailure failure;
  final String? detail;

  /// For [AttachmentFailure.incomplete]: the chunk numbers that did not arrive.
  final List<int> missing;

  @override
  String toString() => 'AttachmentException($failure, $detail)';
}

/// What a person is told when something about a file went wrong.
String attachmentErrorMessage(AttachmentException e, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  return switch (e.failure) {
    AttachmentFailure.tooBig => t.grpLAttTooBig,
    AttachmentFailure.quota => t.grpLAttQuota,
    AttachmentFailure.tooManyUploads => t.grpLAttTooMany,
    AttachmentFailure.unavailable => t.grpLAttUnavailable,
    AttachmentFailure.chunkRejected => t.grpLAttChunk,
    AttachmentFailure.refused =>
      e.detail == null || e.detail!.isEmpty
          ? t.grpLAttRefusedPlain
          : t.grpLAttRefused(e.detail!),
    AttachmentFailure.incomplete => t.grpLAttIncomplete,
    AttachmentFailure.expired => t.grpLAttExpired,
    AttachmentFailure.unreadable => t.grpLAttUnreadable,
    AttachmentFailure.denied => _deniedText(e.detail, t),
    AttachmentFailure.forbidden => t.grpLAttNotAllowed,
    AttachmentFailure.archived => t.grpLAttArchived,
    AttachmentFailure.notFound => t.grpLAttGone,
    AttachmentFailure.network => t.grpLNoConn,
    AttachmentFailure.other => t.grpLGeneric,
  };
}

final _needPermission = RegExp(r'^You need permission "(.+)"$');

/// The server's refusal text; "You need permission "x"" is said in the
/// language of [t], anything else as the server wrote it.
String _deniedText(String? detail, AppLocalizations t) {
  if (detail == null) return t.grpLAttNotAllowed;
  final match = _needPermission.firstMatch(detail);
  return match == null ? detail : t.grpRDenyNeed(match.group(1)!);
}

enum UploadState { queued, uploading, done, failed, cancelled }

/// One file on its way up. [progress] is the share of its bytes the server
/// has (0..1).
@immutable
class UploadItem {
  const UploadItem({
    required this.localId,
    required this.filename,
    required this.size,
    this.state = UploadState.queued,
    this.sent = 0,
    this.commentId = '',
    this.error,
    this.errorDetail,
    this.kept = false,
  });

  final String localId;
  final String filename;
  final int size;
  final UploadState state;
  final int sent;
  final String commentId;
  final AttachmentFailure? error;

  /// What the server said about a refusal, when it said more than the kind.
  final String? errorDetail;

  /// Kept on this device until the connection is back (see the outbox).
  final bool kept;

  double get progress => size <= 0 ? 0 : (sent / size).clamp(0.0, 1.0);
  bool get active =>
      state == UploadState.queued || state == UploadState.uploading;

  /// A file refused for its size or kind will be refused again: no retry.
  bool get canRetry =>
      state == UploadState.cancelled ||
      (state == UploadState.failed &&
          error != AttachmentFailure.tooBig &&
          error != AttachmentFailure.refused &&
          error != AttachmentFailure.unreadable &&
          error != AttachmentFailure.notFound);

  UploadItem copyWith({
    UploadState? state,
    int? sent,
    AttachmentFailure? error,
    String? errorDetail,
    bool? kept,
  }) {
    final next = state ?? this.state;
    return UploadItem(
      localId: localId,
      filename: filename,
      size: size,
      state: next,
      sent: sent ?? this.sent,
      commentId: commentId,
      error: next == UploadState.failed ? error : null,
      errorDetail: next == UploadState.failed ? errorDetail : null,
      kept: kept ?? this.kept,
    );
  }
}

/// Where a file's bytes come from: a picked file, a dropped one, a camera
/// shot or a pasted image. Read in ranges so a large file is never in memory
/// whole.
abstract interface class UploadSource {
  String get name;
  Future<int> length();

  /// The bytes in `[start, end)`.
  Stream<List<int>> read(int start, int end);
}

/// Any [XFile]: what file_picker, image_picker and desktop_drop all hand over,
/// on every platform (a path natively, a blob on the web).
class XFileSource implements UploadSource {
  const XFileSource(this.file, {this.nameOverride});

  final XFile file;
  final String? nameOverride;

  @override
  String get name => nameOverride ?? file.name;

  @override
  Future<int> length() => file.length();

  @override
  Stream<List<int>> read(int start, int end) => file.openRead(start, end);
}

/// A file already in memory (a pasted screenshot).
class BytesSource implements UploadSource {
  const BytesSource(this.name, this.bytes);

  @override
  final String name;
  final Uint8List bytes;

  @override
  Future<int> length() async => bytes.length;

  @override
  Stream<List<int>> read(int start, int end) => Stream.value(
    Uint8List.sublistView(bytes, start, end.clamp(0, bytes.length)),
  );
}

/// "1.4 MB" for [bytes]; the unit is in the language of [l10n] (English when
/// null).
String formatBytes(int bytes, [AppLocalizations? l10n]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  final units = [
    l.grpRUnitB,
    l.grpRUnitKB,
    l.grpRUnitMB,
    l.grpRUnitGB,
    l.grpRUnitTB,
  ];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final text = unit == 0 || value >= 100
      ? value.round().toString()
      : value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  return '$text ${units[unit]}';
}
